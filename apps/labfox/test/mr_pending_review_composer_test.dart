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
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/gitlab_client_provider.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
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
const body =
    '  **Private note**\n\n![image](https://example.com/private.png)\n  ';
MergeRequest mr({int id = 1100, int iid = 142, int? project = 8}) =>
    MergeRequest(
      id: id,
      iid: iid,
      projectId: project,
      title: 'Review resource',
      state: 'opened',
      sourceBranch: 'feature',
      targetBranch: 'dev',
    );
MergeRequestDraftNote draft(
  int id, {
  String note = body,
  int author = 23,
  int global = 1100,
}) => MergeRequestDraftNote(
  id: id,
  authorId: author,
  mergeRequestId: global,
  note: note,
);
Paginated<MergeRequestDraftNote> page(
  List<MergeRequestDraftNote> items, {
  int? next,
}) => Paginated(items: items, nextPage: next);
final accountState = StateProvider<Account?>((ref) => account);
final draftState = StateProvider<Future<MrDraftNotesRepository?>>(
  (ref) async => null,
);
final detailState = StateProvider<Future<MergeRequestsRepository?>>(
  (ref) async => null,
);
final clientState = StateProvider<GitLabClient>(
  (ref) => throw UnimplementedError(),
);
final commentsState = StateProvider<Future<CommentsRepository?>>(
  (ref) async => null,
);
GitLabClient client() => GitLabClient(
  baseUrl: 'https://gitlab.example.com',
  token: 'glpat-xxxxxxxxxxxx',
);

class Drafts extends MrDraftNotesRepository {
  Drafts(this.api) : super(api, authorId: 23);
  final GitLabClient api;
  Object result = draft(7);
  final writes = <(int, int, int, String, DiffNotePosition?)>[];
  final reads = <int>[];
  final pages = <int, Object>{1: page([])};
  @override
  Future<MergeRequestDraftNote> create({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String note,
    DiffNotePosition? position,
  }) async {
    writes.add((projectId, iid, mergeRequestId, note, position));
    final value = result;
    if (value is Future<MergeRequestDraftNote>) return value;
    if (value is MergeRequestDraftNote) {
      pages[1] = page([value]);
      return value;
    }
    throw value;
  }

  @override
  Future<Paginated<MergeRequestDraftNote>> list({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    expect(projectId, 8);
    expect(iid, 142);
    reads.add(page);
    final value = pages[page]!;
    if (value is Future<Paginated<MergeRequestDraftNote>>) return value;
    if (value is Paginated<MergeRequestDraftNote>) return value;
    throw value;
  }
}

class Details extends MergeRequestsRepository {
  Details(super.client);
  Object value = mr();
  int reads = 0;
  @override
  Future<MergeRequest> get({required int projectId, required int iid}) async {
    reads++;
    final v = value;
    if (v is Future<MergeRequest>) return v;
    if (v is MergeRequest) return v;
    throw v;
  }
}

class Comments extends CommentsRepository {
  Comments(super.client);
  Object value = const Paginated<Discussion>(items: []);
  final posts = <String>[];
  @override
  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    final v = value;
    if (v is Future<Paginated<Discussion>>) return v;
    if (v is Paginated<Discussion>) return v;
    throw v;
  }

  @override
  Future<Note> post({
    required NoteableType type,
    required int projectId,
    required int iid,
    required String body,
  }) async {
    posts.add(body);
    return const Note(id: 9, body: 'Public');
  }
}

class Events implements Analytics {
  final names = <String>[];
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    names.add(name);
  }
}

class Actions extends MrActionsController {
  @override
  Future<void> build(MergeRequestRef arg) async {}
}

