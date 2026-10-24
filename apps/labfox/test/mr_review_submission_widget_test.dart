import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'mr_pending_review_maintenance_widget_test.dart' as b;
import 'mr_pending_review_publish_widget_test.dart' as p;

const summaryKey = ValueKey('mr-review-summary');
const stateKey = ValueKey('mr-review-state');

class Drafts extends p.Drafts {
  Drafts(super.api);
  Object review = const Paginated<MergeRequestReviewer>(items: []);
  final submissions = <(String?, ReviewerSubmissionState?)>[];
  @override
  Future<Paginated<MergeRequestReviewer>> reviewers({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    if (review is Paginated<MergeRequestReviewer>) {
      return review as Paginated<MergeRequestReviewer>;
    }
    throw review;
  }

  @override
  Future<void> publish({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    String? summaryNote,
    ReviewerSubmissionState? reviewerState,
  }) async {
    submissions.add((summaryNote, reviewerState));
    await super.publish(
      projectId: projectId,
      iid: iid,
      mergeRequestId: mergeRequestId,
      summaryNote: summaryNote,
      reviewerState: reviewerState,
    );
    if (reviewerState != null) {
      review = Paginated(
        items: [
          MergeRequestReviewer(
            user: const User(
              id: 23,
              username: 'reviewer',
              name: 'Reviewer',
              state: 'active',
            ),
            state: reviewerState.value,
          ),
        ],
      );
    }
  }
}

class Fixture extends b.Fixture {
  late final private = Drafts(api);
  void setup() {
    c.read(b.draftState.notifier).state = Future.value(private);
  }
}

Future<void> enter(WidgetTester t, String text) async {
  await t.ensureVisible(find.byKey(summaryKey));
  await t.pump();
  await t.enterText(find.byKey(summaryKey), text);
  await t.pumpAndSettle();
}

Future<void> select(WidgetTester t, String label) async {
  await b.tap(t, stateKey);
  await t.tap(find.text(label).last);
  await t.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    testWidgets('large text with keyboard supports full review in $locale', (
      t,
    ) async {
      final f = Fixture()..setup();
      final l = await b.pump(
        t,
        f,
        width: 390,
        height: 844,
        scale: 1.8,
        keyboard: 320,
        locale: Locale(locale),
      );
      await p.open(t);
      await enter(t, 'Summary');
      await select(t, l.mrReviewRequestChanges);
      final checkbox = find.descendant(
        of: find.byKey(p.ackKey),
        matching: find.byType(Checkbox),
      );
      await t.ensureVisible(checkbox);
      await t.pump();
      await t.tap(checkbox);
      await t.pumpAndSettle();
      expect(b.enabled(t, p.publishKey), true);
      expect(t.takeException(), isNull);
      await b.tap(t, p.cancelKey);
    });
  }

