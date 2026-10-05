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
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_discussion_thread.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'mr_pending_reply_controller_test.dart' as r;
import 'mr_pending_review_maintenance_widget_test.dart' as b;

class Drafts extends b.Drafts {
  Drafts(super.api);
  final replies = <(int, int, int, String, String)>[];
  Object? replyResult;
  @override
  Future<MergeRequestDraftNote> createReply({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String discussionId,
    required String note,
  }) async {
    replies.add((projectId, iid, mergeRequestId, discussionId, note));
    final v = replyResult;
    if (v is Future<MergeRequestDraftNote>) return v;
    if (v != null) throw v;
    final created = b
        .draft(8, note: note)
        .copyWith(discussionId: discussionId, resolveDiscussion: false);
    pages[1] = b.page([created]);
    return created;
  }
}

class Comments extends b.Comments {
  Comments(super.client);
  Object fresh = r.thread;
  int targetReads = 0;
  @override
  Future<Discussion> discussion({
    required int projectId,
    required int iid,
    required String discussionId,
  }) async {
    expect((projectId, iid, discussionId), (8, 142, 'thread'));
    targetReads++;
    final v = fresh;
    if (v is Future<Discussion>) return v;
    if (v is Discussion) return v;
    throw v;
  }
}

class Fixture extends b.Fixture {
  late final privateDrafts = Drafts(api)..pages[1] = b.page([]);
  late final publicComments = Comments(api)
    ..value = const Paginated<Discussion>(items: [r.thread]);
  final theme = ValueNotifier(LabFoxTheme.light);
  void init() {
    c.read(b.draftState.notifier).state = Future.value(privateDrafts);
    c.read(b.commentsState.notifier).state = Future.value(publicComments);
  }
}

