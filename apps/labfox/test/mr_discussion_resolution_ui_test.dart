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
  Future<Discussion>? resolutionResult;
  final resolutions = <(int, int, String, bool)>[];
  @override
  Future<Discussion> setDiscussionResolved({
    required int projectId,
    required int iid,
    required String discussionId,
    required bool resolved,
  }) async {
    resolutions.add((projectId, iid, discussionId, resolved));
    return resolutionResult ?? _thread(discussionId, resolved: resolved);
  }

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
Future<void> _open(WidgetTester tester, String id) async {
  final button = find.byKey(ValueKey('mr-discussion-reply-$id'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _resolve(
  WidgetTester tester,
  String id, {
  bool settle = true,
}) async {
  final button = find.byKey(ValueKey('mr-discussion-resolution-$id'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  for (final resolved in [false, true]) {
    test(
      'repository forwards resolution $resolved to the correct thread',
      () async {
        late RequestOptions request;
        final dio = Dio()
          ..httpClientAdapter = _Adapter((r) => request = r, resolved);
        final client = GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
          dio: dio,
        );
        addTearDown(client.close);
        final result = await CommentsRepository(client).setDiscussionResolved(
          projectId: 8,
          iid: 142,
          discussionId: 'thread/1',
          resolved: resolved,
        );
        expect(
          request.path,
          '/projects/8/merge_requests/142/discussions/thread%2F1',
        );
        expect(request.method, 'PUT');
        expect(request.data, {'resolved': resolved});
        expect(result.notes.single.resolved, resolved);
      },
    );
  }
  for (final error in [
    const GitLabAuthException('private-content-marker'),
    const GitLabServerException('private-content-marker'),
    const GitLabNotFoundException('private-content-marker'),
    const GitLabRateLimitException('private-content-marker'),
  ]) {
    testWidgets(
      'typed resolution failure retains draft: ${error.runtimeType}',
      (tester) async {
        final gate = Completer<Discussion>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: [_thread('a')])
          ..resolutionResult = gate.future;
        final l10n = await _pump(tester, repo);
        await tester.enterText(find.byType(TextField), 'Draft');
        await _resolve(tester, 'a', settle: false);
        gate.completeError(error);
        await tester.pumpAndSettle();
        expect(
          find.text(
            error is GitLabAuthException
                ? l10n.mrDiscussionResolveForbidden
                : l10n.mrDiscussionResolveError,
          ),
          findsOneWidget,
        );
        expect(find.textContaining('private-content-marker'), findsNothing);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Draft',
        );
        expect(repo.reads.length, 1);
      },
    );
  }

  test(
    'resolution shares write reservation with replies, notes and paging',
    () async {
      final gate = Completer<Discussion>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a')], nextPage: 2)
        ..resolutionResult = gate.future;
      final events = _Analytics();
      final c = _container(repo, events);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
      final pending = n.setResolved(discussionId: 'a', resolved: true);
      await Future<void>.delayed(Duration.zero);
      expect(await n.setResolved(discussionId: 'a', resolved: true), false);
      expect(await n.reply(discussionId: 'a', body: 'Reply'), false);
      expect(await n.post('Top'), false);
      await n.loadMore();
      gate.complete(_thread('a', resolved: true));
      expect(await pending, true);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(repo.resolutions, [(8, 142, 'a', true)]);
      expect(repo.reads.length, 2);
      expect(repo.posts, isEmpty);
      expect(repo.replies, isEmpty);
      expect(events.events, isEmpty);
    },
  );
  test('pending reply prevents resolution', () async {
    final gate = Completer<Note>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..replyResult = gate.future;
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
    final pending = n.reply(discussionId: 'a', body: 'Reply');
    await Future<void>.delayed(Duration.zero);
    expect(await n.setResolved(discussionId: 'a', resolved: true), false);
    expect(repo.resolutions, isEmpty);
    gate.complete(const Note(id: 999, body: 'Reply'));
    expect(await pending, true);
  });
  for (final id in ['', 'missing']) {
    test('unknown thread resolution rejected $id', () async {
      final repo = _Repository()..pages[1] = Paginated(items: [_thread('a')]);
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(
        await c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .setResolved(discussionId: id, resolved: true),
        false,
      );
      expect(repo.resolutions, isEmpty);
    });
  }
  for (final current in [false, true, null]) {
    test('stale or unknown state does not dispatch current=$current', () async {
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a', resolved: current)]);
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(
        await c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .setResolved(discussionId: 'a', resolved: current ?? true),
        false,
      );
      expect(repo.resolutions, isEmpty);
    });
  }
  for (final failed in [false, true]) {
    test('account replacement isolates resolution failed=$failed', () async {
      final gate = Completer<Discussion>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a')])
        ..resolutionResult = gate.future;
      final other = _Repository()..pages[1] = Paginated(items: [_thread('b')]);
      addTearDown(other.client.close);
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final pending = c
          .read(mrDiscussionsControllerProvider(_key).notifier)
          .setResolved(discussionId: 'a', resolved: true);
      await Future<void>.delayed(Duration.zero);
      c.read(_session.notifier).state = Future.value(other);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      if (failed) {
        gate.completeError(
          const GitLabForbiddenException('private-content-marker'),
        );
      } else {
        gate.complete(_thread('a', resolved: true));
      }
      expect(await pending, false);
      expect(other.reads.length, 1);
      expect(other.resolutions, isEmpty);
    });
    testWidgets(
      'replacement account draft survives late resolution failed=$failed',
      (tester) async {
        final gate = Completer<Discussion>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: [_thread('a')])
          ..resolutionResult = gate.future;
        final other = _Repository()
          ..pages[1] = Paginated(items: [_thread('a')]);
        addTearDown(other.client.close);
        final c = _container(repo, _Analytics());
        await _pump(tester, repo, container: c);
        await _resolve(tester, 'a', settle: false);
        c.read(_session.notifier).state = Future.value(other);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'New draft');
        if (failed) {
          gate.completeError(
            const GitLabForbiddenException('private-content-marker'),
          );
        } else {
          gate.complete(_thread('a', resolved: true));
        }
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'New draft',
        );
        expect(find.textContaining('private-content-marker'), findsNothing);
        expect(other.reads.length, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
  test('logout before dispatch prevents old-session resolution', () async {
    final repo = _Repository()..pages[1] = Paginated(items: [_thread('a')]);
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
    c.read(_session.notifier).state = Future.value(null);
    expect(await n.setResolved(discussionId: 'a', resolved: true), false);
    expect(repo.resolutions, isEmpty);
  });
  test('controller disposal ignores late resolution error', () async {
    final gate = Completer<Discussion>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..resolutionResult = gate.future;
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final pending = c
        .read(mrDiscussionsControllerProvider(_key).notifier)
        .setResolved(discussionId: 'a', resolved: true);
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    gate.completeError(const GitLabServerException('private-content-marker'));
    expect(await pending, false);
  });
  testWidgets('resolution failure retains current state and draft for retry', (
    tester,
  ) async {
    final gate = Completer<Discussion>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..resolutionResult = gate.future;
    final l10n = await _pump(tester, repo);
    await tester.enterText(find.byType(TextField), 'Top draft');
    await _resolve(tester, 'a', settle: false);
    gate.completeError(
      const GitLabForbiddenException('private-content-marker'),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.mrDiscussionResolveForbidden), findsOneWidget);
    expect(find.text(l10n.mrDiscussionUnresolved), findsOneWidget);
    expect(repo.reads.length, 1);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Top draft',
    );
    repo.resolutionResult = null;
    repo.pages[1] = Paginated(items: [_thread('a', resolved: true)]);
    await _resolve(tester, 'a');
    expect(repo.resolutions, [(8, 142, 'a', true), (8, 142, 'a', true)]);
    expect(find.text(l10n.mrDiscussionResolveForbidden), findsNothing);
  });
  testWidgets('active reply draft disables resolution and cancel restores it', (
    tester,
  ) async {
    final repo = _Repository()..pages[1] = Paginated(items: [_thread('a')]);
    await _pump(tester, repo);
    await _open(tester, 'a');
    await tester.enterText(_replyField, 'Unsent');
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-discussion-resolution-a')),
          )
          .onPressed,
      isNull,
    );
    final cancel = find.byKey(const ValueKey('mr-reply-cancel'));
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-discussion-resolution-a')),
          )
          .onPressed,
      isNotNull,
    );
    expect(repo.resolutions, isEmpty);
  });
  testWidgets(
    'unknown and nonresolvable discussions have no resolution action',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _thread('a', resolved: null),
            const Discussion(
              id: 'b',
              individualNote: true,
              notes: [Note(id: 1, body: 'Single')],
            ),
          ],
        );
      await _pump(tester, repo);
      expect(
        find.byKey(const ValueKey('mr-discussion-resolution-a')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('mr-discussion-resolution-b')),
        findsNothing,
      );
      expect(repo.resolutions, isEmpty);
    },
  );
  testWidgets('MR replacement keeps new draft after old resolution error', (
    tester,
  ) async {
    final gate = Completer<Discussion>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a')])
      ..resolutionResult = gate.future;
    final c = _container(repo, _Analytics());
    await _pump(tester, repo, container: c);
    await _resolve(tester, 'a', settle: false);
    await _pump(tester, repo, container: c, iid: 143);
    await tester.enterText(find.byType(TextField), 'New draft');
    gate.completeError(const GitLabServerException('private-content-marker'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'New draft',
    );
    expect(find.textContaining('private-content-marker'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('resolve and reopen $locale $width dark=$dark', (
          tester,
        ) async {
          final gate = Completer<Discussion>();
          final repo = _Repository()
            ..pages[1] = Paginated(items: [_thread('a')])
            ..resolutionResult = gate.future;
          final l10n = await _pump(
            tester,
            repo,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          await tester.enterText(find.byType(TextField), 'Top draft');
          expect(find.text(l10n.mrDiscussionResolveButton), findsOneWidget);
          await _resolve(tester, 'a', settle: false);
          expect(
            tester
                .widget<TextButton>(
                  find.byKey(const ValueKey('mr-discussion-reply-a')),
                )
                .onPressed,
            isNull,
          );
          expect(
            tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
            isNull,
          );
          repo.pages[1] = Paginated(items: [_thread('a', resolved: true)]);
          gate.complete(_thread('a', resolved: true));
          await tester.pumpAndSettle();
          expect(find.text(l10n.mrDiscussionReopenButton), findsOneWidget);
          repo.resolutionResult = null;
          repo.pages[1] = Paginated(items: [_thread('a')]);
          await _resolve(tester, 'a');
          expect(repo.resolutions, [(8, 142, 'a', true), (8, 142, 'a', false)]);
          expect(repo.reads.length, 3);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Top draft',
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.onRequest, this.resolved);
  final void Function(RequestOptions) onRequest;
  final bool resolved;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest(options);
    return ResponseBody.fromString(
      json.encode({
        'id': 'thread/1',
        'individual_note': false,
        'notes': [
          {
            'id': 301,
            'body': 'Review',
            'resolvable': true,
            'resolved': resolved,
          },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
