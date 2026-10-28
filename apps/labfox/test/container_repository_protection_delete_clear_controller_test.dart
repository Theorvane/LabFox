import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_repository_protection_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_repository_protection_delete_clear_controller.dart';

const reviewedRule = ContainerRepositoryProtectionRule(
  id: 2,
  projectId: 7,
  repositoryPathPattern: 'team/app/*',
  minimumAccessLevelForDelete: 'maintainer',
  minimumAccessLevelForPush: 'owner',
);

class ProtectionDeleteClearRepository extends ContainerRegistryRepository {
  ProtectionDeleteClearRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  List<ContainerRepositoryProtectionRule> rules = [reviewedRule];
  Object? failure;
  Object? readFailure;
  Completer<void>? pending;
  ContainerRepositoryProtectionRule? response;
  int reads = 0;
  final writes = <(int, int)>[];
  @override
  Future<List<ContainerRepositoryProtectionRule>> repositoryProtectionRules(
    int projectId,
  ) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return rules;
  }

  @override
  Future<ContainerRepositoryProtectionRule> clearRepositoryProtectionDeleteRole(
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
            .copyWith(minimumAccessLevelForDelete: null);
    rules = rules.map((r) => r.id == ruleId ? updated : r).toList();
    return updated;
  }
}

void main() {
  late ProtectionDeleteClearRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectionDeleteClearRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> clear([
    ContainerRepositoryProtectionRule expected = reviewedRule,
  ]) => container
      .read(
        containerRepositoryProtectionDeleteClearControllerProvider(7).notifier,
      )
      .clearDeleteRole(expected: expected);

  for (final cleared in [null, '']) {
    test(
      'accepts cleared response $cleared and refreshes exact retained criteria',
      () async {
        repository.response = reviewedRule.copyWith(
          minimumAccessLevelForDelete: cleared,
        );
        final sub = container.listen(
          containerRepositoryProtectionControllerProvider(7),
          (_, _) {},
        );
        addTearDown(sub.close);
        await container.read(
          containerRepositoryProtectionControllerProvider(7).future,
        );
        await clear();
        expect(repository.writes, [(7, 2)]);
        expect(
          await container.read(
            containerRepositoryProtectionControllerProvider(7).future,
          ),
          [repository.response],
        );
        await expectLater(clear(repository.response!), throwsArgumentError);
        expect(repository.writes, hasLength(1));
      },
    );
  }
  for (final deleteRole in ['maintainer', 'owner', 'admin']) {
    for (final pushRole in ['maintainer', 'owner', 'admin']) {
      test(
        'clears supported delete $deleteRole and retains push $pushRole',
        () async {
          final original = reviewedRule.copyWith(
            minimumAccessLevelForDelete: deleteRole,
            minimumAccessLevelForPush: pushRole,
          );
          repository.rules = [original];
          await clear(original);
          expect(
            repository.rules.single,
            original.copyWith(minimumAccessLevelForDelete: null),
          );
          expect(repository.writes, [(7, 2)]);
        },
      );
    }
  }
  for (final expected in [
    reviewedRule.copyWith(minimumAccessLevelForDelete: null),
    reviewedRule.copyWith(minimumAccessLevelForDelete: ''),
    reviewedRule.copyWith(minimumAccessLevelForDelete: 'future_role'),
    reviewedRule.copyWith(minimumAccessLevelForPush: null),
    reviewedRule.copyWith(minimumAccessLevelForPush: ''),
    reviewedRule.copyWith(minimumAccessLevelForPush: 'future_role'),
    reviewedRule.copyWith(projectId: 8),
    reviewedRule.copyWith(id: 0),
    reviewedRule.copyWith(repositoryPathPattern: ''),
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
  for (final current in <List<ContainerRepositoryProtectionRule>>[
    [],
    [reviewedRule, reviewedRule],
    [reviewedRule.copyWith(projectId: 8)],
    [reviewedRule.copyWith(repositoryPathPattern: 'other')],
    [reviewedRule.copyWith(minimumAccessLevelForDelete: 'admin')],
    [reviewedRule.copyWith(minimumAccessLevelForPush: null)],
  ]) {
    test('changed missing or ambiguous rule never clears $current', () async {
      repository.rules = current;
      await expectLater(clear(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
    });
  }
  final intended = reviewedRule.copyWith(minimumAccessLevelForDelete: null);
  for (final response in [
    intended.copyWith(id: 3),
    intended.copyWith(projectId: 8),
    intended.copyWith(repositoryPathPattern: 'other'),
    reviewedRule,
    intended.copyWith(minimumAccessLevelForDelete: 'future_role'),
    intended.copyWith(minimumAccessLevelForPush: null),
    intended.copyWith(minimumAccessLevelForPush: 'admin'),
  ]) {
    test('mismatched response never confirms success $response', () async {
      repository.response = response;
      final sub = container.listen(
        containerRepositoryProtectionControllerProvider(7),
        (_, _) {},
      );
      addTearDown(sub.close);
      await container.read(
        containerRepositoryProtectionControllerProvider(7).future,
      );
      await expectLater(clear(), throwsA(isA<GitLabServerException>()));
      expect(
        container
            .read(containerRepositoryProtectionControllerProvider(7))
            .requireValue,
        [reviewedRule],
      );
    });
  }
  test('permission failure retains cache and retries real request', () async {
    final sub = container.listen(
      containerRepositoryProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(
      containerRepositoryProtectionControllerProvider(7).future,
    );
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(clear(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container
          .read(containerRepositoryProtectionControllerProvider(7))
          .requireValue,
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
