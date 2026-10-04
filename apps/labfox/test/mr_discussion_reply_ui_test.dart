import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_discussion_thread.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _key = MergeRequestRef(projectId: 8, iid: 142);
Discussion _thread(
  String id, {
  String body = 'Review comment',
  bool? resolved = false,
}) => Discussion(
  id: id,
  individualNote: false,
  notes: [
    Note(
      id: 301,
      body: body,
      resolvable: true,
      resolved: resolved,
      author: const User(id: 7, username: 'reviewer', name: 'Reviewer'),
    ),
    const Note(id: 302, body: 'Review reply'),
  ],
);

class _Repository extends CommentsRepository {
  _Repository()
    : this._(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  _Repository._(this.client) : super(client);
  final GitLabClient client;
  final pages = <int, Object>{1: const Paginated<Discussion>(items: [])};
  final reads = <(int, int, int)>[];
  final posts = <String>[];
  Future<Note>? postResult;
  Future<Note>? replyResult;
  final replies = <(int, int, String, String)>[];
  @override
  Future<Note> replyToDiscussion({
    required int projectId,
    required int iid,
    required String discussionId,
    required String body,
  }) async {
    replies.add((projectId, iid, discussionId, body));
    return replyResult ?? Note(id: 999, body: body);
  }

  @override
  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    reads.add((projectId, iid, page));
    final result = pages[page]!;
    if (result is Future<Paginated<Discussion>>) return result;
    if (result is Paginated<Discussion>) return result;
    throw result;
  }

  @override
  Future<Note> post({
    required NoteableType type,
    required int projectId,
    required int iid,
    required String body,
  }) async {
    expect(type, NoteableType.mergeRequest);
    posts.add(body);
    return postResult ?? const Note(id: 999, body: 'Posted');
  }

  @override
  Future<List<Note>> list({
    required NoteableType type,
    required int projectId,
    required int iid,
  }) async => throw StateError('MRs must read grouped discussions');
}

class _Analytics implements Analytics {
  final events = <String>[];
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async =>
      events.add(name);
}

final _session = StateProvider<Future<CommentsRepository?>>(
  (ref) async => null,
);
ProviderContainer _container(_Repository repo, _Analytics analytics) {
  final container = ProviderContainer(
    overrides: [
      _session.overrideWith((ref) async => repo),
      commentsRepositoryProvider.overrideWith((ref) => ref.watch(_session)),
      analyticsProvider.overrideWithValue(analytics),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(repo.client.close);
  return container;
}

Future<AppLocalizations> _pump(
  WidgetTester tester,
  _Repository repo, {
  double width = 390,
  bool dark = false,
  Locale locale = const Locale('en'),
  bool settle = true,
  ProviderContainer? container,
  ThemeData? theme,
  int iid = 142,
}) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final scope = container ?? _container(repo, _Analytics());
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
        theme: theme ?? (dark ? LabFoxTheme.dark : LabFoxTheme.light),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MrDiscussionThread(projectId: 8, iid: iid),
            ),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  return AppLocalizations.of(tester.element(find.byType(MrDiscussionThread)));
}

Finder get _replyComposer => find.byKey(const ValueKey('mr-reply-composer'));
Finder get _replyField =>
    find.descendant(of: _replyComposer, matching: find.byType(TextField));
Finder get _replySubmit =>
    find.descendant(of: _replyComposer, matching: find.byType(FilledButton));
