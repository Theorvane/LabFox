import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/presentation/container_immutability_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_immutability_delete_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'container_immutability_test.dart' as fixture;

class DeletingRepository extends fixture.FakeRepository {
  int writes = 0;
  Object? deleteError;
  Completer<void>? deletion;
  @override
  Future<void> deleteImmutableTagRule(
    int projectId,
    ContainerTagImmutabilityRule expected, {
    bool Function()? isCurrent,
  }) async {
    expect(projectId, 7);
    expect(expected, fixture.rule);
    writes++;
    if (deletion != null) await deletion!.future;
    if (deleteError != null) throw deleteError!;
    rules = [];
  }
}

ProviderContainer container(DeletingRepository r) => ProviderContainer(
  overrides: [
    containerRegistryRepositoryProvider.overrideWith((ref) async => r),
  ],
);
void main() {
  testWidgets('cancel does not delete or reload', (tester) async {
    final r = DeletingRepository();
    await fixture.open(tester, r, width: 800);
    await tester.tap(find.byTooltip('Delete immutable rule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(r.writes, 0);
    expect(r.reads, [7]);
  });
  testWidgets(
    'pending deletion blocks input, cancel, back and duplicate submit',
    (tester) async {
      final r = DeletingRepository()..deletion = Completer();
      await fixture.open(tester, r, width: 800);
      await tester.tap(find.byTooltip('Delete immutable rule'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        fixture.rule.tagNamePattern,
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete rule'));
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
              find.widgetWithText(FilledButton, 'Delete rule'),
            )
            .onPressed,
        isNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(r.writes, 1);
      r.deletion!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('No immutable tag rules.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'account change locks the open dialog and cannot show old success',
    (tester) async {
      final old = DeletingRepository()..deletion = Completer();
      final fresh = DeletingRepository();
      final account = StateProvider<DeletingRepository>((ref) => old);
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
      await tester.tap(find.byTooltip('Delete immutable rule'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        fixture.rule.tagNamePattern,
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete rule'));
      await tester.pump();
      c.read(account.notifier).state = fresh;
      await tester.pump();
      old.deletion!.complete();
      await tester.pumpAndSettle();
      expect(
        find.text(
          'The account changed. Close this dialog and reopen it for the selected account.',
        ),
        findsOneWidget,
      );
      expect(find.text('Immutable rule deleted.'), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(fresh.writes, 0);
      expect(tester.takeException(), isNull);
    },
  );
  test('disposing a scope discards pending deletion', () async {
    final r = DeletingRepository()..deletion = Completer();
    final c = container(r);
    final controller = c.read(
      containerImmutabilityDeleteControllerProvider(7).notifier,
    );
    final pending = controller.delete(fixture.rule);
    final check = expectLater(pending, throwsStateError);
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    r.deletion!.complete();
    await check;
  });
  for (final expected in [
    fixture.rule.copyWith(id: ''),
    fixture.rule.copyWith(tagNamePattern: ' '),
    fixture.rule.copyWith(immutable: false),
  ]) {
    test('invalid target never reaches the repository $expected', () async {
      final r = DeletingRepository();
      final c = container(r);
      addTearDown(c.dispose);
      await expectLater(
        c
            .read(containerImmutabilityDeleteControllerProvider(7).notifier)
            .delete(expected),
        throwsArgumentError,
      );
      expect(r.writes, 0);
    });
  }
  test('pending deletion blocks duplicate controller requests', () async {
    final r = DeletingRepository()..deletion = Completer();
    final c = container(r);
    addTearDown(c.dispose);
    final controller = c.read(
      containerImmutabilityDeleteControllerProvider(7).notifier,
    );
    final first = controller.delete(fixture.rule);
    await expectLater(controller.delete(fixture.rule), throwsStateError);
    await Future<void>.delayed(Duration.zero);
    expect(r.writes, 1);
    r.deletion!.complete();
    await first;
  });
  test(
    'uncertain deletion requires reload and cannot retry a missing target',
    () async {
      final r = DeletingRepository()
        ..deleteError = const GitLabConnectionException('private failure');
      final c = container(r);
      addTearDown(c.dispose);
      final controller = c.read(
        containerImmutabilityDeleteControllerProvider(7).notifier,
      );
      await expectLater(
        controller.delete(fixture.rule),
        throwsA(isA<GitLabConnectionException>()),
      );
      await expectLater(controller.delete(fixture.rule), throwsStateError);
      r.rules = [];
      await expectLater(
        controller.reload(fixture.rule.id),
        throwsA(isA<GitLabNotFoundException>()),
      );
      expect(controller.needsReload, isTrue);
      expect(r.writes, 1);
      r.rules = [fixture.rule];
      expect(await controller.reload(fixture.rule.id), fixture.rule);
      expect(controller.needsReload, isFalse);
      r.deleteError = null;
      await controller.delete(fixture.rule);
      expect(r.writes, 2);
    },
  );
  test('account switch discards old deletion completion', () async {
    final old = DeletingRepository()..deletion = Completer();
    final fresh = DeletingRepository();
    final account = StateProvider<DeletingRepository>((ref) => old);
    final c = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => ref.watch(account),
        ),
      ],
    );
    addTearDown(c.dispose);
    final p = containerImmutabilityDeleteControllerProvider(7);
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    final controller = c.read(p.notifier);
    final pending = controller.delete(fixture.rule);
    final check = expectLater(pending, throwsStateError);
    await Future<void>.delayed(Duration.zero);
    c.read(account.notifier).state = fresh;
    await Future<void>.delayed(Duration.zero);
    old.deletion!.complete();
    await check;
    expect(fresh.writes, 0);
    expect(controller.needsReload, isTrue);
  });
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'requires exact confirmation and acknowledgement $width/$dark',
        (tester) async {
          final r = DeletingRepository();
          await fixture.open(tester, r, width: width, dark: dark);
          await tester.tap(find.byTooltip('Delete immutable rule'));
          await tester.pumpAndSettle();
          expect(find.text(fixture.rule.id), findsOneWidget);
          expect(find.textContaining('Project 7'), findsOneWidget);
          await tester.enterText(find.byType(TextField), 'wrong');
          await tester.ensureVisible(find.byType(Checkbox));
          await tester.tap(find.byType(Checkbox));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilledButton>(
                  find.widgetWithText(FilledButton, 'Delete rule'),
                )
                .onPressed,
            isNull,
          );
          await tester.ensureVisible(find.byType(TextField));
          await tester.enterText(
            find.byType(TextField),
            fixture.rule.tagNamePattern,
          );
          await tester.pumpAndSettle();
          expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
          await tester.ensureVisible(find.byType(Checkbox));
          await tester.tap(find.byType(Checkbox));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Delete rule'));
          await tester.pumpAndSettle();
          expect(r.writes, 1);
          expect(find.byType(AlertDialog), findsNothing);
          expect(find.text('Immutable rule deleted.'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'failure retains exact draft but requires reload and renewed confirmation',
    (tester) async {
      final r = DeletingRepository()
        ..deleteError = const GitLabServerException('private response');
      await fixture.open(tester, r, width: 800);
      await tester.tap(find.byTooltip('Delete immutable rule'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        fixture.rule.tagNamePattern,
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete rule'));
      await tester.pumpAndSettle();
      expect(find.textContaining('private'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        fixture.rule.tagNamePattern,
      );
      await tester.ensureVisible(find.text('Reload rule'));
      await tester.tap(find.text('Reload rule'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(r.writes, 1);
    },
  );
}
