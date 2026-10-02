import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/widgets/cleanup_policy_age_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'cleanup_policy_age_controller_test.dart'
    show AgeRepository, reviewedPolicy;

class _Repositories extends ContainerRepositoriesController {
  @override
  Future<Paginated<RegistryRepository>> build(int arg) async =>
      const Paginated(items: []);
}

Future<void> open(
  WidgetTester tester,
  AgeRepository repository, {
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
                builder: (_) => const CleanupPolicyAgeDialog(projectId: 7),
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

Future<void> selectYoungest(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1d').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('current retention count has its own criterion label', (
    tester,
  ) async {
    await open(tester, AgeRepository());
    final context = tester.element(find.byType(CleanupPolicyAgeDialog));
    final l10n = AppLocalizations.of(context);
    expect(find.text(l10n.containerPolicyKeepCount), findsOneWidget);
  });

  testWidgets('registry entry opens project-wide age limit confirmation', (
    tester,
  ) async {
    final repository = AgeRepository();
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
    await tester.tap(find.byTooltip('Edit cleanup age limit'));
    await tester.pumpAndSettle();
    expect(find.byType(CleanupPolicyAgeDialog), findsOneWidget);
    expect(repository.writes, isEmpty);
  });
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('explicit age limit confirmation fits $width dark=$dark', (
        tester,
      ) async {
        final repository = AgeRepository();
        await open(tester, repository, width: width, dark: dark);
        expect(find.text('Project 7 — all image repositories'), findsOneWidget);
        expect(find.text('release.+'), findsOneWidget);
        expect(find.text('stable'), findsOneWidget);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        await selectYoungest(tester);
        expect(repository.writes, isEmpty);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(repository.writes, ['1d']);
        expect(find.byType(CleanupPolicyAgeDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('unknown age limit remains unchanged until explicit selection', (
    tester,
  ) async {
    final repository = AgeRepository()
      ..policy = reviewedPolicy.copyWith(olderThan: 'future');
    await open(tester, repository);
    expect(find.text('future'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
  });
  testWidgets('stale criteria block save until reloaded and reselected', (
    tester,
  ) async {
    final repository = AgeRepository();
    await open(tester, repository);
    await selectYoungest(tester);
    repository.policy = reviewedPolicy.copyWith(keepN: 25);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Reload policy'));
    await tester.pumpAndSettle();
    expect(find.text('25'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await selectYoungest(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, ['1d']);
  });
  testWidgets('forbidden update retains selection with private text hidden', (
    tester,
  ) async {
    final repository = AgeRepository()
      ..failure = const GitLabForbiddenException('private details');
    await open(tester, repository);
    await selectYoungest(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('private details'), findsNothing);
    repository.failure = null;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, ['1d', '1d']);
  });
  testWidgets('pending save blocks cancellation and duplicate writes', (
    tester,
  ) async {
    final repository = AgeRepository()..pending = Completer<void>();
    await open(tester, repository);
    await selectYoungest(tester);
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
    expect(find.byType(CleanupPolicyAgeDialog), findsOneWidget);
    expect(repository.writes, ['1d']);
    repository.pending!.complete();
    await tester.pumpAndSettle();
  });
  testWidgets('absent policy cannot be created', (tester) async {
    final repository = AgeRepository()..policy = null;
    await open(tester, repository);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(repository.writes, isEmpty);
  });
  testWidgets('unreported criteria cannot be rescheduled', (tester) async {
    final repository = AgeRepository()
      ..policy = reviewedPolicy.copyWith(olderThan: null);
    await open(tester, repository);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(repository.writes, isEmpty);
  });
}
