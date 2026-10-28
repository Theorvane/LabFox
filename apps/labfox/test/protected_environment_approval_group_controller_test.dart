import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environment_approval_group_controller.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

const _rule = ProtectedEnvironment(
  name: 'review/production',
  deployAccessLevels: [ProtectedEnvironmentAccess(id: 12, accessLevel: 40)],
  approvalRules: [
    ProtectedEnvironmentAccess(
      id: 38,
      groupId: 134,
      groupInheritanceType: 0,
      requiredApprovals: 1,
    ),
  ],
);
const _key = ProtectedEnvironmentRef(projectId: 7, name: 'review/production');
ProtectedEnvironment _added() => _rule.copyWith(
  approvalRules: [
    ..._rule.approvalRules,
    const ProtectedEnvironmentAccess(
      id: 39,
      groupId: 135,
      groupInheritanceType: 0,
      requiredApprovals: 2,
    ),
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
  ProtectedEnvironment response = _added();
  ProtectedEnvironment postRead = _added();
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
  Future<ProtectedEnvironment> getForApprovalGroupEdit(
    int projectId,
    String name,
  ) async {
    reads++;
    await readGate?.future;
    return writes == 0 ? detail : postRead;
  }

  @override
  Future<ProtectedEnvironment> addApprovalGroup(
    int projectId,
    String name, {
    required int groupId,
    required int requiredApprovals,
  }) async {
    writes++;
    await writeGate?.future;
    if (failure != null) throw failure!;
    return response;
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
    'adds one group after every inventory page and confirms response plus read-back',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      addTearDown(container.dispose);
      await container
          .read(
            protectedEnvironmentApprovalGroupControllerProvider(_key).notifier,
          )
          .add(expected: _rule, groupId: 135, requiredApprovals: 2);
      expect(repository.pages, [1, 2]);
      expect(repository.reads, 2);
      expect(repository.writes, 1);
    },
  );
  test(
    'stale, duplicate, missing and already granted groups cannot write',
    () async {
      for (final repository in [
        _Repository()..detail = _rule.copyWith(requiredApprovalCount: 1),
        _Repository()..duplicate = true,
        _Repository()..missing = true,
        _Repository()..detail = _added(),
      ]) {
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentApprovalGroupControllerProvider(
                  _key,
                ).notifier,
              )
              .add(expected: _rule, groupId: 135, requiredApprovals: 2),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 0);
      }
    },
  );
  test('an existing group cannot receive a second rule', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    await expectLater(
      container
          .read(
            protectedEnvironmentApprovalGroupControllerProvider(_key).notifier,
          )
          .add(expected: _rule, groupId: 134, requiredApprovals: 2),
      throwsA(isA<GitLabConflictException>()),
    );
    expect(repository.writes, 0);
  });
  test(
    'changed deploy, approval, count, group, membership or reused IDs fail after one write',
    () async {
      final wrong = [
        _added().copyWith(deployAccessLevels: []),
        _added().copyWith(requiredApprovalCount: 1),
        _added().copyWith(approvalRules: [_added().approvalRules.last]),
        _added().copyWith(
          approvalRules: [
            ..._rule.approvalRules,
            _added().approvalRules.last.copyWith(id: 38),
          ],
        ),
        _added().copyWith(
          approvalRules: [
            ..._rule.approvalRules,
            _added().approvalRules.last.copyWith(groupId: 136),
          ],
        ),
        _added().copyWith(
          approvalRules: [
            ..._rule.approvalRules,
            _added().approvalRules.last.copyWith(groupInheritanceType: 1),
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
                  protectedEnvironmentApprovalGroupControllerProvider(
                    _key,
                  ).notifier,
                )
                .add(expected: _rule, groupId: 135, requiredApprovals: 2),
            throwsA(isA<GitLabException>()),
          );
          expect(repository.writes, 1);
        }
      }
    },
  );
  for (final dispatched in [false, true]) {
    test(
      'overlap and account change isolate writes dispatched=$dispatched',
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
          protectedEnvironmentApprovalGroupControllerProvider(_key).notifier,
        );
        final pending = controller.add(
          expected: _rule,
          groupId: 135,
          requiredApprovals: 2,
        );
        final rejected = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        await expectLater(
          controller.add(expected: _rule, groupId: 135, requiredApprovals: 2),
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
              .read(protectedEnvironmentApprovalGroupControllerProvider(_key))
              .hasError,
          isFalse,
        );
      },
    );
  }
}