  if (Platform.environment['LABFOX_REVIEW_SUBMISSION_CAPTURE']
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
            final l = await b.pump(
              t,
              f,
              width: width,
              height: width < 600 ? 1000 : 1100,
              dark: dark,
              theme: theme,
            );
            await p.open(t);
            await enter(
              t,
              'The pagination handling is ready after the noted changes.',
            );
            await select(t, l.mrReviewRequestChanges);
            if (recovering) {
              await b.tap(t, p.ackKey);
              f.private.outcome = const GitLabServerException(
                'Synthetic publication failure',
              );
              await b.tap(t, p.publishKey);
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
              await b.tap(t, p.inspectKey);
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

  testWidgets('exact summary and selected outcome require renewed consent', (
    t,
  ) async {
    final f = Fixture()..setup();
    final l = await b.pump(t, f);
    await p.open(t);
    expect(find.byKey(summaryKey), findsOneWidget);
    expect(find.byKey(stateKey), findsOneWidget);
    await b.tap(t, p.ackKey);
    await enter(t, '  **Public summary**\n ');
    expect(b.enabled(t, p.publishKey), false);
    await b.tap(t, p.ackKey);
    await select(t, l.mrReviewRequestChanges);
    expect(b.enabled(t, p.publishKey), false);
    await b.tap(t, p.ackKey);
    await b.tap(t, p.publishKey);
    expect(f.private.submissions, [
      ('  **Public summary**\n ', ReviewerSubmissionState.requestedChanges),
    ]);
    expect(f.comments.posts, isEmpty);
    expect(f.events.names, isEmpty);
  });
  testWidgets(
    'unavailable preflight recovery clears outcome and permits summary publication',
    (t) async {
      final f = Fixture()..setup();
      final l = await b.pump(t, f);
      await p.open(t);
      await enter(t, 'Public summary');
      await select(t, l.mrReviewReviewed);
      await b.tap(t, p.ackKey);
      f.private.review = const GitLabNotFoundException('No status read');
      await b.tap(t, p.publishKey);
      expect(f.private.submissions, isEmpty);
      await b.tap(t, p.inspectKey);
      expect(find.text(l.mrReviewStateUnavailable), findsOneWidget);
      await b.tap(t, p.ackKey);
      expect(b.enabled(t, p.publishKey), true);
      await b.tap(t, p.publishKey);
      expect(f.private.submissions, [('Public summary', null)]);
    },
  );
  testWidgets('summary-only submission with empty drafts', (t) async {
    final f = Fixture()..setup();
    f.private.pages[1] = b.page([]);
    await b.pump(t, f);
    await p.open(t);
    expect(b.enabled(t, p.publishKey), false);
    await enter(t, 'Public summary');
    await b.tap(t, p.ackKey);
    await b.tap(t, p.publishKey);
    expect(f.private.submissions, [('Public summary', null)]);
  });
  testWidgets('unavailable reviewer read still permits notes and summary', (
    t,
  ) async {
    final f = Fixture()..setup();
    f.private.review = const GitLabNotFoundException('Unsupported');
    final l = await b.pump(t, f);
    await p.open(t);
    expect(find.text(l.mrReviewStateUnavailable), findsOneWidget);
    expect(
      t
          .widget<DropdownButtonFormField<ReviewerSubmissionState?>>(
            find.byKey(stateKey),
          )
          .onChanged,
      isNull,
    );
    await enter(t, 'Summary');
    await b.tap(t, p.ackKey);
    await b.tap(t, p.publishKey);
    expect(f.private.submissions, [('Summary', null)]);
  });
  testWidgets(
    'uncertain submission retains input but requires inspection and fresh consent',
    (t) async {
      final f = Fixture()..setup();
      final l = await b.pump(t, f);
      await p.open(t);
      await enter(t, 'Retained summary');
      await select(t, l.mrReviewReviewed);
      await b.tap(t, p.ackKey);
      f.private.outcome = const GitLabServerException('Partly applied');
      await b.tap(t, p.publishKey);
      expect(f.private.submissions.length, 1);
      expect(find.text(l.mrReviewPartialHint), findsOneWidget);
      expect(
        t.widget<TextField>(find.byKey(summaryKey)).controller!.text,
        'Retained summary',
      );
      f.private.outcome = null;
      await b.tap(t, p.inspectKey);
      expect(b.enabled(t, p.publishKey), false);
      expect(f.private.submissions.length, 1);
      await b.tap(t, p.ackKey);
      await b.tap(t, p.publishKey);
      expect(f.private.submissions.length, 2);
    },
  );
  testWidgets('account replacement discards unsent review options', (t) async {
    final f = Fixture()..setup();
    final l = await b.pump(t, f);
    await p.open(t);
    await enter(t, 'Private input to discard');
    await select(t, l.mrReviewReviewed);
    f.c.read(b.accountState.notifier).state = b.account.copyWith(
      user: b.account.user.copyWith(id: 99),
    );
    await t.pumpAndSettle();
    expect(find.byKey(summaryKey), findsNothing);
    expect(find.text('Private input to discard'), findsNothing);
    expect(b.enabled(t, p.publishKey), false);
  });
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('review options $locale $width dark=$dark', (t) async {
          final f = Fixture()..setup();
          final l = await b.pump(
            t,
            f,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          await p.open(t);
          await enter(t, 'Synthetic public summary');
          await select(t, l.mrReviewRequestChanges);
          await b.tap(t, p.ackKey);
          expect(b.enabled(t, p.publishKey), true);
          expect(t.takeException(), isNull);
          await b.tap(t, p.cancelKey);
          expect(f.private.submissions, isEmpty);
        });
      }
    }
  }
}
