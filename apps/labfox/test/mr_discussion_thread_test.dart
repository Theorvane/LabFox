import 'dart:async';
import 'package:design_system/design_system.dart';
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

void main() {
  test(
    'loads one page, replaces overlapping groups and retains cursor on failure',
    () async {
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_thread('a')], nextPage: 2);
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      repo.pages[2] = const GitLabServerException('private-content-marker');
      final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
      await expectLater(n.loadMore(), throwsA(isA<GitLabServerException>()));
      expect(c.read(mrDiscussionsControllerProvider(_key)).value!.nextPage, 2);
      repo.pages[2] = Paginated(
        items: [
          _thread('a', body: 'Updated'),
          _thread('b'),
        ],
      );
      await n.loadMore();
      final value = c.read(mrDiscussionsControllerProvider(_key)).value!;
      expect(value.items.map((d) => d.id), ['a', 'b']);
      expect(value.items.first.notes.first.body, 'Updated');
      expect(value.nextPage, isNull);
      expect(repo.reads, [(8, 142, 1), (8, 142, 2), (8, 142, 2)]);
    },
  );
  test('duplicate pagination requests dispatch once', () async {
    final gate = Completer<Paginated<Discussion>>();
    final repo = _Repository()
      ..pages[1] = const Paginated<Discussion>(items: [], nextPage: 2)
      ..pages[2] = gate.future;
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
    final first = n.loadMore();
    await Future<void>.delayed(Duration.zero);
    await n.loadMore();
    expect(repo.reads.where((r) => r.$3 == 2).length, 1);
    gate.complete(const Paginated<Discussion>(items: [], nextPage: 3));
    await first;
    expect(c.read(mrDiscussionsControllerProvider(_key)).value!.nextPage, 3);
  });
  for (final error in [false, true]) {
    test(
      'late pagination completion is isolated after account replacement error=$error',
      () async {
        final gate = Completer<Paginated<Discussion>>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: [_thread('old')], nextPage: 2)
          ..pages[2] = gate.future;
        final other = _Repository()
          ..pages[1] = Paginated(items: [_thread('new')]);
        addTearDown(other.client.close);
        final c = _container(repo, _Analytics());
        await c.read(mrDiscussionsControllerProvider(_key).future);
        final pending = c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .loadMore();
        await Future<void>.delayed(Duration.zero);
        c.read(_session.notifier).state = Future.value(other);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        if (error) {
          gate.completeError(const GitLabServerException('old'));
        } else {
          gate.complete(Paginated(items: [_thread('late')]));
        }
        await pending;
        expect(
          c.read(mrDiscussionsControllerProvider(_key)).value!.items.single.id,
          'new',
        );
      },
    );
    test(
      'late post completion has no refresh or analytics effects error=$error',
      () async {
        final gate = Completer<Note>();
        final repo = _Repository()..postResult = gate.future;
        final other = _Repository();
        addTearDown(other.client.close);
        final events = _Analytics();
        final c = _container(repo, events);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        final pending = c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .post('Old draft');
        await Future<void>.delayed(Duration.zero);
        c.read(_session.notifier).state = Future.value(other);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        if (error) {
          gate.completeError(const GitLabForbiddenException('old'));
        } else {
          gate.complete(const Note(id: 999, body: 'Old'));
        }
        expect(await pending, false);
        expect(events.events, isEmpty);
        expect(other.reads.length, 1);
      },
    );
  }
  test(
    'duplicate posts dispatch once and refresh grouped feed after success',
    () async {
      final gate = Completer<Note>();
      final repo = _Repository()..postResult = gate.future;
      final events = _Analytics();
      final c = _container(repo, events);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
      final pending = n.post('Draft');
      await Future<void>.delayed(Duration.zero);
      expect(await n.post('Duplicate'), false);
      gate.complete(const Note(id: 999, body: 'Draft'));
      expect(await pending, true);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(repo.posts, ['Draft']);
      expect(events.events, ['comment_posted']);
      expect(repo.reads.length, 2);
    },
  );
  test('disposed controller ignores late post failure and analytics', () async {
    final gate = Completer<Note>();
    final repo = _Repository()..postResult = gate.future;
    final events = _Analytics();
    final c = _container(repo, events);
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final pending = c
        .read(mrDiscussionsControllerProvider(_key).notifier)
        .post('Draft');
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    gate.completeError(const GitLabForbiddenException('old'));
    expect(await pending, false);
    expect(events.events, isEmpty);
  });
  test(
    'logout before dispatch does not post through a previous repository',
    () async {
      final repo = _Repository();
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final n = c.read(mrDiscussionsControllerProvider(_key).notifier);
      c.read(_session.notifier).state = Future.value(null);
      expect(await n.post('Draft'), false);
      expect(repo.posts, isEmpty);
    },
  );
  testWidgets(
    'initial read loading disables submit without showing an empty state',
    (tester) async {
      final gate = Completer<Paginated<Discussion>>();
      final repo = _Repository()..pages[1] = gate.future;
      final l10n = await _pump(tester, repo, settle: false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.commentsEmpty), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      gate.complete(const Paginated<Discussion>(items: []));
      await tester.pumpAndSettle();
      expect(find.text(l10n.commentsEmpty), findsOneWidget);
    },
  );
  testWidgets('unknown resolution is not presented as unresolved', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_thread('a', resolved: null)]);
    final l10n = await _pump(tester, repo);
    expect(find.text(l10n.mrDiscussionUnresolved), findsNothing);
    expect(find.text(l10n.mrDiscussionResolved), findsNothing);
  });
  testWidgets('system root is hidden while a user reply remains visible', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = const Paginated<Discussion>(
        items: [
          Discussion(
            id: 'a',
            individualNote: false,
            notes: [
              Note(id: 1, body: 'System root', isSystem: true),
              Note(id: 2, body: 'User reply'),
            ],
          ),
        ],
      );
    await _pump(tester, repo);
    expect(
      tester
          .widgetList<MarkdownViewer>(find.byType(MarkdownViewer))
          .map((v) => v.data),
      ['User reply'],
    );
  });
  testWidgets('resizing preserves the draft and loaded discussions', (
    tester,
  ) async {
    final repo = _Repository()..pages[1] = Paginated(items: [_thread('a')]);
    await _pump(tester, repo, width: 320);
    await tester.enterText(find.byType(TextField), 'Preserved draft');
    tester.view.physicalSize = const Size(1200, 1400);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Preserved draft',
    );
    expect(repo.reads.length, 1);
    expect(find.byKey(const ValueKey('mr-discussion-a')), findsOneWidget);
  });
  testWidgets(
    'long author and localized time do not overflow at narrow width',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            Discussion(
              id: 'a',
              individualNote: false,
              notes: [
                Note(
                  id: 1,
                  body: 'Review',
                  author: User(
                    id: 7,
                    username: 'reviewer' * 20,
                    name: 'Reviewer',
                  ),
                  createdAt: DateTime.utc(2026, 10, 4),
                ),
              ],
            ),
          ],
        );
      await _pump(tester, repo, width: 320, locale: const Locale('hi'));
      expect(tester.takeException(), isNull);
    },
  );
  for (final error in [false, true]) {
    testWidgets(
      'replaced account ignores a late composer result error=$error',
      (tester) async {
        final gate = Completer<Note>();
        final repo = _Repository()..postResult = gate.future;
        final other = _Repository()
          ..pages[1] = Paginated(items: [_thread('new')]);
        addTearDown(other.client.close);
        final c = _container(repo, _Analytics());
        final l10n = await _pump(tester, repo, container: c);
        await tester.enterText(find.byType(TextField), 'Old draft');
        await tester.tap(
          find.widgetWithText(FilledButton, l10n.commentComposerSubmit),
        );
        await tester.pump();
        c.read(_session.notifier).state = Future.value(other);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'New draft');
        if (error) {
          gate.completeError(const GitLabForbiddenException('old'));
        } else {
          gate.complete(const Note(id: 999, body: 'Old'));
        }
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'New draft',
        );
        expect(find.text(l10n.commentPostForbidden), findsNothing);
        expect(other.reads.length, 1);
      },
    );
  }
  testWidgets('forbidden post retains draft for an explicit retry', (
    tester,
  ) async {
    final gate = Completer<Note>();
    final repo = _Repository()..postResult = gate.future;
    final l10n = await _pump(tester, repo);
    await tester.enterText(find.byType(TextField), 'Draft');
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.commentComposerSubmit),
    );
    await tester.pump();
    gate.completeError(
      const GitLabForbiddenException('private-content-marker'),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Draft',
    );
    expect(find.text(l10n.commentPostForbidden), findsOneWidget);
    expect(find.textContaining('private-content-marker'), findsNothing);
    repo.postResult = null;
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.commentComposerSubmit),
    );
    await tester.pumpAndSettle();
    expect(repo.posts, ['Draft', 'Draft']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });
  for (final error in [false, true]) {
    testWidgets('account replacement ignores late initial read error=$error', (
      tester,
    ) async {
      final gate = Completer<Paginated<Discussion>>();
      final repo = _Repository()..pages[1] = gate.future;
      final other = _Repository()
        ..pages[1] = Paginated(items: [_thread('new')]);
      addTearDown(other.client.close);
      final c = _container(repo, _Analytics());
      await _pump(tester, repo, container: c, settle: false);
      c.read(_session.notifier).state = Future.value(other);
      await tester.pumpAndSettle();
      if (error) {
        gate.completeError(const GitLabServerException('old'));
      } else {
        gate.complete(Paginated(items: [_thread('old')]));
      }
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('mr-discussion-new')), findsOneWidget);
      expect(find.byKey(const ValueKey('mr-discussion-old')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'switching MR resources preserves the new draft after old post completion',
    (tester) async {
      final gate = Completer<Note>();
      final repo = _Repository()..postResult = gate.future;
      final c = _container(repo, _Analytics());
      final l10n = await _pump(tester, repo, container: c);
      await tester.enterText(find.byType(TextField), 'Old MR draft');
      await tester.tap(
        find.widgetWithText(FilledButton, l10n.commentComposerSubmit),
      );
      await tester.pump();
      await _pump(tester, repo, container: c, iid: 143);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), 'New MR draft');
      gate.complete(const Note(id: 999, body: 'Posted'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'New MR draft',
      );
      expect(repo.reads.where((r) => r.$2 == 143).length, 1);
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('grouped MR conversations $locale $width dark=$dark', (
          tester,
        ) async {
          final repo = _Repository()
            ..pages[1] = Paginated(
              items: [
                _thread('a'),
                _thread('b', body: 'Resolved comment', resolved: true),
              ],
              nextPage: 2,
            )
            ..pages[2] = const Paginated<Discussion>(items: []);
          final l10n = await _pump(
            tester,
            repo,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          expect(find.byKey(const ValueKey('mr-discussion-a')), findsOneWidget);
          expect(find.byKey(const ValueKey('mr-discussion-b')), findsOneWidget);
          expect(find.text(l10n.mrDiscussionResolved), findsOneWidget);
          expect(find.text(l10n.mrDiscussionUnresolved), findsOneWidget);
          expect(
            tester
                .widgetList<MarkdownViewer>(find.byType(MarkdownViewer))
                .map((v) => v.data),
            [
              'Review comment',
              'Review reply',
              'Resolved comment',
              'Review reply',
            ],
          );
          await tester.tap(find.byKey(const ValueKey('mr-discussions-more')));
          await tester.pumpAndSettle();
          expect(repo.reads, [(8, 142, 1), (8, 142, 2)]);
          await tester.enterText(find.byType(TextField), 'Top-level comment');
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.commentComposerSubmit),
          );
          await tester.pumpAndSettle();
          expect(repo.posts, ['Top-level comment']);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            isEmpty,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'read retry and page retry retain comments and exclude server details',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = const GitLabServerException('private-content-marker');
      final l10n = await _pump(tester, repo);
      expect(find.text(l10n.commentsError), findsOneWidget);
      repo.pages[1] = Paginated(items: [_thread('a')], nextPage: 2);
      await tester.tap(find.byKey(const ValueKey('mr-discussions-retry')));
      await tester.pumpAndSettle();
      repo.pages[2] = const GitLabServerException('private-content-marker');
      await tester.tap(find.byKey(const ValueKey('mr-discussions-more')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.mrDiscussionsMoreError), findsOneWidget);
      expect(find.byKey(const ValueKey('mr-discussion-a')), findsOneWidget);
      expect(find.textContaining('private-content-marker'), findsNothing);
      repo.pages[2] = Paginated(items: [_thread('b')]);
      await tester.tap(find.byKey(const ValueKey('mr-discussions-more')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('mr-discussion-b')), findsOneWidget);
    },
  );
  testWidgets(
    'system-only partial pages show pagination, not final empty state',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = const Paginated(
          items: [
            Discussion(
              id: 'system',
              individualNote: true,
              notes: [Note(id: 1, body: 'System event', isSystem: true)],
            ),
          ],
          nextPage: 2,
        );
      final l10n = await _pump(tester, repo);
      expect(find.text(l10n.commentsEmpty), findsNothing);
      expect(find.text(l10n.mrDiscussionsPartial), findsOneWidget);
      expect(find.byType(MarkdownViewer), findsNothing);
    },
  );
}
