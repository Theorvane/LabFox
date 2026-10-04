import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/inbox/presentation/controllers/inbox_controllers.dart';
import 'package:labfox/features/merge_requests/data/mr_actions_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

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

class _Entitlement extends EntitlementController {
  @override
  Entitlement build() => Entitlement.subscribed;
}

class _Comments extends CommentsController {
  @override
  Future<List<Note>> build(CommentsRef arg) async => const [];
}

class _Inbox extends InboxController {
  _Inbox(this.loaded);
  final void Function() loaded;
  @override
  Future<List<Todo>> build(InboxQuery arg) async {
    loaded();
    return const [];
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
  late _Analytics analytics;
  late ProviderContainer c;
  setUp(() async {
    repo = _Repository();
    analytics = _Analytics();
    c = ProviderContainer(
      overrides: [
        mrActionsRepositoryProvider.overrideWith((ref) async => repo),
        analyticsProvider.overrideWithValue(analytics),
      ],
    );
    await c.read(_provider.future);
  });
  tearDown(() => c.dispose());
  Future<void> replace(_Repository? next) async {
    c.updateOverrides([
      mrActionsRepositoryProvider.overrideWith((ref) async => next),
      analyticsProvider.overrideWithValue(analytics),
    ]);
    c.invalidate(mrActionsRepositoryProvider);
    c.read(_provider.notifier);
    await Future<void>.delayed(Duration.zero);
  }

  for (final name in [
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
      'late $name completion after replacement has no current-session effects',
      () async {
        repo.pending = Completer<void>();
        final old = _command(c.read(_provider.notifier), name);
        await Future<void>.delayed(Duration.zero);
        expect(repo.calls, [(name, 4, 7)]);
        final next = _Repository();
        await replace(next);
        repo.pending!.complete();
        expect(await old, null);
        expect(analytics.names, isEmpty);
        expect(c.read(_provider).hasError, isFalse);
        await _command(c.read(_provider.notifier), name);
        expect(next.calls, [(name, 4, 7)]);
      },
    );
  }
  test(
    'repository replacement before dispatch cancels the obsolete command',
    () async {
      final old = c.read(_provider.notifier).approve();
      final next = _Repository();
      await replace(next);
      await old.timeout(const Duration(seconds: 2));
      expect(repo.calls, isEmpty);
      expect(next.calls, isEmpty);
      await c.read(_provider.notifier).approve();
      expect(next.calls, [('approve', 4, 7)]);
    },
  );
  test(
    'waiting for a replaced repository cannot dispatch to its old account',
    () async {
      final ready = Completer<MrActionsRepository?>();
      c.updateOverrides([
        mrActionsRepositoryProvider.overrideWith((ref) => ready.future),
        analyticsProvider.overrideWithValue(analytics),
      ]);
      c.invalidate(mrActionsRepositoryProvider);
      final old = c.read(_provider.notifier).approve();
      final next = _Repository();
      await replace(next);
      ready.complete(repo);
      await old.timeout(const Duration(seconds: 2));
      expect(repo.calls, isEmpty);
      expect(next.calls, isEmpty);
    },
  );
  for (final logout in [false, true]) {
    test('late domain error after logout=$logout is suppressed', () async {
      repo.pending = Completer<void>();
      final old = c.read(_provider.notifier).approve();
      await Future<void>.delayed(Duration.zero);
      await replace(logout ? null : _Repository());
      final observed = expectLater(old, completes);
      repo.pending!.completeError(
        const GitLabForbiddenException('Old account'),
      );
      await observed;
      expect(c.read(_provider).hasError, isFalse);
      expect(analytics.names, isEmpty);
      if (logout) {
        await expectLater(
          c.read(_provider.notifier).approve(),
          throwsA(isA<StateError>()),
        );
      }
    });
  }
  test('an old finally cannot release a new session reservation', () async {
    repo.pending = Completer<void>();
    final n = c.read(_provider.notifier);
    final old = n.approve();
    await Future<void>.delayed(Duration.zero);
    final next = _Repository()..pending = Completer<void>();
    await replace(next);
    final fresh = c.read(_provider.notifier).merge();
    await Future<void>.delayed(Duration.zero);
    expect(next.calls, [('merge', 4, 7)]);
    repo.pending!.complete();
    await old.timeout(const Duration(seconds: 2));
    expect(c.read(_provider).isLoading, isTrue);
    await c.read(_provider.notifier).unapprove();
    expect(next.calls, [('merge', 4, 7)]);
    next.pending!.complete();
    await fresh;
    expect(analytics.names, ['mr_merged']);
  });
  for (final failure in [false, true]) {
    test(
      'disposed provider ignores late completion failure=$failure',
      () async {
        repo.pending = Completer<void>();
        final old = c.read(_provider.notifier).approve();
        await Future<void>.delayed(Duration.zero);
        c.invalidate(_provider);
        await c.read(_provider.future);
        final observed = expectLater(old, completes);
        if (failure) {
          repo.pending!.completeError(
            const GitLabForbiddenException('Disposed'),
          );
        } else {
          repo.pending!.complete();
        }
        await observed;
        expect(analytics.names, isEmpty);
        expect(c.read(_provider).hasError, isFalse);
      },
    );
  }
  test('stale todo does not invalidate the current inbox or detail', () async {
    c.dispose();
    var details = 0;
    var approvals = 0;
    var inboxLoads = 0;
    c = ProviderContainer(
      overrides: [
        inboxControllerProvider.overrideWith(() => _Inbox(() => inboxLoads++)),
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
    await c.read(_provider.future);
    final detail = mergeRequestControllerProvider(_key);
    final approval = mrApprovalsProvider(_key);
    await c.read(detail.future);
    await c.read(approval.future);
    final inbox = inboxControllerProvider(const InboxQuery());
    await c.read(inbox.future);
    repo.pending = Completer<void>();
    final old = c.read(_provider.notifier).createTodo();
    await Future<void>.delayed(Duration.zero);
    final next = _Repository();
    c.updateOverrides([
      inboxControllerProvider.overrideWith(() => _Inbox(() => inboxLoads++)),
      mrActionsRepositoryProvider.overrideWith((ref) async => next),
      analyticsProvider.overrideWithValue(analytics),
      mergeRequestControllerProvider.overrideWith(
        () => _Detail(() => details++),
      ),
      mrApprovalsProvider.overrideWith((ref, arg) async {
        approvals++;
        return null;
      }),
    ]);
    c.invalidate(mrActionsRepositoryProvider);
    c.read(_provider.notifier);
    await Future<void>.delayed(Duration.zero);
    repo.pending!.complete();
    expect(await old, isNull);
    await c.read(detail.future);
    await c.read(approval.future);
    await c.read(inbox.future);
    expect(inboxLoads, 1);
    expect(details, 1);
    expect(approvals, 1);
  });
  for (final failure in [false, true]) {
    test(
      'container disposal suppresses late completion failure=$failure',
      () async {
        repo.pending = Completer<void>();
        final old = c.read(_provider.notifier).approve();
        await Future<void>.delayed(Duration.zero);
        c.dispose();
        final observed = expectLater(old, completes);
        if (failure) {
          repo.pending!.completeError(
            const GitLabForbiddenException('Disposed container'),
          );
        } else {
          repo.pending!.complete();
        }
        await observed;
        expect(analytics.names, isEmpty);
        c = ProviderContainer();
      },
    );
  }
  test(
    'a current-session repository error propagates for explicit retry',
    () async {
      c.dispose();
      c = ProviderContainer(
        overrides: [
          mrActionsRepositoryProvider.overrideWith(
            (ref) async => throw const GitLabConnectionException('Unavailable'),
          ),
          analyticsProvider.overrideWithValue(analytics),
        ],
      );
      await c.read(_provider.future);
      await expectLater(
        c.read(_provider.notifier).approve(),
        throwsA(isA<GitLabConnectionException>()),
      );
      expect(c.read(_provider).hasError, isTrue);
      await replace(repo);
      await c.read(_provider.notifier).approve();
      expect(repo.calls, [('approve', 4, 7)]);
    },
  );
  testWidgets(
    'obsolete todo completion does not show a current-account toast',
    (tester) async {
      repo.pending = Completer<void>();
      final session = StateProvider<MrActionsRepository?>((ref) => repo);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mrActionsRepositoryProvider.overrideWith(
              (ref) async => ref.watch(session),
            ),
            mrApprovalsProvider.overrideWith((ref, arg) async => null),
            mergeRequestControllerProvider.overrideWith(() => _Detail(() {})),
            commentsControllerProvider.overrideWith(_Comments.new),
            entitlementProvider.overrideWith(_Entitlement.new),
            analyticsProvider.overrideWithValue(analytics),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MergeRequestDetailScreen(projectId: 4, iid: 7),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final screen = tester.element(find.byType(MergeRequestDetailScreen));
      final l10n = AppLocalizations.of(screen);
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.mrAddTodo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(repo.calls, [('todo', 4, 7)]);
      ProviderScope.containerOf(screen).read(session.notifier).state =
          _Repository();
      await tester.pumpAndSettle();
      repo.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
