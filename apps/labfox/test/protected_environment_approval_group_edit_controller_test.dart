import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environment_approval_group_edit_controller.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

const _rule = ProtectedEnvironment(
  name: 'review/production',
  deployAccessLevels: [ProtectedEnvironmentAccess(id: 12, accessLevel: 40)],
  approvalRules: [
    ProtectedEnvironmentAccess(
      id: 38,
      groupId: 134,
      groupInheritanceType: 1,
      requiredApprovals: 2,
      description: 'Release team',
    ),
    ProtectedEnvironmentAccess(
      id: 39,
      groupId: 135,
      groupInheritanceType: 0,
      requiredApprovals: 1,
    ),
  ],
);
const _key = ProtectedEnvironmentRef(projectId: 7, name: 'review/production');
ProtectedEnvironment _changed() => _rule.copyWith(
  approvalRules: [
    _rule.approvalRules.first.copyWith(
      groupId: 136,
      description: 'New release team',
    ),
    _rule.approvalRules.last,
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
  ProtectedEnvironment response = _changed();
  ProtectedEnvironment postRead = _changed();
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
  Future<ProtectedEnvironment> editApprovalGroup(
    int projectId,
    String name, {
    required int ruleId,
    required int groupId,
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
    'preserves every field except the group and its server description',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      addTearDown(container.dispose);
      await container
          .read(
            protectedEnvironmentApprovalGroupEditControllerProvider(
              _key,
            ).notifier,
          )
          .edit(expected: _rule, ruleId: 38, groupId: 136);
      expect(repository.pages, [1, 2]);
      expect(repository.reads, 2);
      expect(repository.writes, 1);
    },
  );
  test(
    'stale missing duplicate or already represented groups cannot write',
    () async {
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
                protectedEnvironmentApprovalGroupEditControllerProvider(
                  _key,
                ).notifier,
              )
              .edit(expected: _rule, ruleId: 38, groupId: 136),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 0);
      }
      for (final group in [134, 135]) {
        final repository = _Repository();
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentApprovalGroupEditControllerProvider(
                  _key,
                ).notifier,
              )
              .edit(expected: _rule, ruleId: 38, groupId: group),
          throwsA(isA<GitLabConflictException>()),
        );
        expect(repository.writes, 0);
      }
    },
  );
  test(
    'unknown membership mixed selectors and duplicate target IDs cannot write',
    () async {
      for (final grants in [
        [_rule.approvalRules.first.copyWith(groupInheritanceType: null)],
        [_rule.approvalRules.first.copyWith(groupInheritanceType: 7)],
        [_rule.approvalRules.first.copyWith(groupId: null, userId: 5)],
        [_rule.approvalRules.first.copyWith(accessLevel: 40)],
        [_rule.approvalRules.first, _rule.approvalRules.first],
        <ProtectedEnvironmentAccess>[],
      ]) {
        final expected = _rule.copyWith(approvalRules: grants);
        final repository = _Repository()..detail = expected;
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentApprovalGroupEditControllerProvider(
                  _key,
                ).notifier,
              )
              .edit(expected: expected, ruleId: 38, groupId: 136),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 0);
      }
    },
  );
  test(
    'only the target description may change and read-back must exactly agree',
    () async {
      final intended = _changed();
      final wrong = [
        intended.copyWith(deployAccessLevels: []),
        intended.copyWith(requiredApprovalCount: 1),
        intended.copyWith(approvalRules: [intended.approvalRules.first]),
        intended.copyWith(
          approvalRules: [
            intended.approvalRules.first.copyWith(requiredApprovals: 3),
            intended.approvalRules.last,
          ],
        ),
        intended.copyWith(
          approvalRules: [
            intended.approvalRules.first.copyWith(groupInheritanceType: 0),
            intended.approvalRules.last,
          ],
        ),
        intended.copyWith(
          approvalRules: [
            intended.approvalRules.first.copyWith(id: 40),
            intended.approvalRules.last,
          ],
        ),
        intended.copyWith(
          approvalRules: [
            intended.approvalRules.first,
            intended.approvalRules.last.copyWith(description: 'Changed'),
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
                  protectedEnvironmentApprovalGroupEditControllerProvider(
                    _key,
                  ).notifier,
                )
                .edit(expected: _rule, ruleId: 38, groupId: 136),
            throwsA(isA<GitLabException>()),
          );
          expect(repository.writes, 1);
        }
      }
      final repository = _Repository()
        ..postRead = intended.copyWith(
          approvalRules: [
            intended.approvalRules.first.copyWith(description: 'Renamed again'),
            intended.approvalRules.last,
          ],
        );
      final container = _container(repository);
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(
              protectedEnvironmentApprovalGroupEditControllerProvider(
                _key,
              ).notifier,
            )
            .edit(expected: _rule, ruleId: 38, groupId: 136),
        throwsA(isA<GitLabServerException>()),
      );
    },
  );
  for (final dispatched in [false, true]) {
    test(
      'overlap and account replacement isolate writes dispatched=$dispatched',
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
          protectedEnvironmentApprovalGroupEditControllerProvider(
            _key,
          ).notifier,
        );
        final pending = controller.edit(
          expected: _rule,
          ruleId: 38,
          groupId: 136,
        );
        final rejected = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        await expectLater(
          controller.edit(expected: _rule, ruleId: 38, groupId: 136),
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
                protectedEnvironmentApprovalGroupEditControllerProvider(_key),
              )
              .hasError,
          isFalse,
        );
      },
    );
  }
}
