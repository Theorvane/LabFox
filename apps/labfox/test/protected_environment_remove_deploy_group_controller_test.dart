import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environment_remove_deploy_group_controller.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

const _rule = ProtectedEnvironment(
  name: 'review/production',
  deployAccessLevels: [
    ProtectedEnvironmentAccess(
      id: 12,
      groupId: 989,
      accessLevel: 40,
      groupInheritanceType: 0,
      description: 'Release team',
    ),
    ProtectedEnvironmentAccess(id: 13, accessLevel: 30),
    ProtectedEnvironmentAccess(id: 14, userId: 5),
  ],
  approvalRules: [
    ProtectedEnvironmentAccess(id: 38, groupId: 134, requiredApprovals: 2),
  ],
);
const _key = ProtectedEnvironmentRef(projectId: 7, name: 'review/production');
ProtectedEnvironment _changed(ProtectedEnvironment expected, int membership) =>
    expected.copyWith(
      deployAccessLevels: [
        for (final grant in expected.deployAccessLevels)
          grant.id == 12
              ? grant.copyWith(groupInheritanceType: membership)
              : grant,
      ],
    );

class _Repository extends ProtectedEnvironmentsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ProtectedEnvironment detail = _rule;
  ProtectedEnvironment? response;
  ProtectedEnvironment? postRead;
  var writes = 0;
  var reads = 0;
  var duplicate = false;
  var missing = false;
  Object? failure;
  Completer<void>? readGate;
  Completer<void>? writeGate;
  final pages = <int>[];
  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async {
    pages.add(page);
    return page == 1
        ? Paginated(items: [if (duplicate) detail], nextPage: 2)
        : Paginated(items: [if (!missing) detail]);
  }

  @override
  Future<ProtectedEnvironment> getForDeployGroupEdit(
    int projectId,
    String name,
  ) async {
    reads++;
    await readGate?.future;
    return writes == 0 ? detail : postRead ?? detail;
  }

  @override
  Future<ProtectedEnvironment> removeDeployGroup(
    int projectId,
    String name, {
    required int grantId,
  }) async {
    writes++;
    await writeGate?.future;
    if (failure != null) throw failure!;
    detail = _removed(detail);
    return response ?? detail;
  }
}

ProtectedEnvironment _removed(ProtectedEnvironment rule) => rule.copyWith(
  deployAccessLevels: rule.deployAccessLevels
      .where((grant) => grant.id != 12)
      .toList(),
);

