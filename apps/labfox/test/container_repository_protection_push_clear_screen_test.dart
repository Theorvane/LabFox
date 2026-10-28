import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_repository_protection_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/widgets/container_repository_protection_push_clear_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'container_repository_protection_push_clear_controller_test.dart'
    show ProtectionPushClearRepository, reviewedRule;

Future<void> open(
  WidgetTester tester,
  ProtectionPushClearRepository repository, {
  double width = 390,
  bool dark = false,
  ContainerRepositoryProtectionRule rule = reviewedRule,
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
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ContainerRepositoryProtectionPushClearDialog(
                  projectId: 7,
                  rule: rule,
                ),
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
  for (final rule in [
    reviewedRule.copyWith(minimumAccessLevelForPush: null),
    reviewedRule.copyWith(minimumAccessLevelForPush: ''),
    reviewedRule.copyWith(minimumAccessLevelForPush: 'future_role'),
    reviewedRule.copyWith(minimumAccessLevelForDelete: null),
    reviewedRule.copyWith(minimumAccessLevelForDelete: ''),
    reviewedRule.copyWith(minimumAccessLevelForDelete: 'future_role'),
  ]) {
    testWidgets('unsafe restriction clearing stays blocked $rule', (
      tester,
    ) async {
      final repository = ProtectionPushClearRepository()..rules = [rule];
      await open(tester, repository, rule: rule);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<CheckboxListTile>(find.byType(CheckboxListTile))
            .onChanged,
        isNull,
      );
      expect(repository.writes, isEmpty);
    });
  }
  testWidgets('reload cannot remove the final remaining restriction', (
    tester,
  ) async {
    final repository = ProtectionPushClearRepository();
    await open(tester, repository);
    await acknowledge(tester);
    repository.rules = [
      reviewedRule.copyWith(minimumAccessLevelForDelete: null),
    ];
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reload rule'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(repository.writes, isEmpty);
  });
  testWidgets('validation rejection retains reviewed criteria for retry', (
    tester,
  ) async {
    final repository = ProtectionPushClearRepository()
      ..failure = const GitLabConflictException(
        'private validation',
        statusCode: 422,
      );
    await open(tester, repository);
    await acknowledge(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('private validation'), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    repository.failure = null;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, [(7, 2), (7, 2)]);
    expect(
      repository.rules.single,
      reviewedRule.copyWith(minimumAccessLevelForPush: null),
    );
  });
  testWidgets(
    'reload failure stays blocked without private text and recovers',
    (tester) async {
      final repository = ProtectionPushClearRepository()
        ..readFailure = const GitLabForbiddenException(
          'private reload details',
        );
      await open(tester, repository);
      await acknowledge(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reload rule'));
      await tester.pumpAndSettle();
      expect(find.textContaining('private reload'), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(repository.writes, isEmpty);
      expect(tester.takeException(), isNull);
      repository.readFailure = null;
      await tester.tap(find.text('Reload rule'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      await acknowledge(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(repository.writes, [(7, 2)]);
    },
  );
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('exact-rule push clearing fits $width dark=$dark', (
        tester,
      ) async {
        final repository = ProtectionPushClearRepository();
        await open(tester, repository, width: width, dark: dark);
        expect(find.text('Project 7 — rule 2'), findsOneWidget);
        expect(find.text('team/app/*'), findsOneWidget);
        expect(find.text('Minimum push role: Maintainer'), findsOneWidget);
        expect(find.text('Minimum delete role: Owner'), findsOneWidget);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        await acknowledge(tester);
        expect(repository.writes, isEmpty);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(repository.writes, [(7, 2)]);
        expect(
          find.byType(ContainerRepositoryProtectionPushClearDialog),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('cancel never clears a push role', (tester) async {
    final repository = ProtectionPushClearRepository();
    await open(tester, repository);
    await acknowledge(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
  });
  testWidgets('nullable and unknown roles do not claim user permission', (
    tester,
  ) async {
    final rule = reviewedRule.copyWith(
      minimumAccessLevelForPush: 'future_role',
      minimumAccessLevelForDelete: null,
    );
    final repository = ProtectionPushClearRepository()..rules = [rule];
    await open(tester, repository, rule: rule);
    expect(find.text('Minimum push role: Unknown role'), findsOneWidget);
    expect(
      find.text('Minimum delete role: Not specified by rule'),
      findsOneWidget,
    );
    expect(find.text('future_role'), findsNothing);
    expect(repository.writes, isEmpty);
  });
  testWidgets('changed rule requires reload and renewed acknowledgement', (
    tester,
  ) async {
    final repository = ProtectionPushClearRepository();
    await open(tester, repository);
    await acknowledge(tester);
    repository.rules = [
      reviewedRule.copyWith(repositoryPathPattern: 'team/changed/*'),
    ];
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Reload rule'));
    await tester.pumpAndSettle();
    expect(find.text('team/changed/*'), findsOneWidget);
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
    expect(repository.writes, [(7, 2)]);
  });
  testWidgets('missing rule after reload cannot be cleared', (tester) async {
    final repository = ProtectionPushClearRepository();
    await open(tester, repository);
    await acknowledge(tester);
    repository.rules = [];
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reload rule'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(repository.writes, isEmpty);
  });
  testWidgets('forbidden push clearing retains confirmation for a real retry', (
    tester,
  ) async {
    final repository = ProtectionPushClearRepository()
      ..failure = const GitLabForbiddenException('private server details');
    await open(tester, repository);
    await acknowledge(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('private server'), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    repository.failure = null;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, [(7, 2), (7, 2)]);
  });
  testWidgets('pending push clearing blocks cancel back and duplicates', (
    tester,
  ) async {
    final repository = ProtectionPushClearRepository()
      ..pending = Completer<void>();
    await open(tester, repository);
    await acknowledge(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
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
    expect(
      find.byType(ContainerRepositoryProtectionPushClearDialog),
      findsOneWidget,
    );
    expect(repository.writes, hasLength(1));
    repository.pending!.complete();
    await tester.pumpAndSettle();
  });
  testWidgets('protection list opens confirmation without clearing', (
    tester,
  ) async {
    final repository = ProtectionPushClearRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ContainerRepositoryProtectionScreen(projectId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear minimum push role'));
    await tester.pumpAndSettle();
    expect(
      find.byType(ContainerRepositoryProtectionPushClearDialog),
      findsOneWidget,
    );
    expect(repository.writes, isEmpty);
  });
}
