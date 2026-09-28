import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/widgets/cleanup_policy_keep_count_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'cleanup_policy_keep_count_controller_test.dart'
    show KeepCountRepository, reviewedPolicy;

class _Repositories extends ContainerRepositoriesController {
  @override
  Future<Paginated<RegistryRepository>> build(int arg) async =>
      const Paginated(items: []);
}

Future<void> open(
  WidgetTester tester,
  KeepCountRepository repository, {
  double width = 390,
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const CleanupPolicyKeepCountDialog(projectId: 7),
              ),
              child: const Text('Open test dialog'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open test dialog'));
  await tester.pumpAndSettle();
}

Future<void> selectOne(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'registry entry opens project-wide retention count confirmation',
    (tester) async {
      final repository = KeepCountRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            containerRegistryRepositoryProvider.overrideWith(
              (ref) async => repository,
            ),
            containerRepositoriesControllerProvider.overrideWith(
              _Repositories.new,
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ContainerRegistryScreen(projectId: 7),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit cleanup retention count'));
      await tester.pumpAndSettle();
      expect(find.byType(CleanupPolicyKeepCountDialog), findsOneWidget);
      expect(repository.writes, isEmpty);
    },
  );
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'explicit retention count confirmation fits $width dark=$dark',
        (tester) async {
          final repository = KeepCountRepository();
          await open(tester, repository, width: width, dark: dark);
          expect(
            find.text('Project 7 — all image repositories'),
            findsOneWidget,
          );
          expect(find.text('release.+'), findsOneWidget);
          expect(find.text('stable'), findsOneWidget);
          expect(
            tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
            isNull,
          );
          await selectOne(tester);
          expect(repository.writes, isEmpty);
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();
          expect(repository.writes, [1]);
          expect(find.byType(CleanupPolicyKeepCountDialog), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'unknown retention count remains unchanged until explicit selection',
    (tester) async {
      final repository = KeepCountRepository()
        ..policy = reviewedPolicy.copyWith(keepN: 999);
      await open(tester, repository);
      expect(find.text('999'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.writes, isEmpty);
    },
  );
  testWidgets('stale criteria block save until reloaded and reselected', (
    tester,
  ) async {
    final repository = KeepCountRepository();
    await open(tester, repository);
    await selectOne(tester);
    repository.policy = reviewedPolicy.copyWith(olderThan: '30d');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Reload policy'));
    await tester.pumpAndSettle();
    expect(find.text('30d'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await selectOne(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, [1]);
  });
  testWidgets('forbidden update retains selection with private text hidden', (
    tester,
  ) async {
    final repository = KeepCountRepository()
      ..failure = const GitLabForbiddenException('private details');
    await open(tester, repository);
    await selectOne(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('private details'), findsNothing);
    repository.failure = null;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, [1, 1]);
  });
  testWidgets('pending save blocks cancellation and duplicate writes', (
    tester,
  ) async {
    final repository = KeepCountRepository()..pending = Completer<void>();
    await open(tester, repository);
    await selectOne(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(CleanupPolicyKeepCountDialog), findsOneWidget);
    expect(repository.writes, [1]);
    repository.pending!.complete();
    await tester.pumpAndSettle();
  });
  testWidgets('absent policy cannot be created', (tester) async {
    final repository = KeepCountRepository()..policy = null;
    await open(tester, repository);
    expect(find.byType(DropdownButtonFormField<int>), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(repository.writes, isEmpty);
  });
  testWidgets('unreported criteria cannot be rescheduled', (tester) async {
    final repository = KeepCountRepository()
      ..policy = reviewedPolicy.copyWith(keepN: null);
    await open(tester, repository);
    expect(find.byType(DropdownButtonFormField<int>), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(repository.writes, isEmpty);
  });
}
