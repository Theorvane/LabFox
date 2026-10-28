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
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';
import 'package:labfox/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_pending_review_panel.dart';
import 'package:labfox/l10n/app_localizations.dart';

const resource = MergeRequestRef(projectId: 8, iid: 142);
const account = Account(
  instanceUrl: 'https://gitlab.example.com',
  user: User(id: 23, username: 'reviewer', name: 'Reviewer'),
);
const mr = MergeRequest(
  id: 1100,
  projectId: 8,
  iid: 142,
  title: 'Review resource',
  state: 'merged',
  sourceBranch: 'feature',
  targetBranch: 'dev',
);
const body =
    '  **Private review**\n\n![image](https://example.com/private.png)\n  ';
MergeRequestDraftNote draft(
  int id, {
  int author = 23,
  int global = 1100,
  String text = body,
  DiffNotePosition? position,
  String? discussion,
  String? commit,
  String? lineCode,
  bool? resolve,
}) => MergeRequestDraftNote(
  id: id,
  authorId: author,
  mergeRequestId: global,
  note: text,
  position: position,
  discussionId: discussion,
  commitId: commit,
  lineCode: lineCode,
  resolveDiscussion: resolve,
);
const position = DiffNotePosition(
  baseSha: 'base',
  startSha: 'start',
  headSha: 'head',
  oldPath: 'src/old.dart',
  newPath: 'src/new.dart',
  positionType: 'text',
  oldLine: 10,
  newLine: 12,
);
final accountState = StateProvider<Account?>((ref) => account);
final draftSession = StateProvider<Future<MrDraftNotesRepository?>>(
  (ref) async => null,
);
final detailSession = StateProvider<Future<MergeRequestsRepository?>>(
  (ref) async => null,
);
GitLabClient client() => GitLabClient(
  baseUrl: 'https://gitlab.example.com',
  token: 'glpat-xxxxxxxxxxxx',
);

