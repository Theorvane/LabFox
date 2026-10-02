import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_branches/data/protected_branches_repository.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';

const rule = ProtectedBranch(
  id: 12,
  name: 'release/*',
  mergeAccessLevels: [ProtectedBranchAccess(id: 3, accessLevel: 40)],
  pushAccessLevels: [ProtectedBranchAccess(id: 4, accessLevel: 40)],
  unprotectAccessLevels: [ProtectedBranchAccess(id: 6, accessLevel: 40)],
);

class _Repository extends ProtectedBranchesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  ProtectedBranch listed = rule;
  ProtectedBranch detail = rule;
  ProtectedBranch? response;
  Completer<void>? pendingRead;
  int reads = 0;
  int writes = 0;
  int? sentRecordId;
  int? sentRole;

  @override
  Future<Paginated<ProtectedBranch>> list(
    int projectId, {
    int page = 1,
  }) async => Paginated(items: [listed]);

  @override
  Future<ProtectedBranch> get(int projectId, String name) async {
    reads++;
    if (pendingRead != null) await pendingRead!.future;
    return detail;
  }

  @override
  Future<ProtectedBranch> updatePushRole(
    int projectId,
    String name, {
    required int accessRecordId,
    required int accessLevel,
  }) async {
    writes++;
    sentRecordId = accessRecordId;
    sentRole = accessLevel;
    return response ??
        rule.copyWith(
          pushAccessLevels: [
            rule.pushAccessLevels.single.copyWith(accessLevel: accessLevel),
          ],
        );
  }
}

void main() {
  late _Repository repository;
  late ProviderContainer container;
  const key = ProtectedBranchRef(projectId: 7, name: 'release/*');
  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [
        protectedBranchesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> update({ProtectedBranch expected = rule, int role = 30}) =>
      container
          .read(protectedBranchPushRoleControllerProvider(key).notifier)
          .setPushRole(expected: expected, accessLevel: role);

  test('preflights and updates only one existing role record', () async {
    await update();
    expect(repository.reads, 1);
    expect(repository.writes, 1);
    expect(repository.sentRecordId, 4);
    expect(repository.sentRole, 30);
  });

  test('stale rule blocks write', () async {
    repository.detail = rule.copyWith(allowForcePush: true);
    await expectLater(update(), throwsA(isA<GitLabConflictException>()));
    expect(repository.writes, 0);
  });

  test('inherited and multi-entry rules cannot be edited', () async {
    await expectLater(
      update(expected: rule.copyWith(inherited: true)),
      throwsA(isA<GitLabForbiddenException>()),
    );
    await expectLater(
      update(
        expected: rule.copyWith(
          pushAccessLevels: [
            ...rule.pushAccessLevels,
            const ProtectedBranchAccess(id: 5, accessLevel: 30),
          ],
        ),
      ),
      throwsArgumentError,
    );
    expect(repository.writes, 0);
  });

  test('user and unknown role records cannot be edited', () async {
    await expectLater(
      update(
        expected: rule.copyWith(
          pushAccessLevels: [const ProtectedBranchAccess(id: 4, userId: 22)],
        ),
      ),
      throwsArgumentError,
    );
    await expectLater(
      update(
        expected: rule.copyWith(
          pushAccessLevels: [
            const ProtectedBranchAccess(id: 4, accessLevel: 60),
          ],
        ),
      ),
      throwsArgumentError,
    );
    await expectLater(
      update(
        expected: rule.copyWith(
          pushAccessLevels: [
            const ProtectedBranchAccess(
              id: 4,
              accessLevel: 40,
              memberRoleId: 8,
            ),
          ],
        ),
      ),
      throwsArgumentError,
    );
    expect(repository.writes, 0);
  });

  test('unchanged and invalid target levels do not write', () async {
    await expectLater(update(role: 40), throwsArgumentError);
    await expectLater(update(role: 60), throwsArgumentError);
    expect(repository.writes, 0);
  });

  test('unconfirmed changes to other protection fields are rejected', () async {
    repository.response = rule.copyWith(
      allowForcePush: true,
      pushAccessLevels: [
        rule.pushAccessLevels.single.copyWith(accessLevel: 30),
      ],
    );
    await expectLater(update(), throwsA(isA<GitLabConflictException>()));
    expect(repository.writes, 1);
  });

  test('unconfirmed changes to unprotect access are rejected', () async {
    repository.response = rule.copyWith(
      unprotectAccessLevels: [],
      pushAccessLevels: [
        rule.pushAccessLevels.single.copyWith(accessLevel: 30),
      ],
    );
    await expectLater(update(), throwsA(isA<GitLabConflictException>()));
    expect(repository.writes, 1);
  });

  test('pending update cannot dispatch twice', () async {
    repository.pendingRead = Completer<void>();
    final pending = update();
    await Future<void>.delayed(Duration.zero);
    await expectLater(update(), throwsStateError);
    repository.pendingRead!.complete();
    await pending;
    expect(repository.writes, 1);
  });

  test('account change before write prevents PATCH', () async {
    repository.pendingRead = Completer<void>();
    final pending = expectLater(
      update(),
      throwsA(isA<GitLabConflictException>()),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(protectedBranchesRepositoryProvider);
    await container.read(protectedBranchesRepositoryProvider.future);
    repository.pendingRead!.complete();
    await pending;
    expect(repository.writes, 0);
  });
}
