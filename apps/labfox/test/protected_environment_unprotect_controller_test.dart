import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

const _rule = ProtectedEnvironment(
  name: 'production',
  deployAccessLevels: [ProtectedEnvironmentAccess(id: 12, accessLevel: 40)],
  approvalRules: [
    ProtectedEnvironmentAccess(id: 38, groupId: 134, requiredApprovals: 1),
  ],
  requiredApprovalCount: 1,
);

class _Repository extends ProtectedEnvironmentsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];
  var deletes = 0;
  ProtectedEnvironment detail = _rule;
  bool duplicate = false;
  bool failDelete = false;

  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async {
    pages.add(page);
    if (page == 1) {
      return Paginated(items: [if (duplicate) _rule], nextPage: 2);
    }
    return const Paginated(items: [_rule]);
  }

  @override
  Future<ProtectedEnvironment> getComplete(int projectId, String name) async =>
      detail;

  @override
  Future<void> unprotect(int projectId, String name) async {
    deletes++;
    if (failDelete) throw const GitLabServerException('Unconfirmed deletion');
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
    'checks every page and current detail before deleting exact rule',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      addTearDown(container.dispose);
      await container
          .read(
            protectedEnvironmentUnprotectControllerProvider(
              const ProtectedEnvironmentRef(projectId: 7, name: 'production'),
            ).notifier,
          )
          .unprotect(expected: _rule);
      expect(repository.pages, [1, 2]);
      expect(repository.deletes, 1);
    },
  );

  test('changed or duplicate rule blocks deletion', () async {
    final changed = _Repository()
      ..detail = _rule.copyWith(requiredApprovalCount: 2);
    final changedContainer = _container(changed);
    addTearDown(changedContainer.dispose);
    await expectLater(
      changedContainer
          .read(
            protectedEnvironmentUnprotectControllerProvider(
              const ProtectedEnvironmentRef(projectId: 7, name: 'production'),
            ).notifier,
          )
          .unprotect(expected: _rule),
      throwsA(isA<GitLabConflictException>()),
    );
    expect(changed.deletes, 0);

    final duplicate = _Repository()..duplicate = true;
    final duplicateContainer = _container(duplicate);
    addTearDown(duplicateContainer.dispose);
    await expectLater(
      duplicateContainer
          .read(
            protectedEnvironmentUnprotectControllerProvider(
              const ProtectedEnvironmentRef(projectId: 7, name: 'production'),
            ).notifier,
          )
          .unprotect(expected: _rule),
      throwsA(isA<GitLabConflictException>()),
    );
    expect(duplicate.deletes, 0);
  });

  test('uncertain deletion surfaces error after one attempt', () async {
    final repository = _Repository()..failDelete = true;
    final container = _container(repository);
    addTearDown(container.dispose);
    await expectLater(
      container
          .read(
            protectedEnvironmentUnprotectControllerProvider(
              const ProtectedEnvironmentRef(projectId: 7, name: 'production'),
            ).notifier,
          )
          .unprotect(expected: _rule),
      throwsA(isA<GitLabServerException>()),
    );
    expect(repository.deletes, 1);
  });
}
