import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/widgets/cleanup_policy_create_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'cleanup_policy_create_controller_test.dart' show PolicyCreateRepository;

class _Repositories extends ContainerRepositoriesController {
  @override
  Future<Paginated<RegistryRepository>> build(int arg) async =>
      const Paginated(items: []);
}

Future<void> open(
  WidgetTester tester,
  PolicyCreateRepository repository, {
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
                builder: (_) => const CleanupPolicyCreateDialog(projectId: 7),
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

Future<void> enterDelete(
  WidgetTester tester, [
  String value = 'release.+',
]) async {
  final field = find.byKey(const ValueKey('cleanup-create-delete'));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> acknowledge(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('documented criteria selections are sent explicitly', (
    tester,
  ) async {
    final repository = PolicyCreateRepository();
    await open(tester, repository, width: 800);
    for (final selection in [
      ('cleanup-create-cadence', 'Every week'),
      ('cleanup-create-count', '5'),
      ('cleanup-create-age', '30 days'),
    ]) {
      final dropdown = find.byKey(ValueKey(selection.$1));
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(selection.$2).last);
      await tester.tap(find.text(selection.$2).last);
      await tester.pumpAndSettle();
    }
    await enterDelete(tester);
    await acknowledge(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(repository.writes.single.cadence, '7d');
    expect(repository.writes.single.keepN, 5);
    expect(repository.writes.single.olderThan, '30d');
    expect(repository.writes.single.enabled, isFalse);
  });
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('disabled creation fits $width dark=$dark', (tester) async {
        final repository = PolicyCreateRepository();
        await open(tester, repository, width: width, dark: dark);
        expect(find.text('Project 7 — all image repositories'), findsOneWidget);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        await enterDelete(tester, r' release\..+ ');
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        await acknowledge(tester);
        expect(repository.writes, isEmpty);
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        final policy = repository.writes.single;
        expect(policy.enabled, isFalse);
        expect(policy.cadence, '1month');
        expect(policy.keepN, 100);
        expect(policy.olderThan, '365d');
        expect(policy.nameRegexDelete, r' release\..+ ');
        expect(policy.nameRegexKeep, '.*');
        expect(find.byType(CleanupPolicyCreateDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final snapshot in [
    const ContainerCleanupPolicySnapshot(reported: false),
    const ContainerCleanupPolicySnapshot(
      reported: true,
      policy: ContainerCleanupPolicy(),
    ),
    const ContainerCleanupPolicySnapshot(
      reported: true,
      policy: ContainerCleanupPolicy(enabled: false),
    ),
  ]) {
    testWidgets(
      'unreported or existing policy cannot be overwritten $snapshot',
      (tester) async {
        final repository = PolicyCreateRepository()..snapshot = snapshot;
        await open(tester, repository);
        expect(find.byType(TextFormField), findsNothing);
        expect(find.byType(FilledButton), findsNothing);
        expect(repository.writes, isEmpty);
      },
    );
  }
  testWidgets('blank delete remains blocked even after acknowledgement', (
    tester,
  ) async {
    final repository = PolicyCreateRepository();
    await open(tester, repository);
    await enterDelete(tester, '  ');
    await acknowledge(tester);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(repository.writes, isEmpty);
  });
  testWidgets(
    'draft changes reset acknowledgement and preserve an explicit empty keep pattern',
    (tester) async {
      final repository = PolicyCreateRepository();
      await open(tester, repository);
      await enterDelete(tester);
      await acknowledge(tester);
      final keep = find.byKey(const ValueKey('cleanup-create-keep'));
      await tester.ensureVisible(keep);
      await tester.enterText(keep, '');
      await tester.pumpAndSettle();
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
      expect(repository.writes.single.nameRegexKeep, '');
    },
  );
  testWidgets(
    'stale absence blocks creation and reload cannot overwrite new policy',
    (tester) async {
      final repository = PolicyCreateRepository();
      await open(tester, repository);
      await enterDelete(tester);
      await acknowledge(tester);
      repository.snapshot = const ContainerCleanupPolicySnapshot(
        reported: true,
        policy: ContainerCleanupPolicy(enabled: false),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(repository.writes, isEmpty);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(find.text('Reload policy'));
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
    },
  );
  for (final error in [
    const GitLabForbiddenException('private server details'),
    const GitLabConflictException('private server details', statusCode: 422),
  ]) {
    testWidgets('rejection retains exact draft and permits retry $error', (
      tester,
    ) async {
      final repository = PolicyCreateRepository()..failure = error;
      await open(tester, repository);
      await enterDelete(tester, r' (?=release).* ');
      await acknowledge(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.textContaining('private server'), findsNothing);
      expect(find.text(r' (?=release).* '), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      repository.failure = null;
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(repository.writes, hasLength(2));
    });
  }
  testWidgets('pending creation blocks cancel, back, editing and duplicates', (
    tester,
  ) async {
    final repository = PolicyCreateRepository()..pending = Completer<void>();
    await open(tester, repository);
    await enterDelete(tester);
    await acknowledge(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(repository.writes, hasLength(1));
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
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const ValueKey('cleanup-create-delete')),
              matching: find.byType(TextField),
            ),
          )
          .readOnly,
      isTrue,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(CleanupPolicyCreateDialog), findsOneWidget);
    repository.pending!.complete();
    await tester.pumpAndSettle();
  });
  testWidgets('registry opens creation without writing', (tester) async {
    final repository = PolicyCreateRepository();
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
    await tester.tap(find.byTooltip('Create disabled cleanup policy'));
    await tester.pumpAndSettle();
    expect(find.byType(CleanupPolicyCreateDialog), findsOneWidget);
    expect(repository.writes, isEmpty);
  });
}
