import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_branches/data/protected_branches_repository.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';

const _rule = ProtectedBranch(
  id: 12,
  name: 'release/*',
  pushAccessLevels: [ProtectedBranchAccess(id: 3, accessLevel: 40)],
  mergeAccessLevels: [ProtectedBranchAccess(id: 4, groupId: 8)],
  unprotectAccessLevels: [ProtectedBranchAccess(id: 5, memberRoleId: 7)],
);
const _key = ProtectedBranchRef(projectId: 7, name: 'release/*');

class _Repository extends ProtectedBranchesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ProtectedBranch inventory = _rule;
  ProtectedBranch detail = _rule;
  var duplicate = false;
  var missing = false;
  var corruptResponse = false;
  var corruptPostRead = false;
  var writes = 0;
  var reads = 0;
  Object? readFailure;
  Object? writeFailure;
  final pages = <int>[];
  Completer<void>? readGate;
  Completer<void>? writeGate;

  @override
  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) async {
    pages.add(page);
    return page == 1
        ? Paginated(items: [if (duplicate) inventory], nextPage: 2)
        : Paginated(items: [if (!missing) inventory]);
  }

  @override
  Future<ProtectedBranch> getForCodeOwnerEdit(
    int projectId,
    String name,
  ) async {
    reads++;
    await readGate?.future;
    if (readFailure != null) throw readFailure!;
    return detail;
  }

  @override
  Future<ProtectedBranch> updateCodeOwnerApproval(
    int projectId,
    String name, {
    required bool codeOwnerApprovalRequired,
  }) async {
    writes++;
    await writeGate?.future;
    if (writeFailure != null) throw writeFailure!;
    final changed = detail.copyWith(
      codeOwnerApprovalRequired: codeOwnerApprovalRequired,
    );
    detail = corruptPostRead ? changed.copyWith(allowForcePush: true) : changed;
    return corruptResponse
        ? changed.copyWith(unprotectAccessLevels: [])
        : changed;
  }
}

ProviderContainer _container(_Repository repository) => ProviderContainer(
  overrides: [
    protectedBranchesRepositoryProvider.overrideWith((ref) async => repository),
  ],
);

void main() {
  for (final enabled in [true, false]) {
    test(
      'updates only Code Owner approval=$enabled after complete preflight and post-read',
      () async {
        final expected = _rule.copyWith(codeOwnerApprovalRequired: !enabled);
        final repository = _Repository()
          ..inventory = expected
          ..detail = expected;
        final container = _container(repository);
        addTearDown(container.dispose);
        await container
            .read(protectedBranchCodeOwnerControllerProvider(_key).notifier)
            .setRequirement(
              expected: expected,
              codeOwnerApprovalRequired: enabled,
            );
        expect(repository.pages, [1, 2]);
        expect(repository.reads, 2);
        expect(repository.writes, 1);
        expect(
          repository.detail,
          expected.copyWith(codeOwnerApprovalRequired: enabled),
        );
      },
    );
  }

  test(
    'stale, duplicate, missing, inherited and incomplete rules cannot write',
    () async {
      for (final repository in [
        _Repository()..detail = _rule.copyWith(pushAccessLevels: []),
        _Repository()
          ..inventory = _rule.copyWith(allowForcePush: true)
          ..detail = _rule.copyWith(allowForcePush: true),
        _Repository()..duplicate = true,
        _Repository()..missing = true,
        _Repository()
          ..inventory = _rule.copyWith(inherited: true)
          ..detail = _rule.copyWith(inherited: true),
        _Repository()
          ..readFailure = const GitLabServerException(
            'Missing explicit Code Owner flag',
          ),
      ]) {
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(protectedBranchCodeOwnerControllerProvider(_key).notifier)
              .setRequirement(expected: _rule, codeOwnerApprovalRequired: true),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 0);
      }
    },
  );

  test('unchanged values cannot write', () async {
    final repository = _Repository();
    final container = _container(repository);
    addTearDown(container.dispose);
    await expectLater(
      container
          .read(protectedBranchCodeOwnerControllerProvider(_key).notifier)
          .setRequirement(expected: _rule, codeOwnerApprovalRequired: false),
      throwsArgumentError,
    );
    expect(repository.writes, 0);
  });

  test(
    'unconfirmed write response or authoritative state fails after one PATCH',
    () async {
      for (final repository in [
        _Repository()..corruptResponse = true,
        _Repository()..corruptPostRead = true,
        _Repository()
          ..writeFailure = const GitLabServerException('Uncertain write'),
      ]) {
        final container = _container(repository);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(protectedBranchCodeOwnerControllerProvider(_key).notifier)
              .setRequirement(expected: _rule, codeOwnerApprovalRequired: true),
          throwsA(isA<GitLabException>()),
        );
        expect(repository.writes, 1);
      }
    },
  );

  for (final dispatched in [false, true]) {
    test(
      'overlap and account replacement are isolated dispatched=$dispatched',
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
          protectedBranchCodeOwnerControllerProvider(_key).notifier,
        );
        final pending = controller.setRequirement(
          expected: _rule,
          codeOwnerApprovalRequired: true,
        );
        final rejected = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        await expectLater(
          controller.setRequirement(
            expected: _rule,
            codeOwnerApprovalRequired: true,
          ),
          throwsStateError,
        );
        final replacement = _Repository();
        container.updateOverrides([
          protectedBranchesRepositoryProvider.overrideWith(
            (ref) async => replacement,
          ),
        ]);
        container.invalidate(protectedBranchesRepositoryProvider);
        await container.read(protectedBranchesRepositoryProvider.future);
        gate.complete();
        await rejected;
        expect(repository.writes, dispatched ? 1 : 0);
        expect(replacement.reads, 0);
        expect(replacement.writes, 0);
        expect(
          container
              .read(protectedBranchCodeOwnerControllerProvider(_key))
              .hasError,
          isFalse,
        );
      },
    );
  }
}
