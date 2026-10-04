import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/features/merge_requests/data/mr_actions_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';

const _mr = MergeRequest(
  id: 900,
  iid: 7,
  title: 'Review',
  state: 'opened',
  sourceBranch: 'feature',
  targetBranch: 'dev',
);
const _key = MergeRequestRef(projectId: 4, iid: 7);
final _provider = mrActionsControllerProvider(_key);

class _Analytics implements Analytics {
  final names = <String>[];
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async =>
      names.add(name);
}

class _Repository extends MrActionsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final calls = <(String, int, int)>[];
  Completer<void>? pending;
  bool fail = false;
  bool todoExists = false;
  Future<void> run(String name, int projectId, int iid) async {
    calls.add((name, projectId, iid));
    if (pending != null) await pending!.future;
    if (fail) throw const GitLabForbiddenException('Private server text');
  }

  @override
  Future<void> approve({required int projectId, required int iid}) =>
      run('approve', projectId, iid);
  @override
  Future<void> unapprove({required int projectId, required int iid}) =>
      run('unapprove', projectId, iid);
  @override
  Future<MergeRequest> merge({
    required int projectId,
    required int iid,
    bool squash = false,
  }) async {
    await run(squash ? 'squash' : 'merge', projectId, iid);
    return _mr;
  }

  @override
  Future<MergeRequest> setOpen({
    required int projectId,
    required int iid,
    required bool open,
  }) async {
    await run(open ? 'reopen' : 'close', projectId, iid);
    return _mr;
  }

  @override
  Future<MergeRequest> setDraft({
    required int projectId,
    required int iid,
    required bool draft,
    required String title,
  }) async {
    await run('draft', projectId, iid);
    return _mr;
  }

  @override
  Future<void> rebase({required int projectId, required int iid}) =>
      run('rebase', projectId, iid);
  @override
  Future<MergeRequest?> setSubscription({
    required int projectId,
    required int iid,
    required bool subscribed,
  }) async {
    await run('subscribe', projectId, iid);
    return _mr;
  }

  @override
  Future<Todo?> createTodo({required int projectId, required int iid}) async {
    await run('todo', projectId, iid);
    return todoExists ? null : const Todo(id: 3, state: 'pending');
  }
}

class _Detail extends MergeRequestController {
  _Detail(this.loaded);
  final void Function() loaded;
  @override
  Future<MergeRequest> build(MergeRequestRef arg) async {
    loaded();
    return _mr;
  }
}

Future<Object?> _command(MrActionsController n, String name) async {
  switch (name) {
    case 'approve':
      await n.approve();
    case 'unapprove':
      await n.unapprove();
    case 'merge':
      await n.merge();
    case 'squash':
      await n.merge(squash: true);
    case 'close':
      await n.setOpen(false);
    case 'reopen':
      await n.setOpen(true);
    case 'draft':
      await n.setDraft(draft: true, title: 'Review');
    case 'rebase':
      await n.rebase();
    case 'subscribe':
      await n.setSubscription(true);
    case 'todo':
      return n.createTodo();
  }
  return null;
}

