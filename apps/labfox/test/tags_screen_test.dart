import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/tags/presentation/controllers/tags_controller.dart';
import 'package:labfox/features/tags/presentation/tags_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubTags extends TagsController {
  _StubTags(this.items);
  final List<RepositoryTag> items;

  @override
  Future<List<RepositoryTag>> build(int projectId) async => items;
}

Future<void> _pump(WidgetTester tester, List<RepositoryTag> items) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tagsControllerProvider.overrideWith(() => _StubTags(items))],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TagsScreen(projectId: 42),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows tag name, protected state, and commit title', (
    tester,
  ) async {
    await _pump(tester, const [
      RepositoryTag(
        name: 'v1.0.0',
        isProtected: true,
        commit: Commit(id: 'abc', title: 'Ship'),
      ),
    ]);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('Ship'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'v1.0.0'),
        matching: find.byIcon(Icons.lock_outline),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an empty state without tags', (tester) async {
    await _pump(tester, const []);
    expect(find.text('No tags yet'), findsOneWidget);
  });

  testWidgets('filters tags by name without losing the loaded list', (
    tester,
  ) async {
    await _pump(tester, const [
      RepositoryTag(name: 'v1.0.0'),
      RepositoryTag(name: 'hotfix'),
    ]);

    await tester.enterText(find.byType(TextField), 'hot');
    await tester.pumpAndSettle();
    expect(find.text('hotfix'), findsOneWidget);
    expect(find.text('v1.0.0'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('v1.0.0'), findsOneWidget);
  });

  testWidgets('requires a name and source ref before creating a tag', (
    tester,
  ) async {
    await _pump(tester, const []);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create tag'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(2));
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('tag list fits a ${width.toInt()} px viewport', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await _pump(tester, const [
        RepositoryTag(
          name: 'release/2026.09',
          commit: Commit(id: 'abc', title: 'Release commit'),
        ),
      ]);
      expect(find.text('release/2026.09'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
