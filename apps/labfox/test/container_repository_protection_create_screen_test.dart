import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/container_registry/presentation/container_repository_protection_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/widgets/container_repository_protection_create_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'container_repository_protection_create_controller_test.dart'
    show ProtectionCreateRepository;

Future<void> open(
  WidgetTester tester,
  ProtectionCreateRepository repo, {
  double width = 390,
  bool dark = false,
  bool screen = false,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith((ref) async => repo),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen
            ? const ContainerRepositoryProtectionScreen(projectId: 7)
            : Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const ContainerRepositoryProtectionCreateDialog(
                            projectId: 7,
                          ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (!screen) {
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }
}

Finder field(String key) => find.byKey(ValueKey(key));
Future<void> select(WidgetTester tester, String key, String role) async {
  await tester.ensureVisible(field(key));
  await tester.tap(field(key));
  await tester.pumpAndSettle();
  await tester.tap(find.text(role).last);
  await tester.pumpAndSettle();
}

Future<void> acknowledge(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

FilledButton save(WidgetTester tester) =>
    tester.widget<FilledButton>(field('protectionCreateSave'));
Future<void> ready(WidgetTester tester) async {
  await tester.enterText(field('protectionCreatePattern'), 'team/app-*');
  await select(tester, 'protectionCreatePush', 'Maintainer');
  await acknowledge(tester);
}

void main() {
  testWidgets('delete-only rule preserves exact pattern and refreshes screen', (
    tester,
  ) async {
    final repo = ProtectionCreateRepository();
    await open(tester, repo, screen: true);
    await tester.tap(find.byTooltip('Create repository protection rule'));
    await tester.pumpAndSettle();
    await tester.enterText(field('protectionCreatePattern'), ' team/app-* ');
    await select(tester, 'protectionCreateDelete', 'Administrator');
    await acknowledge(tester);
    await tester.ensureVisible(field('protectionCreateSave'));
    await tester.tap(field('protectionCreateSave'));
    await tester.pumpAndSettle();
    expect(repo.writes, [(7, ' team/app-* ', null, 'admin')]);
    expect(find.text(' team/app-* '), findsOneWidget);
    expect(find.text('The rule was created.'), findsOneWidget);
  });
  testWidgets('unselected roles display their lack of restriction', (
    tester,
  ) async {
    final repo = ProtectionCreateRepository();
    await open(tester, repo);
    expect(find.text('No restriction from this rule'), findsNWidgets(2));
    await ready(tester);
    await select(
      tester,
      'protectionCreatePush',
      'No restriction from this rule',
    );
    expect(save(tester).onPressed, isNull);
    await acknowledge(tester);
    expect(save(tester).onPressed, isNull);
    expect(repo.writes, isEmpty);
  });
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('explicit criteria and acknowledgement $width dark=$dark', (
        tester,
      ) async {
        final repo = ProtectionCreateRepository();
        await open(tester, repo, width: width, dark: dark);
        expect(save(tester).onPressed, isNull);
        expect(find.text('Project 7'), findsOneWidget);
        await ready(tester);
        expect(save(tester).onPressed, isNotNull);
        await tester.ensureVisible(field('protectionCreateSave'));
        await tester.tap(field('protectionCreateSave'));
        await tester.pumpAndSettle();
        expect(repo.writes, [(7, 'team/app-*', 'maintainer', null)]);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('editing pattern or roles clears acknowledgement', (
    tester,
  ) async {
    final repo = ProtectionCreateRepository();
    await open(tester, repo);
    await ready(tester);
    await tester.enterText(field('protectionCreatePattern'), 'team/changed-*');
    await tester.pumpAndSettle();
    expect(save(tester).onPressed, isNull);
    await acknowledge(tester);
    await select(tester, 'protectionCreateDelete', 'Owner');
    expect(save(tester).onPressed, isNull);
    await acknowledge(tester);
    await tester.ensureVisible(field('protectionCreateSave'));
    await tester.tap(field('protectionCreateSave'));
    await tester.pumpAndSettle();
    expect(repo.writes, [(7, 'team/changed-*', 'maintainer', 'owner')]);
  });
  testWidgets('blank pattern and no roles cannot submit', (tester) async {
    final repo = ProtectionCreateRepository();
    await open(tester, repo);
    await tester.enterText(field('protectionCreatePattern'), 'team/app-*');
    await acknowledge(tester);
    expect(save(tester).onPressed, isNull);
    await select(tester, 'protectionCreateDelete', 'Administrator');
    await acknowledge(tester);
    await tester.enterText(field('protectionCreatePattern'), '   ');
    await acknowledge(tester);
    expect(save(tester).onPressed, isNull);
    expect(repo.writes, isEmpty);
  });
  testWidgets('cancel does not write', (tester) async {
    final repo = ProtectionCreateRepository();
    await open(tester, repo);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.writes, isEmpty);
  });
  for (final error in [
    const GitLabForbiddenException('private token'),
    const GitLabConflictException('private pattern', statusCode: 422),
  ]) {
    testWidgets('rejection retains editable draft for retry $error', (
      tester,
    ) async {
      final repo = ProtectionCreateRepository()..failure = error;
      await open(tester, repo);
      await ready(tester);
      await tester.ensureVisible(field('protectionCreateSave'));
      await tester.tap(field('protectionCreateSave'));
      await tester.pumpAndSettle();
      expect(find.textContaining('private'), findsNothing);
      expect(
        tester
            .widget<TextField>(field('protectionCreatePattern'))
            .controller!
            .text,
        'team/app-*',
      );
      expect(save(tester).onPressed, isNotNull);
      repo.failure = null;
      await tester.tap(field('protectionCreateSave'));
      await tester.pumpAndSettle();
      expect(repo.writes.length, 2);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
  testWidgets('pending creation blocks dismissal edits and duplicates', (
    tester,
  ) async {
    final repo = ProtectionCreateRepository()..pending = Completer<void>();
    await open(tester, repo);
    await ready(tester);
    await tester.ensureVisible(field('protectionCreateSave'));
    await tester.tap(field('protectionCreateSave'));
    await tester.pump();
    expect(save(tester).onPressed, isNull);
    expect(
      tester.widget<TextField>(field('protectionCreatePattern')).enabled,
      isFalse,
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
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
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(repo.writes.length, 1);
    repo.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
  testWidgets('empty rule list exposes creation entry', (tester) async {
    final repo = ProtectionCreateRepository();
    await open(tester, repo, screen: true);
    await tester.tap(find.byTooltip('Create repository protection rule'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(repo.writes, isEmpty);
  });
}
