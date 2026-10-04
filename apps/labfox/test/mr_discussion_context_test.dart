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
import 'package:labfox/features/diff/data/diff_repository.dart';
import 'package:labfox/features/diff/presentation/controllers/diff_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussion_context_controller.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_discussion_thread.dart';
import 'package:labfox/l10n/app_localizations.dart';

final _diffSession = StateProvider<Future<DiffRepository?>>(
  (ref) async => null,
);

Discussion _thread(
  String id, {
  String body = 'Review comment',
  bool? resolved = false,
  DiffNotePosition? position,
}) => Discussion(
  id: id,
  individualNote: false,
  notes: [
    Note(
      id: 301,
      body: body,
      position: position,
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
ProviderContainer _container(
  _Repository repo,
  _Analytics analytics, {
  _DiffRepository? diff,
}) {
  final diffRepo = diff ?? _DiffRepository();
  addTearDown(diffRepo.client.close);
  final container = ProviderContainer(
    overrides: [
      _session.overrideWith((ref) async => repo),
      commentsRepositoryProvider.overrideWith((ref) => ref.watch(_session)),
      analyticsProvider.overrideWithValue(analytics),
      _diffSession.overrideWith((ref) async => diffRepo),
      diffRepositoryProvider.overrideWith((ref) => ref.watch(_diffSession)),
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

DiffNotePosition _position({
  String type = 'text',
  int? oldLine = 27,
  int? newLine = 29,
  DiffNoteLineRange? range,
}) => DiffNotePosition(
  baseSha: 'base',
  startSha: 'start',
  headSha: 'original',
  oldPath: 'old.dart',
  newPath: 'new.dart',
  positionType: type,
  oldLine: oldLine,
  newLine: newLine,
  lineRange: range,
);
MergeRequestVersionFile _file({
  bool tooLarge = false,
  String? diff = '@@ -27,2 +29,2 @@\n context line\n-old line\n+new line\n',
}) => MergeRequestVersionFile(
  oldPath: 'old.dart',
  newPath: 'new.dart',
  isNew: false,
  isDeleted: false,
  isRenamed: true,
  isCollapsed: false,
  isTooLarge: tooLarge,
  diff: diff,
);
MergeRequestDiffVersion _version({
  int id = 110,
  String head = 'original',
  List<MergeRequestVersionFile>? files,
}) => MergeRequestDiffVersion(
  id: id,
  baseCommitSha: 'base',
  startCommitSha: 'start',
  headCommitSha: head,
  state: 'collected',
  files: files,
);
MrDiscussionContextRef _arg([DiffNotePosition? position]) =>
    MrDiscussionContextRef(
      projectId: 8,
      iid: 142,
      position: position ?? _position(),
    );

class _DiffRepository extends DiffRepository {
  _DiffRepository()
    : this._(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  _DiffRepository._(this.client) : super(client);
  final GitLabClient client;
  final pages = <int, Object>{
    1: Paginated<MergeRequestDiffVersion>(items: [_version()]),
  };
  final details = <int, Object>{
    110: _version(files: [_file()]),
  };
  final reads = <(int, int, int)>[];
  final snapshots = <(int, int, int)>[];
  @override
  Future<Paginated<MergeRequestDiffVersion>> mergeRequestDiffVersions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    reads.add((projectId, iid, page));
    final result = pages[page]!;
    if (result is Future<Paginated<MergeRequestDiffVersion>>) return result;
    if (result is Paginated<MergeRequestDiffVersion>) return result;
    throw result;
  }

  @override
  Future<MergeRequestDiffVersion> mergeRequestDiffVersion({
    required int projectId,
    required int iid,
    required int versionId,
  }) async {
    snapshots.add((projectId, iid, versionId));
    final result = details[versionId]!;
    if (result is Future<MergeRequestDiffVersion>) return result;
    if (result is MergeRequestDiffVersion) return result;
    throw result;
  }

  @override
  Future<List<FileDiff>> mergeRequestDiff({
    required int projectId,
    required int iid,
  }) async => throw StateError(
    'Original context must never fall back to current diffs.',
  );
}

Future<
  ({
    AppLocalizations l10n,
    _Repository comments,
    _DiffRepository diffs,
    ProviderContainer container,
  })
>
_fixture(
  WidgetTester tester, {
  DiffNotePosition? position,
  double width = 390,
  bool dark = false,
  Locale locale = const Locale('en'),
  _DiffRepository? diff,
}) async {
  final comments = _Repository()
    ..pages[1] = Paginated<Discussion>(
      items: [_thread('thread', position: position ?? _position())],
    );
  final diffs = diff ?? _DiffRepository();
  final container = _container(comments, _Analytics(), diff: diffs);
  final l10n = await _pump(
    tester,
    comments,
    width: width,
    dark: dark,
    locale: locale,
    container: container,
  );
  return (l10n: l10n, comments: comments, diffs: diffs, container: container);
}

Finder get _open => find.byKey(const ValueKey('mr-context-open-301'));
Future<void> _openContext(WidgetTester tester, {bool settle = true}) async {
  await tester.ensureVisible(_open);
  await tester.tap(_open);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets(
          'original context $locale width=$width dark=$dark preserves the draft',
          (tester) async {
            final f = await _fixture(
              tester,
              width: width,
              dark: dark,
              locale: Locale(locale),
            );
            await tester.enterText(
              find.byType(TextField).first,
              'Unsent top-level draft',
            );
            expect(f.diffs.reads, isEmpty);
            await _openContext(tester);
            expect(f.diffs.reads, [(8, 142, 1)]);
            expect(f.diffs.snapshots, [(8, 142, 110)]);
            expect(find.text('old.dart → new.dart'), findsOneWidget);
            final viewer = tester.widget<DiffViewer>(find.byType(DiffViewer));
            expect(viewer.highlightedLine!.oldLine, 27);
            expect(viewer.highlightedLine!.newLine, 29);
            expect(viewer.focusOnHighlightedLine, true);
            expect(
              viewer.highlightedLineLabel,
              f.l10n.mrDiscussionContextLineLabel,
            );
            expect(
              tester
                  .widget<TextField>(find.byType(TextField).first)
                  .controller!
                  .text,
              'Unsent top-level draft',
            );
            await tester.ensureVisible(
              find.byKey(const ValueKey('mr-context-hide-301')),
            );
            await tester.tap(find.byKey(const ValueKey('mr-context-hide-301')));
            await tester.pumpAndSettle();
            expect(find.byType(DiffViewer), findsNothing);
            expect(tester.takeException(), isNull);
            expect(
              tester
                  .widget<TextField>(find.byType(TextField).first)
                  .controller!
                  .text,
              'Unsent top-level draft',
            );
          },
        );
      }
    }
  }
  for (final p in [
    _position(oldLine: null, newLine: 30),
    _position(oldLine: 28, newLine: null),
    _position(),
  ]) {
    test(
      'matches exact old/new text coordinates ${p.oldLine}/${p.newLine}',
      () async {
        final repo = _Repository(), diff = _DiffRepository();
        final c = _container(repo, _Analytics(), diff: diff);
        final result = await c.read(
          mrDiscussionContextControllerProvider(_arg(p)).future,
        );
        expect(result.file!.oldPath, 'old.dart');
        expect(result.file!.newPath, 'new.dart');
        expect(result.line!.oldLine, p.oldLine);
        expect(result.line!.newLine, p.newLine);
        expect(result.versionId, 110);
      },
    );
  }
  for (final p in [
    _position(type: 'image'),
    _position(type: 'file'),
    _position(type: 'future'),
    _position(range: const DiffNoteLineRange()),
    _position().copyWith(headSha: null),
    _position().copyWith(oldPath: null),
    _position(oldLine: null, newLine: null),
    _position(oldLine: 0, newLine: 29),
  ]) {
    test(
      'incomplete or unsupported position is unavailable without reads $p',
      () async {
        final repo = _Repository(), diff = _DiffRepository();
        final c = _container(repo, _Analytics(), diff: diff);
        final result = await c.read(
          mrDiscussionContextControllerProvider(_arg(p)).future,
        );
        expect(result.file, isNull);
        expect(result.nextPage, isNull);
        expect(diff.reads, isEmpty);
        expect(diff.snapshots, isEmpty);
      },
    );
  }
  for (final file in [
    _file().copyWith(oldPath: 'another.dart'),
    _file(tooLarge: true),
    _file(diff: null),
    _file().copyWith(isCollapsed: true),
    _file().copyWith(diff: '@@ -1,1 +1,1 @@\n other line\n'),
  ]) {
    test(
      'unmatched or unavailable original file does not use current diff $file',
      () async {
        final repo = _Repository(),
            diff = _DiffRepository()..details[110] = _version(files: [file]);
        final c = _container(repo, _Analytics(), diff: diff);
        final result = await c.read(
          mrDiscussionContextControllerProvider(_arg()).future,
        );
        expect(result.file, isNull);
        expect(result.nextPage, isNull);
      },
    );
  }
  test('requires both context-side coordinates', () async {
    final repo = _Repository(), diff = _DiffRepository();
    final c = _container(repo, _Analytics(), diff: diff);
    final result = await c.read(
      mrDiscussionContextControllerProvider(
        _arg(_position(newLine: 30)),
      ).future,
    );
    expect(result.file, isNull);
  });
  test('snapshot SHA changes are typed failures', () async {
    final repo = _Repository(),
        diff = _DiffRepository()
          ..details[110] = _version(head: 'different', files: [_file()]);
    final c = _container(repo, _Analytics(), diff: diff);
    await expectLater(
      c.read(mrDiscussionContextControllerProvider(_arg()).future),
      throwsA(isA<GitLabServerException>()),
    );
  });
  test(
    'manual older-page reads reserve once and retain the cursor on failure',
    () async {
      final pending = Completer<Paginated<MergeRequestDiffVersion>>();
      final repo = _Repository(),
          diff = _DiffRepository()
            ..pages[1] = Paginated<MergeRequestDiffVersion>(
              items: [_version(head: 'current')],
              nextPage: 2,
            )
            ..pages[2] = pending.future;
      final c = _container(repo, _Analytics(), diff: diff);
      final provider = mrDiscussionContextControllerProvider(_arg());
      final sub = c.listen(provider, (_, _) {});
      addTearDown(sub.close);
      final initial = await c.read(provider.future);
      expect(initial.file, isNull);
      expect(initial.nextPage, 2);
      expect(diff.snapshots, isEmpty);
      final controller = c.read(provider.notifier);
      final first = controller.loadMore();
      await Future<void>.delayed(Duration.zero);
      await controller.loadMore();
      expect(diff.reads, [(8, 142, 1), (8, 142, 2)]);
      pending.completeError(
        const GitLabForbiddenException('private-content-marker'),
      );
      await first;
      expect(c.read(provider).value!.nextPage, 2);
      expect(c.read(provider).value!.loadMoreFailed, true);
      diff.pages[2] = Paginated<MergeRequestDiffVersion>(items: [_version()]);
      await controller.loadMore();
      expect(c.read(provider).value!.file, isNotNull);
      expect(diff.snapshots, [(8, 142, 110)]);
    },
  );
  test('account replacement cancels the follow-up snapshot read', () async {
    final pending = Completer<Paginated<MergeRequestDiffVersion>>();
    final repo = _Repository(),
        old = _DiffRepository()..pages[1] = pending.future;
    final next = _DiffRepository();
    addTearDown(next.client.close);
    final c = _container(repo, _Analytics(), diff: old);
    final provider = mrDiscussionContextControllerProvider(_arg());
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    unawaited(c.read(provider.future));
    await Future<void>.delayed(Duration.zero);
    c.read(_diffSession.notifier).state = Future.value(next);
    await c.read(provider.future);
    pending.complete(Paginated<MergeRequestDiffVersion>(items: [_version()]));
    await Future<void>.delayed(Duration.zero);
    expect(old.snapshots, isEmpty);
    expect(c.read(provider).value!.file!.newPath, 'new.dart');
  });
  test(
    'disposal prevents a late page from dispatching the snapshot read',
    () async {
      final pending = Completer<Paginated<MergeRequestDiffVersion>>();
      final repo = _Repository(),
          diff = _DiffRepository()..pages[1] = pending.future;
      final c = _container(repo, _Analytics(), diff: diff);
      final provider = mrDiscussionContextControllerProvider(_arg());
      final sub = c.listen(provider, (_, _) {});
      unawaited(c.read(provider.future));
      await Future<void>.delayed(Duration.zero);
      sub.close();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      pending.complete(Paginated<MergeRequestDiffVersion>(items: [_version()]));
      await Future<void>.delayed(Duration.zero);
      expect(diff.snapshots, isEmpty);
    },
  );
  testWidgets('older versions and read retries preserve the top-level draft', (
    tester,
  ) async {
    final diff = _DiffRepository()
      ..pages[1] = Paginated<MergeRequestDiffVersion>(
        items: [_version(head: 'current')],
        nextPage: 2,
      )
      ..pages[2] = const GitLabForbiddenException('private-content-marker');
    final f = await _fixture(tester, diff: diff);
    await tester.enterText(
      find.byType(TextField).first,
      'Draft survives read failure',
    );
    await _openContext(tester);
    expect(find.text(f.l10n.mrDiscussionContextUnavailable), findsOneWidget);
    await tester.ensureVisible(
      find.text(f.l10n.mrDiscussionContextOlderButton),
    );
    await tester.tap(find.text(f.l10n.mrDiscussionContextOlderButton));
    await tester.pumpAndSettle();
    expect(find.text(f.l10n.mrDiscussionContextError), findsOneWidget);
    expect(find.textContaining('private-content-marker'), findsNothing);
    diff.pages[2] = Paginated<MergeRequestDiffVersion>(items: [_version()]);
    await tester.tap(find.text(f.l10n.mrDiscussionContextOlderButton));
    await tester.pumpAndSettle();
    expect(find.byType(DiffViewer), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Draft survives read failure',
    );
  });
  testWidgets('initial read failure offers read-only retry', (tester) async {
    final diff = _DiffRepository()
      ..pages[1] = const GitLabServerException('private-content-marker');
    final f = await _fixture(tester, diff: diff);
    await _openContext(tester);
    expect(find.text(f.l10n.mrDiscussionContextError), findsOneWidget);
    diff.pages[1] = Paginated<MergeRequestDiffVersion>(items: [_version()]);
    await tester.ensureVisible(find.text(f.l10n.retry));
    await tester.tap(find.text(f.l10n.retry));
    await tester.pumpAndSettle();
    expect(find.byType(DiffViewer), findsOneWidget);
    expect(f.comments.posts, isEmpty);
    expect(f.comments.replies, isEmpty);
  });
  for (final fail in [false, true]) {
    testWidgets(
      'account change removes the old panel and isolates late detail fail=$fail',
      (tester) async {
        final pending = Completer<MergeRequestDiffVersion>();
        final old = _DiffRepository()..details[110] = pending.future;
        final f = await _fixture(tester, diff: old);
        await _openContext(tester, settle: false);
        final nextComments = _Repository()
          ..pages[1] = Paginated<Discussion>(
            items: [_thread('next', position: _position())],
          );
        addTearDown(nextComments.client.close);
        final next = _DiffRepository();
        addTearDown(next.client.close);
        f.container.read(_session.notifier).state = Future.value(nextComments);
        f.container.read(_diffSession.notifier).state = Future.value(next);
        await tester.pumpAndSettle();
        expect(find.byType(DiffViewer), findsNothing);
        expect(_open, findsOneWidget);
        await tester.enterText(
          find.byType(TextField).first,
          'New account draft',
        );
        if (fail) {
          pending.completeError(
            const GitLabServerException('old-private-error'),
          );
        } else {
          pending.complete(_version(files: [_file()]));
        }
        await tester.pumpAndSettle();
        expect(find.byType(DiffViewer), findsNothing);
        expect(find.text(f.l10n.mrDiscussionContextError), findsNothing);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          'New account draft',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'resizing and theme changes retain expanded context and the draft',
    (tester) async {
      final f = await _fixture(tester);
      await tester.enterText(find.byType(TextField).first, 'Resize draft');
      await _openContext(tester);
      await _pump(
        tester,
        f.comments,
        width: 1200,
        dark: true,
        container: f.container,
      );
      expect(find.byType(DiffViewer), findsOneWidget);
      expect(f.diffs.reads, [(8, 142, 1)]);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Resize draft',
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'MR replacement collapses context and isolates the late original page',
    (tester) async {
      final pending = Completer<Paginated<MergeRequestDiffVersion>>();
      final diff = _DiffRepository()..pages[1] = pending.future;
      final f = await _fixture(tester, diff: diff);
      await _openContext(tester, settle: false);
      await _pump(tester, f.comments, iid: 143, container: f.container);
      expect(find.byType(DiffViewer), findsNothing);
      expect(_open, findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Other MR draft');
      pending.complete(Paginated<MergeRequestDiffVersion>(items: [_version()]));
      await tester.pumpAndSettle();
      expect(diff.snapshots, isEmpty);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Other MR draft',
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('unpositioned notes offer no context action or diff reads', (
    tester,
  ) async {
    final comments = _Repository()
      ..pages[1] = Paginated<Discussion>(items: [_thread('thread')]);
    final diff = _DiffRepository();
    final c = _container(comments, _Analytics(), diff: diff);
    final l10n = await _pump(tester, comments, container: c);
    expect(find.text(l10n.mrDiscussionContextViewButton), findsNothing);
    expect(diff.reads, isEmpty);
  });
  test(
    'duplicate original line coordinates are unavailable instead of guessed',
    () async {
      final file = _file(
        diff:
            '@@ -27,1 +29,1 @@\n context one\n@@ -27,1 +29,1 @@\n context two\n',
      );
      final repo = _Repository(),
          diff = _DiffRepository()..details[110] = _version(files: [file]);
      final c = _container(repo, _Analytics(), diff: diff);
      expect(
        (await c.read(
          mrDiscussionContextControllerProvider(_arg()).future,
        )).file,
        isNull,
      );
    },
  );
  test(
    'ambiguous original file paths are unavailable instead of guessed',
    () async {
      final repo = _Repository(),
          diff = _DiffRepository()
            ..details[110] = _version(files: [_file(), _file()]);
      final c = _container(repo, _Analytics(), diff: diff);
      expect(
        (await c.read(
          mrDiscussionContextControllerProvider(_arg()).future,
        )).file,
        isNull,
      );
    },
  );
  test('late older-page failure cannot replace new-session context', () async {
    final pending = Completer<Paginated<MergeRequestDiffVersion>>();
    final repo = _Repository(),
        old = _DiffRepository()
          ..pages[1] = Paginated<MergeRequestDiffVersion>(
            items: [_version(head: 'current')],
            nextPage: 2,
          )
          ..pages[2] = pending.future;
    final next = _DiffRepository();
    addTearDown(next.client.close);
    final c = _container(repo, _Analytics(), diff: old);
    final provider = mrDiscussionContextControllerProvider(_arg());
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await c.read(provider.future);
    final more = c.read(provider.notifier).loadMore();
    await Future<void>.delayed(Duration.zero);
    c.read(_diffSession.notifier).state = Future.value(next);
    await c.read(provider.future);
    pending.completeError(const GitLabServerException('private-old-error'));
    await more;
    expect(c.read(provider).value!.file, isNotNull);
    expect(c.read(provider).value!.loadMoreFailed, false);
    expect(old.snapshots, isEmpty);
  });
  for (final operation in ['list', 'detail']) {
    test('real diff repository forwards $operation routing', () async {
      late RequestOptions request;
      final dio = Dio()
        ..httpClientAdapter = _Adapter((o) {
          request = o;
          return (
            status: 200,
            body: operation == 'detail'
                ? _version(files: [_file()]).toJson()
                : [_version().toJson()],
          );
        }, {});
      final client = GitLabClient(
        baseUrl: 'https://gitlab.example.com',
        token: 'glpat-xxxxxxxxxxxx',
        dio: dio,
      );
      addTearDown(client.close);
      final repo = DiffRepository(client);
      if (operation == 'detail') {
        await repo.mergeRequestDiffVersion(
          projectId: 8,
          iid: 142,
          versionId: 110,
        );
      } else {
        await repo.mergeRequestDiffVersions(projectId: 8, iid: 142, page: 3);
      }
      expect(
        request.path,
        '/projects/8/merge_requests/142/versions${operation == 'detail' ? '/110' : ''}',
      );
      expect(
        request.queryParameters,
        operation == 'detail' ? {'unidiff': true} : {'page': 3, 'per_page': 20},
      );
    });
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler, this.headers);
  final Map<String, List<String>> headers;
  final ({int status, Object? body}) Function(RequestOptions) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    return ResponseBody.fromString(
      r.body == null ? '' : json.encode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
