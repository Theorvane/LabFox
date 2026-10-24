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
  Future<void> addDeployRole(
    int projectId,
    String name, {
    required int accessLevel,
  }) async {
    writes++;
    if (failWrite) throw const GitLabServerException('Unconfirmed write');
    detail = detail.copyWith(
      deployAccessLevels: [
        ...detail.deployAccessLevels,
        ProtectedEnvironmentAccess(id: 13, accessLevel: accessLevel),
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
  test('inspects every list page and confirms one added grant', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    await container
        .read(
          protectedEnvironmentAddDeployRoleControllerProvider(_key).notifier,
        )
        .add(expected: _rule, accessLevel: 30);
    expect(repository.pages, [1, 2]);
    expect(repository.writes, 1);
    expect(repository.detail.deployAccessLevels.length, 2);
    expect(repository.detail.approvalRules, _rule.approvalRules);
  });

  test('stale, duplicate, or already granted roles block the write', () async {
    for (final repository in [
      _Repository()..detail = _rule.copyWith(requiredApprovalCount: 2),
      _Repository()..duplicate = true,
    ]) {
      final container = _container(repository);
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(
              protectedEnvironmentAddDeployRoleControllerProvider(
                _key,
              ).notifier,
            )
            .add(expected: _rule, accessLevel: 30),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, 0);
    }
    final existing = _Repository();
    final container = _container(existing);
    addTearDown(container.dispose);
    await expectLater(
      container
          .read(
            protectedEnvironmentAddDeployRoleControllerProvider(_key).notifier,
          )
          .add(expected: _rule, accessLevel: 40),
      throwsA(isA<GitLabConflictException>()),
    );
    expect(existing.writes, 0);
  });

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
                protectedEnvironmentAddDeployRoleControllerProvider(
                  _key,
                ).notifier,
              )
              .add(expected: _rule, accessLevel: 30),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 1);
      }
    },
  );
}
