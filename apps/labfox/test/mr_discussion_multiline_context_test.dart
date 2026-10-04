import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

final _captureKey = GlobalKey();
Future<AppLocalizations> _pump(
  WidgetTester tester,
  _Repository repo, {
  double width = 390,
  double height = 1400,
  double textScale = 1,
  bool dark = false,
  Locale locale = const Locale('en'),
  bool settle = true,
  ProviderContainer? container,
  ThemeData? theme,
  int iid = 142,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final scope = container ?? _container(repo, _Analytics());
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) => RepaintBoundary(
          key: _captureKey,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
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
  double height = 1400,
  double textScale = 1,
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
    height: height,
    textScale: textScale,
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

const _rangeDiff =
    '@@ -1,1 +1,1 @@\n earlier unrelated hunk\n@@ -27,4 +29,4 @@\n before\n-old one\n-old two\n+new one\n+new two\n after\n';
DiffNoteRangeEndpoint _end(
  String type,
  int old,
  int newer, {
  int? oldLine,
  int? newLine,
}) => DiffNoteRangeEndpoint(
  type: type,
  lineCode: '87776303bc424d2317286267dca1d8fe850aae77_${old}_$newer',
  oldLine: oldLine,
  newLine: newLine,
);
DiffNotePosition _rangePosition(
  DiffNoteRangeEndpoint start,
  DiffNoteRangeEndpoint end,
) => _position(
  range: DiffNoteLineRange(start: start, end: end),
);
DiffNotePosition _newRange() => _rangePosition(
  _end('new', 30, 30, newLine: 30),
  _end('new', 30, 31, newLine: 31),
);
DiffNotePosition _oldRange() => _rangePosition(
  _end('old', 28, 30, oldLine: 28),
  _end('old', 29, 30, oldLine: 29),
);
DiffNotePosition _mixedRange() => _rangePosition(
  _end('old', 28, 30, oldLine: 28),
  _end('new', 30, 31, newLine: 31),
);
_DiffRepository _rangeRepo({String diff = _rangeDiff}) =>
    _DiffRepository()..details[110] = _version(files: [_file(diff: diff)]);
Future<MrDiscussionContext> _readRange(
  DiffNotePosition position, {
  String diff = _rangeDiff,
}) async {
  final repo = _Repository(), diffs = _rangeRepo(diff: diff);
  final c = _container(repo, _Analytics(), diff: diffs);
  return c.read(mrDiscussionContextControllerProvider(_arg(position)).future);
}

void main() {
  test(
    'oversized declared hunk counts remain unavailable without decoding errors',
    () async {
      final raw = _rangeDiff.replaceFirst(
        '@@ -27,4 +29,4 @@',
        '@@ -27,${'9' * 100} +29,4 @@',
      );
      expect((await _readRange(_newRange(), diff: raw)).file, isNull);
    },
  );

  testWidgets(
    'multiline marks retain the draft across resize and theme changes',
    (tester) async {
      final f = await _fixture(
        tester,
        position: _mixedRange(),
        diff: _rangeRepo(),
      );
      await _openContext(tester);
      await tester.enterText(find.byType(TextField).first, 'Resize draft');
      await _pump(
        tester,
        f.comments,
        container: f.container,
        width: 1200,
        dark: true,
      );
      expect(find.byIcon(LabFoxIcons.comment), findsNWidgets(4));
      expect(f.diffs.snapshots.length, 1);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Resize draft',
      );
    },
  );
  testWidgets('multiline context fits compact large text and keyboard insets', (
    tester,
  ) async {
    await _fixture(
      tester,
      position: _mixedRange(),
      diff: _rangeRepo(),
      width: 320,
      height: 640,
      textScale: 2,
    );
    await _openContext(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('resource replacement clears original range source and markers', (
    tester,
  ) async {
    final f = await _fixture(
      tester,
      position: _mixedRange(),
      diff: _rangeRepo(),
    );
    await _openContext(tester);
    expect(find.byIcon(LabFoxIcons.comment), findsNWidgets(4));
    await _pump(tester, f.comments, container: f.container, iid: 143);
    expect(find.byType(DiffViewer), findsNothing);
    expect(find.textContaining('old one'), findsNothing);
  });
  for (final (p, raw, texts) in [
    (
      _rangePosition(_end('new', 0, 1), _end('new', 0, 2)),
      '@@ -0,0 +1,2 @@\n+first\n+second\n',
      ['first', 'second'],
    ),
    (
      _rangePosition(_end('old', 1, 0), _end('old', 2, 0)),
      '@@ -1,2 +0,0 @@\n-first\n-second\n',
      ['first', 'second'],
    ),
    (
      _rangePosition(
        _end('new', 30, 30),
        _end('old', 30, 32, oldLine: 30, newLine: 32),
      ),
      _rangeDiff,
      ['new one', 'new two', 'after'],
    ),
  ]) {
    test(
      'zero opposite counters and forward mixed-side ranges are supported $p',
      () async {
        expect(
          (await _readRange(p, diff: raw)).lines.map((l) => l.text),
          texts,
        );
      },
    );
  }

  test(
    'oversized endpoint code counters are unavailable before reads',
    () async {
      final p = _newRange();
      final code = p.lineRange!.start!.lineCode!.split('_').first;
      final invalid = p.copyWith(
        lineRange: p.lineRange!.copyWith(
          start: p.lineRange!.start!.copyWith(
            lineCode: '${code}_30_${'9' * 100}',
          ),
        ),
      );
      final diffs = _rangeRepo();
      final c = _container(_Repository(), _Analytics(), diff: diffs);
      expect(
        (await c.read(
          mrDiscussionContextControllerProvider(_arg(invalid)).future,
        )).file,
        isNull,
      );
      expect(diffs.reads, isEmpty);
    },
  );

  test(
    'optional opposite context coordinate is resolved by full endpoint code',
    () async {
      final p = _rangePosition(
        _end('new', 27, 29, newLine: 29),
        _end('new', 30, 32, newLine: 32),
      );
      final result = await _readRange(p);
      expect(result.lines.map((l) => l.text), [
        'before',
        'new one',
        'new two',
        'after',
      ]);
    },
  );
  test(
    'documented line codes locate endpoints when optional coordinates are absent',
    () async {
      final p = _rangePosition(_end('new', 30, 30), _end('new', 30, 31));
      final result = await _readRange(p);
      expect(result.lines.map((l) => l.text), ['new one', 'new two']);
    },
  );
  testWidgets(
    'optional range coordinates render without assuming a legacy anchor',
    (tester) async {
      final p = _rangePosition(
        _end('new', 30, 30),
        _end('new', 30, 31),
      ).copyWith(oldLine: null, newLine: null);
      await _fixture(tester, position: p, diff: _rangeRepo());
      await _openContext(tester);
      expect(find.byIcon(LabFoxIcons.comment), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  for (final (p, texts) in [
    (_newRange(), ['new one', 'new two']),
    (_oldRange(), ['old one', 'old two']),
    (_mixedRange(), ['old one', 'old two', 'new one', 'new two']),
    (
      _rangePosition(
        _end('old', 27, 29, oldLine: 27, newLine: 29),
        _end('old', 30, 32, oldLine: 30, newLine: 32),
      ),
      ['before', 'old one', 'old two', 'after'],
    ),
    (
      _rangePosition(
        _end('new', 27, 29, oldLine: 27, newLine: 29),
        _end('new', 30, 32, oldLine: 30, newLine: 32),
      ),
      ['before', 'new one', 'new two', 'after'],
    ),
    (
      _rangePosition(
        _end('new', 30, 30, newLine: 30),
        _end('new', 30, 30, newLine: 30),
      ),
      ['new one'],
    ),
  ]) {
    test(
      'resolves exact inclusive range ${p.lineRange} without opposite-side marks',
      () async {
        final result = await _readRange(p);
        expect(result.file, isNotNull);
        expect(result.versionId, 110);
        expect(result.lines.map((l) => l.text), texts);
        expect(() => result.lines.clear(), throwsUnsupportedError);
      },
    );
  }
  test(
    'range endpoints can locate context without a legacy single-line anchor',
    () async {
      final result = await _readRange(
        _newRange().copyWith(oldLine: null, newLine: null),
      );
      expect(result.lines.map((l) => l.text), ['new one', 'new two']);
    },
  );
  final valid = _newRange();
  final start = valid.lineRange!.start!, end = valid.lineRange!.end!;
  for (final range in [
    const DiffNoteLineRange(),
    DiffNoteLineRange(start: start),
    DiffNoteLineRange(end: end),
    DiffNoteLineRange(
      start: start.copyWith(type: 'future'),
      end: end,
    ),
    DiffNoteLineRange(start: start.copyWith(lineCode: null), end: end),
    DiffNoteLineRange(
      start: start.copyWith(lineCode: 'malformed'),
      end: end,
    ),
    DiffNoteLineRange(start: start.copyWith(newLine: 0), end: end),
    DiffNoteLineRange(start: start.copyWith(newLine: 31), end: end),
  ]) {
    test(
      'incomplete range metadata never dispatches a version read $range',
      () async {
        final diffs = _rangeRepo();
        final c = _container(_Repository(), _Analytics(), diff: diffs);
        final result = await c.read(
          mrDiscussionContextControllerProvider(
            _arg(valid.copyWith(lineRange: range)),
          ).future,
        );
        expect(result.file, isNull);
        expect(diffs.reads, isEmpty);
        expect(diffs.snapshots, isEmpty);
      },
    );
  }
  for (final p in [
    _rangePosition(end, start),
    _rangePosition(
      start.copyWith(
        lineCode: '0000000000000000000000000000000000000000_30_30',
      ),
      end,
    ),
    _rangePosition(start.copyWith(oldLine: 30), end),
    _rangePosition(
      start.copyWith(
        lineCode: '87776303bc424d2317286267dca1d8fe850aae77_99_30',
      ),
      end,
    ),
    _rangePosition(
      start,
      end.copyWith(
        lineCode: '87776303bc424d2317286267dca1d8fe850aae77_30_99',
        newLine: 99,
      ),
    ),
    _rangePosition(_end('old', 30, 30, oldLine: 30), end),
  ]) {
    test(
      'mismatched identity side coordinate or direction is unavailable $p',
      () async {
        expect((await _readRange(p)).file, isNull);
      },
    );
  }
  for (final raw in [
    _rangeDiff.replaceFirst('@@ -27,4 +29,4 @@', '@@ -27,5 +29,4 @@'),
    '$_rangeDiff@@ -30,1 +30,1 @@\n duplicate position\n',
    '@@ -27,1 +29,1 @@\n first\n@@ -30,1 +32,1 @@\n last\n',
  ]) {
    test(
      'incomplete duplicate or omitted span has no guessed context $raw',
      () async {
        final p = _rangePosition(
          _end('new', 27, 29, oldLine: 27, newLine: 29),
          _end('new', 30, 32, oldLine: 30, newLine: 32),
        );
        expect((await _readRange(p, diff: raw)).file, isNull);
      },
    );
  }
  test(
    'adjacent complete hunks can represent one fully available range',
    () async {
      final p = _rangePosition(
        _end('new', 27, 29, oldLine: 27, newLine: 29),
        _end('new', 28, 30, oldLine: 28, newLine: 30),
      );
      final result = await _readRange(
        p,
        diff: '@@ -27,1 +29,1 @@\n first\n@@ -28,1 +30,1 @@\n second\n',
      );
      expect(result.lines.map((l) => l.text), ['first', 'second']);
    },
  );
  test('older range snapshots require an explicit page request', () async {
    final diffs = _rangeRepo()
      ..pages[1] = Paginated(
        items: [_version(id: 999, head: 'latest')],
        nextPage: 2,
      )
      ..pages[2] = Paginated(items: [_version()]);
    final c = _container(_Repository(), _Analytics(), diff: diffs);
    final p = mrDiscussionContextControllerProvider(_arg(_newRange()));
    expect((await c.read(p.future)).nextPage, 2);
    expect(diffs.snapshots, isEmpty);
    await c.read(p.notifier).loadMore();
    expect(c.read(p).requireValue.lines.length, 2);
    expect(diffs.reads, [(8, 142, 1), (8, 142, 2)]);
    expect(diffs.snapshots, [(8, 142, 110)]);
  });
  test('account replacement cancels follow-up range snapshot reads', () async {
    final pending = Completer<Paginated<MergeRequestDiffVersion>>();
    final diffs = _rangeRepo()..pages[1] = pending.future;
    final c = _container(_Repository(), _Analytics(), diff: diffs);
    final p = mrDiscussionContextControllerProvider(_arg(_newRange()));
    final listener = c.listen(p, (_, _) {});
    addTearDown(listener.close);
    final old = c.read(p.future);
    await Future<void>.delayed(Duration.zero);
    final next = _rangeRepo();
    addTearDown(next.client.close);
    c.read(_diffSession.notifier).state = Future.value(next);
    await c.read(p.future);
    pending.complete(Paginated(items: [_version()]));
    await old;
    expect(diffs.snapshots, isEmpty);
    expect(c.read(p).requireValue.lines.map((l) => l.text), [
      'new one',
      'new two',
    ]);
  });
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets(
          'multiline context $locale $width dark=$dark retains drafts',
          (tester) async {
            final f = await _fixture(
              tester,
              position: _mixedRange(),
              diff: _rangeRepo(),
              locale: Locale(locale),
              width: width,
              dark: dark,
            );
            await tester.enterText(
              find.byType(TextField).first,
              'Keep this draft',
            );
            await _openContext(tester);
            expect(find.byType(DiffViewer), findsOneWidget);
            final viewer = tester.widget<DiffViewer>(find.byType(DiffViewer));
            expect(viewer.highlightedLines.map((l) => l.text), [
              'old one',
              'old two',
              'new one',
              'new two',
            ]);
            expect(find.byIcon(LabFoxIcons.comment), findsNWidgets(4));
            expect(find.textContaining('earlier unrelated'), findsNothing);
            expect(
              tester
                  .widget<TextField>(find.byType(TextField).first)
                  .controller!
                  .text,
              'Keep this draft',
            );
            expect(f.comments.posts, isEmpty);
            expect(f.comments.replies, isEmpty);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  if (Platform.environment['LABFOX_MULTILINE_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('synthetic multiline context capture $width $dark', (
          tester,
        ) async {
          final sdk = Platform.environment['FLUTTER_ROOT']!;
          await tester.runAsync(() async {
            for (final (family, name) in [
              ('Roboto', 'Roboto-Regular.ttf'),
              ('monospace', 'Roboto-Regular.ttf'),
              ('MaterialIcons', 'MaterialIcons-Regular.otf'),
            ]) {
              final loader = FontLoader(family)
                ..addFont(
                  Future.value(
                    ByteData.sublistView(
                      File(
                        '$sdk/bin/cache/artifacts/material_fonts/$name',
                      ).readAsBytesSync(),
                    ),
                  ),
                );
              if (family == 'Roboto') {
                for (final weight in ['Medium', 'Bold']) {
                  loader.addFont(
                    Future.value(
                      ByteData.sublistView(
                        File(
                          '$sdk/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
                        ).readAsBytesSync(),
                      ),
                    ),
                  );
                }
              }
              await loader.load();
            }
          });
          final baseTheme = dark ? LabFoxTheme.dark : LabFoxTheme.light;
          final buttonStyle = baseTheme.filledButtonTheme.style!;
          final captureTheme = baseTheme.copyWith(
            filledButtonTheme: FilledButtonThemeData(
              style: buttonStyle.copyWith(
                textStyle: WidgetStatePropertyAll(
                  buttonStyle.textStyle!
                      .resolve({})!
                      .copyWith(fontFamily: 'Roboto'),
                ),
              ),
            ),
          );
          final f = await _fixture(
            tester,
            position: _mixedRange().copyWith(oldPath: 'new.dart'),
            diff: _rangeRepo()
              ..details[110] = _version(
                files: [
                  _file(
                    diff: _rangeDiff,
                  ).copyWith(oldPath: 'new.dart', isRenamed: false),
                ],
              ),
            width: width,
            dark: dark,
            height: width < 600 ? 844 : 900,
          );
          await _pump(
            tester,
            f.comments,
            container: f.container,
            width: width,
            height: width < 600 ? 844 : 900,
            theme: captureTheme,
          );
          await _openContext(tester);
          expect(tester.takeException(), isNull);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(_captureKey),
          );
          final image = (await tester.runAsync(boundary.toImage))!;
          final data = await tester.runAsync(
            () => image.toByteData(format: ui.ImageByteFormat.png),
          );
          await tester.runAsync(() async {
            final file = File(
              '$directory/context-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
          });
          image.dispose();
        });
      }
    }
  }
}
