import 'dart:async';

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
    ProtectedEnvironmentAccess(id: 38, groupId: 134, requiredApprovals: 2),
    ProtectedEnvironmentAccess(id: 39, userId: 5, requiredApprovals: 1),
  ],
  requiredApprovalCount: 0,
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
  var reads = 0;
  var writes = 0;
  var duplicate = false;
  var failWrite = false;
  var keepSelected = false;
  var changeDeploy = false;
  var changeOtherApproval = false;
  var changeLegacyCount = false;
  ProtectedEnvironment detail = _rule;
  Completer<void>? readGate;
  Completer<void>? writeGate;

  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async {
    pages.add(page);
    return page == 1
        ? Paginated(items: [if (duplicate) detail], nextPage: 2)
        : Paginated(items: [detail]);
  }

  @override
  Future<ProtectedEnvironment> getComplete(int projectId, String name) async {
    reads++;
    await readGate?.future;
    return detail;
  }

  @override
  Future<void> removeApprovalRule(
    int projectId,
    String name, {
    required int ruleId,
  }) async {
    writes++;
    await writeGate?.future;
    if (failWrite) throw const GitLabServerException('Unconfirmed write');
    detail = detail.copyWith(
      approvalRules: [
        for (final rule in detail.approvalRules)
          if (keepSelected || rule.id != ruleId)
            changeOtherApproval && rule.id != ruleId
                ? rule.copyWith(requiredApprovals: 3)
                : rule,
      ],
      deployAccessLevels: changeDeploy ? [] : detail.deployAccessLevels,
      requiredApprovalCount: changeLegacyCount
          ? 3
          : detail.requiredApprovalCount,
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
  for (final lastRule in [false, true]) {
    test(
      'removes only the selected approval rule lastRule=$lastRule',
      () async {
        final expected = lastRule
            ? _rule.copyWith(approvalRules: [_rule.approvalRules.first])
            : _rule;
        final repository = _Repository()..detail = expected;
        final container = _container(repository);
        addTearDown(container.dispose);
        await container
            .read(
              protectedEnvironmentRemoveApprovalRuleControllerProvider(
                _key,
              ).notifier,
            )
            .remove(expected: expected, ruleId: 38);
        expect(repository.pages, [1, 2]);
        expect(repository.reads, 2);
        expect(repository.writes, 1);
        expect(
          repository.detail,
          expected.copyWith(
            approvalRules: [if (!lastRule) _rule.approvalRules.last],
          ),
        );
      },
    );
  }

  test(
    'stale, duplicate, missing and unknown approval rules cannot write',
    () async {
      final unknown = _rule.copyWith(
        approvalRules: [const ProtectedEnvironmentAccess(id: 38, groupId: 134)],
      );
      final duplicateId = _rule.copyWith(
        approvalRules: [_rule.approvalRules.first, _rule.approvalRules.first],
      );
      for (final scenario in [
        (
          repository: _Repository()
            ..detail = _rule.copyWith(requiredApprovalCount: 2),
          expected: _rule,
          id: 38,
        ),
        (repository: _Repository()..duplicate = true, expected: _rule, id: 38),
        (repository: _Repository(), expected: _rule, id: 99),
        (
          repository: _Repository()..detail = unknown,
          expected: unknown,
          id: 38,
        ),
        (
          repository: _Repository()..detail = duplicateId,
          expected: duplicateId,
          id: 38,
        ),
      ]) {
        final container = _container(scenario.repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentRemoveApprovalRuleControllerProvider(
                  _key,
                ).notifier,
              )
              .remove(expected: scenario.expected, ruleId: scenario.id),
          throwsA(isA<GitLabConflictException>()),
        );
        expect(scenario.repository.writes, 0);
      }
    },
  );

  test(
    'uncertain removal and unrelated changes fail after one dispatch',
    () async {
      for (final repository in [
        _Repository()..failWrite = true,
        _Repository()..keepSelected = true,
        _Repository()..changeDeploy = true,
        _Repository()..changeOtherApproval = true,
        _Repository()..changeLegacyCount = true,
      ]) {
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(
                protectedEnvironmentRemoveApprovalRuleControllerProvider(
                  _key,
                ).notifier,
              )
              .remove(expected: _rule, ruleId: 38),
          throwsA(isA<GitLabServerException>()),
        );
        expect(repository.writes, 1);
      }
    },
  );

  for (final dispatched in [false, true]) {
    test(
      'account replacement isolates removal dispatched=$dispatched',
      () async {
        final gate = Completer<void>();
        final repository = _Repository();
        if (dispatched) {
          repository.writeGate = gate;
        } else {
          repository.readGate = gate;
        }
        final container = _container(repository);
        addTearDown(container.dispose);
        final controller = container.read(
          protectedEnvironmentRemoveApprovalRuleControllerProvider(
            _key,
          ).notifier,
        );
        final pending = controller.remove(expected: _rule, ruleId: 38);
        final rejected = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        await expectLater(
          controller.remove(expected: _rule, ruleId: 38),
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
        expect(replacement.pages, isEmpty);
        expect(
          container
              .read(
                protectedEnvironmentRemoveApprovalRuleControllerProvider(_key),
              )
              .hasError,
          isFalse,
        );
      },
    );
  }
}