class Fixture {
  Fixture() {
    c = ProviderContainer(
      overrides: [
        currentAccountProvider.overrideWith((ref) => ref.watch(accountState)),
        clientState.overrideWith((ref) => api),
        draftState.overrideWith((ref) async => drafts),
        detailState.overrideWith((ref) async => details),
        commentsState.overrideWith((ref) async => comments),
        mrDraftNotesRepositoryProvider.overrideWith((ref) {
          ref.watch(clientState);
          return ref.watch(draftState);
        }),
        mergeRequestsRepositoryProvider.overrideWith((ref) {
          ref.watch(clientState);
          return ref.watch(detailState);
        }),
        commentsRepositoryProvider.overrideWith((ref) {
          ref.watch(clientState);
          return ref.watch(commentsState);
        }),
        gitLabClientProvider.overrideWith(
          (ref) async => ref.watch(clientState),
        ),
        mrApprovalsProvider.overrideWith((ref, arg) async => null),
        mrActionsControllerProvider.overrideWith(Actions.new),
        analyticsProvider.overrideWithValue(events),
      ],
    );
    addTearDown(c.dispose);
    addTearDown(api.close);
  }
  final api = client();
  final events = Events();
  late final drafts = Drafts(api);
  late final details = Details(api);
  late final comments = Comments(api);
  late final ProviderContainer c;
}

final captureKey = GlobalKey();
Future<AppLocalizations> pump(
  WidgetTester t,
  Fixture f, {
  double width = 390,
  double height = 1000,
  bool dark = false,
  double scale = 1,
  double keyboard = 0,
  Locale locale = const Locale('en'),
  bool settle = true,
  bool integrated = false,
  MergeRequestRef arg = resource,
  ThemeData? theme,
}) async {
  t.view.physicalSize = Size(width, height);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: f.c,
      child: RepaintBoundary(
        key: captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme ?? (dark ? LabFoxTheme.dark : LabFoxTheme.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: child!,
          ),
          home: integrated
              ? MergeRequestDetailScreen(projectId: arg.projectId, iid: arg.iid)
              : Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: MrPendingReviewPanel(mergeRequest: arg),
                    ),
                  ),
                ),
        ),
      ),
    ),
  );
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
  }
  return AppLocalizations.of(t.element(find.byType(Scaffold).first));
}

const openKey = ValueKey('mr-pending-compose-open');
const inputKey = ValueKey('mr-pending-compose-input');
const saveKey = ValueKey('mr-pending-compose-save');
const cancelKey = ValueKey('mr-pending-compose-cancel');
const inspectKey = ValueKey('mr-pending-compose-inspect');
const ackKey = ValueKey('mr-pending-compose-acknowledge');
Future<void> open(WidgetTester t) async {
  await t.ensureVisible(find.byKey(openKey));
  await t.tap(find.byKey(openKey));
  await t.pumpAndSettle();
}