void main() {
  late _Repository repo;
  late ProviderContainer container;
  late _Analytics analytics;
  setUp(() async {
    repo = _Repository();
    analytics = _Analytics();
    container = ProviderContainer(
      overrides: [
        mrActionsRepositoryProvider.overrideWith((ref) async => repo),
        analyticsProvider.overrideWithValue(analytics),
      ],
    );
    await container.read(_provider.future);
  });
  tearDown(() => container.dispose());
  for (final command in [
    'approve',
    'unapprove',
    'merge',
    'squash',
    'close',
    'reopen',
    'draft',
    'rebase',
    'subscribe',
    'todo',
  ]) {
    test(
      '$command reserves before repository await and rejects an overlapping command',
      () async {
        repo.pending = Completer<void>();
        final notifier = container.read(_provider.notifier);
        final first = _command(notifier, command);
        expect(container.read(_provider).isLoading, isTrue);
        final duplicate = _command(notifier, command);
        await Future<void>.delayed(Duration.zero);
        expect(repo.calls, [(command, 4, 7)]);
        expect(await duplicate, isNull);
        repo.pending!.complete();
        expect(await first, command == 'todo' ? true : null);
        expect(container.read(_provider).hasError, isFalse);
        expect(
          analytics.names.length,
          command == 'subscribe' || command == 'todo' ? 0 : 1,
        );
        repo.pending = null;
        await _command(notifier, command);
        expect(repo.calls.length, 2);
      },
    );
  }
  test('different command cannot overtake an active approval', () async {
    repo.pending = Completer<void>();
    final n = container.read(_provider.notifier);
    final first = n.approve();
    await Future<void>.delayed(Duration.zero);
    final ignored = n.merge(squash: true);
    await Future<void>.delayed(Duration.zero);
    expect(repo.calls, [('approve', 4, 7)]);
    await ignored;
    repo.pending!.complete();
    await first;
  });
  test('delayed repository resolution still reserves synchronously', () async {
    final ready = Completer<MrActionsRepository?>();
    container.updateOverrides([
      mrActionsRepositoryProvider.overrideWith((ref) => ready.future),
      analyticsProvider.overrideWithValue(analytics),
    ]);
    container.invalidate(mrActionsRepositoryProvider);
    final n = container.read(_provider.notifier);
    final first = n.approve();
    final duplicate = n.unapprove();
    expect(container.read(_provider).isLoading, isTrue);
    ready.complete(repo);
    await Future<void>.delayed(Duration.zero);
    expect(repo.calls, [('approve', 4, 7)]);
    await Future.wait([first, duplicate]);
  });
  test(
    'failure releases the guard and reports only the original error without automatic retry',
    () async {
      repo.fail = true;
      final n = container.read(_provider.notifier);
      await expectLater(n.approve(), throwsA(isA<GitLabForbiddenException>()));
      expect(container.read(_provider).hasError, isTrue);
      expect(repo.calls.length, 1);
      expect(analytics.names, isEmpty);
      repo.fail = false;
      await n.approve();
      expect(repo.calls.length, 2);
      expect(analytics.names, ['mr_approved']);
    },
  );
  test(
    'missing authentication releases the guard for explicit retry',
    () async {
      container.updateOverrides([
        mrActionsRepositoryProvider.overrideWith((ref) async => null),
        analyticsProvider.overrideWithValue(analytics),
      ]);
      container.invalidate(mrActionsRepositoryProvider);
      await container.read(mrActionsRepositoryProvider.future);
      final n = container.read(_provider.notifier);
      await expectLater(n.approve(), throwsA(isA<StateError>()));
      expect(container.read(_provider).hasError, isTrue);
      container.updateOverrides([
        mrActionsRepositoryProvider.overrideWith((ref) async => repo),
        analyticsProvider.overrideWithValue(analytics),
      ]);
      container.invalidate(mrActionsRepositoryProvider);
      await container.read(mrActionsRepositoryProvider.future);
      await n.approve();
      expect(repo.calls, [('approve', 4, 7)]);
    },
  );
  test(
    'same iid in another project and another iid have independent reservations',
    () async {
      repo.pending = Completer<void>();
      final keys = [
        _key,
        const MergeRequestRef(projectId: 5, iid: 7),
        const MergeRequestRef(projectId: 4, iid: 8),
      ];
      for (final key in keys) {
        await container.read(mrActionsControllerProvider(key).future);
      }
      final requests = [
        for (final key in keys)
          container.read(mrActionsControllerProvider(key).notifier).approve(),
      ];
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, [
        ('approve', 4, 7),
        ('approve', 5, 7),
        ('approve', 4, 8),
      ]);
      repo.pending!.complete();
      await Future.wait(requests);
    },
  );
  test(
    'only the successful original command refreshes detail and approvals',
    () async {
      var details = 0;
      var approvals = 0;
      container.dispose();
      container = ProviderContainer(
        overrides: [
          mrActionsRepositoryProvider.overrideWith((ref) async => repo),
          analyticsProvider.overrideWithValue(analytics),
          mergeRequestControllerProvider.overrideWith(
            () => _Detail(() => details++),
          ),
          mrApprovalsProvider.overrideWith((ref, arg) async {
            approvals++;
            return null;
          }),
        ],
      );
      final detail = mergeRequestControllerProvider(_key);
      final approval = mrApprovalsProvider(_key);
      await container.read(detail.future);
      await container.read(approval.future);
      repo.pending = Completer<void>();
      final n = container.read(_provider.notifier);
      final first = n.approve();
      await Future<void>.delayed(Duration.zero);
      await n.unapprove();
      expect(details, 1);
      expect(approvals, 1);
      repo.pending!.complete();
      await first;
      await container.read(detail.future);
      await container.read(approval.future);
      expect(details, 2);
      expect(approvals, 2);
      repo.pending = null;
      repo.fail = true;
      await expectLater(n.approve(), throwsA(isA<GitLabForbiddenException>()));
      await container.read(detail.future);
      await container.read(approval.future);
      expect(details, 2);
      expect(approvals, 2);
      expect(analytics.names, ['mr_approved']);
    },
  );
  test('existing todo stays false after an explicit request', () async {
    repo.todoExists = true;
    expect(await container.read(_provider.notifier).createTodo(), isFalse);
    expect(repo.calls, [('todo', 4, 7)]);
  });
}
