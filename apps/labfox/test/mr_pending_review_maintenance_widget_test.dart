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
  final pages = <int, Object>{
    1: page([draft(7)]),
  };
  final updates = <(MergeRequestDraftNote, String)>[];
  final deletes = <MergeRequestDraftNote>[];
  Object? updateResult, deleteResult;
  @override
  Future<MergeRequestDraftNote> update({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
    required String note,
  }) async {
    updates.add((draft, note));
    final result = updateResult;
    if (result is Future<MergeRequestDraftNote>) return result;
    if (result != null) throw result;
    final updated = draft.copyWith(note: note);
    pages[1] = page([updated]);
    return updated;
  }

  @override
  Future<void> delete({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
  }) async {
    deletes.add(draft);
    final result = deleteResult;
    if (result is Future<void>) return result;
    if (result != null) throw result;
    pages[1] = page([]);
  }

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

const edited = '  **Edited private**\nKeep exact whitespace.  ';
Key action(bool deleting) =>
    ValueKey(deleting ? 'mr-pending-delete-7' : 'mr-pending-edit-7');
Future<void> openAction(WidgetTester t, bool deleting) =>
    tap(t, action(deleting));
void main() {
  testWidgets('edits captured Markdown once and refreshes saved private rows', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f);
    await openAction(t, false);
    expect(t.widget<TextField>(find.byKey(inputKey)).controller!.text, body);
    expect(enabled(t, saveKey), false);
    await enter(t, edited);
    expect(enabled(t, saveKey), true);
    await tap(t, saveKey);
    expect(f.drafts.updates, [(draft(7), edited)]);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(edited), findsOneWidget);
    expect(f.drafts.writes, isEmpty);
    expect(f.comments.posts, isEmpty);
    expect(f.events.names, isEmpty);
  });
  testWidgets(
    'deletion displays original note and requires explicit confirmation',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await openAction(t, true);
      expect(inDialog(find.text(body)), findsOneWidget);
      expect(find.byKey(inputKey), findsNothing);
      expect(enabled(t, saveKey), false);
      expect(f.drafts.deletes, isEmpty);
      await tap(t, ackKey);
      expect(enabled(t, saveKey), true);
      await tap(t, saveKey);
      expect(f.drafts.deletes, [draft(7)]);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(body), findsNothing);
      expect(f.drafts.writes, isEmpty);
      expect(f.comments.posts, isEmpty);
    },
  );
  for (final deleting in [false, true]) {
    testWidgets('cancel ${deleting ? 'delete' : 'edit'} never writes', (
      t,
    ) async {
      final f = Fixture();
      await pump(t, f);
      await openAction(t, deleting);
      await tap(t, cancelKey);
      expect(f.drafts.updates, isEmpty);
      expect(f.drafts.deletes, isEmpty);
      expect(f.drafts.writes, isEmpty);
    });
    testWidgets(
      'uncertain ${deleting ? 'delete' : 'edit'} preserves input and requires visible inspection plus acknowledgement',
      (t) async {
        final f = Fixture();
        await pump(t, f);
        await openAction(t, deleting);
        if (deleting) {
          await tap(t, ackKey);
          f.drafts.deleteResult = const GitLabServerException(
            'Do not expose payload',
          );
        } else {
          await enter(t, edited);
          f.drafts.updateResult = const GitLabServerException(
            'Do not expose payload',
          );
        }
        await tap(t, saveKey);
        expect(enabled(t, saveKey), false);
        expect(find.text('Do not expose payload'), findsNothing);
        final fresh = draft(7, note: 'Changed on server');
        f.drafts.pages[1] = page([fresh]);
        await tap(t, inspectKey);
        expect(inDialog(find.text(fresh.note)), findsWidgets);
        expect(enabled(t, saveKey), false);
        await tap(t, ackKey);
        expect(enabled(t, saveKey), true);
        f.drafts.deleteResult = null;
        f.drafts.updateResult = null;
        await tap(t, saveKey);
        expect(f.drafts.updates.length + f.drafts.deletes.length, 2);
        if (deleting) {
          expect(f.drafts.deletes.last, fresh);
        } else {
          expect(f.drafts.updates.last, (fresh, edited));
        }
        expect(f.drafts.writes, isEmpty);
        expect(f.comments.posts, isEmpty);
      },
    );
    testWidgets(
      'inspection with missing target cannot repeat ${deleting ? 'delete' : 'edit'}',
      (t) async {
        final f = Fixture();
        await pump(t, f);
        await openAction(t, deleting);
        if (deleting) {
          await tap(t, ackKey);
        } else {
          await enter(t, edited);
        }
        f.drafts.pages[1] = page([]);
        await tap(t, saveKey);
        expect(f.drafts.updates, isEmpty);
        expect(f.drafts.deletes, isEmpty);
        await tap(t, inspectKey);
        expect(enabled(t, saveKey), false);
        expect(find.byKey(ackKey), findsNothing);
        await tap(t, cancelKey);
      },
    );
    for (final phase in ['preflight', 'write']) {
      for (final changed in [
        'account',
        'draft',
        'source',
        'comments',
        'origin',
      ]) {
        testWidgets(
          '${deleting ? 'delete' : 'edit'} hides private state after $changed during $phase',
          (t) async {
            final f = Fixture();
            await pump(t, f);
            await openAction(t, deleting);
            if (deleting) {
              await tap(t, ackKey);
            } else {
              await enter(t, edited);
            }
            final details = Completer<MergeRequest>(),
                update = Completer<MergeRequestDraftNote>(),
                remove = Completer<void>();
            if (phase == 'preflight') {
              f.details.value = details.future;
            } else if (deleting) {
              f.drafts.deleteResult = remove.future;
            } else {
              f.drafts.updateResult = update.future;
            }
            await tap(t, saveKey, settle: false);
            switch (changed) {
              case 'account':
                f.c.read(accountState.notifier).state = account.copyWith(
                  user: const User(id: 99, username: 'other', name: 'Other'),
                );
              case 'draft':
                f.c.read(draftState.notifier).state = Future.value(
                  Drafts(f.api),
                );
              case 'source':
                f.c.read(detailState.notifier).state = Future.value(
                  Details(f.api),
                );
              case 'comments':
                f.c.read(commentsState.notifier).state = Future.value(
                  Comments(f.api),
                );
              case 'origin':
                await t.pumpWidget(
                  UncontrolledProviderScope(
                    container: f.c,
                    child: const MaterialApp(
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      home: Scaffold(body: Text('Other view')),
                    ),
                  ),
                );
            }
            await t.pump();
            if (phase == 'preflight') {
              details.complete(mr());
            } else if (deleting) {
              remove.complete();
            } else {
              update.complete(draft(7, note: edited));
            }
            await t.pumpAndSettle();
            expect(find.byKey(inputKey), findsNothing);
            expect(inDialog(find.text(body)), findsNothing);
            expect(inDialog(find.text(edited)), findsNothing);
            expect(
              f.drafts.updates.length + f.drafts.deletes.length,
              phase == 'write' ? 1 : 0,
            );
            expect(t.takeException(), isNull);
          },
        );
      }
    }
  }
  for (final p in [
    const DiffNotePosition(positionType: 'image'),
    const DiffNotePosition(positionType: 'file'),
    const DiffNotePosition(positionType: 'text', newLine: 1),
  ]) {
    testWidgets('unsupported anchor has deletion but no edit action $p', (
      t,
    ) async {
      final f = Fixture();
      f.drafts.pages[1] = page([draft(7).copyWith(position: p)]);
      await pump(t, f);
      expect(find.byKey(action(false)), findsNothing);
      expect(find.byKey(action(true)), findsOneWidget);
    });
  }
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 1200.0]) {
      for (final deleting in [false, true]) {
        testWidgets(
          '$locale ${width.toInt()} ${deleting ? 'delete' : 'edit'} supports large text and keyboard',
          (t) async {
            final f = Fixture();
            await pump(
              t,
              f,
              width: width,
              height: 900,
              scale: 1.7,
              keyboard: deleting ? 0 : 270,
              locale: Locale(locale),
            );
            await openAction(t, deleting);
            if (deleting) {
              await tap(t, ackKey);
            } else {
              await enter(t, edited);
            }
            await tap(t, saveKey);
            expect(f.drafts.updates.length + f.drafts.deletes.length, 1);
            expect(t.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets(
    'changed original anchor is confirmed again after inspection before an edit',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await openAction(t, false);
      await enter(t, edited);
      final d = draft(7).copyWith(
        position: const DiffNotePosition(
          positionType: 'text',
          baseSha: 'base',
          startSha: 'start',
          headSha: 'head',
          oldPath: 'old.dart',
          newPath: 'new.dart',
          newLine: 9,
        ),
      );
      f.drafts.pages[1] = page([d]);
      await tap(t, saveKey);
      expect(f.drafts.updates, isEmpty);
      await tap(t, inspectKey);
      expect(enabled(t, saveKey), false);
      await tap(t, ackKey);
      await enter(t, '${edited}Again');
      expect(enabled(t, saveKey), false);
      await tap(t, ackKey);
      await tap(t, saveKey);
      expect(f.drafts.updates.single, (d, '${edited}Again'));
    },
  );
  testWidgets(
    'failed complete inspection exposes no partial list and cannot retry',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await openAction(t, false);
      await enter(t, edited);
      f.drafts.updateResult = const GitLabConnectionException(
        'Private payload',
      );
      await tap(t, saveKey);
      f.drafts.pages[1] = page([draft(7, note: 'Partial result')], next: 2);
      f.drafts.pages[2] = const GitLabServerException('Unread page');
      await tap(t, inspectKey);
      expect(inDialog(find.text('Partial result')), findsNothing);
      expect(find.byKey(ackKey), findsNothing);
      expect(enabled(t, saveKey), false);
      expect(f.drafts.updates.length, 1);
    },
  );
  testWidgets(
    'reopening after uncertain write still requires complete inspection',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await openAction(t, false);
      await enter(t, edited);
      f.drafts.updateResult = const GitLabConnectionException(
        'Private payload',
      );
      await tap(t, saveKey);
      await tap(t, cancelKey);
      await openAction(t, false);
      await enter(t, edited);
      expect(enabled(t, saveKey), false);
      await tap(t, inspectKey);
      await tap(t, ackKey);
      f.drafts.updateResult = null;
      await tap(t, saveKey);
      expect(f.drafts.updates.length, 2);
      expect(f.drafts.writes, isEmpty);
    },
  );
  if (Platform.environment['LABFOX_PENDING_MAINTENANCE_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        for (final recovering in [false, true]) {
          testWidgets('synthetic maintenance capture $width $dark $recovering', (
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
            await openAction(t, recovering);
            if (!recovering) {
              await enter(
                t,
                'Please cover empty intermediate pages.\n\nThe original Markdown stays private.',
              );
            }
            if (recovering) {
              await tap(t, ackKey);
              f.drafts.deleteResult = const GitLabServerException(
                'Synthetic save failure',
              );
              await tap(t, saveKey);
              f.drafts.pages[1] = page([
                draft(
                  7,
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
                '$directory/${recovering ? 'delete-inspection' : 'edit'}-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
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
  testWidgets(
    'delete shows specific progress and prevents duplicate confirmation',
    (t) async {
      final f = Fixture();
      final l = await pump(t, f);
      await openAction(t, true);
      await tap(t, ackKey);
      final pending = Completer<void>();
      f.drafts.deleteResult = pending.future;
      await tap(t, saveKey, settle: false);
      expect(find.text(l.mrPendingDeleting), findsOneWidget);
      expect(enabled(t, saveKey), false);
      expect(enabled(t, cancelKey), false);
      pending.complete();
      await t.pumpAndSettle();
      expect(f.drafts.deletes.length, 1);
    },
  );
}