ProviderContainer _container(_Repository repository) => ProviderContainer(
  overrides: [
    protectedEnvironmentsRepositoryProvider.overrideWith(
      (ref) async => repository,
    ),
  ],
);
void main() {
  for (final membership in [0, 1]) {
    test(
      'removes one group with membership=$membership after all pages and read-back',
      () async {
        final expected = _changed(_rule, 1 - membership);
        final repository = _Repository()..detail = expected;
        final container = _container(repository);
        addTearDown(container.dispose);
        await container
            .read(
              protectedEnvironmentRemoveDeployGroupControllerProvider(
                _key,
              ).notifier,
            )
            .remove(expected: expected, grantId: 12);
        expect(repository.pages, [1, 2]);
        expect(repository.reads, 2);
        expect(repository.writes, 1);
        expect(repository.detail, _removed(expected));
      },
    );
  }
  test(
    'last deploy group removal keeps protection and approval rules',
    () async {
      final expected = _rule.copyWith(
        deployAccessLevels: [_rule.deployAccessLevels.first],
      );
      final repository = _Repository()..detail = expected;
      final container = _container(repository);
      addTearDown(container.dispose);
      await container
          .read(
            protectedEnvironmentRemoveDeployGroupControllerProvider(
              _key,
            ).notifier,
          )
          .remove(expected: expected, grantId: 12);
      expect(repository.detail, expected.copyWith(deployAccessLevels: []));
      expect(repository.writes, 1);
    },
  );
  test('stale missing and duplicate environments cannot write', () async {
    for (final repository in [
      _Repository()..detail = _rule.copyWith(requiredApprovalCount: 1),
      _Repository()..duplicate = true,
      _Repository()..missing = true,
    ]) {
      final container = _container(repository);
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(
              protectedEnvironmentRemoveDeployGroupControllerProvider(
                _key,
              ).notifier,
            )
            .remove(expected: _rule, grantId: 12),
        throwsA(isA<GitLabException>()),
      );
      expect(repository.writes, 0);
    }
  });
  test(
    'unknown non-group mixed-user and duplicate targets cannot write',
    () async {
      for (final grants in [
        [_rule.deployAccessLevels.first.copyWith(groupInheritanceType: null)],
        [_rule.deployAccessLevels.first.copyWith(groupInheritanceType: 7)],
        [_rule.deployAccessLevels.first.copyWith(groupId: null)],
        [_rule.deployAccessLevels.first.copyWith(userId: 5)],
        [_rule.deployAccessLevels.first, _rule.deployAccessLevels.first],
        <ProtectedEnvironmentAccess>[],
      ]) {
        final expected = _rule.copyWith(deployAccessLevels: grants);
        final repository = _Repository()..detail = expected;
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentRemoveDeployGroupControllerProvider(
                  _key,
                ).notifier,
              )
              .remove(expected: expected, grantId: 12),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 0);
      }
    },
  );
  test(
    'uncertain writes and any changed response or read-back fail once',
    () async {
      final intended = _removed(_rule);
      final wrong = [
        intended.copyWith(approvalRules: []),
        intended.copyWith(requiredApprovalCount: 1),
        intended.copyWith(
          deployAccessLevels: [intended.deployAccessLevels.first],
        ),
        intended.copyWith(
          deployAccessLevels: [
            intended.deployAccessLevels.first.copyWith(groupId: 990),
            ...intended.deployAccessLevels.skip(1),
          ],
        ),
        intended.copyWith(
          deployAccessLevels: [
            intended.deployAccessLevels.first.copyWith(accessLevel: 40),
            ...intended.deployAccessLevels.skip(1),
          ],
        ),
        intended.copyWith(
          deployAccessLevels: [
            intended.deployAccessLevels.first.copyWith(description: 'Renamed'),
            ...intended.deployAccessLevels.skip(1),
          ],
        ),
      ];
      for (final responseFailure in [true, false]) {
        for (final changed in wrong) {
          final repository = _Repository();
          if (responseFailure) {
            repository.response = changed;
          } else {
            repository.postRead = changed;
          }
          final container = _container(repository);
          addTearDown(container.dispose);
          await expectLater(
            container
                .read(
                  protectedEnvironmentRemoveDeployGroupControllerProvider(
                    _key,
                  ).notifier,
                )
                .remove(expected: _rule, grantId: 12),
            throwsA(isA<GitLabException>()),
          );
          expect(repository.writes, 1);
        }
      }
      final repository = _Repository()
        ..failure = const GitLabServerException('Uncertain write');
      final container = _container(repository);
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(
              protectedEnvironmentRemoveDeployGroupControllerProvider(
                _key,
              ).notifier,
            )
            .remove(expected: _rule, grantId: 12),
        throwsA(isA<GitLabServerException>()),
      );
      expect(repository.writes, 1);
    },
  );
  for (final dispatched in [false, true]) {
    test(
      'overlap and account replacement isolate deploy writes dispatched=$dispatched',
      () async {
        final repository = _Repository();
        final gate = Completer<void>();
        if (dispatched) {
          repository.writeGate = gate;
        } else {
          repository.readGate = gate;
        }
        final container = _container(repository);
        addTearDown(container.dispose);
        final controller = container.read(
          protectedEnvironmentRemoveDeployGroupControllerProvider(
            _key,
          ).notifier,
        );
        final pending = controller.remove(expected: _rule, grantId: 12);
        final rejected = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        await expectLater(
          controller.remove(expected: _rule, grantId: 12),
          throwsStateError,
        );
        final replacement = _Repository();
        container.updateOverrides([
          protectedEnvironmentsRepositoryProvider.overrideWith(
            (ref) async => replacement,
          ),
        ]);
        container.invalidate(protectedEnvironmentsRepositoryProvider);
        await container.read(protectedEnvironmentsRepositoryProvider.future);
        gate.complete();
        await rejected;
        expect(repository.writes, dispatched ? 1 : 0);
        expect(replacement.writes, 0);
        expect(
          container
              .read(
                protectedEnvironmentRemoveDeployGroupControllerProvider(_key),
              )
              .hasError,
          isFalse,
        );
      },
    );
  }
}
