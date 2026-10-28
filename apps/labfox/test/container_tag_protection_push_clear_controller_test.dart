import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_push_clear_controller.dart';

const reviewedRule = ContainerTagProtectionRule(
  id: 2,
  projectId: 7,
  tagNamePattern: 'v*-release',
  minimumAccessLevelForPush: 'maintainer',
  minimumAccessLevelForDelete: 'owner',
);

class ProtectionPushClearRepository extends ContainerRegistryRepository {
  ProtectionPushClearRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  List<ContainerTagProtectionRule> rules = [reviewedRule];
  Object? failure;
  Object? readFailure;
  Completer<void>? pending;
  ContainerTagProtectionRule? response;
  int reads = 0;
  final writes = <(int, int)>[];
  @override
  Future<List<ContainerTagProtectionRule>> tagProtectionRules(
    int projectId,
  ) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return rules;
  }

  @override
  Future<ContainerTagProtectionRule> clearTagProtectionPushRole(
    int projectId,
    int ruleId,
  ) async {
    writes.add((projectId, ruleId));
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    final updated =
        response ??
        rules
            .singleWhere((r) => r.id == ruleId)
            .copyWith(minimumAccessLevelForPush: null);
    rules = rules.map((r) => r.id == ruleId ? updated : r).toList();
    return updated;
  }
}

void main() {
  for (final push in ['maintainer', 'owner', 'admin']) {
    for (final deletion in ['maintainer', 'owner', 'admin']) {
      test(
        'clears $push while retaining $deletion deletion protection',
        () async {
          final repository = ProtectionPushClearRepository();
          final original = reviewedRule.copyWith(
            minimumAccessLevelForPush: push,
            minimumAccessLevelForDelete: deletion,
          );
          repository.rules = [original];
          final container = ProviderContainer(
            overrides: [
              containerRegistryRepositoryProvider.overrideWith(
                (ref) async => repository,
              ),
            ],
          );
          addTearDown(container.dispose);
          await container
              .read(
                containerTagProtectionPushClearControllerProvider(7).notifier,
              )
              .clearPushRole(expected: original);
          expect(
            repository.rules.single,
            original.copyWith(minimumAccessLevelForPush: null),
          );
        },
      );
    }
  }
  late ProtectionPushClearRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectionPushClearRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> clear([ContainerTagProtectionRule expected = reviewedRule]) =>
      container
          .read(containerTagProtectionPushClearControllerProvider(7).notifier)
          .clearPushRole(expected: expected);

  for (final cleared in [null, '']) {
    test(
      'accepts cleared response $cleared and refreshes exact retained criteria',
      () async {
        repository.response = reviewedRule.copyWith(
          minimumAccessLevelForPush: cleared,
        );
        final sub = container.listen(
          containerTagProtectionControllerProvider(7),
          (_, _) {},
        );
        addTearDown(sub.close);
        await container.read(
          containerTagProtectionControllerProvider(7).future,
        );
        await clear();
        expect(repository.writes, [(7, 2)]);
        expect(
          await container.read(
            containerTagProtectionControllerProvider(7).future,
          ),
          [repository.response],
        );
        await expectLater(clear(repository.response!), throwsArgumentError);
        expect(repository.writes, hasLength(1));
      },
    );
  }
  for (final expected in [
    reviewedRule.copyWith(minimumAccessLevelForPush: null),
    reviewedRule.copyWith(minimumAccessLevelForPush: ''),
    reviewedRule.copyWith(minimumAccessLevelForPush: 'future_role'),
    reviewedRule.copyWith(minimumAccessLevelForDelete: null),
    reviewedRule.copyWith(minimumAccessLevelForDelete: ''),
    reviewedRule.copyWith(minimumAccessLevelForDelete: 'future_role'),
    reviewedRule.copyWith(projectId: 8),
    reviewedRule.copyWith(id: 0),
    reviewedRule.copyWith(tagNamePattern: ''),
  ]) {
    test(
      'unsafe or invalid reviewed rule rejects before network $expected',
      () async {
        repository.rules = [expected];
        await expectLater(clear(expected), throwsArgumentError);
        expect(repository.reads, 0);
        expect(repository.writes, isEmpty);
      },
    );
  }
  for (final current in <List<ContainerTagProtectionRule>>[
    [],
    [reviewedRule, reviewedRule],
    [reviewedRule.copyWith(projectId: 8)],
    [reviewedRule.copyWith(tagNamePattern: 'other')],
    [reviewedRule.copyWith(minimumAccessLevelForPush: 'admin')],
    [reviewedRule.copyWith(minimumAccessLevelForDelete: null)],
  ]) {
    test('changed missing or ambiguous rule never clears $current', () async {
      repository.rules = current;
      await expectLater(clear(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
    });
  }
  final intended = reviewedRule.copyWith(minimumAccessLevelForPush: null);
  for (final response in [
    intended.copyWith(id: 3),
    intended.copyWith(projectId: 8),
    intended.copyWith(tagNamePattern: 'other'),
    reviewedRule,
    intended.copyWith(minimumAccessLevelForPush: 'future_role'),
    intended.copyWith(minimumAccessLevelForDelete: null),
    intended.copyWith(minimumAccessLevelForDelete: 'admin'),
  ]) {
    test('mismatched response never confirms success $response', () async {
      repository.response = response;
      final sub = container.listen(
        containerTagProtectionControllerProvider(7),
        (_, _) {},
      );
      addTearDown(sub.close);
      await container.read(containerTagProtectionControllerProvider(7).future);
      await expectLater(clear(), throwsA(isA<GitLabServerException>()));
      expect(
        container
            .read(containerTagProtectionControllerProvider(7))
            .requireValue,
        [reviewedRule],
      );
    });
  }
  test('permission failure retains cache and retries real request', () async {
    final sub = container.listen(
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(containerTagProtectionControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(clear(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container.read(containerTagProtectionControllerProvider(7)).requireValue,
      [reviewedRule],
    );
    repository.failure = null;
    await clear();
    expect(repository.writes, [(7, 2), (7, 2)]);
  });
  test('failed preflight never writes', () async {
    repository.readFailure = const GitLabForbiddenException('private');
    await expectLater(clear(), throwsA(isA<GitLabForbiddenException>()));
    expect(repository.writes, isEmpty);
  });
  test('pending clear blocks duplicate commands', () async {
    repository.pending = Completer<void>();
    final first = clear();
    await Future<void>.delayed(Duration.zero);
    await expectLater(clear(), throwsStateError);
    expect(repository.writes, hasLength(1));
    repository.pending!.complete();
    await first;
  });
}
