import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

const _rule = ProtectedEnvironment(
  name: 'production',
  deployAccessLevels: [
    ProtectedEnvironmentAccess(
      id: 12,
      accessLevel: 30,
      description: 'Developers + Maintainers',
      groupInheritanceType: 0,
    ),
    ProtectedEnvironmentAccess(id: 13, groupId: 9),
  ],
  approvalRules: [
    ProtectedEnvironmentAccess(id: 38, groupId: 134, requiredApprovals: 1),
  ],
  requiredApprovalCount: 1,
);
const _key = ProtectedEnvironmentRef(projectId: 7, name: 'production');

class _Repository extends ProtectedEnvironmentsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final pages = <int>[];
  var writes = 0;
  ProtectedEnvironment detail = _rule;
  bool duplicate = false;
  bool failWrite = false;
  bool changeApprovals = false;
  Completer<void>? readGate;
  Completer<void>? writeGate;

  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async {
    pages.add(page);
    if (page == 1) {
      return Paginated(items: [if (duplicate) detail], nextPage: 2);
    }
    return Paginated(items: [detail]);
  }

  @override
  Future<ProtectedEnvironment> getComplete(int projectId, String name) async {
    await readGate?.future;
    return detail;
  }

  @override
  Future<void> editDeployRole(
    int projectId,
    String name, {
    required int grantId,
    required int accessLevel,
  }) async {
    writes++;
    await writeGate?.future;
    if (failWrite) throw const GitLabServerException('Unconfirmed write');
    detail = detail.copyWith(
      deployAccessLevels: [
        for (final grant in detail.deployAccessLevels)
          if (grant.id == grantId)
            grant.copyWith(accessLevel: accessLevel, description: 'Maintainers')
          else
            grant,
      ],
      approvalRules: changeApprovals ? [] : detail.approvalRules,
    );
  }
}

ProviderContainer _container(_Repository repository) => ProviderContainer(
  overrides: [
    protectedEnvironmentsRepositoryProvider.overrideWith(
      (ref) async => repository,
    ),
  ],
);

void main() {
  test(
    'an old-account write completion cannot update the new account',
    () async {
      final repository = _Repository()..writeGate = Completer<void>();
      final replacement = _Repository();
      final container = _container(repository);
      addTearDown(container.dispose);
      final pending = container
          .read(
            protectedEnvironmentEditDeployRoleControllerProvider(_key).notifier,
          )
          .edit(expected: _rule, grantId: 12, accessLevel: 40);
      final rejected = expectLater(
        pending,
        throwsA(isA<GitLabConflictException>()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(repository.writes, 1);
      container.updateOverrides([
        protectedEnvironmentsRepositoryProvider.overrideWith(
          (ref) async => replacement,
        ),
      ]);
      container.invalidate(protectedEnvironmentsRepositoryProvider);
      await container.read(protectedEnvironmentsRepositoryProvider.future);
      repository.writeGate!.complete();
      await rejected;
      expect(replacement.writes, 0);
      expect(replacement.pages, isEmpty);
      expect(
        container
            .read(protectedEnvironmentEditDeployRoleControllerProvider(_key))
            .hasError,
        isFalse,
      );
    },
  );

  test(
    'inspects all pages and confirms only the selected role changed',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      addTearDown(container.dispose);
      await container
          .read(
            protectedEnvironmentEditDeployRoleControllerProvider(_key).notifier,
          )
          .edit(expected: _rule, grantId: 12, accessLevel: 40);
      expect(repository.pages, [1, 2]);
      expect(repository.writes, 1);
      expect(repository.detail.deployAccessLevels.first.accessLevel, 40);
      expect(
        repository.detail.deployAccessLevels.last,
        _rule.deployAccessLevels.last,
      );
      expect(repository.detail.approvalRules, _rule.approvalRules);
    },
  );

  test(
    'stale, duplicate, missing, non-role, unchanged and duplicate-role targets cannot write',
    () async {
      for (final scenario in [
        (
          repository: _Repository()
            ..detail = _rule.copyWith(requiredApprovalCount: 2),
          expected: _rule,
          id: 12,
          role: 40,
        ),
        (
          repository: _Repository()..duplicate = true,
          expected: _rule,
          id: 12,
          role: 40,
        ),
        (repository: _Repository(), expected: _rule, id: 99, role: 40),
        (repository: _Repository(), expected: _rule, id: 13, role: 40),
        (repository: _Repository(), expected: _rule, id: 12, role: 30),
        (
          repository: _Repository()
            ..detail = _rule.copyWith(
              deployAccessLevels: [
                _rule.deployAccessLevels.first,
                const ProtectedEnvironmentAccess(id: 14, accessLevel: 40),
              ],
            ),
          expected: _rule.copyWith(
            deployAccessLevels: [
              _rule.deployAccessLevels.first,
              const ProtectedEnvironmentAccess(id: 14, accessLevel: 40),
            ],
          ),
          id: 12,
          role: 40,
        ),
      ]) {
        final container = _container(scenario.repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentEditDeployRoleControllerProvider(
                  _key,
                ).notifier,
              )
              .edit(
                expected: scenario.expected,
                grantId: scenario.id,
                accessLevel: scenario.role,
              ),
          throwsA(isA<GitLabConflictException>()),
        );
        expect(scenario.repository.writes, 0);
      }
    },
  );

  test(
    'uncertain write and changed approvals fail after one dispatch',
    () async {
      for (final repository in [
        _Repository()..failWrite = true,
        _Repository()..changeApprovals = true,
      ]) {
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentEditDeployRoleControllerProvider(
                  _key,
                ).notifier,
              )
              .edit(expected: _rule, grantId: 12, accessLevel: 40),
          throwsA(isA<GitLabServerException>()),
        );
        expect(repository.writes, 1);
      }
    },
  );

  test(
    'a pending edit rejects overlap and account replacement before dispatch',
    () async {
      final repository = _Repository()..readGate = Completer<void>();
      final container = _container(repository);
      addTearDown(container.dispose);
      final controller = container.read(
        protectedEnvironmentEditDeployRoleControllerProvider(_key).notifier,
      );
      final pending = controller.edit(
        expected: _rule,
        grantId: 12,
        accessLevel: 40,
      );
      final rejected = expectLater(
        pending,
        throwsA(isA<GitLabConflictException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await expectLater(
        controller.edit(expected: _rule, grantId: 12, accessLevel: 40),
        throwsStateError,
      );
      container.updateOverrides([
        protectedEnvironmentsRepositoryProvider.overrideWith(
          (ref) async => _Repository(),
        ),
      ]);
      container.invalidate(protectedEnvironmentsRepositoryProvider);
      await container.read(protectedEnvironmentsRepositoryProvider.future);
      repository.readGate!.complete();
      await rejected;
      expect(repository.writes, 0);
    },
  );
}
