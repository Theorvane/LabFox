import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_delete_controller.dart';

const reviewedRule = ContainerTagProtectionRule(
  id: 2,
  projectId: 7,
  tagNamePattern: 'v*-release',
  minimumAccessLevelForPush: 'maintainer',
  minimumAccessLevelForDelete: 'owner',
);

class ProtectionDeleteRepository extends ContainerRegistryRepository {
  ProtectionDeleteRepository()
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
  Future<void> deleteTagProtectionRule(int projectId, int ruleId) async {
    writes.add((projectId, ruleId));
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    rules = rules.where((rule) => rule.id != ruleId).toList();
  }
}

void main() {
  for (final projectId in [0, -1]) {
    test('invalid project $projectId never reads or writes', () async {
      final repository = ProtectionDeleteRepository();
      final container = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(
              containerTagProtectionDeleteControllerProvider(
                projectId,
              ).notifier,
            )
            .remove(expected: reviewedRule.copyWith(projectId: projectId)),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    });
  }
  late ProtectionDeleteRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectionDeleteRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> remove([ContainerTagProtectionRule expected = reviewedRule]) =>
      container
          .read(containerTagProtectionDeleteControllerProvider(7).notifier)
          .remove(expected: expected);

  test('deletes exact rule and refreshes list only after success', () async {
    final other = reviewedRule.copyWith(id: 3, tagNamePattern: 'other-*');
    repository.rules = [reviewedRule, other];
    final sub = container.listen(
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    await container.read(containerTagProtectionControllerProvider(7).future);
    await remove();
    expect(repository.writes, [(7, 2)]);
    expect(
      await container.read(containerTagProtectionControllerProvider(7).future),
      [other],
    );
    sub.close();
  });
  for (final current in <List<ContainerTagProtectionRule>>[
    [],
    [reviewedRule.copyWith(tagNamePattern: 'changed-*')],
    [reviewedRule.copyWith(minimumAccessLevelForPush: 'admin')],
    [reviewedRule.copyWith(minimumAccessLevelForDelete: null)],
    [reviewedRule.copyWith(projectId: 8)],
    [reviewedRule, reviewedRule],
  ]) {
    test('missing, changed or ambiguous rule rejects $current', () async {
      repository.rules = current;
      await expectLater(remove(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
    });
  }
  for (final expected in [
    reviewedRule.copyWith(projectId: 8),
    reviewedRule.copyWith(id: 0),
    reviewedRule.copyWith(tagNamePattern: ''),
    reviewedRule.copyWith(tagNamePattern: '   '),
  ]) {
    test('invalid target rejects before reading $expected', () async {
      await expectLater(remove(expected), throwsArgumentError);
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    });
  }
  test(
    'unknown and nullable roles are retained rather than inferred permission',
    () async {
      final rule = reviewedRule.copyWith(
        minimumAccessLevelForPush: 'future_role',
        minimumAccessLevelForDelete: null,
      );
      repository.rules = [rule];
      await remove(rule);
      expect(repository.writes, [(7, 2)]);
    },
  );
  test('failed delete retains cache and retries the real operation', () async {
    final sub = container.listen(
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    await container.read(containerTagProtectionControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(remove(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container.read(containerTagProtectionControllerProvider(7)).requireValue,
      [reviewedRule],
    );
    repository.failure = null;
    await remove();
    expect(repository.writes, [(7, 2), (7, 2)]);
    sub.close();
  });
  test('failed re-read never deletes', () async {
    repository.readFailure = const GitLabForbiddenException('private');
    await expectLater(remove(), throwsA(isA<GitLabForbiddenException>()));
    expect(repository.writes, isEmpty);
  });
  test('pending deletion rejects duplicates', () async {
    repository.pending = Completer<void>();
    final pending = remove();
    await Future<void>.delayed(Duration.zero);
    await expectLater(remove(), throwsStateError);
    expect(repository.writes, hasLength(1));
    repository.pending!.complete();
    await pending;
  });
}
