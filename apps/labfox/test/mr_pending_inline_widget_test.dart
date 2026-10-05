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
import 'package:labfox/features/merge_requests/presentation/mr_changes_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'mr_pending_inline_save_test.dart' as b;

Future<AppLocalizations> pump(
  WidgetTester tester,
  b.Fixture f, {
  double width = 390,
  bool dark = false,
  Locale locale = const Locale('en'),
  double scale = 1,
  double keyboard = 0,
  bool settle = true,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: f.c,
      child: RepaintBoundary(
        key: const ValueKey('capture'),
        child: MaterialApp(
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
          home: const MrChangesScreen(projectId: 8, iid: 142),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return AppLocalizations.of(tester.element(find.byType(MrChangesScreen)));
}

Finder key(String s) => find.byKey(ValueKey(s));
Future<void> tap(WidgetTester tester, String s, {bool settle = true}) async {
  await tester.pump();
  final f = key(s);
  await tester.ensureVisible(f);
  await tester.tap(f);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> select(
  WidgetTester tester,
  AppLocalizations l,
  int index, {
  bool range = false,
}) async {
  final f = find
      .byTooltip(range ? l.mrDiffRangeEndButton : l.mrDiffDiscussLineButton)
      .at(index);
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'private inline action opens separate input without changing public draft',
    (tester) async {
      final f = b.Fixture();
      final l = await pump(tester, f);
      await select(tester, l, 2);
      await tester.enterText(
        key('mr-diff-discussion-draft'),
        'Public draft retained',
      );
      await tap(tester, 'mr-pending-inline-open');
      expect(
        tester
            .widget<TextField>(key('mr-pending-compose-input'))
            .controller!
            .text,
        isEmpty,
      );
      await tester.enterText(key('mr-pending-compose-input'), b.markdown);
      await f.displayed();
      final p = f.selection(2);
      f.confirms(p);
      await tap(tester, 'mr-pending-compose-save');
      expect(f.drafts.writes, [(8, 142, 1100, b.markdown, p)]);
      expect(
        tester
            .widget<TextField>(key('mr-diff-discussion-draft'))
            .controller!
            .text,
        'Public draft retained',
      );
      expect(f.comments.posts, isEmpty);
      expect(f.events.names, isEmpty);
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('localized private range $locale $width $dark', (t) async {
          final f = b.Fixture();
          final l = await pump(
            t,
            f,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          await select(t, l, 0);
          await t.tap(find.text(l.mrDiffSelectRangeButton));
          await t.pumpAndSettle();
          await select(t, l, 1, range: true);
          await f.displayed();
          final p = f.selection(2, range: true);
          f.confirms(p);
          await tap(t, 'mr-pending-inline-open');
          expect(find.text(l.mrPendingInlineTitle), findsOneWidget);
          expect(
            find.text(l.mrDiscussionContextRangeLabel('-27', '+30')),
            findsOneWidget,
          );
          await t.enterText(key('mr-pending-compose-input'), b.markdown);
          await tap(t, 'mr-pending-compose-save');
          expect(f.drafts.writes.single.$5, p);
          expect(f.comments.posts, isEmpty);
          expect(find.text(l.mrPendingComposeSaved), findsOneWidget);
          expect(t.takeException(), isNull);
        });
      }
    }
  }
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    testWidgets('large text with keyboard retains private input $locale', (
      t,
    ) async {
      final f = b.Fixture();
      final l = await pump(t, f, locale: Locale(locale));
      await select(t, l, 2);
      await tap(t, 'mr-pending-inline-open');
      await t.enterText(key('mr-pending-compose-input'), b.markdown);
      await pump(t, f, locale: Locale(locale), scale: 1.8, keyboard: 320);
      expect(
        t.widget<TextField>(key('mr-pending-compose-input')).controller!.text,
        b.markdown,
      );
      await tap(t, 'mr-pending-compose-cancel');
      expect(f.drafts.writes, isEmpty);
      expect(t.takeException(), isNull);
    });
  }
  for (final changed in ['version', 'text']) {
    testWidgets(
      'fresh diff $changed change discards obsolete private input without reanchoring',
      (t) async {
        final f = b.Fixture();
        final l = await pump(t, f);
        await select(t, l, 2);
        await tap(t, 'mr-pending-inline-open');
        await t.enterText(key('mr-pending-compose-input'), b.markdown);
        if (changed == 'version') {
          f.diffs.listing = Paginated(items: [b.version(head: 'other')]);
          f.diffs.detail = b.version(head: 'other');
        } else {
          f.diffs.detail = b.version(
            diff: b.raw.replaceFirst('+new', '+changed'),
          );
        }
        await tap(t, 'mr-pending-compose-save');
        expect(f.drafts.writes, isEmpty);
        expect(key('mr-pending-compose-input'), findsNothing);
        expect(find.text(l.mrPendingComposeChanged), findsOneWidget);
        expect(f.controller.pendingSaveNeedsInspection, false);
        expect(find.text(l.mrPendingComposeSaved), findsNothing);
        await tap(t, 'mr-pending-compose-cancel');
        expect(t.takeException(), isNull);
      },
    );
  }
  for (final change in ['account', 'client', 'drafts', 'diffs', 'route']) {
    for (final lateError in [false, true]) {
      testWidgets(
        'obsolete private dialog $change lateError=$lateError hides input and late effects',
        (t) async {
          final f = b.Fixture();
          final l = await pump(t, f);
          await select(t, l, 2);
          await tap(t, 'mr-pending-inline-open');
          await f.displayed();
          final p = f.selection(2);
          await t.enterText(key('mr-pending-compose-input'), b.markdown);
          final write = Completer<MergeRequestDraftNote>();
          f.drafts.result = write.future;
          await tap(t, 'mr-pending-compose-save', settle: false);
          expect(f.drafts.writes.length, 1);
          switch (change) {
            case 'account':
              f.c.read(b.accountState.notifier).state = b.account.copyWith(
                instanceUrl: 'https://other.example.com',
              );
            case 'client':
              f.c.read(b.clientState.notifier).state = Future.value(null);
            case 'drafts':
              f.c.read(b.draftState.notifier).state = Future.value(
                b.Drafts(f.api),
              );
            case 'diffs':
              f.c.read(b.diffState.notifier).state = Future.value(
                b.Diffs(f.api),
              );
            case 'route':
              await t.pumpWidget(const MaterialApp(home: Text('Other route')));
          }
          await t.pump();
          await t.pump(const Duration(milliseconds: 100));
          expect(key('mr-pending-compose-input'), findsNothing);
          if (lateError) {
            write.completeError(const GitLabServerException('Late'));
          } else {
            write.complete(b.draft(7).copyWith(position: p));
          }
          await t.pumpAndSettle();
          expect(find.text(l.mrPendingComposeSaved), findsNothing);
          expect(f.drafts.writes.length, 1);
          expect(f.events.names, isEmpty);
          expect(t.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'uncertain inline save requires complete visible inspection and explicit new consent',
    (t) async {
      final f = b.Fixture();
      final l = await pump(t, f);
      await select(t, l, 2);
      await f.displayed();
      final p = f.selection(2);
      await tap(t, 'mr-pending-inline-open');
      await t.enterText(key('mr-pending-compose-input'), b.markdown);
      f.drafts.result = const GitLabServerException('Uncertain');
      await tap(t, 'mr-pending-compose-save');
      expect(f.drafts.writes.length, 1);
      expect(find.text(l.mrPendingComposeUncertain), findsOneWidget);
      f.drafts.pages[1] = b.page([b.draft(7).copyWith(position: p)], next: 2);
      f.drafts.pages[2] = b.page([]);
      await tap(t, 'mr-pending-compose-inspect');
      expect(f.drafts.reads.map((r) => r.$3), [1, 2]);
      expect(
        t.widget<TextButton>(key('mr-pending-compose-save')).onPressed,
        isNull,
      );
      await tap(t, 'mr-pending-compose-acknowledge');
      f.confirms(p);
      await tap(t, 'mr-pending-compose-save');
      expect(f.drafts.writes.length, 2);
      expect(f.comments.posts, isEmpty);
    },
  );
  testWidgets(
    'diff read failure retries preparation without dispatching private or public writes',
    (t) async {
      final f = b.Fixture();
      final l = await pump(t, f);
      await select(t, l, 2);
      await tap(t, 'mr-pending-inline-open');
      await t.enterText(key('mr-pending-compose-input'), b.markdown);
      f.diffs.detail = const GitLabServerException('Synthetic diff failure');
      await tap(t, 'mr-pending-compose-save');
      expect(f.drafts.writes, isEmpty);
      expect(key('mr-pending-compose-input'), findsOneWidget);
      f.diffs.detail = b.version();
      await tap(t, 'mr-pending-compose-prepare-retry');
      expect(f.drafts.writes, isEmpty);
      expect(f.comments.posts, isEmpty);
      await f.displayed();
      final p = f.selection(2);
      f.confirms(p);
      await tap(t, 'mr-pending-compose-save');
      expect(f.drafts.writes.length, 1);
    },
  );

  if (Platform.environment['LABFOX_INLINE_DRAFT_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        for (final recovery in [false, true]) {
          testWidgets('synthetic inline capture $width $dark $recovery', (
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
              filledButtonTheme: FilledButtonThemeData(
                style: font(base.filledButtonTheme.style!),
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
            final f = b.Fixture();
            final l = await pump(t, f, width: width, dark: dark, theme: theme);
            await select(t, l, 0);
            await t.tap(find.text(l.mrDiffSelectRangeButton));
            await t.pumpAndSettle();
            await select(t, l, 1, range: true);
            await f.displayed();
            final p = f.selection(2, range: true);
            await tap(t, 'mr-pending-inline-open');
            await t.enterText(
              key('mr-pending-compose-input'),
              'Please add a regression test for this selected range.',
            );
            await t.pumpAndSettle();
            if (recovery) {
              f.drafts.result = const GitLabServerException(
                'Synthetic uncertain save',
              );
              await tap(t, 'mr-pending-compose-save');
              f.drafts.pages[1] = b.page([
                b
                    .draft(
                      7,
                      body:
                          'Please add a regression test for this selected range.',
                    )
                    .copyWith(position: p),
              ]);
              await tap(t, 'mr-pending-compose-inspect');
            }
            expect(t.takeException(), isNull);
            final boundary = t.renderObject<RenderRepaintBoundary>(
              key('capture'),
            );
            await t.runAsync(() async {
              final img = await boundary.toImage(pixelRatio: 1);
              final png = await img.toByteData(format: ui.ImageByteFormat.png);
              Directory(directory).createSync(recursive: true);
              File(
                '$directory/inline-${width.toInt()}-${dark ? 'dark' : 'light'}-${recovery ? 'inspection' : 'compose'}.png',
              ).writeAsBytesSync(png!.buffer.asUint8List());
              img.dispose();
            });
          });
        }
      }
    }
  }
}
