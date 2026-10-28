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
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_commits_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_original_review_controller.dart';
import 'package:labfox/features/merge_requests/presentation/mr_commits_screen.dart';
import 'package:labfox/features/merge_requests/presentation/mr_original_changes_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'mr_original_review_snapshot_test.dart' as o;
import 'mr_pending_original_review_save_test.dart' as b;
import 'mr_pending_review_save_test.dart' as pending;

Future<AppLocalizations> pump(
  WidgetTester t,
  b.Fixture f, {
  double width = 390,
  bool dark = false,
  String locale = 'en',
  bool settle = true,
  double scale = 1,
  double keyboard = 0,
  ThemeData? theme,
}) async {
  t.view.physicalSize = Size(width, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: f.c,
      child: RepaintBoundary(
        key: const ValueKey('capture'),
        child: MaterialApp(
          theme: theme ?? (dark ? LabFoxTheme.dark : LabFoxTheme.light),
          debugShowCheckedModeBanner: false,
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: child!,
          ),
          home: const MrOriginalChangesScreen(
            projectId: 8,
            iid: 142,
            commitId: o.head,
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
  }
  return AppLocalizations.of(t.element(find.byType(MrOriginalChangesScreen)));
}

Future<void> tap(WidgetTester t, String key, {bool settle = true}) async {
  await t.pump();
  final f = find.byKey(ValueKey(key));
  await t.ensureVisible(f);
  await t.tap(f);
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> select(
  WidgetTester t,
  AppLocalizations l, {
  int index = 2,
  bool end = false,
}) async {
  final f = find
      .byTooltip(end ? l.mrDiffRangeEndButton : l.mrPendingComposeOpen)
      .at(index);
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
}

class FakeList extends MrCommitsController {
  FakeList(this.readResult);
  final Object Function() readResult;
  @override
  Future<List<Commit>?> build(MergeRequestRef arg) async {
    final v = readResult();
    if (v is List<Commit>) return v;
    if (v is Future<List<Commit>?>) return v;
    throw v;
  }
}

void main() {
  testWidgets(
    'single-line private selection survives a window resize and saves exact Markdown',
    (t) async {
      final f = b.Fixture();
      final l = await pump(t, f, width: 390);
      await select(t, l);
      t.view.physicalSize = const Size(1200, 1000);
      await t.pumpAndSettle();
      final s = f.c.read(mrOriginalReviewControllerProvider(o.arg)).value!;
      final file = s.files.single;
      f.position = s.positionFor(file, file.hunks.single.lines.last)!;
      f.mockDrafts.position = f.position;
      await tap(t, 'mr-original-private-open');
      await t.enterText(
        find.byKey(const ValueKey('mr-pending-compose-input')),
        pending.markdown,
      );
      await tap(t, 'mr-pending-compose-save');
      expect(f.mockDrafts.commits.single.$6.lineRange, null);
      expect(f.mockDrafts.commits.single.$5, pending.markdown);
      expect(t.takeException(), null);
    },
  );
  testWidgets(
    'large text and keyboard keep original private input and controls reachable',
    (t) async {
      final f = b.Fixture();
      final l = await pump(t, f, width: 390, scale: 2, keyboard: 300);
      await select(t, l);
      await tap(t, 'mr-original-private-open');
      await t.enterText(
        find.byKey(const ValueKey('mr-pending-compose-input')),
        'Private review',
      );
      await t.ensureVisible(
        find.byKey(const ValueKey('mr-pending-compose-save')),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), null);
      expect(
        find.byKey(const ValueKey('mr-pending-compose-input')),
        findsOneWidget,
      );
    },
  );

  test(
    'commit routes remove canonical and invalid commit values from analytics',
    () {
      expect(
        sanitizeRoute(
          '/projects/8/merge_requests/142/commits/${o.head}',
          routeTemplate: '/projects/:id/merge_requests/:iid/commits/:sha',
        ),
        '/projects/:id/merge_requests/:iid/commits/:sha',
      );
      expect(
        sanitizeRoute(
          '/projects/8/commit/private-value/changes',
          routeTemplate: '/projects/:id/commit/:sha/changes',
        ),
        '/projects/:id/commit/:sha/changes',
      );
    },
  );
  testWidgets('MR commit list navigates by route identifiers only', (t) async {
    final router = GoRouter(
      initialLocation: '/list',
      routes: [
        GoRoute(
          path: '/list',
          builder: (_, _) => const MrCommitsScreen(projectId: 8, iid: 142),
        ),
        GoRoute(
          path: '/projects/:project/merge_requests/:iid/commits/:sha',
          builder: (_, s) => Text(s.uri.path),
        ),
      ],
    );
    addTearDown(router.dispose);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          mrCommitsControllerProvider.overrideWith(
            () => FakeList(
              () => const [
                Commit(id: o.head, title: 'Original selected commit'),
              ],
            ),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Original selected commit'));
    await t.pumpAndSettle();
    expect(
      find.text(Routes.mergeRequestCommitChanges(8, 142, o.head)),
      findsOneWidget,
    );
    expect(t.takeException(), null);
  });
  testWidgets(
    'commit list loading, current error, retry and empty state are distinct',
    (t) async {
      final pendingList = Completer<List<Commit>?>();
      Object result = pendingList.future;
      final c = ProviderContainer(
        overrides: [
          mrCommitsControllerProvider.overrideWith(
            () => FakeList(() => result),
          ),
        ],
      );
      addTearDown(c.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MrCommitsScreen(projectId: 8, iid: 142),
          ),
        ),
      );
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pendingList.completeError(const GitLabServerException('Hidden details'));
      await t.pumpAndSettle();
      final l = AppLocalizations.of(t.element(find.byType(MrCommitsScreen)));
      expect(find.text(l.commitsError), findsOneWidget);
      expect(find.textContaining('Hidden details'), findsNothing);
      result = <Commit>[];
      await t.tap(find.text(l.retry));
      await t.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      expect(find.text(l.commitsError), findsNothing);
      expect(t.takeException(), null);
    },
  );

  test(
    'identifier-only original routes and analytics never expose a commit value',
    () {
      expect(
        Routes.mergeRequestCommits(8, 142),
        '/projects/8/merge_requests/142/commits',
      );
      expect(
        Routes.mergeRequestCommitChanges(8, 142, o.head),
        '/projects/8/merge_requests/142/commits/${o.head}',
      );
      expect(
        sanitizeRoute(
          '/projects/8/merge_requests/142/commits/${o.head}',
          routeTemplate: '/projects/:id/merge_requests/:iid/commits/:sha',
        ),
        '/projects/:id/merge_requests/:iid/commits/:sha',
      );
      expect(
        sanitizeRoute(
          '/projects/8/merge_requests/142/commits/private-value',
          routeTemplate: '/projects/:id/merge_requests/:iid/commits/:sha',
        ),
        '/projects/:id/merge_requests/:iid/commits/:sha',
      );
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('original private range $locale $width $dark', (t) async {
          final f = b.Fixture();
          final l = await pump(t, f, width: width, dark: dark, locale: locale);
          expect(find.textContaining('same'), findsOneWidget);
          expect(find.textContaining('new'), findsOneWidget);
          await select(t, l, index: 0);
          await tap(t, 'mr-original-select-range');
          await select(t, l, index: 1, end: true);
          final s = f.c.read(mrOriginalReviewControllerProvider(o.arg)).value!;
          final file = s.files.single;
          f.position = s.rangePositionFor(
            file,
            file.hunks.single.lines.first,
            file.hunks.single.lines.last,
          )!;
          f.mockDrafts.position = f.position;
          await tap(t, 'mr-original-private-open');
          expect(find.text(l.mrPendingInlineTitle), findsOneWidget);
          await t.enterText(
            find.byKey(const ValueKey('mr-pending-compose-input')),
            pending.markdown,
          );
          await tap(t, 'mr-pending-compose-save');
          expect(f.mockDrafts.commits.single.$6, f.position);
          expect(f.mockDrafts.commits.single.$5, pending.markdown);
          expect(f.mockDrafts.writes, isEmpty);
          expect(f.comments.posts, isEmpty);
          expect(find.text(l.mrPendingComposeSaved), findsOneWidget);
          expect(t.takeException(), null);
        });
      }
    }
  }
  for (final parents in <List<String>?>[
    null,
    [],
    [o.parent, o.other],
  ]) {
    testWidgets(
      'unsupported original parents remain readable without selection $parents',
      (t) async {
        final f = b.Fixture();
        f.details.contextResult = o.context(parents: parents);
        final l = await pump(t, f);
        expect(find.textContaining('same'), findsOneWidget);
        expect(find.byTooltip(l.mrPendingComposeOpen), findsNothing);
        expect(
          find.byKey(const ValueKey('mr-original-private-open')),
          findsNothing,
        );
        expect(t.takeException(), null);
      },
    );
  }
  testWidgets(
    'omitted or malformed files are explicit and never use permissive rows',
    (t) async {
      final f = b.Fixture();
      f.details.contextResult = o.context(
        files: [
          o.literal.copyWith(diff: '@@ -1 +1 @@\n? untrusted'),
          o.literal.copyWith(
            oldPath: 'b.dart',
            newPath: 'b.dart',
            isTooLarge: true,
            diff: '',
          ),
        ],
      );
      await pump(t, f);
      expect(find.text('a.dart'), findsOneWidget);
      expect(find.text('b.dart'), findsOneWidget);
      expect(find.textContaining('untrusted'), findsNothing);
      expect(t.takeException(), null);
    },
  );
  testWidgets('current original error has read-only retry', (t) async {
    final f = b.Fixture();
    f.details.contextResult = const GitLabServerException('private details');
    final l = await pump(t, f);
    expect(find.text(l.changesError), findsOneWidget);
    expect(find.textContaining('private details'), findsNothing);
    f.details.contextResult = o.context();
    await t.tap(find.text(l.retry));
    await t.pumpAndSettle();
    expect(find.textContaining('same'), findsOneWidget);
    expect(f.mockDrafts.commits, isEmpty);
  });
  testWidgets('account replacement discards private dialog input', (t) async {
    final f = b.Fixture();
    final l = await pump(t, f);
    await select(t, l);
    await tap(t, 'mr-original-private-open');
    await t.enterText(
      find.byKey(const ValueKey('mr-pending-compose-input')),
      'Secret private body',
    );
    f.c.read(pending.accountState.notifier).state = null;
    await t.pumpAndSettle();
    expect(find.text('Secret private body'), findsNothing);
    expect(
      find.byKey(const ValueKey('mr-pending-compose-input')),
      findsNothing,
    );
    expect(f.mockDrafts.commits, isEmpty);
  });
  testWidgets(
    'uncertain original save exposes existing inspection with no replay',
    (t) async {
      final f = b.Fixture();
      final l = await pump(t, f);
      await select(t, l);
      await tap(t, 'mr-original-private-open');
      await t.enterText(
        find.byKey(const ValueKey('mr-pending-compose-input')),
        pending.markdown,
      );
      f.mockDrafts.outcome = const GitLabServerException('Uncertain');
      await tap(t, 'mr-pending-compose-save');
      expect(f.mockDrafts.commits.length, 1);
      expect(
        find.byKey(const ValueKey('mr-pending-compose-inspect')),
        findsOneWidget,
      );
      await tap(t, 'mr-pending-compose-inspect');
      expect(f.mockDrafts.reads, isNotEmpty);
      expect(f.mockDrafts.commits.length, 1);
      expect(f.comments.posts, isEmpty);
    },
  );
  testWidgets(
    'changed complete literal fingerprint prevents a save of old selected text',
    (t) async {
      final f = b.Fixture();
      final l = await pump(t, f);
      await select(t, l);
      await tap(t, 'mr-original-private-open');
      await t.enterText(
        find.byKey(const ValueKey('mr-pending-compose-input')),
        pending.markdown,
      );
      f.details.contextResult = o.context(
        files: [
          o.literal.copyWith(diff: o.raw.replaceFirst('same', 'changed')),
        ],
      );
      await tap(t, 'mr-pending-compose-save');
      expect(f.mockDrafts.commits, isEmpty);
      expect(
        find.byKey(const ValueKey('mr-pending-compose-input')),
        findsNothing,
      );
    },
  );
  testWidgets('invalid commit deep link starts no identity or original read', (
    t,
  ) async {
    final f = b.Fixture();
    await t.pump();
    f.details.contexts = 0;
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: f.c,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MrOriginalChangesScreen(
            projectId: 8,
            iid: 142,
            commitId: 'HEAD',
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(f.details.reads, isEmpty);
    expect(f.details.contexts, 0);
  });
  if (Platform.environment['LABFOX_ORIGINAL_REVIEW_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 1200.0]) {
      for (final dark in [false, true]) {
        for (final dialog in [false, true]) {
          testWidgets('synthetic original review capture $width $dark $dialog', (
            t,
          ) async {
            await t.runAsync(() async {
              final sdk = Platform.environment['FLUTTER_ROOT']!;
              for (final (family, name) in [
                ('Roboto', 'Roboto-Regular.ttf'),
                ('monospace', 'Roboto-Regular.ttf'),
                ('MaterialIcons', 'MaterialIcons-Regular.otf'),
              ]) {
                final loader = FontLoader(family)
                  ..addFont(
                    Future.value(
                      ByteData.view(
                        File(
                          '$sdk/bin/cache/artifacts/material_fonts/$name',
                        ).readAsBytesSync().buffer,
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
              filledButtonTheme: FilledButtonThemeData(
                style: font(base.filledButtonTheme.style!),
              ),
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
            );
            final f = b.Fixture();
            final l = await pump(t, f, width: width, dark: dark, theme: theme);
            await select(t, l, index: 0);
            await tap(t, 'mr-original-select-range');
            await select(t, l, index: 1, end: true);
            if (dialog) {
              await tap(t, 'mr-original-private-open');
              await t.enterText(
                find.byKey(const ValueKey('mr-pending-compose-input')),
                'Please add a regression test for this original commit.',
              );
              await t.pumpAndSettle();
            }
            expect(t.takeException(), null);
            final boundary = t.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('capture')),
            );
            await t.runAsync(() async {
              final img = await boundary.toImage(pixelRatio: 1);
              final png = await img.toByteData(format: ui.ImageByteFormat.png);
              Directory(directory).createSync(recursive: true);
              File(
                '$directory/original-${width.toInt()}-${dark ? 'dark' : 'light'}-${dialog ? 'compose' : 'selection'}.png',
              ).writeAsBytesSync(png!.buffer.asUint8List());
              img.dispose();
            });
          });
        }
      }
    }
  }
}
