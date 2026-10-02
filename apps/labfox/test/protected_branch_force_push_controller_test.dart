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
  pushAccessLevels: [ProtectedBranchAccess(id: 3, accessLevel: 40)],
);

class _Repository extends ProtectedBranchesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  List<ProtectedBranch> first = [const ProtectedBranch(name: 'main')];
  List<ProtectedBranch> second = [rule];
  ProtectedBranch detail = rule;
  ProtectedBranch? response;
  int reads = 0;
  int writes = 0;
  final pages = <int>[];
  Completer<void>? pendingRead;
  Completer<void>? pendingWrite;
  Object? failure;

  @override
  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) async {
    pages.add(page);
    return page == 1
        ? Paginated(items: first, nextPage: 2)
        : Paginated(items: second);
  }

  @override
  Future<ProtectedBranch> get(int projectId, String name) async {
    reads++;
    if (pendingRead != null) await pendingRead!.future;
    return detail;
  }

  @override
  Future<ProtectedBranch> updateForcePush(
    int projectId,
    String name, {
    required bool allowForcePush,
  }) async {
    writes++;
    if (pendingWrite != null) await pendingWrite!.future;
    if (failure != null) throw failure!;
    return response ?? rule.copyWith(allowForcePush: allowForcePush);
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
  Future<void> update({ProtectedBranch expected = rule, bool desired = true}) =>
      container
          .read(protectedBranchForcePushControllerProvider(key).notifier)
          .setForcePush(expected: expected, allowForcePush: desired);

  test('scans every page, compares detail, updates one flag once', () async {
    await update();
    expect(repository.pages, [1, 2]);
    expect(repository.reads, 1);
    expect(repository.writes, 1);
  });
  test('duplicate exact name blocks update', () async {
    repository.first = [rule];
    await expectLater(update(), throwsA(isA<GitLabConflictException>()));
    expect(repository.writes, 0);
  });
  test('changed permissions block update', () async {
    repository.detail = rule.copyWith(pushAccessLevels: []);
    await expectLater(update(), throwsA(isA<GitLabConflictException>()));
    expect(repository.writes, 0);
  });
  test('inherited rule cannot be edited', () async {
    await expectLater(
      update(expected: rule.copyWith(inherited: true)),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(repository.writes, 0);
  });
  test('unchanged value cannot dispatch PATCH', () async {
    await expectLater(update(desired: false), throwsArgumentError);
    expect(repository.writes, 0);
  });
  test('unconfirmed response requires fresh inspection', () async {
    repository.response = rule.copyWith(
      allowForcePush: true,
      mergeAccessLevels: [const ProtectedBranchAccess(accessLevel: 30)],
    );
    await expectLater(update(), throwsA(isA<GitLabConflictException>()));
    expect(repository.writes, 1);
  });
  test('failure retains retry preflight', () async {
    repository.failure = const GitLabForbiddenException('Denied');
    await expectLater(update(), throwsA(isA<GitLabForbiddenException>()));
    repository.failure = null;
    await update();
    expect(repository.pages.take(2), [1, 2]);
    expect(repository.pages.skip(repository.pages.length - 2), [1, 2]);
    expect(repository.writes, 2);
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
  test(
    'account change during write does not commit old-session state',
    () async {
      repository.pendingWrite = Completer<void>();
      final pending = expectLater(
        update(),
        throwsA(isA<GitLabConflictException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      container.invalidate(protectedBranchesRepositoryProvider);
      await container.read(protectedBranchesRepositoryProvider.future);
      repository.pendingWrite!.complete();
      await pending;
      expect(repository.writes, 1);
    },
  );
}
