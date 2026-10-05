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
import 'mr_pending_review_maintenance_widget_test.dart' as b;

const openKey = ValueKey('mr-pending-publish-note-7');
const publishKey = ValueKey('mr-pending-publish-submit');
const inspectKey = ValueKey('mr-pending-publish-inspect');
const ackKey = ValueKey('mr-pending-publish-acknowledge');
const cancelKey = ValueKey('mr-pending-publish-cancel');

class Drafts extends b.Drafts {
  Drafts(super.api);
  int publications = 0;
  Object? outcome;
  @override
  Future<void> publishNote({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
  }) async {
    expect((projectId, iid, mergeRequestId), (8, 142, 1100));
    expect(draft.id, 7);
    publications++;
    if (outcome is Future<void>) return outcome as Future<void>;
    if (outcome != null) throw outcome!;
    pages[1] = b.page([b.draft(8, note: 'Other saved note')]);
  }
}

class Fixture extends b.Fixture {
  late final private = Drafts(api);
  void setup() {
    c.read(b.draftState.notifier).state = Future.value(private);
  }
}

Future<void> open(WidgetTester t) => b.tap(t, openKey);
void main() {
  testWidgets('selected publication preserves unsent public discussion input', (
    t,
  ) async {
    final f = Fixture()..setup();
    await b.pump(t, f, integrated: true);
    final public = find.byType(TextField);
    await t.scrollUntilVisible(
      public,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pump();
    await t.enterText(public, 'Unsent public discussion');
    await open(t);
    await b.tap(t, ackKey);
    await b.tap(t, publishKey);
    await t.scrollUntilVisible(
      find.byType(TextField),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pumpAndSettle();
    expect(find.text('Unsent public discussion'), findsOneWidget);
    expect(f.comments.posts, isEmpty);
    expect(f.private.publications, 1);
  });

  testWidgets(
    'missing selected note after recovery cannot publish another note',
    (t) async {
      final f = Fixture()..setup();
      final l = await b.pump(t, f);
      await open(t);
      f.private.pages[1] = b.page([b.draft(8)]);
      await b.tap(t, inspectKey);
      expect(find.text(l.mrPendingTargetMissing), findsOneWidget);
      expect(b.enabled(t, publishKey), false);
      expect(find.byKey(ackKey), findsNothing);
      expect(f.private.publications, 0);
    },
  );

  for (final action in ['compose', 'edit', 'delete']) {
    testWidgets('uncertain publication directs $action to two-sided recovery', (
      t,
    ) async {
      final f = Fixture()..setup();
      final l = await b.pump(t, f);
      await open(t);
      await b.tap(t, ackKey);
      f.private.outcome = const GitLabServerException('Uncertain publication');
      await b.tap(t, publishKey);
      await b.tap(t, cancelKey);
      await b.tap(t, switch (action) {
        'compose' => b.openKey,
        'edit' => const ValueKey('mr-pending-edit-7'),
        _ => const ValueKey('mr-pending-delete-7'),
      });
      expect(find.text(l.mrPendingPublishRecoveryRequired), findsOneWidget);
      await b.tap(t, b.inspectKey);
      expect(b.enabled(t, b.saveKey), false);
      expect(
        f.c
            .read(mrDiscussionsControllerProvider(b.resource).notifier)
            .pendingPublicationNeedsInspection,
        true,
      );
      expect(f.private.publications, 1);
    });
  }

  if (Platform.environment['LABFOX_SINGLE_PUBLICATION_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        for (final recovering in [false, true]) {
          testWidgets('synthetic publication capture $width $dark $recovering', (
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
            final f = Fixture()..setup();
            f.private.pages[1] = b.page([
              b.draft(7, note: 'Please cover empty intermediate pages.'),
              b.draft(
                8,
                note: 'The original Markdown stays private until publication.',
              ),
            ]);
            await b.pump(
              t,
              f,
              width: width,
              height: width < 600 ? 1000 : 1100,
              dark: dark,
              theme: theme,
            );
            await open(t);
            if (recovering) {
              await b.tap(t, ackKey);
              f.private.outcome = const GitLabServerException(
                'Synthetic publication failure',
              );
              await b.tap(t, publishKey);
              f.comments.value = const Paginated<Discussion>(
                items: [
                  Discussion(
                    id: 'public-thread',
                    individualNote: true,
                    notes: [
                      Note(
                        id: 99,
                        body:
                            'Current public discussion. Check before another publication.',
                      ),
                    ],
                  ),
                ],
              );
              await b.tap(t, inspectKey);
            }
            // Capture with no focused-field cursor so repeated frames are stable.
            FocusManager.instance.primaryFocus?.unfocus();
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
            final boundary = t.renderObject<RenderRepaintBoundary>(
              find.byKey(b.captureKey),
            );
            final image = (await t.runAsync(boundary.toImage))!;
            final data = await t.runAsync(
              () => image.toByteData(format: ui.ImageByteFormat.png),
            );
            await t.runAsync(() async {
              final file = File(
                '$directory/${recovering ? 'inspection' : 'publish'}-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
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

  testWidgets('initial public read failure can recover without reopening', (
    t,
  ) async {
    final f = Fixture()..setup();
    f.comments.value = const GitLabServerException('Initial read failed');
    await b.pump(t, f);
    await open(t);
    expect(b.enabled(t, inspectKey), true);
    f.comments.value = const Paginated<Discussion>(items: []);
    await b.tap(t, inspectKey);
    expect(find.byKey(ackKey), findsOneWidget);
    await b.tap(t, ackKey);
    expect(b.enabled(t, publishKey), true);
  });

  testWidgets(
    'only selected note appears before explicit consent and publication',
    (t) async {
      final f = Fixture()..setup();
      f.private.pages[1] = b.page([b.draft(7)], next: 3);
      f.private.pages[3] = b.page([b.draft(8, note: 'Second private note')]);
      final l = await b.pump(t, f);
      await open(t);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Second private note'),
        ),
        findsNothing,
      );
      expect(find.text(l.mrPendingPublishNoteHint), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(b.enabled(t, publishKey), false);
      expect(f.private.publications, 0);
      await b.tap(t, ackKey);
      expect(b.enabled(t, publishKey), true);
      await b.tap(t, publishKey);
      expect(f.private.publications, 1);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(l.mrPendingNotePublished), findsOneWidget);
      expect(find.text('Other saved note'), findsOneWidget);
      expect(f.events.names, isEmpty);
      expect(f.comments.posts, isEmpty);
    },
  );
  testWidgets('changed notes require a new visible inspection and consent', (
    t,
  ) async {
    final f = Fixture()..setup();
    final l = await b.pump(t, f);
    await open(t);
    await b.tap(t, ackKey);
    f.private.pages[1] = b.page([b.draft(7, note: 'Changed elsewhere')]);
    await b.tap(t, publishKey);
    expect(f.private.publications, 0);
    expect(find.text(l.mrPendingPublishUncertain), findsOneWidget);
    expect(b.enabled(t, publishKey), false);
    await b.tap(t, inspectKey);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Changed elsewhere'),
      ),
      findsOneWidget,
    );
    expect(b.enabled(t, publishKey), false);
    await b.tap(t, ackKey);
    await b.tap(t, publishKey);
    expect(f.private.publications, 1);
  });
  testWidgets(
    'uncertain publication survives close and requires both-side recovery',
    (t) async {
      final f = Fixture()..setup();
      final l = await b.pump(t, f);
      await open(t);
      await b.tap(t, ackKey);
      f.private.outcome = const GitLabServerException('private-server-marker');
      await b.tap(t, publishKey);
      expect(f.private.publications, 1);
      expect(find.textContaining('private-server-marker'), findsNothing);
      await b.tap(t, cancelKey);
      await open(t);
      expect(find.text(l.mrPendingPublishUncertain), findsOneWidget);
      expect(b.enabled(t, publishKey), false);
      f.comments.value = const GitLabServerException(
        'private-inspection-marker',
      );
      await b.tap(t, inspectKey);
      expect(find.textContaining('private-inspection-marker'), findsNothing);
      expect(b.enabled(t, publishKey), false);
      f.comments.value = const Paginated<Discussion>(
        items: [
          Discussion(
            id: 'thread',
            individualNote: true,
            notes: [Note(id: 9, body: 'Current public note')],
          ),
        ],
      );
      await b.tap(t, inspectKey);
      expect(find.text('Current public note'), findsOneWidget);
      expect(find.text(l.mrPendingPublishRecoveryHint), findsOneWidget);
      expect(b.enabled(t, publishKey), false);
      expect(f.private.publications, 1);
      f.private.outcome = null;
      await b.tap(t, ackKey);
      await b.tap(t, publishKey);
      expect(f.private.publications, 2);
    },
  );
  for (final change in [
    'account',
    'drafts',
    'detail',
    'comments',
    'client',
    'origin',
  ]) {
    testWidgets('publication dialog discards obsolete $change content', (
      t,
    ) async {
      final f = Fixture()..setup();
      final l = await b.pump(t, f);
      await open(t);
      await b.tap(t, ackKey);
      switch (change) {
        case 'account':
          f.c.read(b.accountState.notifier).state = b.account.copyWith(
            instanceUrl: 'https://other.example.com',
          );
        case 'drafts':
          f.c.read(b.draftState.notifier).state = Future.value(Drafts(f.api));
        case 'detail':
          f.c.read(b.detailState.notifier).state = Future.value(
            b.Details(f.api),
          );
        case 'comments':
          f.c.read(b.commentsState.notifier).state = Future.value(
            b.Comments(f.api),
          );
        case 'client':
          f.c.read(b.clientState.notifier).state = b.client();
        case 'origin':
          await t.pumpWidget(
            UncontrolledProviderScope(
              container: f.c,
              child: const MaterialApp(home: SizedBox()),
            ),
          );
      }
      await t.pumpAndSettle();
      if (change != 'origin') {
        expect(find.text(l.mrPendingComposeChanged), findsOneWidget);
        expect(b.enabled(t, publishKey), false);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(b.body),
          ),
          findsNothing,
        );
      }
      expect(f.private.publications, 0);
    });
  }
  for (final width in [390.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
        testWidgets('publication fits $width dark $dark locale $locale', (
          t,
        ) async {
          final f = Fixture()..setup();
          await b.pump(
            t,
            f,
            width: width,
            dark: dark,
            locale: Locale(locale),
            scale: 1.8,
            keyboard: 320,
          );
          await open(t);
          await b.tap(t, ackKey);
          await b.tap(t, cancelKey);
          expect(t.takeException(), isNull);
          expect(f.private.publications, 0);
        });
      }
    }
  }
  testWidgets('in-flight publication disables cancellation and never replays', (
    t,
  ) async {
    final f = Fixture()..setup();
    await b.pump(t, f);
    await open(t);
    await b.tap(t, ackKey);
    final pending = Completer<void>();
    f.private.outcome = pending.future;
    await b.tap(t, publishKey, settle: false);
    expect(b.enabled(t, publishKey), false);
    expect(b.enabled(t, cancelKey), false);
    expect(f.private.publications, 1);
    pending.complete();
    await t.pumpAndSettle();
    expect(f.private.publications, 1);
  });
}
