import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/diff/data/diff_repository.dart';
import 'package:labfox/features/diff/presentation/controllers/diff_controllers.dart';
import 'package:labfox/features/merge_requests/data/original_diff_range.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_review_snapshot_controller.dart';
import 'package:labfox/features/merge_requests/presentation/mr_changes_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

final _captureKey = GlobalKey();
const _arg = MergeRequestRef(projectId: 8, iid: 142);
const _raw =
    '@@ -27,3 +29,3 @@\n final count = items.length;\n-return count;\n+return pending.length;\n return count;\n';
MergeRequestDiffVersion _version({
  List<MergeRequestVersionFile>? files,
  String? head = 'head',
  String? state = 'collected',
}) => MergeRequestDiffVersion(
  id: 110,
  baseCommitSha: 'base',
  startCommitSha: 'start',
  headCommitSha: head,
  state: state,
  files:
      files ??
      [
        const MergeRequestVersionFile(
          oldPath: 'old.dart',
          newPath: 'new.dart',
          diff: _raw,
          isRenamed: true,
        ),
      ],
);

class _Repo extends DiffRepository {
  _Repo()
    : this._(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  _Repo._(this.client) : super(client);
  final GitLabClient client;
  Object list = Paginated<MergeRequestDiffVersion>(items: [_version()]);
  Object detail = _version();
  final reads = <(int, int, int)>[];
  final snapshots = <(int, int, int)>[];
  @override
  Future<Paginated<MergeRequestDiffVersion>> mergeRequestDiffVersions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    reads.add((projectId, iid, page));
    if (list is Paginated<MergeRequestDiffVersion>) {
      return list as Paginated<MergeRequestDiffVersion>;
    }
    if (list is Future<Paginated<MergeRequestDiffVersion>>) {
      return list as Future<Paginated<MergeRequestDiffVersion>>;
    }
    throw list;
  }

  @override
  Future<MergeRequestDiffVersion> mergeRequestDiffVersion({
    required int projectId,
    required int iid,
    required int versionId,
  }) async {
    snapshots.add((projectId, iid, versionId));
    if (detail is MergeRequestDiffVersion) {
      return detail as MergeRequestDiffVersion;
    }
    if (detail is Future<MergeRequestDiffVersion>) {
      return detail as Future<MergeRequestDiffVersion>;
    }
    throw detail;
  }

  @override
  Future<List<FileDiff>> mergeRequestDiff({
    required int projectId,
    required int iid,
  }) async => throw StateError('No current diff fallback');
}

final _session = StateProvider<Future<DiffRepository?>>((ref) async => null);

class _Comments extends CommentsRepository {
  _Comments()
    : this._(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  _Comments._(this.client) : super(client);
  final GitLabClient client;
  final creates = <(int, int, String, DiffNotePosition)>[];
  final posts = <String>[];
  int reads = 0;
  Future<Discussion>? result;
  Object? readError;
  final pages = <int, Paginated<Discussion>>{};
  @override
  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    reads++;
    if (readError != null) throw readError!;
    return pages[page] ?? const Paginated(items: []);
  }

  @override
  Future<Discussion> createPositionedDiscussion({
    required int projectId,
    required int iid,
    required String body,
    required DiffNotePosition position,
  }) async {
    creates.add((projectId, iid, body, position));
    return result ??
        Discussion(
          id: 'created',
          individualNote: false,
          notes: [Note(id: 999, body: body, position: position)],
        );
  }

  @override
  Future<Note> post({
    required NoteableType type,
    required int projectId,
    required int iid,
    required String body,
  }) async {
    posts.add(body);
    return Note(id: 888, body: body);
  }
}

final _commentsSession = StateProvider<Future<CommentsRepository?>>(
  (ref) async => null,
);
ProviderContainer _container(_Repo repo, _Comments comments) {
  final c = ProviderContainer(
    overrides: [
      _session.overrideWith((ref) async => repo),
      diffRepositoryProvider.overrideWith((ref) => ref.watch(_session)),
      _commentsSession.overrideWith((ref) async => comments),
      commentsRepositoryProvider.overrideWith(
        (ref) => ref.watch(_commentsSession),
      ),
    ],
  );
  addTearDown(c.dispose);
  addTearDown(repo.client.close);
  addTearDown(comments.client.close);
  return c;
}