Future<void> tap(WidgetTester t, Key key, {bool settle = true}) async {
  await t.ensureVisible(find.byKey(key));
  await t.tap(find.byKey(key));
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> enter(WidgetTester t, [String text = body]) async {
  await t.enterText(find.byKey(inputKey), text);
  await t.pump();
}

bool enabled(WidgetTester t, Key key) =>
    t.widget<ButtonStyleButton>(find.byKey(key)).onPressed != null;
Future<void> fail(WidgetTester t, Fixture f) async {
  f.drafts.result = const GitLabServerException('Never expose this payload');
  await enter(t);
  await tap(t, saveKey);
  expect(f.drafts.writes.length, 1);
  expect(enabled(t, saveKey), false);
}

Finder inDialog(Finder finder) =>
    find.descendant(of: find.byType(AlertDialog), matching: finder);
void hidden() => expect(find.byKey(inputKey), findsNothing);
void main() {
  testWidgets(
    'opens private composer and saves exact Markdown once without public fallback',
    (t) async {
      final f = Fixture();
      final l = await pump(t, f);
      await open(t);
      expect(find.text(l.mrPendingComposeTitle), findsOneWidget);
      expect(enabled(t, saveKey), false);
      await enter(t);
      expect(enabled(t, saveKey), true);
      await tap(t, saveKey);
      expect(find.byType(AlertDialog), findsNothing);
      expect(f.drafts.writes, [(8, 142, 1100, body, null)]);
      expect(f.comments.posts, isEmpty);
      expect(f.events.names, isEmpty);
      expect(find.text(l.mrPendingComposeSaved), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is SelectableText && w.data == body),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'busy save disables editing duplicates cancellation and back navigation',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await enter(t);
      final pending = Completer<MergeRequestDraftNote>();
      f.drafts.result = pending.future;
      await tap(t, saveKey, settle: false);
      expect(enabled(t, saveKey), false);
      expect(enabled(t, cancelKey), false);
      expect(t.widget<TextField>(find.byKey(inputKey)).enabled, false);
      await t.binding.handlePopRoute();
      await t.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(f.drafts.writes.length, 1);
      pending.complete(draft(7));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
  testWidgets('ordinary cancel discards only the private local draft', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f);
    await open(t);
    await enter(t);
    await tap(t, cancelKey);
    await open(t);
    expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, isEmpty);
    expect(f.drafts.writes, isEmpty);
  });
  testWidgets(
    'fresh detail loading during own save does not dispose its originating view',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await enter(t);
      final pending = Completer<MergeRequest>();
      f.details.value = pending.future;
      await tap(t, saveKey, settle: false);
      expect(f.drafts.writes, isEmpty);
      expect(find.byKey(inputKey), findsOneWidget);
      pending.complete(mr());
      await t.pumpAndSettle();
      expect(f.drafts.writes.length, 1);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
  testWidgets(
    'failed dispatched save retains editable exact text and requires visible inspection acknowledgement',
    (t) async {
      final f = Fixture();
      final l = await pump(t, f);
      await open(t);
      await fail(t, f);
      expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, body);
      expect(t.widget<TextField>(find.byKey(inputKey)).enabled, true);
      expect(find.textContaining('Never expose'), findsNothing);
      expect(find.text(l.mrPendingComposeUncertain), findsOneWidget);
      f.drafts.pages.addAll({
        1: page([draft(2)], next: 3),
        3: page([], next: 8),
        8: page([draft(9, note: 'Different saved note')]),
      });
      final before = f.drafts.reads.length;
      await tap(t, inspectKey);
      expect(f.drafts.reads.sublist(before), containsAllInOrder([1, 3, 8]));
      expect(f.drafts.reads.sublist(before).where((p) => p != 1), [3, 8]);
      expect(find.text(l.mrPendingComposeInspectionTitle), findsOneWidget);
      expect(
        inDialog(
          find.byWidgetPredicate((w) => w is SelectableText && w.data == body),
        ),
        findsOneWidget,
      );
      expect(inDialog(find.text('Different saved note')), findsOneWidget);
      expect(find.byKey(ackKey), findsOneWidget);
      expect(enabled(t, saveKey), false);
      expect(f.drafts.writes.length, 1);
      await t.ensureVisible(find.byKey(ackKey));
      await t.tap(find.byKey(ackKey));
      await t.pumpAndSettle();
      expect(enabled(t, saveKey), true);
      f.drafts.result = draft(11);
      await tap(t, saveKey);
      expect(f.drafts.writes.length, 2);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
  testWidgets('editing after inspection resets retry acknowledgement', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f);
    await open(t);
    await fail(t, f);
    await tap(t, inspectKey);
    await t.ensureVisible(find.byKey(ackKey));
    await t.tap(find.byKey(ackKey));
    await t.pumpAndSettle();
    expect(enabled(t, saveKey), true);
    await enter(t, 'Changed note');
    expect(enabled(t, saveKey), false);
    expect(t.widget<CheckboxListTile>(find.byKey(ackKey)).value, false);
  });
  testWidgets(
    'failed later inspection page hides all partial rows and never enables retry',
    (t) async {
      final f = Fixture();
      final l = await pump(t, f);
      await open(t);
      await fail(t, f);
      f.drafts.pages.addAll({
        1: page([draft(1, note: 'Never expose partial inspection')], next: 2),
        2: const GitLabForbiddenException('Private error payload'),
      });
      await tap(t, inspectKey);
      expect(
        inDialog(find.text('Never expose partial inspection')),
        findsNothing,
      );
      expect(find.textContaining('Private error payload'), findsNothing);
      expect(find.text(l.mrPendingComposeInspectError), findsOneWidget);
      expect(find.byKey(ackKey), findsNothing);
      expect(enabled(t, saveKey), false);
      expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, body);
      expect(f.drafts.writes.length, 1);
    },
  );
  testWidgets(
    'reopened uncertain composer still requires inspection before a new save',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await fail(t, f);
      await tap(t, cancelKey);
      await open(t);
      await enter(t, 'Another note');
      expect(enabled(t, saveKey), false);
      expect(find.byKey(inspectKey), findsOneWidget);
      expect(f.drafts.writes.length, 1);
    },
  );
  testWidgets(
    'initial discussion preparation failure has read-only retry preserving typed text',
    (t) async {
      final f = Fixture();
      f.comments.value = const GitLabForbiddenException('Do not expose');
      final l = await pump(t, f);
      await open(t);
      await enter(t);
      expect(find.text(l.mrPendingComposePrepareError), findsOneWidget);
      expect(enabled(t, saveKey), false);
      f.comments.value = const Paginated<Discussion>(items: []);
      await tap(t, const ValueKey('mr-pending-compose-prepare-retry'));
      await t.pumpAndSettle();
      expect(enabled(t, saveKey), true);
      expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, body);
      expect(f.drafts.writes, isEmpty);
    },
  );
  testWidgets(
    'preflight detail failure retains input and retries reads without save replay',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await enter(t);
      f.details.value = const GitLabServerException('Hidden detail');
      await tap(t, saveKey);
      expect(f.drafts.writes, isEmpty);
      expect(find.byKey(inputKey), findsOneWidget);
      expect(find.byKey(inspectKey), findsNothing);
      f.details.value = mr();
      await tap(t, const ValueKey('mr-pending-compose-prepare-retry'));
      await t.pumpAndSettle();
      expect(f.drafts.writes, isEmpty);
      expect(enabled(t, saveKey), true);
      expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, body);
    },
  );
  for (final change in [
    'account',
    'instance',
    'sign-out',
    'draft repository',
    'detail repository',
    'comments repository',
    'resource',
    'client',
  ]) {
    testWidgets('$change replacement hides and discards private input', (
      t,
    ) async {
      final f = Fixture();
      final l = await pump(t, f);
      await open(t);
      await enter(t);
      switch (change) {
        case 'account':
          f.c.read(accountState.notifier).state = account.copyWith(
            user: const User(id: 24, username: 'other', name: 'Other'),
          );
        case 'instance':
          f.c.read(accountState.notifier).state = account.copyWith(
            instanceUrl: 'https://other.example.com',
          );
        case 'sign-out':
          f.c.read(accountState.notifier).state = null;
        case 'draft repository':
          f.c.read(draftState.notifier).state = Future.value(Drafts(f.api));
        case 'detail repository':
          f.c.read(detailState.notifier).state = Future.value(Details(f.api));
        case 'comments repository':
          f.c.read(commentsState.notifier).state = Future.value(
            Comments(f.api),
          );
        case 'client':
          final replacement = client();
          addTearDown(replacement.close);
          f.c.read(clientState.notifier).state = replacement;
        case 'resource':
          await pump(t, f, arg: const MergeRequestRef(projectId: 8, iid: 143));
      }
      await t.pumpAndSettle();
      hidden();
      expect(find.text(l.mrPendingComposeChanged), findsOneWidget);
      expect(enabled(t, saveKey), false);
      expect(f.drafts.writes, isEmpty);
      expect(find.text(body), findsNothing);
    });
  }
  for (final lateError in [false, true]) {
    testWidgets(
      'old-session save lateError=$lateError cannot toast or expose private input',
      (t) async {
        final f = Fixture();
        final l = await pump(t, f);
        await open(t);
        await enter(t);
        final pending = Completer<MergeRequestDraftNote>();
        f.drafts.result = pending.future;
        await tap(t, saveKey, settle: false);
        expect(f.drafts.writes.length, 1);
        f.c.read(accountState.notifier).state = null;
        await t.pumpAndSettle();
        hidden();
        if (lateError) {
          pending.completeError(
            const GitLabServerException('Old private error'),
          );
        } else {
          pending.complete(draft(7));
        }
        await t.pumpAndSettle();
        expect(find.text(l.mrPendingComposeSaved), findsNothing);
        expect(find.textContaining('Old private'), findsNothing);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('account switch back cannot restore an obsolete dialog input', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f);
    await open(t);
    await enter(t);
    f.c.read(accountState.notifier).state = null;
    await t.pumpAndSettle();
    f.c.read(accountState.notifier).state = account;
    await t.pumpAndSettle();
    hidden();
    expect(find.text(body), findsNothing);
  });
  testWidgets(
    'inspection replacement clears saved snapshot and obsolete late pages',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await fail(t, f);
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      f.drafts.pages[1] = pending.future;
      await tap(t, inspectKey, settle: false);
      f.c.read(accountState.notifier).state = null;
      await t.pumpAndSettle();
      hidden();
      final before = f.drafts.reads.length;
      pending.complete(page([draft(1, note: 'Old inspection')], next: 2));
      await t.pumpAndSettle();
      expect(find.text('Old inspection'), findsNothing);
      expect(f.drafts.reads.length, before);
      expect(find.byKey(ackKey), findsNothing);
    },
  );
  testWidgets(
    'private save preserves existing public composer draft on detail',
    (t) async {
      final f = Fixture();
      await pump(t, f, integrated: true);
      final public = find.byType(TextField).first;
      await t.ensureVisible(public);
      await t.enterText(public, 'Existing public draft');
      await open(t);
      await enter(t);
      await tap(t, saveKey);
      expect(find.text('Existing public draft'), findsOneWidget);
      expect(f.comments.posts, isEmpty);
      expect(f.drafts.writes.length, 1);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'resize and theme preserve exact private input without another save',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await enter(t);
      await pump(t, f, width: 1200, dark: true);
      expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, body);
      expect(enabled(t, saveKey), true);
      expect(f.drafts.writes, isEmpty);
      expect(t.takeException(), isNull);
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('localized composer $locale $width $dark', (t) async {
          final f = Fixture();
          final l = await pump(
            t,
            f,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          await open(t);
          await enter(t, 'Localized test note');
          expect(find.text(l.mrPendingComposeTitle), findsOneWidget);
          expect(find.text(l.mrPendingComposeSave), findsOneWidget);
          expect(enabled(t, saveKey), true);
          expect(t.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('pending preparation accepts input but prevents save', (t) async {
    final f = Fixture();
    final preparation = Completer<Paginated<Discussion>>();
    f.comments.value = preparation.future;
    await pump(t, f);
    await tap(t, openKey, settle: false);
    await enter(t);
    expect(enabled(t, saveKey), false);
    expect(f.drafts.writes, isEmpty);
    preparation.complete(const Paginated(items: []));
    await t.pumpAndSettle();
    expect(enabled(t, saveKey), true);
    expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, body);
  });
  for (final invalid in [mr(id: 0), mr(iid: 143), mr(project: 9)]) {
    testWidgets(
      'invalid initial detail ${invalid.id}/${invalid.iid}/${invalid.projectId} disables entry',
      (t) async {
        final f = Fixture();
        f.details.value = invalid;
        await pump(t, f);
        expect(enabled(t, openKey), false);
        expect(find.byType(AlertDialog), findsNothing);
        expect(f.drafts.reads, isEmpty);
        expect(f.drafts.writes, isEmpty);
      },
    );
  }
  testWidgets('signed-out entry cannot open a composer', (t) async {
    final f = Fixture();
    f.c.read(accountState.notifier).state = null;
    await pump(t, f);
    expect(find.byKey(openKey), findsNothing);
    expect(f.drafts.writes, isEmpty);
  });
  testWidgets(
    'successful inspection snapshot disappears permanently after session replacement',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await fail(t, f);
      f.drafts.pages[1] = page([draft(3, note: 'Private inspected snapshot')]);
      await tap(t, inspectKey);
      expect(inDialog(find.text('Private inspected snapshot')), findsOneWidget);
      f.c.read(accountState.notifier).state = null;
      await t.pumpAndSettle();
      expect(inDialog(find.text('Private inspected snapshot')), findsNothing);
      expect(find.byKey(ackKey), findsNothing);
      hidden();
      f.c.read(accountState.notifier).state = account;
      await t.pumpAndSettle();
      hidden();
      expect(find.byKey(ackKey), findsNothing);
    },
  );
  testWidgets(
    'new failed inspection discards previous snapshot and acknowledgement',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await open(t);
      await fail(t, f);
      f.drafts.pages[1] = page([draft(3, note: 'Previous private snapshot')]);
      await tap(t, inspectKey);
      await t.ensureVisible(find.byKey(ackKey));
      await t.tap(find.byKey(ackKey));
      await t.pumpAndSettle();
      expect(enabled(t, saveKey), true);
      f.drafts.pages[1] = const GitLabServerException('Hidden renewed error');
      await tap(t, inspectKey);
      expect(inDialog(find.text('Previous private snapshot')), findsNothing);
      expect(find.byKey(ackKey), findsNothing);
      expect(enabled(t, saveKey), false);
      expect(f.drafts.writes.length, 1);
    },
  );
  testWidgets('whitespace-only body never enables or dispatches save', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f);
    await open(t);
    await enter(t, ' \n\t ');
    expect(enabled(t, saveKey), false);
    expect(f.drafts.writes, isEmpty);
  });
  testWidgets(
    'large text keyboard inspection allows scrolling to acknowledgement and actions',
    (t) async {
      final f = Fixture();
      await pump(
        t,
        f,
        width: 320,
        height: 700,
        keyboard: 240,
        scale: 2,
        locale: const Locale('hi'),
      );
      await open(t);
      await fail(t, f);
      f.drafts.pages[1] = page(
        List.generate(
          12,
          (i) => draft(
            i + 1,
            note:
                'Long inspected note $i\n${List.filled(20, 'Exact private Markdown').join('\n')}',
          ),
        ),
      );
      await tap(t, inspectKey);
      await t.ensureVisible(find.byKey(ackKey));
      await t.tap(find.byKey(ackKey));
      await t.pumpAndSettle();
      expect(enabled(t, saveKey), true);
      expect(f.drafts.writes.length, 1);
      expect(t.takeException(), isNull);
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('localized inspection $locale $width $dark', (t) async {
          final f = Fixture();
          final l = await pump(
            t,
            f,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          await open(t);
          await fail(t, f);
          f.drafts.pages[1] = page([
            draft(3, note: 'Synthetic inspected note'),
          ]);
          await tap(t, inspectKey);
          expect(find.text(l.mrPendingComposeInspectionTitle), findsOneWidget);
          expect(
            inDialog(find.text('Synthetic inspected note')),
            findsOneWidget,
          );
          await t.ensureVisible(find.byKey(ackKey));
          await t.tap(find.byKey(ackKey));
          await t.pumpAndSettle();
          expect(enabled(t, saveKey), true);
          expect(f.drafts.writes.length, 1);
          expect(t.takeException(), isNull);
        });
      }
    }
  }
  testWidgets('compact keyboard large text and long body remain usable', (
    t,
  ) async {
    final f = Fixture();
    await pump(
      t,
      f,
      width: 320,
      height: 700,
      keyboard: 240,
      scale: 2,
      locale: const Locale('hi'),
    );
    await open(t);
    await enter(t, List.filled(50, 'Very long exact Markdown note').join('\n'));
    await tap(t, saveKey);
    expect(f.drafts.writes.length, 1);
    expect(t.takeException(), isNull);
  });

  if (Platform.environment['LABFOX_PENDING_COMPOSER_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        for (final recovering in [false, true]) {
          testWidgets('synthetic composer capture $width $dark $recovering', (
            t,
          ) async {
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
            ButtonStyle font(ButtonStyle style) => style.copyWith(
              textStyle: WidgetStatePropertyAll(
                style.textStyle!.resolve({})!.copyWith(fontFamily: 'Roboto'),
              ),
            );
            final theme = base.copyWith(
              textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: font(base.outlinedButtonTheme.style!),
              ),
              textButtonTheme: const TextButtonThemeData(
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
              ),
              inputDecorationTheme: base.inputDecorationTheme.copyWith(
                labelStyle: const TextStyle(fontFamily: 'Roboto'),
              ),
            );
            final f = Fixture();
            await pump(
              t,
              f,
              width: width,
              height: width < 600 ? 1000 : 1100,
              dark: dark,
              theme: theme,
            );
            await open(t);
            await enter(
              t,
              'Please cover empty intermediate pages.\n\nThe original Markdown stays private.',
            );
            if (recovering) {
              f.drafts.result = const GitLabServerException(
                'Synthetic save failure',
              );
              await tap(t, saveKey);
              f.drafts.pages[1] = page([
                draft(
                  3,
                  note: 'Could the parser preserve the original whitespace?',
                ),
              ]);
              await tap(t, inspectKey);
              await t.ensureVisible(find.byKey(ackKey));
              await t.pumpAndSettle();
            }
            // Capture with no focused-field cursor so repeated frames are stable.
            FocusManager.instance.primaryFocus?.unfocus();
            await t.pumpAndSettle();
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
                '$directory/${recovering ? 'inspection' : 'composer'}-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
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
}
