import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_branches/data/protected_branches_repository.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';

const target = ProtectedBranch(
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
  List<ProtectedBranch> second = [target];
  ProtectedBranch detail = target;
  bool removed = false;
  int? nextPageOverride;
  int reads = 0;
  int deletes = 0;
  final pages = <int>[];
  Completer<void>? pendingRead;
  Completer<void>? pendingDelete;
  Object? failure;

  @override
  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) async {
    pages.add(page);
    if (removed) return const Paginated(items: []);
    return page == 1
        ? Paginated(items: first, nextPage: nextPageOverride ?? 2)
        : Paginated(items: second);
  }

  @override
  Future<ProtectedBranch> get(int projectId, String name) async {
    reads++;
    if (pendingRead != null) await pendingRead!.future;
    if (removed) throw const GitLabNotFoundException('Gone');
    return detail;
  }

  @override
  Future<void> unprotect(int projectId, String name) async {
    deletes++;
    if (pendingDelete != null) await pendingDelete!.future;
    if (failure != null) throw failure!;
    removed = true;
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
  Future<void> remove({ProtectedBranch expected = target}) => container
      .read(protectedBranchUnprotectControllerProvider(key).notifier)
      .unprotect(expected: expected);

  test('scans every page, checks exact detail, then removes once', () async {
    await remove();
    expect(repository.pages, [1, 2]);
    expect(repository.reads, 1);
    expect(repository.deletes, 1);
  });
  test('duplicate name fails closed', () async {
    repository.first = [target];
    await expectLater(remove(), throwsA(isA<GitLabConflictException>()));
    expect(repository.deletes, 0);
  });
  test('missing rule fails closed', () async {
    repository.second = [];
    await expectLater(remove(), throwsA(isA<GitLabNotFoundException>()));
    expect(repository.deletes, 0);
  });
  test('skipped or repeated page fails closed', () async {
    repository.nextPageOverride = 3;
    await expectLater(remove(), throwsA(isA<GitLabServerException>()));
    expect(repository.deletes, 0);
  });
  test('changed detail fails closed', () async {
    repository.detail = target.copyWith(allowForcePush: true);
    await expectLater(remove(), throwsA(isA<GitLabConflictException>()));
    expect(repository.deletes, 0);
  });
  test('inherited rule cannot be removed', () async {
    repository.second = [target.copyWith(inherited: true)];
    await expectLater(
      remove(expected: target.copyWith(inherited: true)),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(repository.deletes, 0);
  });
  test(
    'failed write requires explicit inspection before another removal',
    () async {
      repository.failure = const GitLabForbiddenException('Denied');
      await expectLater(remove(), throwsA(isA<GitLabForbiddenException>()));
      repository.failure = null;
      await expectLater(remove(), throwsA(isA<GitLabConflictException>()));
      expect(repository.deletes, 1);
      await container
          .read(protectedBranchUnprotectControllerProvider(key).notifier)
          .inspect();
      await remove();
      expect(repository.pages, [1, 2, 1, 2, 1, 2]);
      expect(repository.reads, 3);
    },
  );
  test('pending removal cannot be duplicated', () async {
    repository.pendingRead = Completer<void>();
    final pending = remove();
    await Future<void>.delayed(Duration.zero);
    await expectLater(remove(), throwsStateError);
    repository.pendingRead!.complete();
    await pending;
    expect(repository.deletes, 1);
  });
  test('session change during preflight prevents deletion', () async {
    repository.pendingRead = Completer<void>();
    final pending = expectLater(
      remove(),
      throwsA(isA<GitLabConflictException>()),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(protectedBranchesRepositoryProvider);
    await container.read(protectedBranchesRepositoryProvider.future);
    repository.pendingRead!.complete();
    await pending;
    expect(repository.deletes, 0);
  });
  test(
    'session change during the DELETE leaves new-session state untouched',
    () async {
      repository.pendingDelete = Completer<void>();
      final pending = expectLater(
        remove(),
        throwsA(isA<GitLabConflictException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      container.invalidate(protectedBranchesRepositoryProvider);
      await container.read(protectedBranchesRepositoryProvider.future);
      repository.pendingDelete!.complete();
      await pending;
      expect(repository.deletes, 1);
    },
  );
}
