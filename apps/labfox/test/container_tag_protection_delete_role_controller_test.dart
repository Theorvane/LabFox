import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_delete_role_controller.dart';

const reviewedRule = ContainerTagProtectionRule(
  id: 2,
  projectId: 7,
  tagNamePattern: 'v*-release',
  minimumAccessLevelForDelete: 'maintainer',
  minimumAccessLevelForPush: 'owner',
);

class ProtectionDeleteRoleRepository extends ContainerRegistryRepository {
  ProtectionDeleteRoleRepository()
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
  ContainerTagProtectionRule? response;
  final writes = <(int, int, String)>[];
  @override
  Future<List<ContainerTagProtectionRule>> tagProtectionRules(
    int projectId,
  ) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return rules;
  }

  @override
  Future<ContainerTagProtectionRule> updateTagProtectionDeleteRole(
    int projectId,
    int ruleId,
    String role,
  ) async {
    writes.add((projectId, ruleId, role));
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    final updated =
        response ??
        rules
            .singleWhere((rule) => rule.id == ruleId)
            .copyWith(minimumAccessLevelForDelete: role);
    rules = rules.map((rule) => rule.id == ruleId ? updated : rule).toList();
    return updated;
  }
}

void main() {
  for (final current in ['maintainer', 'owner', 'admin']) {
    for (final target in ['maintainer', 'owner', 'admin']) {
      if (current == target) continue;
      test(
        'changes delete role $current to $target with exact retained criteria',
        () async {
          final repository = ProtectionDeleteRoleRepository();
          final original = reviewedRule.copyWith(
            minimumAccessLevelForDelete: current,
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
                containerTagProtectionDeleteRoleControllerProvider(7).notifier,
              )
              .saveDeleteRole(expected: original, role: target);
          expect(
            repository.rules.single,
            original.copyWith(minimumAccessLevelForDelete: target),
          );
        },
      );
    }
  }
  late ProtectionDeleteRoleRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectionDeleteRoleRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> save({
    ContainerTagProtectionRule expected = reviewedRule,
    String role = 'owner',
  }) => container
      .read(containerTagProtectionDeleteRoleControllerProvider(7).notifier)
      .saveDeleteRole(expected: expected, role: role);
  for (final role in ['', '   ', 'future_role', 'maintainer']) {
    test('invalid or unchanged role rejects before network $role', () async {
      await expectLater(save(role: role), throwsArgumentError);
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    });
  }
  test('only delete role changes and list refreshes after success', () async {
    final sub = container.listen(
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(containerTagProtectionControllerProvider(7).future);
    await save();
    expect(repository.writes, [(7, 2, 'owner')]);
    expect(
      await container.read(containerTagProtectionControllerProvider(7).future),
      [reviewedRule.copyWith(minimumAccessLevelForDelete: 'owner')],
    );
  });
  for (final role in ['maintainer', 'owner', 'admin']) {
    test(
      'supported role can be set on previously unset delete rule $role',
      () async {
        final original = reviewedRule.copyWith(
          minimumAccessLevelForDelete: null,
          minimumAccessLevelForPush: 'future_push',
        );
        repository.rules = [original];
        await save(expected: original, role: role);
        expect(
          repository.rules.single,
          original.copyWith(minimumAccessLevelForDelete: role),
        );
      },
    );
  }
  test('unknown current delete role blocks without guessing access', () async {
    final original = reviewedRule.copyWith(
      minimumAccessLevelForDelete: 'future_role',
    );
    repository.rules = [original];
    await expectLater(save(expected: original), throwsArgumentError);
    expect(repository.reads, 0);
    expect(repository.writes, isEmpty);
  });
  for (final current in <List<ContainerTagProtectionRule>>[
    [],
    [reviewedRule.copyWith(tagNamePattern: 'changed-*')],
    [reviewedRule.copyWith(minimumAccessLevelForDelete: 'admin')],
    [reviewedRule.copyWith(minimumAccessLevelForPush: null)],
    [reviewedRule.copyWith(projectId: 8)],
    [reviewedRule, reviewedRule],
  ]) {
    test('stale missing or ambiguous rule rejects $current', () async {
      repository.rules = current;
      await expectLater(save(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
    });
  }
  for (final expected in [
    reviewedRule.copyWith(id: 0),
    reviewedRule.copyWith(projectId: 8),
    reviewedRule.copyWith(tagNamePattern: ''),
  ]) {
    test('invalid target rejects before read $expected', () async {
      await expectLater(save(expected: expected), throwsArgumentError);
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    });
  }
  final intended = reviewedRule.copyWith(minimumAccessLevelForDelete: 'owner');
  for (final response in [
    intended.copyWith(id: 3),
    intended.copyWith(projectId: 8),
    intended.copyWith(tagNamePattern: 'other'),
    reviewedRule,
    intended.copyWith(minimumAccessLevelForPush: 'admin'),
  ]) {
    test('mismatched response does not confirm success $response', () async {
      repository.response = response;
      await expectLater(save(), throwsA(isA<GitLabServerException>()));
    });
  }
  test('permission error keeps cache and supports real retry', () async {
    final sub = container.listen(
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(containerTagProtectionControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(save(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container.read(containerTagProtectionControllerProvider(7)).requireValue,
      [reviewedRule],
    );
    repository.failure = null;
    await save();
    expect(repository.writes.length, 2);
  });
  test('failed preflight never writes', () async {
    repository.readFailure = const GitLabForbiddenException('private');
    await expectLater(save(), throwsA(isA<GitLabForbiddenException>()));
    expect(repository.writes, isEmpty);
  });
  test('pending command rejects duplicates', () async {
    repository.pending = Completer<void>();
    final first = save();
    await Future<void>.delayed(Duration.zero);
    await expectLater(save(), throwsStateError);
    expect(repository.writes.length, 1);
    repository.pending!.complete();
    await first;
  });
}
