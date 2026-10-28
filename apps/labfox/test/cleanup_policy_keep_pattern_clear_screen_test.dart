import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/widgets/cleanup_policy_keep_pattern_clear_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'cleanup_policy_keep_pattern_clear_controller_test.dart'
    show KeepPatternClearRepository, reviewedPolicy;

class _Repositories extends ContainerRepositoriesController {
  @override
  Future<Paginated<RegistryRepository>> build(int arg) async =>
      const Paginated(items: []);
}

Future<void> open(
  WidgetTester tester,
  KeepPatternClearRepository repository, {
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
                    const CleanupPolicyKeepPatternClearDialog(projectId: 7),
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

Future<void> acknowledge(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('explicit clear confirmation fits $width dark=$dark', (
        tester,
      ) async {
        final repository = KeepPatternClearRepository();
        await open(tester, repository, width: width, dark: dark);
        expect(find.text('Project 7 — all image repositories'), findsOneWidget);
        expect(find.text('stable'), findsOneWidget);
        expect(find.text('release.+'), findsOneWidget);
        expect(find.text('Matching tags to keep per image'), findsOneWidget);
        expect(find.text('Remove tags older than'), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        await acknowledge(tester);
        expect(repository.writes, 0);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(repository.writes, 1);
        expect(repository.policy, reviewedPolicy.copyWith(nameRegexKeep: ''));
        expect(find.byType(CleanupPolicyKeepPatternClearDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final policy in [
    null,
    reviewedPolicy.copyWith(nameRegexKeep: null),
    reviewedPolicy.copyWith(nameRegexKeep: ''),
    reviewedPolicy.copyWith(keepN: null),
  ]) {
    testWidgets(
      'missing criteria or already empty pattern blocks clearing $policy',
      (tester) async {
        final repository = KeepPatternClearRepository()..policy = policy;
        await open(tester, repository);
        expect(find.byType(CheckboxListTile), findsNothing);
        expect(find.byType(FilledButton), findsNothing);
        expect(repository.writes, 0);
      },
    );
  }
  testWidgets('cancel preserves the pattern', (tester) async {
    final repository = KeepPatternClearRepository();
    await open(tester, repository);
    await acknowledge(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.writes, 0);
    expect(repository.policy, reviewedPolicy);
  });
  testWidgets('stale criteria require reload and renewed acknowledgement', (
    tester,
  ) async {
    final repository = KeepPatternClearRepository();
    await open(tester, repository);
    await acknowledge(tester);
    repository.policy = reviewedPolicy.copyWith(keepN: 25);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, 0);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Reload policy'));
    await tester.pumpAndSettle();
    expect(find.text('25'), findsOneWidget);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await acknowledge(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
  });
  for (final error in [
    const GitLabForbiddenException('private server details'),
    const GitLabConflictException('private server details', statusCode: 422),
  ]) {
    testWidgets(
      'server rejection retains acknowledgement and allows retry $error',
      (tester) async {
        final repository = KeepPatternClearRepository()..failure = error;
        await open(tester, repository);
        await acknowledge(tester);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(find.textContaining('private server'), findsNothing);
        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isTrue,
        );
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull,
        );
        repository.failure = null;
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(repository.writes, 2);
      },
    );
  }
  testWidgets('pending clear blocks dismissal and duplicate writes', (
    tester,
  ) async {
    final repository = KeepPatternClearRepository()
      ..pending = Completer<void>();
    await open(tester, repository);
    await acknowledge(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(repository.writes, 1);
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
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(CleanupPolicyKeepPatternClearDialog), findsOneWidget);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
  });
  testWidgets('registry entry opens confirmation without a write', (
    tester,
  ) async {
    final repository = KeepPatternClearRepository();
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
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ContainerRegistryScreen(projectId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear cleanup keep pattern'));
    await tester.pumpAndSettle();
    expect(find.byType(CleanupPolicyKeepPatternClearDialog), findsOneWidget);
    expect(repository.writes, 0);
  });
}
