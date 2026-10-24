import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/project_labels/presentation/controllers/project_labels_controller.dart';
import 'package:labfox/features/project_labels/presentation/project_labels_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubLabels extends ProjectLabelsController {
  _StubLabels(this.items);
  final List<ProjectLabel> items;

  @override
  Future<List<ProjectLabel>> build(int projectId) async => items;
}

Future<void> _pump(
  WidgetTester tester,
  List<ProjectLabel> items, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectLabelsControllerProvider.overrideWith(() => _StubLabels(items)),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProjectLabelsScreen(projectId: 42),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows label names and marks inherited group labels', (
    tester,
  ) async {
    await _pump(tester, const [
      ProjectLabel(
        id: 7,
        name: 'bug',
        color: '#D9534F',
        description: 'A defect',
      ),
      ProjectLabel(
        id: 8,
        name: 'priority',
        color: '#5843AD',
        isProjectLabel: false,
      ),
    ]);
    expect(find.text('bug'), findsOneWidget);
    expect(find.text('priority'), findsOneWidget);
    expect(find.text('Group label'), findsOneWidget);
  });

  testWidgets('shows an empty state when no labels exist', (tester) async {
    await _pump(tester, const []);
    expect(find.text('No labels yet'), findsOneWidget);
  });

  testWidgets('validates a six-digit hex color before creation', (
    tester,
  ) async {
    await _pump(tester, const []);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'feature',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Color (#RRGGBB)'),
      'red',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create label'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a color like #5843AD'), findsOneWidget);
  });

  testWidgets('searches labels by name', (tester) async {
    await _pump(tester, const [
      ProjectLabel(id: 7, name: 'bug', color: '#D9534F'),
      ProjectLabel(id: 8, name: 'feature', color: '#5843AD'),
    ]);
    await tester.enterText(find.byType(TextField), 'fea');
    await tester.pumpAndSettle();
    expect(find.text('feature'), findsOneWidget);
    expect(find.text('bug'), findsNothing);
  });

  for (final width in [390.0, 1200.0]) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets('labels fit ${width.toInt()} px in $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        await _pump(tester, const [
          ProjectLabel(id: 7, name: 'bug', color: '#D9534F'),
        ], brightness: brightness);
        expect(find.text('bug'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
