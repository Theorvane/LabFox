import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'cleanup_policy_activation_controller_test.dart'
    show ActivationRepository, reviewedPolicy;

class _Repositories extends ContainerRepositoriesController {
  @override
  Future<Paginated<RegistryRepository>> build(int arg) async =>
      const Paginated(items: []);
}

Future<void> _pump(
  WidgetTester tester,
  ActivationRepository repository, {
  double width = 390,
  bool dark = false,
  bool settle = true,
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
        containerRepositoriesControllerProvider.overrideWith(_Repositories.new),
      ],
      child: MaterialApp(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ContainerRegistryScreen(projectId: 7),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Change cleanup policy status'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  testWidgets('loading cannot be interpreted as an activation state', (
    tester,
  ) async {
    final repository = ActivationRepository()
      ..readPending = Completer<ContainerCleanupPolicy?>();
    await _pump(tester, repository, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Enable cleanup'), findsNothing);
    expect(find.text('Disable cleanup'), findsNothing);
    repository.readPending!.complete(reviewedPolicy);
    await tester.pumpAndSettle();
    expect(find.text('Disable cleanup'), findsOneWidget);
  });
  testWidgets('typed load error exposes safe reload without a write', (
    tester,
  ) async {
    final repository = ActivationRepository()
      ..readFailure = const GitLabNotFoundException(
        'private server text',
        statusCode: 404,
      );
    await _pump(tester, repository);
    expect(find.textContaining('project is not accessible'), findsOneWidget);
    expect(find.textContaining('private server'), findsNothing);
    expect(find.text('Disable cleanup'), findsNothing);
    repository.readFailure = null;
    await tester.tap(find.text('Reload policy'));
    await tester.pumpAndSettle();
    expect(find.text('Disable cleanup'), findsOneWidget);
    expect(repository.writes, isEmpty);
  });
  testWidgets('incomplete active policy can still be explicitly disabled', (
    tester,
  ) async {
    final repository = ActivationRepository()
      ..policy = const ContainerCleanupPolicy(enabled: true);
    await _pump(tester, repository);
    await tester.tap(find.text('Disable cleanup'));
    await tester.pumpAndSettle();
    expect(repository.writes, [false]);
  });
  testWidgets('incomplete disabled policy cannot be activated', (tester) async {
    final repository = ActivationRepository()
      ..policy = const ContainerCleanupPolicy(enabled: false);
    await _pump(tester, repository);
    expect(find.text('Enable cleanup'), findsNothing);
    expect(find.textContaining('retention count'), findsOneWidget);
    expect(repository.writes, isEmpty);
  });
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('activation confirmation fits $width dark=$dark', (
        tester,
      ) async {
        final repository = ActivationRepository();
        await _pump(tester, repository, width: width, dark: dark);
        expect(find.text('Project 7 — all image repositories'), findsOneWidget);
        expect(find.text('release.+'), findsOneWidget);
        expect(find.text('stable'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
        expect(find.text('Disable cleanup'), findsOneWidget);
        expect(repository.writes, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(repository.writes, isEmpty);
      });
    }
  }
  for (final enabled in [true, false]) {
    testWidgets('requires explicit confirmation for enabled=$enabled', (
      tester,
    ) async {
      final repository = ActivationRepository()
        ..policy = reviewedPolicy.copyWith(enabled: !enabled);
      await _pump(tester, repository);
      await tester.tap(
        find.text(enabled ? 'Enable cleanup' : 'Disable cleanup'),
      );
      await tester.pumpAndSettle();
      expect(repository.writes, [enabled]);
      expect(
        find.text('Cleanup policy status update accepted.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
  for (final policy in [null, const ContainerCleanupPolicy()]) {
    testWidgets('unreported policy $policy cannot be enabled', (tester) async {
      final repository = ActivationRepository()..policy = policy;
      await _pump(tester, repository);
      expect(find.text('Enable cleanup'), findsNothing);
      expect(find.text('Disable cleanup'), findsNothing);
      expect(find.textContaining('known activation status'), findsOneWidget);
      expect(repository.writes, isEmpty);
    });
  }
  testWidgets('stale criteria require reload and a new explicit confirmation', (
    tester,
  ) async {
    final repository = ActivationRepository();
    await _pump(tester, repository);
    repository.policy = reviewedPolicy.copyWith(keepN: 25);
    await tester.tap(find.text('Disable cleanup'));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(find.textContaining('policy changed'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Disable cleanup'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Reload policy'));
    await tester.pumpAndSettle();
    expect(find.text('25'), findsOneWidget);
    await tester.tap(find.text('Disable cleanup'));
    await tester.pumpAndSettle();
    expect(repository.writes, [false]);
  });
  testWidgets(
    'forbidden write preserves intent for retry without private text',
    (tester) async {
      final repository = ActivationRepository()
        ..failure = const GitLabForbiddenException(
          'private server text',
          statusCode: 403,
        );
      await _pump(tester, repository);
      await tester.tap(find.text('Disable cleanup'));
      await tester.pumpAndSettle();
      expect(find.textContaining('permission to change'), findsOneWidget);
      expect(find.textContaining('private server'), findsNothing);
      expect(find.text('10'), findsOneWidget);
      repository.failure = null;
      await tester.tap(find.text('Disable cleanup'));
      await tester.pumpAndSettle();
      expect(repository.writes, [false, false]);
    },
  );
  testWidgets('pending write blocks cancel, back and duplicate action', (
    tester,
  ) async {
    final repository = ActivationRepository()..pending = Completer<void>();
    await _pump(tester, repository);
    await tester.tap(find.text('Disable cleanup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(repository.writes, [false]);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