class Drafts extends MrDraftNotesRepository {
  Drafts({int author = 23}) : super(client(), authorId: author);
  final pages = <int, Object>{
    1: Paginated<MergeRequestDraftNote>(items: [draft(5)]),
  };
  final reads = <(int, int, int, int)>[];
  @override
  Future<Paginated<MergeRequestDraftNote>> list({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    reads.add((projectId, iid, page, perPage));
    final value = pages[page]!;
    if (value is Future<Paginated<MergeRequestDraftNote>>) return value;
    if (value is Paginated<MergeRequestDraftNote>) return value;
    throw value;
  }

  @override
  Future<MergeRequestDraftNote> create({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String note,
    DiffNotePosition? position,
  }) => throw StateError('The panel must never write.');
}

class Detail extends MergeRequestsRepository {
  Detail() : super(client());
  Object value = mr;
  final reads = <(int, int)>[];
  @override
  Future<MergeRequest> get({required int projectId, required int iid}) async {
    reads.add((projectId, iid));
    final v = value;
    if (v is Future<MergeRequest>) return v;
    if (v is MergeRequest) return v;
    throw v;
  }
}

class Actions extends MrActionsController {
  @override
  Future<void> build(MergeRequestRef arg) async {}
}

ProviderContainer container(Drafts drafts, Detail detail) {
  final c = ProviderContainer(
    overrides: [
      currentAccountProvider.overrideWith((ref) => ref.watch(accountState)),
      draftSession.overrideWith((ref) async => drafts),
      detailSession.overrideWith((ref) async => detail),
      mrDraftNotesRepositoryProvider.overrideWith(
        (ref) => ref.watch(draftSession),
      ),
      mergeRequestsRepositoryProvider.overrideWith((ref) {
        ref.watch(currentAccountProvider);
        return ref.watch(detailSession);
      }),
      mrActionsControllerProvider.overrideWith(Actions.new),
      mrApprovalsProvider.overrideWith((ref, arg) async => null),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

final captureKey = GlobalKey();
Future<AppLocalizations> pump(
  WidgetTester tester,
  ProviderContainer c, {
  double width = 390,
  double height = 1000,
  bool dark = false,
  double scale = 1,
  Locale locale = const Locale('en'),
  bool settle = true,
  MergeRequestRef ref = resource,
  bool integrated = false,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: RepaintBoundary(
        key: captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme ?? (dark ? LabFoxTheme.dark : LabFoxTheme.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: integrated
              ? MergeRequestDetailScreen(projectId: ref.projectId, iid: ref.iid)
              : Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: MrPendingReviewPanel(mergeRequest: ref),
                    ),
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
  return AppLocalizations.of(tester.element(find.byType(Scaffold).first));
}

void noBody() => expect(
  find.byWidgetPredicate((w) => w is SelectableText && w.data == body),
  findsNothing,
);
void exactBody() => expect(
  find.byWidgetPredicate((w) => w is SelectableText && w.data == body),
  findsOneWidget,
);
void main() {
  testWidgets(
    'shows exact selectable private Markdown without image fetch or publication',
    (t) async {
      final drafts = Drafts(), detail = Detail(), c = container(drafts, detail);
      final l = await pump(t, c);
      exactBody();
      expect(find.byType(Image), findsNothing);
      expect(find.text(l.mrPendingReviewTitle), findsOneWidget);
      expect(find.text(l.mrPendingReviewPrivate), findsOneWidget);
      expect(find.text(l.mrPendingReviewGeneralNote), findsOneWidget);
      expect(find.text(l.mrPendingReviewCount(1)), findsOneWidget);
      expect(detail.reads, [(8, 142)]);
      expect(drafts.reads, [(8, 142, 1, 20)]);
      expect(find.textContaining('1100'), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'detail screen integrates the panel with independently fresh global identity',
    (t) async {
      final drafts = Drafts(), detail = Detail(), c = container(drafts, detail);
      await pump(t, c, integrated: true);
      expect(find.byType(MrPendingReviewPanel), findsOneWidget);
      exactBody();
      expect(drafts.reads, [(8, 142, 1, 20)]);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'pending detail prevents draft dispatch and later reads correct identity',
    (t) async {
      final pending = Completer<MergeRequest>();
      final drafts = Drafts(),
          detail = Detail()..value = pending.future,
          c = container(drafts, detail);
      final l = await pump(t, c, settle: false);
      noBody();
      expect(drafts.reads, isEmpty);
      expect(find.text(l.mrPendingReviewLoading), findsOneWidget);
      pending.complete(mr);
      await t.pumpAndSettle();
      exactBody();
      expect(drafts.reads.length, 1);
    },
  );
  for (final invalid in [
    mr.copyWith(id: 0),
    mr.copyWith(iid: 143),
    mr.copyWith(projectId: 9),
  ]) {
    testWidgets(
      'invalid detail identity prevents draft dispatch ${invalid.id}/${invalid.iid}/${invalid.projectId}',
      (t) async {
        final drafts = Drafts(),
            detail = Detail()..value = invalid,
            c = container(drafts, detail);
        final l = await pump(t, c);
        noBody();
        expect(drafts.reads, isEmpty);
        expect(find.text(l.mrPendingReviewError), findsOneWidget);
        detail.value = mr;
        await t.tap(find.text(l.retry));
        await t.pumpAndSettle();
        exactBody();
        expect(drafts.reads.length, 1);
      },
    );
  }
  testWidgets('failed detail retries only detail before reading drafts', (
    t,
  ) async {
    final drafts = Drafts(),
        detail = Detail()
          ..value = const GitLabForbiddenException('Private detail payload'),
        c = container(drafts, detail);
    final l = await pump(t, c);
    noBody();
    expect(drafts.reads, isEmpty);
    expect(find.text(l.mrPendingReviewError), findsOneWidget);
    expect(find.textContaining('Private detail'), findsNothing);
    detail.value = mr;
    await t.tap(find.text(l.retry));
    await t.pumpAndSettle();
    exactBody();
    expect(detail.reads.length, 2);
  });
  testWidgets('loading and empty states do not infer missing pages', (t) async {
    final pending = Completer<Paginated<MergeRequestDraftNote>>();
    final drafts = Drafts()..pages[1] = pending.future,
        c = container(drafts, Detail());
    final l = await pump(t, c, settle: false);
    noBody();
    expect(find.text(l.mrPendingReviewLoading), findsOneWidget);
    pending.complete(const Paginated(items: []));
    await t.pumpAndSettle();
    expect(find.text(l.mrPendingReviewEmpty), findsOneWidget);
    expect(find.text(l.mrPendingReviewLoadMore), findsNothing);
  });
  testWidgets('empty intermediate page still offers explicit load more', (
    t,
  ) async {
    final drafts = Drafts()
      ..pages[1] = const Paginated<MergeRequestDraftNote>(
        items: [],
        nextPage: 4,
      )
      ..pages[4] = Paginated(items: [draft(5)]);
    final c = container(drafts, Detail());
    final l = await pump(t, c);
    expect(find.text(l.mrPendingReviewEmpty), findsNothing);
    expect(find.text(l.mrPendingReviewMore), findsOneWidget);
    expect(drafts.reads.length, 1);
    await t.tap(find.text(l.mrPendingReviewLoadMore));
    await t.pumpAndSettle();
    exactBody();
    expect(drafts.reads.map((r) => r.$3), [1, 4]);
  });
  testWidgets(
    'duplicate load more blocked while rows stay visible in current session',
    (t) async {
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      final drafts = Drafts()
            ..pages[1] = Paginated(items: [draft(5)], nextPage: 2)
            ..pages[2] = pending.future,
          c = container(drafts, Detail());
      final l = await pump(t, c);
      await t.tap(find.text(l.mrPendingReviewLoadMore));
      await t.pump();
      exactBody();
      expect(
        t
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('mr-pending-load-more')),
            )
            .onPressed,
        isNull,
      );
      pending.complete(
        Paginated(items: [draft(6, text: 'Second private note')]),
      );
      await t.pumpAndSettle();
      expect(find.text(l.mrPendingReviewCount(2)), findsOneWidget);
      expect(drafts.reads.length, 2);
    },
  );
  testWidgets('permission failure hides private rows; retry starts page one', (
    t,
  ) async {
    final drafts = Drafts()
          ..pages[1] = Paginated(items: [draft(5)], nextPage: 2)
          ..pages[2] = const GitLabForbiddenException('Private failure'),
        c = container(drafts, Detail());
    final l = await pump(t, c);
    await t.tap(find.text(l.mrPendingReviewLoadMore));
    await t.pumpAndSettle();
    noBody();
    expect(find.text(l.mrPendingReviewError), findsOneWidget);
    expect(find.textContaining('Private failure'), findsNothing);
    await t.tap(find.text(l.retry));
    await t.pumpAndSettle();
    exactBody();
    expect(drafts.reads.map((r) => r.$3), [1, 2, 1]);
  });
  testWidgets(
    'refresh removes loaded body immediately and failure cannot restore it',
    (t) async {
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      final drafts = Drafts(), c = container(drafts, Detail());
      final l = await pump(t, c);
      drafts.pages[1] = pending.future;
      await t.tap(find.byTooltip(l.mrPendingReviewRefresh));
      await t.pump();
      noBody();
      pending.completeError(const GitLabForbiddenException('Private refresh'));
      await t.pumpAndSettle();
      noBody();
      expect(find.text(l.mrPendingReviewError), findsOneWidget);
    },
  );
  testWidgets(
    'detail refresh hides private rows until a fresh authenticated identity returns',
    (t) async {
      final pending = Completer<MergeRequest>();
      final drafts = Drafts(), detail = Detail(), c = container(drafts, detail);
      final l = await pump(t, c);
      exactBody();
      detail.value = pending.future;
      c.invalidate(mergeRequestControllerProvider(resource));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      noBody();
      expect(drafts.reads.length, 1);
      pending.completeError(
        const GitLabForbiddenException('Private detail refresh'),
      );
      await t.pumpAndSettle();
      noBody();
      expect(find.text(l.mrPendingReviewError), findsOneWidget);
      detail.value = mr;
      await t.tap(find.text(l.retry));
      await t.pumpAndSettle();
      exactBody();
      expect(drafts.reads.length, 2);
      expect(t.takeException(), isNull);
    },
  );
  for (final change in ['account', 'instance', 'client', 'sign-out']) {
    testWidgets(
      'private body disappears on $change until fresh detail and draft reads',
      (t) async {
        final drafts = Drafts(), c = container(drafts, Detail());
        await pump(t, c);
        exactBody();
        final pending = Completer<MergeRequest>();
        final nextDetail = Detail()..value = pending.future;
        final author = change == 'account' ? 24 : 23;
        final global = change == 'instance' ? 1200 : 1100;
        final next = Drafts(author: author)
          ..pages[1] = Paginated(
            items: [
              draft(
                6,
                author: author,
                global: global,
                text: 'Current private note',
              ),
            ],
          );
        if (change == 'account') {
          c.read(accountState.notifier).state = account.copyWith(
            user: const User(id: 24, username: 'other', name: 'Other'),
          );
        }
        if (change == 'instance') {
          c.read(accountState.notifier).state = account.copyWith(
            instanceUrl: 'https://other.example.com',
          );
        }
        if (change == 'sign-out') c.read(accountState.notifier).state = null;
        c.read(detailSession.notifier).state = Future.value(nextDetail);
        c.read(draftSession.notifier).state = Future.value(next);
        await t.pump();
        await t.pump(const Duration(milliseconds: 100));
        noBody();
        expect(next.reads, isEmpty);
        if (change != 'sign-out') {
          pending.complete(mr.copyWith(id: global));
          await t.pumpAndSettle();
          expect(find.text('Current private note'), findsOneWidget);
          expect(next.reads.length, 1);
        } else {
          expect(find.byKey(const ValueKey('mr-pending-panel')), findsNothing);
        }
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'resource replacement cancels old pagination error without a toast',
    (t) async {
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      final drafts = Drafts()
            ..pages[1] = Paginated(items: [draft(5)], nextPage: 2)
            ..pages[2] = pending.future,
          detail = Detail(),
          c = container(drafts, detail);
      final l = await pump(t, c);
      await t.tap(find.text(l.mrPendingReviewLoadMore));
      await t.pump();
      detail.value = mr.copyWith(iid: 143, id: 1200);
      drafts.pages[1] = Paginated(
        items: [draft(7, global: 1200, text: 'New resource note')],
      );
      await pump(t, c, ref: const MergeRequestRef(projectId: 8, iid: 143));
      pending.completeError(const GitLabForbiddenException('Old resource'));
      await t.pumpAndSettle();
      noBody();
      expect(find.text('New resource note'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  for (final kind in [
    'regular placeholder',
    'text',
    'multiline',
    'image',
    'file',
    'future',
    'line-code only',
    'reply',
    'commit',
  ]) {
    testWidgets(
      'original metadata is visible without anchor inference: $kind',
      (t) async {
        final p = switch (kind) {
          'regular placeholder' => const DiffNotePosition(positionType: 'text'),
          'text' => position,
          'multiline' => position.copyWith(
            lineRange: const DiffNoteLineRange(
              start: DiffNoteRangeEndpoint(lineCode: 'original-a', type: 'new'),
              end: DiffNoteRangeEndpoint(lineCode: 'original-b', type: 'new'),
            ),
          ),
          'image' => const DiffNotePosition(
            positionType: 'image',
            oldPath: 'old.png',
            newPath: 'new.png',
          ),
          'file' => const DiffNotePosition(
            positionType: 'file',
            oldPath: 'old.dart',
            newPath: 'new.dart',
          ),
          'future' => const DiffNotePosition(positionType: 'future'),
          _ => null,
        };
        final drafts = Drafts()
          ..pages[1] = Paginated(
            items: [
              draft(
                5,
                position: p,
                lineCode: kind == 'line-code only'
                    ? 'original-line-code'
                    : null,
                discussion: kind == 'reply' ? 'original-thread' : null,
                resolve: kind == 'reply' ? true : null,
                commit: kind == 'commit' ? 'original-commit' : null,
              ),
            ],
          );
        final c = container(drafts, Detail());
        final l = await pump(t, c);
        exactBody();
        final label = switch (kind) {
          'regular placeholder' => l.mrPendingReviewGeneralNote,
          'text' => l.mrPendingReviewTextNote,
          'multiline' => l.mrPendingReviewMultilineNote,
          'image' => l.mrPendingReviewImageNote,
          'file' => l.mrPendingReviewFileNote,
          'future' || 'line-code only' => l.mrPendingReviewPositionedNote,
          'reply' => l.mrPendingReviewReplyNote,
          _ => l.mrPendingReviewCommitNote,
        };
        expect(find.text(label), findsOneWidget);
        if (kind == 'text') {
          expect(
            find.text(l.mrPendingReviewOldPath('src/old.dart')),
            findsOneWidget,
          );
          expect(
            find.text(l.mrPendingReviewNewPath('src/new.dart')),
            findsOneWidget,
          );
          expect(find.text(l.mrPendingReviewOldLine('10')), findsOneWidget);
          expect(find.text(l.mrPendingReviewNewLine('12')), findsOneWidget);
        }
        if (kind == 'multiline') {
          expect(find.text(l.mrPendingReviewNewLine('12')), findsNothing);
        }
        if (kind == 'reply') {
          expect(find.text(l.mrPendingReviewResolve), findsOneWidget);
        }
        if (kind == 'commit') {
          expect(
            find.text(l.mrPendingReviewCommit('original-commit')),
            findsOneWidget,
          );
        }
        expect(find.byType(Image), findsNothing);
        expect(t.takeException(), isNull);
      },
    );
  }
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('localized responsive private panel $locale $width $dark', (
          t,
        ) async {
          final drafts = Drafts()
                ..pages[1] = Paginated(
                  items: [draft(5, position: position)],
                  nextPage: 3,
                ),
              c = container(drafts, Detail());
          final l = await pump(
            t,
            c,
            locale: Locale(locale),
            width: width,
            dark: dark,
          );
          exactBody();
          expect(find.text(l.mrPendingReviewTitle), findsOneWidget);
          expect(find.text(l.mrPendingReviewPrivate), findsOneWidget);
          expect(find.text(l.mrPendingReviewCount(1)), findsOneWidget);
          expect(find.text(l.mrPendingReviewMore), findsOneWidget);
          expect(
            t.getSize(find.byKey(const ValueKey('mr-pending-panel'))).width,
            lessThanOrEqualTo(1000),
          );
          expect(t.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'narrow large text and long paths/bodies remain bounded and scrollable',
    (t) async {
      final long = '**Exact Markdown**\n' * 100;
      final drafts = Drafts()
            ..pages[1] = Paginated(
              items: [
                draft(
                  5,
                  text: long,
                  position: position.copyWith(
                    newPath: '${'segment/' * 60}file.dart',
                  ),
                ),
              ],
              nextPage: 3,
            ),
          c = container(drafts, Detail());
      final l = await pump(t, c, width: 320, height: 700, scale: 2);
      expect(
        find.byWidgetPredicate((w) => w is SelectableText && w.data == long),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
      await t.ensureVisible(find.text(l.mrPendingReviewLoadMore));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'resize and theme change preserve loaded pages without another read',
    (t) async {
      final drafts = Drafts()
            ..pages[1] = Paginated(items: [draft(5)], nextPage: 2)
            ..pages[2] = Paginated(items: [draft(6, text: 'Second note')]),
          c = container(drafts, Detail());
      final l = await pump(t, c);
      await t.tap(find.text(l.mrPendingReviewLoadMore));
      await t.pumpAndSettle();
      expect(drafts.reads.length, 2);
      await pump(t, c, width: 1200, dark: true);
      expect(find.text(l.mrPendingReviewCount(2)), findsOneWidget);
      expect(drafts.reads.length, 2);
      exactBody();
      expect(t.takeException(), isNull);
    },
  );
  if (Platform.environment['LABFOX_PENDING_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('synthetic pending review capture $width $dark', (t) async {
          final sdk = Platform.environment['FLUTTER_ROOT']!;
          await t.runAsync(() async {
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
              await loader.load();
            }
          });
          final base = dark ? LabFoxTheme.dark : LabFoxTheme.light;
          final button = base.outlinedButtonTheme.style!;
          final theme = base.copyWith(
            textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: button.copyWith(
                textStyle: WidgetStatePropertyAll(
                  button.textStyle!.resolve({})!.copyWith(fontFamily: 'Roboto'),
                ),
              ),
            ),
          );
          final drafts = Drafts()
                ..pages[1] = Paginated(
                  items: [
                    draft(
                      5,
                      text: 'Could this return path be shared?',
                      position: position,
                    ),
                    draft(
                      6,
                      text: 'Please add a regression for an empty page.',
                      discussion: 'original-thread',
                      resolve: true,
                    ),
                  ],
                  nextPage: 2,
                ),
              c = container(drafts, Detail());
          await pump(
            t,
            c,
            width: width,
            height: width < 600 ? 844 : 900,
            dark: dark,
            theme: theme,
          );
          expect(t.takeException(), isNull);
          final boundary = t.renderObject<RenderRepaintBoundary>(
            find.byKey(captureKey),
          );
          final image = (await t.runAsync(boundary.toImage))!;
          final data = await t.runAsync(
            () => image.toByteData(format: ui.ImageByteFormat.png),
          );
          await t.runAsync(() async {
            final file = File(
              '$directory/pending-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
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
