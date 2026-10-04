import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/mr_changes_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/diff/data/diff_repository.dart';
import 'package:labfox/features/diff/presentation/controllers/diff_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_review_snapshot_controller.dart';

const _arg = MergeRequestRef(projectId: 8, iid: 142);
const _raw =
    '@@ -27,2 +29,2 @@\n final count = items.length;\n-return count;\n+return pending.length;\n';
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
    if (list is Paginated<MergeRequestDiffVersion>)
      return list as Paginated<MergeRequestDiffVersion>;
    if (list is Future<Paginated<MergeRequestDiffVersion>>)
      return list as Future<Paginated<MergeRequestDiffVersion>>;
    throw list;
  }

  @override
  Future<MergeRequestDiffVersion> mergeRequestDiffVersion({
    required int projectId,
    required int iid,
    required int versionId,
  }) async {
    snapshots.add((projectId, iid, versionId));
    if (detail is MergeRequestDiffVersion)
      return detail as MergeRequestDiffVersion;
    if (detail is Future<MergeRequestDiffVersion>)
      return detail as Future<MergeRequestDiffVersion>;
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
  @override
  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    reads++;
    if (readError != null) throw readError!;
    return const Paginated(items: []);
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
  bool dark = false,
  Locale locale = const Locale('en'),
  int iid = 142,
  bool settle = true,
}) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: dark ? LabFoxTheme.dark : LabFoxTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MrChangesScreen(projectId: 8, iid: iid),
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
  await tester.ensureVisible(_submit);
  await tester.tap(_submit);
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
        testWidgets('select and create $locale width=$width dark=$dark', (
          tester,
        ) async {
          final comments = _Comments(), repo = _Repo();
          final c = _container(repo, comments);
          final l10n = await _pump(
            tester,
            c,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          final action = find.byTooltip(l10n.mrDiffDiscussLineButton).first;
          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(find.byType(DiffViewer), findsOneWidget);
          await tester.enterText(
            _draft,
            '  **Inline review**\n\nKeep formatting.  ',
          );
          await _send(tester);
          expect(comments.creates, hasLength(1));
          final p = comments.creates.single.$4;
          expect(p.oldLine, 27);
          expect(p.newLine, 29);
          expect(p.baseSha, 'base');
          expect(p.headSha, 'head');
          expect(p.startSha, 'start');
          expect(p.oldPath, 'old.dart');
          expect(p.newPath, 'new.dart');
          expect(
            comments.creates.single.$3,
            '  **Inline review**\n\nKeep formatting.  ',
          );
          expect(_draft, findsNothing);
          expect(find.text(l10n.mrDiffDiscussionCreated), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final index in [1, 2]) {
    testWidgets('creates side coordinates at index $index', (tester) async {
      final comments = _Comments();
      final c = _container(_Repo(), comments);
      await _pump(tester, c);
      await _select(tester, index);
      await tester.enterText(_draft, 'Review');
      await _send(tester);
      final p = comments.creates.single.$4;
      expect(p.oldLine, index == 1 ? 28 : null);
      expect(p.newLine, index == 2 ? 30 : null);
    });
  }
  testWidgets('resize and theme preserve selection and unsent draft', (
    tester,
  ) async {
    final comments = _Comments();
    final c = _container(_Repo(), comments);
    await _pump(tester, c);
    await _select(tester, 0);
    await tester.enterText(_draft, 'Unsent draft');
    await _pump(tester, c, width: 1200, dark: true);
    expect(tester.widget<TextField>(_draft).controller!.text, 'Unsent draft');
    expect(
      tester
          .widget<DiffViewer>(find.byType(DiffViewer))
          .highlightedLine!
          .newLine,
      29,
    );
    expect(comments.creates, isEmpty);
  });
  testWidgets('cancel is explicit and empty drafts cannot submit', (
    tester,
  ) async {
    final comments = _Comments();
    final c = _container(_Repo(), comments);
    final l = await _pump(tester, c);
    await _select(tester, 0);
    expect(tester.widget<FilledButton>(_submit).onPressed, isNull);
    await tester.enterText(_draft, '  ');
    expect(tester.widget<FilledButton>(_submit).onPressed, isNull);
    await tester.enterText(_draft, 'Draft');
    await tester.tap(find.text(l.mrDiffDiscussionCancel));
    await tester.pumpAndSettle();
    expect(_draft, findsNothing);
    expect(comments.creates, isEmpty);
  });
  testWidgets('pending write blocks duplicate actions and draft dismissal', (
    tester,
  ) async {
    final pending = Completer<Discussion>();
    final comments = _Comments()..result = pending.future;
    final c = _container(_Repo(), comments);
    final l = await _pump(tester, c);
    await _select(tester, 0);
    await tester.enterText(_draft, 'Draft');
    await _send(tester, settle: false);
    expect(tester.widget<TextField>(_draft).enabled, false);
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, l.mrDiffDiscussionCancel),
          )
          .onPressed,
      isNull,
    );
    expect(find.byTooltip(l.mrDiffDiscussLineButton), findsNothing);
    await _send(tester, settle: false);
    expect(comments.creates, hasLength(1));
    pending.complete(Discussion(id: 'new', individualNote: false, notes: []));
    await tester.pumpAndSettle();
    expect(_draft, findsNothing);
  });
  for (final error in [
    const GitLabForbiddenException('Forbidden'),
    const GitLabServerException('Unconfirmed'),
  ]) {
    testWidgets(
      'uncertain failure retains draft and requires fresh discussions $error',
      (tester) async {
        final pending = Completer<Discussion>();
        final comments = _Comments()..result = pending.future;
        final c = _container(_Repo(), comments);
        final l = await _pump(tester, c);
        await _select(tester, 0);
        await tester.enterText(_draft, 'Retained draft');
        await _send(tester, settle: false);
        pending.completeError(error);
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(_draft).controller!.text,
          'Retained draft',
        );
        expect(tester.widget<FilledButton>(_submit).onPressed, isNull);
        await _send(tester);
        expect(comments.creates, hasLength(1));
        comments.readError = const GitLabServerException('Read failure');
        await tester.tap(find.text(l.mrDiffDiscussionReloadButton));
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(_submit).onPressed, isNull);
        comments.readError = null;
        comments.result = null;
        await tester.tap(find.text(l.mrDiffDiscussionReloadButton));
        await tester.pumpAndSettle();
        await _send(tester);
        expect(comments.creates, hasLength(2));
      },
    );
  }
  for (final fail in [false, true]) {
    testWidgets(
      'account replacement resets composer and isolates late write fail=$fail',
      (tester) async {
        final pending = Completer<Discussion>();
        final old = _Comments()..result = pending.future;
        final c = _container(_Repo(), old);
        await _pump(tester, c);
        await _select(tester, 0);
        await tester.enterText(_draft, 'Old draft');
        await _send(tester, settle: false);
        final next = _Comments();
        addTearDown(next.client.close);
        final nextRepo = _Repo();
        addTearDown(nextRepo.client.close);
        c.read(_commentsSession.notifier).state = Future.value(next);
        c.read(_session.notifier).state = Future.value(nextRepo);
        await tester.pumpAndSettle();
        expect(_draft, findsNothing);
        await _select(tester, 0);
        await tester.enterText(_draft, 'New draft');
        if (fail) {
          pending.completeError(const GitLabServerException('Old failure'));
        } else {
          pending.complete(
            Discussion(id: 'old', individualNote: false, notes: []),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(_draft).controller!.text, 'New draft');
        expect(next.creates, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('MR replacement resets composer', (tester) async {
    final c = _container(_Repo(), _Comments());
    await _pump(tester, c);
    await _select(tester, 0);
    await tester.enterText(_draft, 'Old MR draft');
    await _pump(tester, c, iid: 143);
    expect(_draft, findsNothing);
  });
  testWidgets('snapshot failure retry is read-only', (tester) async {
    final repo = _Repo()..list = const GitLabServerException('Read failure');
    final comments = _Comments();
    final c = _container(repo, comments);
    final l = await _pump(tester, c);
    expect(find.text(l.retry), findsOneWidget);
    expect(find.byTooltip(l.mrDiffDiscussLineButton), findsNothing);
    repo.list = Paginated(items: [_version()]);
    await tester.tap(find.text(l.retry));
    await tester.pumpAndSettle();
    expect(find.byTooltip(l.mrDiffDiscussLineButton), findsNWidgets(3));
    expect(comments.creates, isEmpty);
  });
  test('positioned writes share root comment reservation', () async {
    final comments = _Comments();
    final c = _container(_Repo(), comments);
    final snapshot = await c.read(
      mrReviewSnapshotControllerProvider(_arg).future,
    );
    final f = snapshot.files.single;
    final p = snapshot.positionFor(f, f.hunks.single.lines.first)!;
    await c.read(mrDiscussionsControllerProvider(_arg).future);
    final pending = Completer<Discussion>();
    comments.result = pending.future;
    final ctrl = c.read(mrDiscussionsControllerProvider(_arg).notifier);
    final first = ctrl.createPositioned(body: 'Draft', position: p);
    await Future<void>.delayed(Duration.zero);
    expect(await ctrl.post('Other'), false);
    expect(await ctrl.createPositioned(body: 'Other', position: p), false);
    expect(comments.creates, hasLength(1));
    expect(comments.posts, isEmpty);
    pending.complete(Discussion(id: 'new', individualNote: false, notes: []));
    expect(await first, true);
  });
  test('forged positions are rejected without dispatch', () async {
    final comments = _Comments();
    final c = _container(_Repo(), comments);
    final snapshot = await c.read(
      mrReviewSnapshotControllerProvider(_arg).future,
    );
    final f = snapshot.files.single;
    final p = snapshot.positionFor(f, f.hunks.single.lines.first)!;
    await c.read(mrDiscussionsControllerProvider(_arg).future);
    expect(
      await c
          .read(mrDiscussionsControllerProvider(_arg).notifier)
          .createPositioned(
            body: 'Draft',
            position: p.copyWith(headSha: 'forged'),
          ),
      false,
    );
    expect(comments.creates, isEmpty);
  });
}
