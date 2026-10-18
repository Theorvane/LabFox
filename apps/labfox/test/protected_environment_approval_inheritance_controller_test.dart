import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environment_approval_inheritance_controller.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

const _rule = ProtectedEnvironment(
  name: 'review/production',
  deployAccessLevels: [ProtectedEnvironmentAccess(id: 12, accessLevel: 40)],
  approvalRules: [
    ProtectedEnvironmentAccess(
      id: 38,
      groupId: 134,
      groupInheritanceType: 0,
      requiredApprovals: 2,
    ),
    ProtectedEnvironmentAccess(id: 39, userId: 5, requiredApprovals: 1),
  ],
);
const _key = ProtectedEnvironmentRef(projectId: 7, name: 'review/production');
ProtectedEnvironment _changed(ProtectedEnvironment expected, int membership) =>
    expected.copyWith(
      approvalRules: [
        for (final rule in expected.approvalRules)
          rule.id == 38
              ? rule.copyWith(groupInheritanceType: membership)
              : rule,
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
  Future<ProtectedEnvironment> getForApprovalGroupEdit(
    int projectId,
    String name,
  ) async {
    reads++;
    await readGate?.future;
    return writes == 0 ? detail : postRead ?? detail;
  }

  @override
  Future<ProtectedEnvironment> editApprovalGroupInheritance(
    int projectId,
    String name, {
    required int ruleId,
    required int groupInheritanceType,
  }) async {
    writes++;
    await writeGate?.future;
    if (failure != null) throw failure!;
    detail = _changed(detail, groupInheritanceType);
    return response ?? detail;
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
  for (final membership in [0, 1]) {
    test(
      'changes only membership=$membership after complete preflight and read-back',
      () async {
        final expected = _changed(_rule, 1 - membership);
        final repository = _Repository()..detail = expected;
        final container = _container(repository);
        addTearDown(container.dispose);
        await container
            .read(
              protectedEnvironmentApprovalInheritanceControllerProvider(
                _key,
              ).notifier,
            )
            .edit(
              expected: expected,
              ruleId: 38,
              groupInheritanceType: membership,
            );
        expect(repository.pages, [1, 2]);
        expect(repository.reads, 2);
        expect(repository.writes, 1);
        expect(repository.detail, _changed(expected, membership));
      },
    );
  }
  test('stale duplicate and missing environments cannot write', () async {
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
              protectedEnvironmentApprovalInheritanceControllerProvider(
                _key,
              ).notifier,
            )
            .edit(expected: _rule, ruleId: 38, groupInheritanceType: 1),
        throwsA(isA<GitLabException>()),
      );
      expect(repository.writes, 0);
    }
  });
  test(
    'unknown unchanged non-group and duplicate targets cannot write',
    () async {
      for (final grants in [
        [_rule.approvalRules.first.copyWith(groupInheritanceType: null)],
        [_rule.approvalRules.first.copyWith(groupInheritanceType: 7)],
        [_rule.approvalRules.first.copyWith(groupInheritanceType: 1)],
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
                protectedEnvironmentApprovalInheritanceControllerProvider(
                  _key,
                ).notifier,
              )
              .edit(expected: expected, ruleId: 38, groupInheritanceType: 1),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 0);
      }
    },
  );
  test(
    'uncertain writes and changed response or read-back cannot report success',
    () async {
      final intended = _changed(_rule, 1);
      final wrong = [
        intended.copyWith(deployAccessLevels: []),
        intended.copyWith(requiredApprovalCount: 1),
        intended.copyWith(approvalRules: [intended.approvalRules.first]),
        intended.copyWith(
          approvalRules: [
            intended.approvalRules.first.copyWith(groupId: 135),
            intended.approvalRules.last,
          ],
        ),
        intended.copyWith(
          approvalRules: [
            intended.approvalRules.first.copyWith(requiredApprovals: 3),
            intended.approvalRules.last,
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
                  protectedEnvironmentApprovalInheritanceControllerProvider(
                    _key,
                  ).notifier,
                )
                .edit(expected: _rule, ruleId: 38, groupInheritanceType: 1),
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
              protectedEnvironmentApprovalInheritanceControllerProvider(
                _key,
              ).notifier,
            )
            .edit(expected: _rule, ruleId: 38, groupInheritanceType: 1),
        throwsA(isA<GitLabServerException>()),
      );
      expect(repository.writes, 1);
    },
  );
  for (final dispatched in [false, true]) {
    test(
      'overlap and account replacement are isolated dispatched=$dispatched',
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
          protectedEnvironmentApprovalInheritanceControllerProvider(
            _key,
          ).notifier,
        );
        final pending = controller.edit(
          expected: _rule,
          ruleId: 38,
          groupInheritanceType: 1,
        );
        final rejected = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        await expectLater(
          controller.edit(expected: _rule, ruleId: 38, groupInheritanceType: 1),
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
                protectedEnvironmentApprovalInheritanceControllerProvider(_key),
              )
              .hasError,
          isFalse,
        );
      },
    );
  }
}
