import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_tag_protection_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/widgets/container_tag_protection_pattern_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'container_tag_protection_pattern_controller_test.dart'
    show ProtectionPatternRepository, reviewedRule;

Future<void> open(
  WidgetTester tester,
  ProtectionPatternRepository repository, {
  double width = 390,
  bool dark = false,
  ContainerTagProtectionRule rule = reviewedRule,
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
                builder: (_) => ContainerTagProtectionPatternDialog(
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
  await tester.enterText(find.byType(TextField), 'v*-stable');
  await tester.pumpAndSettle();
}

Future<void> acknowledge(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'draft edits reset acknowledgement and unchanged or blank drafts stay disabled',
    (tester) async {
      final repository = ProtectionPatternRepository();
      await open(tester, repository);
      await acknowledge(tester);
      await tester.enterText(find.byType(TextField), 'team/other-*');
      await tester.pumpAndSettle();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      for (final text in ['   ', reviewedRule.tagNamePattern]) {
        await tester.enterText(find.byType(TextField), text);
        await acknowledge(tester);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
      }
      expect(repository.writes, isEmpty);
    },
  );
  testWidgets(
    'server pattern validation retains editable draft without requiring reload',
    (tester) async {
      final repository = ProtectionPatternRepository()
        ..failure = const GitLabConflictException('private', statusCode: 422);
      await open(tester, repository);
      await acknowledge(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('private'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'v*-stable',
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      repository.failure = null;
      await tester.enterText(find.byType(TextField), 'team/valid-*');
      await acknowledge(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(repository.writes, [(7, 2, 'v*-stable'), (7, 2, 'team/valid-*')]);
    },
  );
  testWidgets(
    'reload failure stays blocked without private text and recovers',
    (tester) async {
      final repository = ProtectionPatternRepository()
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
      expect(repository.writes, [(7, 2, 'v*-stable')]);
    },
  );
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('exact-rule pattern editing fits $width dark=$dark', (
        tester,
      ) async {
        final repository = ProtectionPatternRepository();
        await open(tester, repository, width: width, dark: dark);
        expect(find.text('Project 7 — rule 2'), findsOneWidget);
        expect(find.text('v*-release'), findsOneWidget);
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
        expect(repository.writes, [(7, 2, 'v*-stable')]);
        expect(find.byType(ContainerTagProtectionPatternDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('cancel never updates a rule', (tester) async {
    final repository = ProtectionPatternRepository();
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
    final repository = ProtectionPatternRepository()..rules = [rule];
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
    final repository = ProtectionPatternRepository();
    await open(tester, repository);
    await acknowledge(tester);
    repository.rules = [reviewedRule.copyWith(tagNamePattern: 'changed-*')];
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Reload rule'));
    await tester.pumpAndSettle();
    expect(find.text('changed-*'), findsOneWidget);
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
    expect(repository.writes, [(7, 2, 'v*-stable')]);
  });
  testWidgets('missing rule after reload cannot be updated', (tester) async {
    final repository = ProtectionPatternRepository();
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
  testWidgets('forbidden update retains confirmation for a real retry', (
    tester,
  ) async {
    final repository = ProtectionPatternRepository()
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
    expect(repository.writes, [(7, 2, 'v*-stable'), (7, 2, 'v*-stable')]);
  });
  testWidgets('pending update blocks cancel back and duplicates', (
    tester,
  ) async {
    final repository = ProtectionPatternRepository()
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
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(ContainerTagProtectionPatternDialog), findsOneWidget);
    expect(repository.writes, hasLength(1));
    repository.pending!.complete();
    await tester.pumpAndSettle();
  });
  testWidgets('protection list opens confirmation without writing', (
    tester,
  ) async {
    final repository = ProtectionPatternRepository();
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
          home: ContainerTagProtectionScreen(projectId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit tag protection pattern'));
    await tester.pumpAndSettle();
    expect(find.byType(ContainerTagProtectionPatternDialog), findsOneWidget);
    expect(repository.writes, isEmpty);
  });
}
