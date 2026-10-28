import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_branches/data/protected_branches_repository.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branch_protect_controller.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';

class ProtectBranchRepository extends ProtectedBranchesRepository {
  ProtectBranchRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int, Paginated<ProtectedBranch>>{
    1: const Paginated(items: []),
  };
  final reads = <int>[];
  final writes = <({String name, int push, int merge})>[];
  Completer<void>? pendingRead;
  Completer<void>? pendingWrite;
  Object? readFailure;
  Object? writeFailure;
  ProtectedBranch? returned;

  @override
  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) async {
    reads.add(page);
    if (pendingRead != null) await pendingRead!.future;
    if (readFailure != null) throw readFailure!;
    return pages[page] ?? const Paginated(items: []);
  }

  @override
  Future<ProtectedBranch> protect(
    int projectId, {
    required String name,
    required int pushAccessLevel,
    required int mergeAccessLevel,
  }) async {
    writes.add((name: name, push: pushAccessLevel, merge: mergeAccessLevel));
    if (pendingWrite != null) await pendingWrite!.future;
    if (writeFailure != null) throw writeFailure!;
    final rule =
        returned ??
        ProtectedBranch(
          name: name,
          pushAccessLevels: [
            ProtectedBranchAccess(accessLevel: pushAccessLevel),
          ],
          mergeAccessLevels: [
            ProtectedBranchAccess(accessLevel: mergeAccessLevel),
          ],
        );
    pages[1] = Paginated(items: [rule]);
    return rule;
  }
}

void main() {
  late ProtectBranchRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectBranchRepository();
    container = ProviderContainer(
      overrides: [
        protectedBranchesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> create({
    String name = 'release/*',
    int push = 0,
    int merge = 40,
  }) => container
      .read(protectedBranchProtectControllerProvider(7).notifier)
      .protect(name: name, pushAccessLevel: push, mergeAccessLevel: merge);

  test('scans every page before creating exact push and merge roles', () async {
    repository.pages[1] = const Paginated(
      items: [ProtectedBranch(name: 'main')],
      nextPage: 2,
    );
    repository.pages[2] = const Paginated(items: []);
    final sub = container.listen(
      protectedBranchesControllerProvider(7),
      (_, _) {},
    );
    await container.read(protectedBranchesControllerProvider(7).future);
    repository.reads.clear();
    await create(push: 30, merge: 0);
    expect(repository.reads.take(2), [1, 2]);
    expect(repository.writes.single, (name: 'release/*', push: 30, merge: 0));
    expect(
      (await container.read(
        protectedBranchesControllerProvider(7).future,
      )).items.single.name,
      'release/*',
    );
    sub.close();
  });
  for (final page in [1, 2]) {
    test('duplicate on page $page blocks POST', () async {
      repository.pages[1] = Paginated(
        items: page == 1 ? [const ProtectedBranch(name: 'release/*')] : [],
        nextPage: 2,
      );
      repository.pages[2] = Paginated(
        items: page == 2 ? [const ProtectedBranch(name: 'release/*')] : [],
      );
      await expectLater(create(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
      expect(repository.reads, [1, 2]);
    });
  }
  test('repeated cursor blocks POST', () async {
    repository.pages[1] = const Paginated(items: [], nextPage: 2);
    repository.pages[2] = const Paginated(items: [], nextPage: 2);
    await expectLater(create(), throwsA(isA<GitLabServerException>()));
    expect(repository.writes, isEmpty);
  });
  test('duplicate names across pages block POST', () async {
    repository.pages[1] = const Paginated(
      items: [ProtectedBranch(name: 'main')],
      nextPage: 2,
    );
    repository.pages[2] = const Paginated(
      items: [ProtectedBranch(name: 'main')],
    );
    await expectLater(create(), throwsA(isA<GitLabServerException>()));
    expect(repository.writes, isEmpty);
  });
  for (final roles in [(push: -1, merge: 40), (push: 40, merge: 10)]) {
    test('unsupported role $roles blocks before a read', () async {
      await expectLater(
        create(push: roles.push, merge: roles.merge),
        throwsArgumentError,
      );
      expect(repository.reads, isEmpty);
    });
  }
  test('failed POST retains list and a retry performs a fresh scan', () async {
    final sub = container.listen(
      protectedBranchesControllerProvider(7),
      (_, _) {},
    );
    await container.read(protectedBranchesControllerProvider(7).future);
    repository.writeFailure = const GitLabConnectionException('network');
    await expectLater(create(), throwsA(isA<GitLabConnectionException>()));
    expect(
      container.read(protectedBranchesControllerProvider(7)).requireValue.items,
      isEmpty,
    );
    repository.writeFailure = null;
    repository.reads.clear();
    await create();
    expect(repository.reads, contains(1));
    expect(repository.writes, hasLength(2));
    sub.close();
  });
  test(
    'unconfirmed returned permission cannot refresh or report success',
    () async {
      repository.returned = const ProtectedBranch(
        name: 'release/*',
        pushAccessLevels: [ProtectedBranchAccess(accessLevel: 30)],
        mergeAccessLevels: [ProtectedBranchAccess(accessLevel: 40)],
      );
      await expectLater(create(), throwsA(isA<GitLabServerException>()));
    },
  );
  test('duplicate submission is blocked during preflight', () async {
    repository.pendingRead = Completer<void>();
    final pending = create();
    await Future<void>.delayed(Duration.zero);
    await expectLater(create(), throwsStateError);
    repository.pendingRead!.complete();
    await pending;
    expect(repository.writes, hasLength(1));
  });
  for (final duringWrite in [false, true]) {
    test(
      'account change isolates ${duringWrite ? 'completion' : 'preflight'}',
      () async {
        final gate = Completer<void>();
        if (duringWrite) {
          repository.pendingWrite = gate;
        } else {
          repository.pendingRead = gate;
        }
        final pending = create();
        final expected = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        container.invalidate(protectedBranchesRepositoryProvider);
        await container.read(protectedBranchesRepositoryProvider.future);
        gate.complete();
        await expected;
        expect(repository.writes.length, duringWrite ? 1 : 0);
      },
    );
  }
}