Future<void> _open(WidgetTester tester, String id) async {
  final button = find.byKey(ValueKey('mr-discussion-reply-$id'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester, {bool settle = true}) async {
  await tester.ensureVisible(_replySubmit);
  await tester.tap(_replySubmit);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  test(
    'repository forwards selected thread, IID and exact body to the API',
    () async {
      late RequestOptions request;
      final dio = Dio()..httpClientAdapter = _Adapter((r) => request = r);
      final client = GitLabClient(
        baseUrl: 'https://gitlab.example.com',
        token: 'glpat-xxxxxxxxxxxx',
        dio: dio,
      );
      addTearDown(client.close);
      final repo = CommentsRepository(client);
      const body = '  **Reply**\n  ';
      final note = await repo.replyToDiscussion(
        projectId: 8,
        iid: 142,
        discussionId: 'thread/1',
        body: body,
      );
      expect(
        request.path,
        '/projects/8/merge_requests/142/discussions/thread%2F1/notes',
      );
      expect(request.method, 'POST');
      expect(request.data, {'body': body});
      expect(note.id, 999);
    },
  );
  testWidgets('single user comment supports reply without flat-note posting', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = const Paginated(
        items: [
          Discussion(
            id: 'single',
            individualNote: true,
            notes: [Note(id: 1, body: 'Single comment')],
          ),
        ],
      );
    await _pump(tester, repo);
    await _open(tester, 'single');
    await tester.enterText(_replyField, 'Reply');
    await _submit(tester);
    expect(repo.replies, [(8, 142, 'single', 'Reply')]);
    expect(repo.posts, isEmpty);
  });

  testWidgets('pending top-level write disables reply selection', (
    tester,
  ) async {
    final gate = Completer<Note>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..postResult = gate.future;
    final l10n = await _pump(tester, repo);
    await tester.enterText(find.byType(TextField), 'Top-level');
    final submit = find.widgetWithText(
      FilledButton,
      l10n.commentComposerSubmit,
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-discussion-reply-a')),
          )
          .onPressed,
      isNull,
    );
    gate.complete(const Note(id: 999, body: 'Top-level'));
    await tester.pumpAndSettle();
  });
  testWidgets('removed reply target restores top-level submission', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')], nextPage: 2)
      ..pages[2] = const Paginated(
        items: [
          Discussion(
            id: 'a',
            individualNote: true,
            notes: [Note(id: 1, body: 'Event', isSystem: true)],
          ),
        ],
      );
    await _pump(tester, repo);
    await _open(tester, 'a');
    final more = find.byKey(const ValueKey('mr-discussions-more'));
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(_replyComposer, findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  test(
    'reply shares reservations with top-level writes and pagination',
    () async {
      final gate = Completer<Note>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a')], nextPage: 2)
        ..replyResult = gate.future;
      final analytics = _Analytics();
      final c = _container(repo, analytics);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
      const body = '  **Reply**\n\nKeep spaces.  ';
      final pending = n.reply(discussionId: 'a', body: body);
      await Future<void>.delayed(Duration.zero);
      expect(await n.reply(discussionId: 'a', body: 'duplicate'), false);
      expect(await n.post('top-level'), false);
      await n.loadMore();
      expect(repo.reads.length, 1);
      expect(repo.posts, isEmpty);
      gate.complete(const Note(id: 999, body: body));
      expect(await pending, true);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(repo.replies, [(8, 142, 'a', body)]);
      expect(repo.reads.length, 2);
      expect(analytics.events, ['comment_posted']);
    },
  );
  test('pending top-level post prevents thread reply', () async {
    final gate = Completer<Note>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..postResult = gate.future;
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
    final pending = n.post('Top-level');
    await Future<void>.delayed(Duration.zero);
    expect(await n.reply(discussionId: 'a', body: 'Reply'), false);
    expect(repo.replies, isEmpty);
    gate.complete(const Note(id: 999, body: 'Top-level'));
    expect(await pending, true);
  });
  for (final id in ['', 'missing']) {
    test('unloaded discussion cannot receive a reply: $id', () async {
      final repo = _Repository()..pages[1] = Paginated(items: [_thread('a')]);
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(
        await c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .reply(discussionId: id, body: 'Reply'),
        false,
      );
      expect(repo.replies, isEmpty);
    });
  }
  test('blank reply and system-only discussion are rejected', () async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _thread('a'),
          const Discussion(
            id: 'system',
            individualNote: true,
            notes: [Note(id: 1, body: 'Event', isSystem: true)],
          ),
        ],
      );
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
    expect(await n.reply(discussionId: 'a', body: ' \n\t'), false);
    expect(await n.reply(discussionId: 'system', body: 'Reply'), false);
    expect(repo.replies, isEmpty);
  });
  for (final failed in [false, true]) {
    test(
      'account replacement isolates reply completion failed=$failed',
      () async {
        final gate = Completer<Note>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: [_thread('a')])
          ..replyResult = gate.future;
        final other = _Repository()
          ..pages[1] = Paginated(items: [_thread('b')]);
        addTearDown(other.client.close);
        final events = _Analytics();
        final c = _container(repo, events);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        final pending = c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .reply(discussionId: 'a', body: 'Old');
        await Future<void>.delayed(Duration.zero);
        c.read(_session.notifier).state = Future.value(other);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        if (failed) {
          gate.completeError(
            const GitLabForbiddenException('private-content-marker'),
          );
        } else {
          gate.complete(const Note(id: 999, body: 'Old'));
        }
        expect(await pending, false);
        expect(events.events, isEmpty);
        expect(other.reads.length, 1);
        expect(other.replies, isEmpty);
      },
    );
    testWidgets('new-account draft survives late reply failed=$failed', (
      tester,
    ) async {
      final gate = Completer<Note>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a')])
        ..replyResult = gate.future;
      final other = _Repository()..pages[1] = Paginated(items: [_thread('a')]);
      addTearDown(other.client.close);
      final c = _container(repo, _Analytics());
      await _pump(tester, repo, container: c);
      await _open(tester, 'a');
      await tester.enterText(_replyField, 'Old reply');
      await _submit(tester, settle: false);
      c.read(_session.notifier).state = Future.value(other);
      await tester.pumpAndSettle();
      expect(_replyComposer, findsNothing);
      await _open(tester, 'a');
      await tester.enterText(_replyField, 'New reply');
      if (failed) {
        gate.completeError(
          const GitLabForbiddenException('private-content-marker'),
        );
      } else {
        gate.complete(const Note(id: 999, body: 'Old'));
      }
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_replyField).controller!.text,
        'New reply',
      );
      expect(find.textContaining('private-content-marker'), findsNothing);
      expect(other.reads.length, 1);
      expect(tester.takeException(), isNull);
    });
  }
  test('logout before dispatch cancels reply', () async {
    final repo = _Repository()..pages[1] = Paginated(items: [_thread('a')]);
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
    c.read(_session.notifier).state = Future.value(null);
    expect(await n.reply(discussionId: 'a', body: 'Old'), false);
    expect(repo.replies, isEmpty);
  });
  test('disposed controller cancels late reply error', () async {
    final gate = Completer<Note>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..replyResult = gate.future;
    final events = _Analytics();
    final c = _container(repo, events);
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final pending = c
        .read(mrDiscussionsControllerProvider(_key).notifier)
        .reply(discussionId: 'a', body: 'Reply');
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    gate.completeError(const GitLabServerException('private-content-marker'));
    expect(await pending, false);
    expect(events.events, isEmpty);
  });
  testWidgets('failed reply retains draft and reservation releases for retry', (
    tester,
  ) async {
    final gate = Completer<Note>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..replyResult = gate.future;
    final l10n = await _pump(tester, repo);
    await _open(tester, 'a');
    await tester.enterText(_replyField, 'Reply');
    await _submit(tester, settle: false);
    gate.completeError(
      const GitLabForbiddenException('private-content-marker'),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(_replyField).controller!.text, 'Reply');
    expect(find.text(l10n.commentPostForbidden), findsOneWidget);
    expect(find.textContaining('private-content-marker'), findsNothing);
    repo.replyResult = null;
    await _submit(tester);
    expect(repo.replies, [(8, 142, 'a', 'Reply'), (8, 142, 'a', 'Reply')]);
    expect(_replyComposer, findsNothing);
  });
  testWidgets(
    'reply cancellation preserves top-level draft and does not dispatch',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a'), _thread('b')]);
      await _pump(tester, repo);
      await tester.enterText(find.byType(TextField), 'Top-level draft');
      await _open(tester, 'a');
      await tester.enterText(_replyField, 'Unsent reply');
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('mr-discussion-reply-b')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
        isNull,
      );
      final cancel = find.byKey(const ValueKey('mr-reply-cancel'));
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(_replyComposer, findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Top-level draft',
      );
      expect(repo.replies, isEmpty);
    },
  );
  testWidgets(
    'resize and pagination preserve selected reply and top-level drafts',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a')], nextPage: 2)
        ..pages[2] = Paginated(items: [_thread('b')]);
      await _pump(tester, repo);
      await tester.enterText(find.byType(TextField), 'Top draft');
      await _open(tester, 'a');
      await tester.enterText(_replyField, 'Reply draft');
      tester.view.physicalSize = const Size(1200, 1400);
      await tester.pumpAndSettle();
      final more = find.byKey(const ValueKey('mr-discussions-more'));
      await tester.ensureVisible(more);
      await tester.tap(more);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_replyField).controller!.text,
        'Reply draft',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'Top draft',
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('MR replacement resets target and isolates late reply', (
    tester,
  ) async {
    final gate = Completer<Note>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..replyResult = gate.future;
    final c = _container(repo, _Analytics());
    await _pump(tester, repo, container: c);
    await _open(tester, 'a');
    await tester.enterText(_replyField, 'Old');
    await _submit(tester, settle: false);
    await _pump(tester, repo, container: c, iid: 143);
    expect(_replyComposer, findsNothing);
    await _open(tester, 'a');
    await tester.enterText(_replyField, 'New');
    gate.complete(const Note(id: 999, body: 'Old'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(_replyField).controller!.text, 'New');
    expect(repo.reads.where((r) => r.$2 == 143).length, 1);
    expect(tester.takeException(), isNull);
  });
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('thread replies $locale $width dark=$dark', (tester) async {
          final gate = Completer<Note>();
          final repo = _Repository()
            ..pages[1] = Paginated(items: [_thread('a')])
            ..replyResult = gate.future;
          final l10n = await _pump(
            tester,
            repo,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          await tester.enterText(find.byType(TextField), 'Top-level draft');
          await _open(tester, 'a');
          expect(find.text(l10n.mrDiscussionReplyTitle), findsOneWidget);
          expect(
            tester.widget<TextField>(_replyField).decoration!.hintText,
            l10n.mrDiscussionReplyHint,
          );
          const body = '  **Reply**\n\nPreserve Markdown.  ';
          await tester.enterText(_replyField, body);
          await _submit(tester, settle: false);
          expect(tester.widget<TextField>(_replyField).enabled, false);
          expect(
            tester
                .widget<TextButton>(
                  find.byKey(const ValueKey('mr-reply-cancel')),
                )
                .onPressed,
            isNull,
          );
          repo.pages[1] = Paginated(
            items: [_thread('a', body: 'Updated by server')],
          );
          gate.complete(const Note(id: 999, body: body));
          await tester.pumpAndSettle();
          expect(repo.replies, [(8, 142, 'a', body)]);
          expect(repo.posts, isEmpty);
          expect(repo.reads.length, 2);
          expect(_replyComposer, findsNothing);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Top-level draft',
          );
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is MarkdownViewer &&
                  widget.data == 'Updated by server',
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.onRequest);
  final void Function(RequestOptions) onRequest;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest(options);
    return ResponseBody.fromString(
      json.encode({'id': 999, 'body': 'Reply'}),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
