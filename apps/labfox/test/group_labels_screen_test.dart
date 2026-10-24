import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/project_labels/presentation/controllers/group_labels_controller.dart';
import 'package:labfox/features/project_labels/presentation/project_labels_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Labels extends GroupLabelsController {
  @override
  Future<List<ProjectLabel>> build(int groupId) async => const [
    ProjectLabel(id: 7, name: 'bug', color: '#D9534F'),
  ];

  @override
  Future<void> create({
    required String name,
    required String color,
    String? description,
  }) async {
    state = AsyncData([
      ...state.requireValue,
      ProjectLabel(id: 8, name: name, color: color, description: description),
    ]);
  }
}

Future<void> _pump(WidgetTester tester, Widget home, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupLabelsControllerProvider.overrideWith(_Labels.new),
        groupLabelProvider.overrideWith(
          (ref, key) async => const ProjectLabel(
            id: 7,
            name: 'bug',
            color: '#D9534F',
            openIssuesCount: 3,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists and creates group labels on mobile', (tester) async {
    await _pump(
      tester,
      const GroupLabelsScreen(groupId: 42),
      const Size(390, 844),
    );
    expect(find.text('Group labels'), findsOneWidget);
    expect(find.text('bug'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'feature',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Color (#RRGGBB)'),
      '#5843AD',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create label'));
    await tester.pumpAndSettle();
    expect(find.text('feature'), findsOneWidget);
  });

  testWidgets('shows group label detail on wide screen', (tester) async {
    await _pump(
      tester,
      const GroupLabelDetailScreen(groupId: 42, labelId: 7),
      const Size(1200, 800),
    );
    expect(find.text('bug'), findsWidgets);
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