final capture = GlobalKey();
Future<AppLocalizations> pump(
  WidgetTester t,
  Fixture f, {
  double width = 390,
  double height = 1000,
  bool dark = false,
  double scale = 1,
  double keyboard = 0,
  Locale locale = const Locale('en'),
  bool integrated = false,
  ThemeData? theme,
}) async {
  t.view.physicalSize = Size(width, height);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  f.init();
  f.theme.value = theme ?? (dark ? LabFoxTheme.dark : LabFoxTheme.light);
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: f.c,
      child: RepaintBoundary(
        key: capture,
        child: ValueListenableBuilder<ThemeData>(
          valueListenable: f.theme,
          builder: (context, currentTheme, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: currentTheme,
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
                ? const MergeRequestDetailScreen(projectId: 8, iid: 142)
                : const Scaffold(
                    body: SingleChildScrollView(
                      child: MrDiscussionThread(projectId: 8, iid: 142),
                    ),
                  ),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  return AppLocalizations.of(t.element(find.byType(Scaffold).first));
}

const open = ValueKey('mr-pending-reply-thread');
Future<void> openReply(WidgetTester t) async {
  await tap(t, open);
}

Future<void> tap(WidgetTester t, Key key, {bool settle = true}) async {
  // Finish editable-text visibility work before scrolling the dialog actions.
  await t.pumpAndSettle();
  await t.ensureVisible(find.byKey(key));
  await t.pumpAndSettle();
  await t.tap(find.byKey(key));
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
  }
}

Future<void> acknowledge(WidgetTester t) async {
  final check = find.descendant(
    of: find.byKey(b.ackKey),
    matching: find.byType(Checkbox),
  );
  await t.pumpAndSettle();
  await t.ensureVisible(check);
  await t.pumpAndSettle();
  await t.tap(check);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('unsent public thread reply survives private save', (t) async {
    final f = Fixture();
    await pump(t, f);
    await tap(t, const ValueKey('mr-discussion-reply-thread'));
    final field = find.descendant(
      of: find.byKey(const ValueKey('mr-reply-composer')),
      matching: find.byType(TextField),
    );
    await t.enterText(field, 'Public reply still unsent');
    await openReply(t);
    await t.enterText(find.byKey(b.inputKey), b.body);
    await tap(t, b.saveKey);
    expect(
      t.widget<TextField>(field).controller!.text,
      'Public reply still unsent',
    );
    expect(f.publicComments.posts, isEmpty);
    expect(f.privateDrafts.replies.length, 1);
  });
  testWidgets(
    'resize and theme changes retain private reply input and target',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await openReply(t);
      await t.enterText(find.byKey(b.inputKey), b.body);
      t.view.physicalSize = const Size(1200, 1000);
      f.theme.value = LabFoxTheme.dark;
      await t.pumpAndSettle();
      expect(
        t.widget<TextField>(find.byKey(b.inputKey)).controller!.text,
        b.body,
      );
      expect(find.text(r.thread.notes.first.body), findsWidgets);
      await tap(t, b.saveKey);
      expect(f.privateDrafts.replies.length, 1);
    },
  );
  testWidgets('same-account close and reopen retains uncertain gate', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f);
    await openReply(t);
    await t.enterText(find.byKey(b.inputKey), b.body);
    f.privateDrafts.replyResult = const GitLabConnectionException('Uncertain');
    await tap(t, b.saveKey);
    await tap(t, b.cancelKey);
    await openReply(t);
    await t.enterText(find.byKey(b.inputKey), 'A new explicit reply');
    expect(b.enabled(t, b.saveKey), false);
    await tap(t, b.inspectKey);
    await acknowledge(t);
    f.privateDrafts.replyResult = null;
    await tap(t, b.saveKey);
    expect(f.privateDrafts.replies.length, 2);
  });
  testWidgets('late write after origin removal cannot toast or post publicly', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f);
    await openReply(t);
    await t.enterText(find.byKey(b.inputKey), b.body);
    final write = Completer<MergeRequestDraftNote>();
    f.privateDrafts.replyResult = write.future;
    await tap(t, b.saveKey, settle: false);
    await t.pump();
    expect(f.privateDrafts.replies.length, 1);
    await t.pumpWidget(const SizedBox());
    write.complete(
      b
          .draft(8, note: b.body)
          .copyWith(discussionId: 'thread', resolveDiscussion: false),
    );
    await t.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(f.publicComments.posts, isEmpty);
    expect(
      f.c
          .read(mrDiscussionsControllerProvider(b.resource).notifier)
          .pendingSaveNeedsInspection,
      true,
    );
  });

  testWidgets(
    'private thread entry saves separately while preserving public input',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await t.enterText(find.byType(TextField), 'Public unsent input');
      await openReply(t);
      expect(find.text(r.thread.notes.first.body), findsWidgets);
      await t.enterText(find.byKey(b.inputKey), b.body);
      await tap(t, b.saveKey);
      expect(f.privateDrafts.replies, [(8, 142, 1100, 'thread', b.body)]);
      expect(f.publicComments.posts, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'Public unsent input',
      );
      expect(f.events.names, isEmpty);
    },
  );
  testWidgets(
    'changed preflight requires target inspection and new consent before retry',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await openReply(t);
      await t.enterText(find.byKey(b.inputKey), b.body);
      f.publicComments.fresh = r.thread.copyWith(
        notes: [
          ...r.thread.notes,
          const Note(id: 2, body: 'New reviewer context'),
        ],
      );
      await tap(t, b.saveKey);
      expect(f.privateDrafts.replies, isEmpty);
      expect(b.enabled(t, b.saveKey), false);
      await tap(t, b.inspectKey);
      expect(find.text('New reviewer context'), findsOneWidget);
      expect(
        t.widget<TextField>(find.byKey(b.inputKey)).controller!.text,
        b.body,
      );
      expect(b.enabled(t, b.saveKey), false);
      await acknowledge(t);
      expect(b.enabled(t, b.saveKey), true);
      await tap(t, b.saveKey);
      expect(f.privateDrafts.replies.length, 1);
    },
  );
  testWidgets(
    'uncertain reply shows all private pages and original context before explicit retry',
    (t) async {
      final f = Fixture();
      await pump(t, f);
      await openReply(t);
      await t.enterText(find.byKey(b.inputKey), b.body);
      f.privateDrafts.replyResult = const GitLabConnectionException(
        'Uncertain',
      );
      await tap(t, b.saveKey);
      expect(f.privateDrafts.replies.length, 1);
      expect(b.enabled(t, b.saveKey), false);
      f.privateDrafts.pages[1] = b.page([
        b
            .draft(8, note: 'Possibly saved reply')
            .copyWith(discussionId: 'thread'),
      ], next: 2);
      f.privateDrafts.pages[2] = b.page([]);
      await tap(t, b.inspectKey);
      expect(f.privateDrafts.reads, [1, 2]);
      expect(find.text('Possibly saved reply'), findsOneWidget);
      await acknowledge(t);
      await t.enterText(find.byKey(b.inputKey), 'A consciously revised reply');
      await t.pump();
      expect(b.enabled(t, b.saveKey), false);
      await acknowledge(t);
      f.privateDrafts.replyResult = null;
      await tap(t, b.saveKey);
      expect(f.privateDrafts.replies.length, 2);
      expect(f.publicComments.posts, isEmpty);
    },
  );
  testWidgets(
    'deleted original target keeps dialog mounted and disables retry',
    (t) async {
      final f = Fixture();
      final l = await pump(t, f);
      await openReply(t);
      await t.enterText(find.byKey(b.inputKey), b.body);
      f.publicComments.fresh = const GitLabNotFoundException('Missing');
      await tap(t, b.saveKey);
      await tap(t, b.inspectKey);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        t.widget<TextField>(find.byKey(b.inputKey)).controller!.text,
        b.body,
      );
      expect(b.enabled(t, b.saveKey), false);
      expect(find.byKey(open), findsNothing);
      expect(find.text(l.mrPendingComposeChanged), findsNothing);
      await tap(t, b.cancelKey);
      expect(f.privateDrafts.replies, isEmpty);
    },
  );
  for (final change in [
    'account',
    'client',
    'drafts',
    'details',
    'comments',
    'origin',
  ]) {
    testWidgets(
      '$change replacement discards private reply input and context',
      (t) async {
        final f = Fixture();
        final l = await pump(t, f);
        await openReply(t);
        await t.enterText(find.byKey(b.inputKey), b.body);
        switch (change) {
          case 'account':
            f.c.read(b.accountState.notifier).state = b.account.copyWith(
              instanceUrl: 'https://other.example.com',
            );
          case 'client':
            final other = b.client();
            addTearDown(other.close);
            f.c.read(b.clientState.notifier).state = other;
          case 'drafts':
            f.c.read(b.draftState.notifier).state = Future.value(Drafts(f.api));
          case 'details':
            f.c.read(b.detailState.notifier).state = Future.value(
              b.Details(f.api),
            );
          case 'comments':
            f.c.read(b.commentsState.notifier).state = Future.value(
              Comments(f.api),
            );
          case 'origin':
            await t.pumpWidget(const SizedBox());
        }
        await t.pumpAndSettle();
        if (change != 'origin') {
          expect(find.text(l.mrPendingComposeChanged), findsOneWidget);
          expect(find.byKey(b.inputKey), findsNothing);
          expect(b.enabled(t, b.saveKey), false);
        }
        expect(f.privateDrafts.replies, isEmpty);
        expect(f.publicComments.posts, isEmpty);
      },
    );
  }
  for (final kind in ['individual', 'system', 'empty']) {
    testWidgets('$kind context has no private reply entry', (t) async {
      final f = Fixture();
      f.publicComments.value = Paginated(
        items: [
          switch (kind) {
            'individual' => r.thread.copyWith(individualNote: true),
            'system' => r.thread.copyWith(
              notes: [const Note(id: 1, body: 'System', isSystem: true)],
            ),
            _ => r.thread.copyWith(notes: []),
          },
        ],
      );
      await pump(t, f);
      expect(find.byKey(open), findsNothing);
    });
  }
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    testWidgets(
      'private reply is usable in $locale with large text and keyboard',
      (t) async {
        final f = Fixture();
        await pump(
          t,
          f,
          width: 390,
          height: 1100,
          scale: 1.8,
          keyboard: 280,
          locale: Locale(locale),
        );
        await openReply(t);
        await t.enterText(find.byKey(b.inputKey), b.body);
        await tap(t, b.saveKey);
        expect(f.privateDrafts.replies.length, 1);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('integrated MR detail refresh retains origin and public draft', (
    t,
  ) async {
    final f = Fixture();
    await pump(t, f, integrated: true);
    await t.scrollUntilVisible(
      find.byType(TextField),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await t.enterText(find.byType(TextField), 'Public unsent input');
    await t.scrollUntilVisible(
      find.byKey(open),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await openReply(t);
    await t.enterText(find.byKey(b.inputKey), b.body);
    await tap(t, b.saveKey);
    expect(f.privateDrafts.replies.length, 1);
    expect(find.byType(AlertDialog), findsNothing);
    await t.scrollUntilVisible(
      find.byType(TextField),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      t.widget<TextField>(find.byType(TextField)).controller!.text,
      'Public unsent input',
    );
    expect(t.takeException(), isNull);
  });
  final output = Platform.environment['LABFOX_PRIVATE_REPLY_CAPTURE'];
  if (output != null) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        for (final recovery in [false, true]) {
          testWidgets('capture private reply $width $dark $recovery', (
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
              filledButtonTheme: FilledButtonThemeData(
                style: font(base.filledButtonTheme.style!),
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
              height: 1000,
              dark: dark,
              theme: theme,
            );
            await openReply(t);
            await t.enterText(
              find.byKey(b.inputKey),
              'I will verify the edge case before publishing this reply.',
            );
            if (recovery) {
              f.privateDrafts.replyResult = const GitLabConnectionException(
                'Uncertain',
              );
              await tap(t, b.saveKey);
              f.privateDrafts.pages[1] = b.page([
                b
                    .draft(8, note: 'A reply that may already have saved.')
                    .copyWith(discussionId: 'thread'),
              ]);
              f.publicComments.fresh = r.thread.copyWith(
                notes: [
                  ...r.thread.notes,
                  const Note(
                    id: 2,
                    body: 'Please also check the missing account case.',
                  ),
                ],
              );
              await tap(t, b.inspectKey);
              await t.ensureVisible(find.byKey(b.ackKey));
              await t.pumpAndSettle();
            }
            FocusManager.instance.primaryFocus?.unfocus();
            await t.pumpAndSettle();
            final boundary = t.renderObject<RenderRepaintBoundary>(
              find.byKey(capture),
            );
            final img = (await t.runAsync(boundary.toImage))!;
            final bytes = await t.runAsync(
              () => img.toByteData(format: ui.ImageByteFormat.png),
            );
            await t.runAsync(() async {
              final file = File(
                '$output/${width.toInt()}-${dark ? 'dark' : 'light'}-${recovery ? 'recovery' : 'compose'}.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
            });
            img.dispose();
            expect(t.takeException(), isNull);
          });
        }
      }
    }
  }
}
