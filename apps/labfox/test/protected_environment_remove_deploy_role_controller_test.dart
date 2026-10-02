import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

const _rule = ProtectedEnvironment(
  name: 'production',
  deployAccessLevels: [
    ProtectedEnvironmentAccess(id: 12, accessLevel: 30),
    ProtectedEnvironmentAccess(id: 13, accessLevel: 40),
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

  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async {
    pages.add(page);
    if (page == 1) return Paginated(items: [if (duplicate) _rule], nextPage: 2);
    return const Paginated(items: [_rule]);
  }

  @override
  Future<ProtectedEnvironment> getComplete(int projectId, String name) async =>
      detail;

  @override
  Future<void> removeDeployRole(
    int projectId,
    String name, {
    required int grantId,
  }) async {
    writes++;
    if (failWrite) throw const GitLabServerException('Unconfirmed write');
    detail = detail.copyWith(
      deployAccessLevels: detail.deployAccessLevels
          .where((grant) => grant.id != grantId)
          .toList(),
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
    'inspects every page and confirms only the chosen grant is gone',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      addTearDown(container.dispose);
      await container
          .read(
            protectedEnvironmentRemoveDeployRoleControllerProvider(
              _key,
            ).notifier,
          )
          .remove(expected: _rule, grantId: 12);
      expect(repository.pages, [1, 2]);
      expect(repository.writes, 1);
      expect(repository.detail.deployAccessLevels, [
        _rule.deployAccessLevels.last,
      ]);
      expect(repository.detail.approvalRules, _rule.approvalRules);
    },
  );

  test(
    'stale, duplicate, missing, or non-role grant blocks the write',
    () async {
      for (final repository in [
        _Repository()..detail = _rule.copyWith(requiredApprovalCount: 2),
        _Repository()..duplicate = true,
      ]) {
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentRemoveDeployRoleControllerProvider(
                  _key,
                ).notifier,
              )
              .remove(expected: _rule, grantId: 12),
          throwsA(isA<GitLabConflictException>()),
        );
        expect(repository.writes, 0);
      }
      final missing = _Repository();
      final container = _container(missing);
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(
              protectedEnvironmentRemoveDeployRoleControllerProvider(
                _key,
              ).notifier,
            )
            .remove(expected: _rule, grantId: 99),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(missing.writes, 0);

      final userGrant = _rule.copyWith(
        deployAccessLevels: [
          const ProtectedEnvironmentAccess(id: 12, userId: 31),
        ],
      );
      final userRepository = _Repository()..detail = userGrant;
      final userContainer = _container(userRepository);
      addTearDown(userContainer.dispose);
      await expectLater(
        userContainer
            .read(
              protectedEnvironmentRemoveDeployRoleControllerProvider(
                _key,
              ).notifier,
            )
            .remove(expected: userGrant, grantId: 12),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(userRepository.writes, 0);
    },
  );

  test(
    'uncertain write or changed approvals is reported after one attempt',
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
                protectedEnvironmentRemoveDeployRoleControllerProvider(
                  _key,
                ).notifier,
              )
              .remove(expected: _rule, grantId: 12),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 1);
      }
    },
  );
}