Future<AppLocalizations> _pump(
  WidgetTester tester,
  ProviderContainer c, {
  double width = 390,
  double height = 1400,
  ThemeData? theme,
  bool dark = false,
  Locale locale = const Locale('en'),
  int iid = 142,
  bool settle = true,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: theme ?? (dark ? LabFoxTheme.dark : LabFoxTheme.light),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: _captureKey,
          child: MrChangesScreen(projectId: 8, iid: iid),
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
  return AppLocalizations.of(tester.element(find.byType(MrChangesScreen)));
}

Finder get _draft => find.byKey(const ValueKey('mr-diff-discussion-draft'));
Finder get _submit => find.byKey(const ValueKey('mr-diff-discussion-submit'));
Future<void> _select(
  WidgetTester tester,
  int index, {
  bool settle = true,
}) async {
  final action = find.byTooltip('Add discussion on this line').at(index);
  await tester.ensureVisible(action);
  await tester.tap(action);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _send(WidgetTester tester, {bool settle = true}) async {
  await tester.pump();
  await tester.ensureVisible(_submit);
  await tester.tap(_submit);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String get _hash => sha1.convert(utf8.encode('new.dart')).toString();
Future<void> _range(
  WidgetTester tester,
  AppLocalizations l, {
  int start = 0,
  int end = 2,
}) async {
  await _select(tester, start);
  await tester.ensureVisible(find.text(l.mrDiffSelectRangeButton));
  await tester.tap(find.text(l.mrDiffSelectRangeButton));
  await tester.pumpAndSettle();
  final actions = find.byTooltip(l.mrDiffRangeEndButton);
  await Scrollable.ensureVisible(
    tester.element(actions.at(end - start - 1)),
    alignment: 0.5,
  );
  await tester.pumpAndSettle();
  await tester.tap(actions.at(end - start - 1));
  await tester.pumpAndSettle();
  expect(find.text(l.mrDiffRangeChooseEnd), findsNothing);
}

void main() {
  testWidgets('newer snapshot never marks or submits an old range', (
    tester,
  ) async {
    final comments = _Comments(),
        repo = _Repo(),
        c = _container(repo, comments),
        l = await _pump(tester, c);
    await _range(tester, l);
    await tester.enterText(_draft, 'Old version draft');
    final newer = _version(head: 'new-head').copyWith(id: 111);
    repo.list = Paginated(items: [newer]);
    repo.detail = newer;
    c.invalidate(mrReviewSnapshotControllerProvider(_arg));
    await tester.pumpAndSettle();
    expect(
      tester.widget<DiffViewer>(find.byType(DiffViewer)).highlightedLines,
      isEmpty,
    );
    expect(tester.widget<FilledButton>(_submit).onPressed, isNull);
    expect(
      tester.widget<TextField>(_draft).controller!.text,
      'Old version draft',
    );
    expect(comments.creates, isEmpty);
  });
  testWidgets('same-version refresh retains draft and allows range editing', (
    tester,
  ) async {
    final comments = _Comments(),
        repo = _Repo(),
        c = _container(repo, comments),
        l = await _pump(tester, c);
    await _range(tester, l);
    await tester.enterText(_draft, 'Retained through read');
    c.invalidate(mrReviewSnapshotControllerProvider(_arg));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(_draft).controller!.text,
      'Retained through read',
    );
    await tester.ensureVisible(find.text(l.mrDiffSelectRangeButton));
    await tester.tap(find.text(l.mrDiffSelectRangeButton));
    await tester.pumpAndSettle();
    expect(find.text(l.mrDiffRangeChooseEnd), findsOneWidget);
    expect(find.byTooltip(l.mrDiffRangeEndButton), findsNWidgets(3));
    expect(
      tester.widget<TextField>(_draft).controller!.text,
      'Retained through read',
    );
    expect(comments.creates, isEmpty);
  });
  for (final fail in [false, true]) {
    test(
      'comments session replacement isolates immediate late range outcome fail=$fail',
      () async {
        final comments = _Comments(),
            c = _container(_Repo(), comments),
            sub = c.listen(mrReviewSnapshotControllerProvider(_arg), (_, _) {});
        addTearDown(sub.close);
        final s = await c.read(mrReviewSnapshotControllerProvider(_arg).future),
            f = s.files.single,
            lines = f.hunks.single.lines;
        final p = s.rangePositionFor(f, lines.first, lines[2])!;
        await c.read(mrDiscussionsControllerProvider(_arg).future);
        final pending = Completer<Discussion>();
        comments.result = pending.future;
        final write = c
            .read(mrDiscussionsControllerProvider(_arg).notifier)
            .createPositioned(body: 'Old draft', position: p);
        await Future<void>.delayed(Duration.zero);
        expect(comments.creates, hasLength(1));
        final next = _Comments();
        addTearDown(next.client.close);
        c.read(_commentsSession.notifier).state = Future.value(next);
        if (fail) {
          pending.completeError(const GitLabServerException('Old failure'));
        } else {
          pending.complete(
            const Discussion(id: 'old', individualNote: false, notes: []),
          );
        }
        expect(await write, false);
        expect(next.creates, isEmpty);
      },
    );
  }
  test('foreign files and duplicate paths do not authorize ranges', () {
    FileDiff file() => FileDiff(
      oldPath: 'old.dart',
      newPath: 'new.dart',
      isNew: false,
      isDeleted: false,
      isRenamed: true,
      diff: _raw,
    );
    final original = file(),
        foreign = file(),
        lines = original.hunks.single.lines;
    final snapshot = MrReviewSnapshot(version: _version(), files: [original]);
    expect(snapshot.rangePositionFor(foreign, lines.first, lines.last), isNull);
    expect(
      MrReviewSnapshot(
        version: _version(),
        files: [original, foreign],
      ).rangePositionFor(original, lines.first, lines.last),
      isNull,
    );
  });
  test(
    'range creation shares write reservation and rejects forged range',
    () async {
      final comments = _Comments(),
          c = _container(_Repo(), comments),
          sub = c.listen(mrReviewSnapshotControllerProvider(_arg), (_, _) {});
      addTearDown(sub.close);
      final s = await c.read(mrReviewSnapshotControllerProvider(_arg).future),
          f = s.files.single,
          lines = f.hunks.single.lines;
      final p = s.rangePositionFor(f, lines.first, lines[2])!;
      await c.read(mrDiscussionsControllerProvider(_arg).future);
      final ctrl = c.read(mrDiscussionsControllerProvider(_arg).notifier);
      expect(
        await ctrl.createPositioned(
          body: 'Forged',
          position: p.copyWith(
            lineRange: p.lineRange!.copyWith(
              start: p.lineRange!.start!.copyWith(lineCode: 'fake'),
            ),
          ),
        ),
        false,
      );
      final pending = Completer<Discussion>();
      comments.result = pending.future;
      final write = ctrl.createPositioned(body: 'Range', position: p);
      await Future<void>.delayed(Duration.zero);
      expect(await ctrl.post('Root'), false);
      expect(
        await ctrl.createPositioned(body: 'Duplicate', position: p),
        false,
      );
      expect(comments.creates, hasLength(1));
      expect(comments.posts, isEmpty);
      pending.complete(
        const Discussion(id: 'created', individualNote: false, notes: []),
      );
      expect(await write, true);
    },
  );
  test('account replacement before range dispatch cancels write', () async {
    final comments = _Comments(),
        c = _container(_Repo(), comments),
        sub = c.listen(mrReviewSnapshotControllerProvider(_arg), (_, _) {});
    addTearDown(sub.close);
    final s = await c.read(mrReviewSnapshotControllerProvider(_arg).future),
        f = s.files.single,
        lines = f.hunks.single.lines;
    final p = s.rangePositionFor(f, lines.first, lines[2])!;
    await c.read(mrDiscussionsControllerProvider(_arg).future);
    final write = c
        .read(mrDiscussionsControllerProvider(_arg).notifier)
        .createPositioned(body: 'Old range', position: p);
    final next = _Comments();
    addTearDown(next.client.close);
    c.read(_commentsSession.notifier).state = Future.value(next);
    expect(await write, false);
    expect(comments.creates, isEmpty);
    expect(next.creates, isEmpty);
  });
  testWidgets(
    'pending range prevents editing selection dismissal and duplicate writes',
    (tester) async {
      final pending = Completer<Discussion>(),
          comments = _Comments()..result = pending.future;
      final c = _container(_Repo(), comments), l = await _pump(tester, c);
      await _range(tester, l);
      await tester.enterText(_draft, 'Pending range');
      await _send(tester, settle: false);
      expect(tester.widget<TextField>(_draft).enabled, false);
      for (final label in [
        l.mrDiffSelectRangeButton,
        l.mrDiffSingleLineButton,
        l.mrDiffDiscussionCancel,
      ]) {
        expect(
          tester
              .widget<TextButton>(find.widgetWithText(TextButton, label))
              .onPressed,
          isNull,
        );
      }
      expect(find.byTooltip(l.mrDiffRangeEndButton), findsNothing);
      await _send(tester, settle: false);
      expect(comments.creates, hasLength(1));
      pending.complete(
        const Discussion(id: 'created', individualNote: false, notes: []),
      );
      await tester.pumpAndSettle();
      expect(_draft, findsNothing);
    },
  );
  for (final fail in [false, true]) {
    testWidgets(
      'account replacement isolates late range completion fail=$fail',
      (tester) async {
        final pending = Completer<Discussion>(),
            old = _Comments()..result = pending.future,
            c = _container(_Repo(), old),
            l = await _pump(tester, c);
        await _range(tester, l);
        await tester.enterText(_draft, 'Old range');
        await _send(tester, settle: false);
        final next = _Comments(), nextRepo = _Repo();
        addTearDown(next.client.close);
        addTearDown(nextRepo.client.close);
        c.read(_commentsSession.notifier).state = Future.value(next);
        c.read(_session.notifier).state = Future.value(nextRepo);
        await tester.pumpAndSettle();
        expect(_draft, findsNothing);
        await _range(tester, l);
        await tester.enterText(_draft, 'New range');
        if (fail) {
          pending.completeError(const GitLabServerException('Old failure'));
        } else {
          pending.complete(
            const Discussion(id: 'old', individualNote: false, notes: []),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(_draft).controller!.text, 'New range');
        expect(next.creates, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('resource replacement clears unfinished range selection', (
    tester,
  ) async {
    final c = _container(_Repo(), _Comments()), l = await _pump(tester, c);
    await _select(tester, 0);
    await tester.enterText(_draft, 'Old draft');
    await tester.tap(find.text(l.mrDiffSelectRangeButton));
    await tester.pumpAndSettle();
    await _pump(tester, c, iid: 143);
    expect(_draft, findsNothing);
    expect(find.text(l.mrDiffRangeChooseEnd), findsNothing);
  });
  testWidgets(
    'compact keyboard and doubled text preserve editable range draft',
    (tester) async {
      final comments = _Comments(),
          c = _container(_Repo(), comments),
          l = await _pump(tester, c, width: 320, height: 640, textScale: 2);
      await _range(tester, l);
      await tester.enterText(_draft, 'Large text draft');
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(_draft);
      expect(
        tester.widget<TextField>(_draft).controller!.text,
        'Large text draft',
      );
      expect(comments.creates, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  final cases = <({String diff, int start, int end, int? count})>[
    (diff: '@@ -1,2 +1,2 @@\n one\n two\n', start: 0, end: 1, count: 2),
    (
      diff: '@@ -1,2 +1,2 @@\n-old1\n-old2\n+new1\n+new2\n',
      start: 0,
      end: 1,
      count: 2,
    ),
    (
      diff: '@@ -1,2 +1,2 @@\n-old1\n-old2\n+new1\n+new2\n',
      start: 2,
      end: 3,
      count: 2,
    ),
    (
      diff: '@@ -1,2 +1,2 @@\n-old1\n-old2\n+new1\n+new2\n',
      start: 0,
      end: 3,
      count: 4,
    ),
    (diff: '@@ -1,1 +1,1 @@\n+new\n-old\n', start: 0, end: 1, count: 2),
    (diff: '@@ -0,0 +1,2 @@\n+new1\n+new2\n', start: 0, end: 1, count: 2),
    (diff: '@@ -1,2 +0,0 @@\n-old1\n-old2\n', start: 0, end: 1, count: 2),
    (
      diff: '@@ -1,1 +1,1 @@\n one\n@@ -2,1 +2,1 @@\n two\n',
      start: 0,
      end: 1,
      count: 2,
    ),
    (
      diff: '@@ -1,1 +1,1 @@\n one\n@@ -3,1 +3,1 @@\n three\n',
      start: 0,
      end: 1,
      count: null,
    ),
    (diff: '@@ -1,3 +1,3 @@\n one\n two\n', start: 0, end: 1, count: null),
    (
      diff: '@@ -1,9999999999999999999999999 +1,2 @@\n one\n two\n',
      start: 0,
      end: 1,
      count: null,
    ),
    (
      diff: '@@ -1,2 +1,2 @@\n one\n two\n@@ -2,1 +2,1 @@\n duplicate\n',
      start: 0,
      end: 1,
      count: null,
    ),
    (diff: '@@ -1,2 +1,2 @@\n one\n two\n', start: 1, end: 0, count: null),
    (
      diff: '@@ -1,1 +1,1 @@\n one\n@@ -2,1 +2,1 @@\n@@ -2,1 +2,1 @@\n two\n',
      start: 0,
      end: 1,
      count: null,
    ),
  ];
  for (var i = 0; i < cases.length; i++) {
    test('range membership and available contiguous hunks $i', () {
      final fixture = cases[i],
          file = FileDiff(
            oldPath: 'old.dart',
            newPath: 'new.dart',
            isNew: false,
            isDeleted: false,
            isRenamed: true,
            diff: fixture.diff,
          );
      final snapshot = MrReviewSnapshot(version: _version(), files: [file]),
          lines = file.hunks.expand((h) => h.lines).toList();
      final p = snapshot.rangePositionFor(
        file,
        lines[fixture.start],
        lines[fixture.end],
      );
      if (fixture.count == null) {
        expect(p, isNull);
      } else {
        expect(p, isNotNull);
        expect(snapshot.containsPosition(p!), true);
        expect(snapshot.linesForPosition(file, p), hasLength(fixture.count!));
        expect(
          snapshot.linesForPosition(file, p),
          originalDiffRange(file, p.lineRange!),
        );
      }
    });
  }
  test(
    'range uses original raw counters and exact snapshot membership',
    () async {
      final c = _container(_Repo(), _Comments());
      final sub = c.listen(mrReviewSnapshotControllerProvider(_arg), (_, _) {});
      addTearDown(sub.close);
      final s = await c.read(mrReviewSnapshotControllerProvider(_arg).future);
      final f = s.files.single, lines = s.files.single.hunks.single.lines;
      final p = s.rangePositionFor(f, lines.first, lines[2])!;
      expect(p.oldLine, isNull);
      expect(p.newLine, 30);
      expect(
        p.lineRange!.start,
        DiffNoteRangeEndpoint(
          lineCode: '${_hash}_27_29',
          type: 'old',
          oldLine: 27,
          newLine: 29,
        ),
      );
      expect(
        p.lineRange!.end,
        DiffNoteRangeEndpoint(
          lineCode: '${_hash}_29_30',
          type: 'new',
          newLine: 30,
        ),
      );
      expect(s.containsPosition(p), true);
      expect(s.containsPosition(p.copyWith(headSha: 'forged')), false);
      expect(s.containsPosition(p.copyWith(newLine: 31)), false);
      expect(s.rangePositionFor(f, lines[2], lines.first), isNull);
      expect(
        s.rangePositionFor(
          f,
          lines.first,
          DiffLine(
            type: lines[2].type,
            text: lines[2].text,
            newLine: lines[2].newLine,
          ),
        ),
        isNull,
      );
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('create multiline $locale $width $dark', (tester) async {
          final comments = _Comments(),
              repo = _Repo(),
              c = _container(repo, comments);
          final l = await _pump(
            tester,
            c,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          // Select in the active locale rather than the English-only helper.
          await tester.tap(find.byTooltip(l.mrDiffDiscussLineButton).first);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(l.mrDiffSelectRangeButton));
          await tester.tap(find.text(l.mrDiffSelectRangeButton));
          await tester.pumpAndSettle();
          expect(find.text(l.mrDiffRangeChooseEnd), findsOneWidget);
          final end = find.byTooltip(l.mrDiffRangeEndButton).at(1);
          await tester.ensureVisible(end);
          await tester.tap(end);
          await tester.pumpAndSettle();
          expect(
            tester.widget<DiffViewer>(find.byType(DiffViewer)).highlightedLines,
            hasLength(3),
          );
          await tester.enterText(
            _draft,
            '  **Range review**\nKeep formatting.  ',
          );
          await _send(tester);
          final p = comments.creates.single.$4;
          expect(p.lineRange!.start!.type, 'old');
          expect(p.lineRange!.end!.type, 'new');
          expect(p.lineRange!.end!.lineCode, '${_hash}_29_30');
          expect(
            comments.creates.single.$3,
            '  **Range review**\nKeep formatting.  ',
          );
          expect(_draft, findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'pending end selection blocks submit and can restore single line with draft',
    (tester) async {
      final comments = _Comments(), c = _container(_Repo(), comments);
      final l = await _pump(tester, c);
      await _select(tester, 0);
      await tester.enterText(_draft, 'Keep draft');
      await tester.tap(find.text(l.mrDiffSelectRangeButton));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(_submit).onPressed, isNull);
      await tester.tap(find.text(l.mrDiffSingleLineButton));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(_draft).controller!.text, 'Keep draft');
      await _send(tester);
      expect(comments.creates.single.$4.lineRange, isNull);
    },
  );
  testWidgets('resize and theme retain range and draft', (tester) async {
    final comments = _Comments(),
        repo = _Repo(),
        c = _container(repo, comments);
    final l = await _pump(tester, c);
    await _range(tester, l);
    await tester.enterText(_draft, 'Range draft');
    await _pump(tester, c, width: 1200, dark: true);
    expect(tester.widget<TextField>(_draft).controller!.text, 'Range draft');
    expect(
      tester.widget<DiffViewer>(find.byType(DiffViewer)).highlightedLines,
      hasLength(3),
    );
    expect(repo.reads, hasLength(1));
    expect(repo.snapshots, hasLength(1));
    expect(comments.creates, isEmpty);
  });
  testWidgets(
    'uncertain range write inspects exact range not a shared end anchor',
    (tester) async {
      final pending = Completer<Discussion>(),
          comments = _Comments()..result = pending.future;
      final c = _container(_Repo(), comments), l = await _pump(tester, c);
      await _range(tester, l);
      await tester.enterText(_draft, 'Retain range');
      await _send(tester, settle: false);
      final p = comments.creates.single.$4;
      pending.completeError(const GitLabServerException('Unconfirmed'));
      await tester.pumpAndSettle();
      comments.pages[1] = Paginated(
        items: [
          Discussion(
            id: 'accepted',
            individualNote: false,
            notes: [Note(id: 1, body: 'Exact accepted range', position: p)],
          ),
          Discussion(
            id: 'single',
            individualNote: false,
            notes: [
              Note(
                id: 2,
                body: 'Unrelated single anchor',
                position: p.copyWith(lineRange: null),
              ),
            ],
          ),
          Discussion(
            id: 'other',
            individualNote: false,
            notes: [
              Note(
                id: 3,
                body: 'Unrelated range',
                position: p.copyWith(
                  lineRange: p.lineRange!.copyWith(start: p.lineRange!.end),
                ),
              ),
            ],
          ),
        ],
      );
      await tester.ensureVisible(find.text(l.mrDiffDiscussionReloadButton));
      await tester.tap(find.text(l.mrDiffDiscussionReloadButton));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is MarkdownViewer && w.data == 'Exact accepted range',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is MarkdownViewer && w.data.startsWith('Unrelated'),
        ),
        findsNothing,
      );
      expect(tester.widget<TextField>(_draft).controller!.text, 'Retain range');
      expect(comments.creates, hasLength(1));
    },
  );

  final directory = Platform.environment['LABFOX_RANGE_CAPTURE'];
  if (directory != null) {
    for (final width in [390.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('synthetic range composer capture $width $dark', (
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
          final base = dark ? LabFoxTheme.dark : LabFoxTheme.light,
              style = base.filledButtonTheme.style!;
          final theme = base.copyWith(
            filledButtonTheme: FilledButtonThemeData(
              style: style.copyWith(
                textStyle: WidgetStatePropertyAll(
                  style.textStyle!.resolve({})!.copyWith(fontFamily: 'Roboto'),
                ),
              ),
            ),
          );
          final repo = _Repo()
                ..detail = _version(
                  files: [
                    const MergeRequestVersionFile(
                      oldPath: 'new.dart',
                      newPath: 'new.dart',
                      diff: _raw,
                    ),
                  ],
                ),
              comments = _Comments(),
              c = _container(repo, comments);
          final l = await _pump(
            tester,
            c,
            width: width,
            height: width < 600 ? 844 : 900,
            theme: theme,
          );
          await _range(tester, l);
          await tester.enterText(
            _draft,
            'Could these lines share one return path?',
          );
          tester.testTextInput.hide();
          await tester.pumpAndSettle();
          await tester.ensureVisible(_submit);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(_captureKey),
          );
          final image = (await tester.runAsync(boundary.toImage))!,
              data = await tester.runAsync(
                () => image.toByteData(format: ui.ImageByteFormat.png),
              );
          await tester.runAsync(() async {
            final file = File(
              '$directory/composer-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
          });
          image.dispose();
          expect(comments.creates, isEmpty);
        });
      }
    }
  }
}
