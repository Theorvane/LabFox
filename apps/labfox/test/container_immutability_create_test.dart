import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_immutability_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_immutability_create_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'container_immutability_test.dart' as fixture;

class CreatingRepository extends fixture.FakeRepository {
  CreatingRepository() {
    rules = [];
  }
  int writes = 0;
  String? pattern;
  Object? createError;
  Completer<ContainerTagImmutabilityRule>? creation;
  @override
  Future<ContainerTagImmutabilityRule> createImmutableTagRule(
    int projectId,
    String pattern, {
    bool Function()? isCurrent,
  }) async {
    expect(projectId, 7);
    writes++;
    this.pattern = pattern;
    if (creation != null) return creation!.future;
    if (createError != null) throw createError!;
    return fixture.rule.copyWith(tagNamePattern: pattern);
  }
}

void main() {
  testWidgets('account changes lock the open dialog without success messaging', (
    tester,
  ) async {
    final old = CreatingRepository()..creation = Completer();
    final fresh = CreatingRepository();
    final account = StateProvider<CreatingRepository>((ref) => old);
    final c = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => ref.watch(account),
        ),
      ],
    );
    addTearDown(c.dispose);
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ContainerImmutabilityScreen(projectId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create immutable rule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), fixture.rule.tagNamePattern);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create rule'));
    await tester.pump();
    c.read(account.notifier).state = fresh;
    await tester.pump();
    old.creation!.complete(fixture.rule);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The account changed. Close this dialog and reopen it for the selected account.',
      ),
      findsOneWidget,
    );
    expect(find.text('Immutable rule created.'), findsNothing);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(fresh.writes, 0);
    expect(tester.takeException(), isNull);
  });
  test(
    'account switch during creation cannot confirm into the new session',
    () async {
      final old = CreatingRepository()..creation = Completer();
      final fresh = CreatingRepository();
      final account = StateProvider<CreatingRepository>((ref) => old);
      final c = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
            (ref) async => ref.watch(account),
          ),
        ],
      );
      addTearDown(c.dispose);
      final p = containerImmutabilityCreateControllerProvider(7);
      final sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      final controller = c.read(p.notifier);
      final pending = controller.create(fixture.rule.tagNamePattern);
      final check = expectLater(pending, throwsStateError);
      await Future<void>.delayed(Duration.zero);
      c.read(account.notifier).state = fresh;
      await Future<void>.delayed(Duration.zero);
      old.creation!.complete(fixture.rule);
      await check;
      expect(fresh.writes, 0);
      expect(c.read(p).hasError, isFalse);
      expect(controller.needsInspection, isTrue);
    },
  );
  test(
    'scope disposal discards an old pending write without touching disposed providers',
    () async {
      final r = CreatingRepository()..creation = Completer();
      final c = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith((ref) async => r),
        ],
      );
      final controller = c.read(
        containerImmutabilityCreateControllerProvider(7).notifier,
      );
      final pending = controller.create(fixture.rule.tagNamePattern);
      final check = expectLater(pending, throwsStateError);
      await Future<void>.delayed(Duration.zero);
      c.dispose();
      r.creation!.complete(fixture.rule);
      await check;
    },
  );
  for (final pattern in ['', ' ', 'x' * 101]) {
    test('invalid draft never reaches the repository: $pattern', () async {
      final r = CreatingRepository();
      final c = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith((ref) async => r),
        ],
      );
      addTearDown(c.dispose);
      await expectLater(
        c
            .read(containerImmutabilityCreateControllerProvider(7).notifier)
            .create(pattern),
        throwsArgumentError,
      );
      expect(r.writes, 0);
    });
  }
  testWidgets('pending creation blocks edits, dismissal and duplicate submit', (
    tester,
  ) async {
    final r = CreatingRepository()..creation = Completer();
    await fixture.open(tester, r, width: 800);
    await tester.tap(find.byTooltip('Create immutable rule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), fixture.rule.tagNamePattern);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create rule'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Create rule'),
          )
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(r.writes, 1);
    r.creation!.complete(fixture.rule);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'cancel never writes and blank or overlong drafts stay disabled',
    (tester) async {
      final r = CreatingRepository();
      await fixture.open(tester, r, width: 800);
      await tester.tap(find.byTooltip('Create immutable rule'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Create rule'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), 'x' * 101);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Create rule'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(r.writes, 0);
    },
  );
  test(
    'controller blocks duplicate requests and refreshes only confirmed success',
    () async {
      final r = CreatingRepository()..creation = Completer();
      final c = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith((ref) async => r),
        ],
      );
      addTearDown(c.dispose);
      final p = containerImmutabilityCreateControllerProvider(7);
      final controller = c.read(p.notifier);
      final first = controller.create(fixture.rule.tagNamePattern);
      await expectLater(
        controller.create(fixture.rule.tagNamePattern),
        throwsStateError,
      );
      await Future<void>.delayed(Duration.zero);
      expect(r.writes, 1);
      r.creation!.complete(fixture.rule);
      await first;
      expect(c.read(p).hasError, isFalse);
    },
  );
  test(
    'uncertain creation requires successful inspection before manual retry',
    () async {
      final r = CreatingRepository()
        ..createError = const GitLabConnectionException('private failure');
      final c = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith((ref) async => r),
        ],
      );
      addTearDown(c.dispose);
      final controller = c.read(
        containerImmutabilityCreateControllerProvider(7).notifier,
      );
      await expectLater(
        controller.create('^v.*'),
        throwsA(isA<GitLabConnectionException>()),
      );
      await expectLater(controller.create('^v.*'), throwsStateError);
      expect(r.writes, 1);
      r.failure = const GitLabServerException('private read');
      await expectLater(
        controller.inspect('^v.*'),
        throwsA(isA<GitLabServerException>()),
      );
      expect(controller.needsInspection, isTrue);
      r.failure = null;
      await controller.inspect('^v.*');
      expect(controller.needsInspection, isFalse);
      r.createError = null;
      await controller.create('^v.*');
      expect(r.writes, 2);
    },
  );
  test(
    'inspection finds existing pattern and cannot authorize another create',
    () async {
      final r = CreatingRepository()..rules = [fixture.rule];
      final c = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith((ref) async => r),
        ],
      );
      addTearDown(c.dispose);
      final controller = c.read(
        containerImmutabilityCreateControllerProvider(7).notifier,
      );
      await expectLater(
        controller.inspect(fixture.rule.tagNamePattern),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(controller.needsInspection, isTrue);
      expect(r.writes, 0);
    },
  );
  test('wrong returned criteria never confirm creation', () async {
    final r = CreatingRepository()..creation = Completer();
    final c = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith((ref) async => r),
      ],
    );
    addTearDown(c.dispose);
    final controller = c.read(
      containerImmutabilityCreateControllerProvider(7).notifier,
    );
    final pending = controller.create('^v.*');
    final check = expectLater(pending, throwsA(isA<GitLabServerException>()));
    await Future<void>.delayed(Duration.zero);
    r.creation!.complete(fixture.rule.copyWith(immutable: false));
    await check;
    expect(controller.needsInspection, isTrue);
  });
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('confirmed creation and draft acknowledgement $width/$dark', (
        tester,
      ) async {
        final r = CreatingRepository();
        await fixture.open(tester, r, width: width, dark: dark);
        await tester.tap(find.byTooltip('Create immutable rule'));
        await tester.pumpAndSettle();
        expect(find.textContaining('RE2'), findsWidgets);
        await tester.enterText(find.byType(TextField), r'^v\d+.*$');
        await tester.ensureVisible(find.byType(Checkbox));
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), r'^release\d+$');
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
        await tester.ensureVisible(find.byType(Checkbox));
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Create rule'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Create rule'));
        await tester.pumpAndSettle();
        expect(r.writes, 1);
        expect(r.pattern, r'^release\d+$');
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Immutable rule created.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'failure retains draft, hides private errors and requires inspection',
    (tester) async {
      final r = CreatingRepository()
        ..createError = const GitLabServerException('private server response');
      await fixture.open(tester, r);
      await tester.tap(find.byTooltip('Create immutable rule'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '^v.*');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create rule'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create rule'));
      await tester.pumpAndSettle();
      expect(find.textContaining('private'), findsNothing);
      expect(find.text('^v.*'), findsOneWidget);
      expect(find.text('Check current rules'), findsOneWidget);
      await tester.ensureVisible(find.text('Check current rules'));
      await tester.tap(find.text('Check current rules'));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(r.writes, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
