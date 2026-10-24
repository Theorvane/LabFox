import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/releases/data/releases_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';
import 'package:labfox/features/releases/presentation/release_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

GitLabRelease _release(List<String> titles) => GitLabRelease.fromJson({
  'name': 'Version 1',
  'tag_name': 'release/1',
  'description': 'Original notes',
  'milestones': [
    for (final title in titles)
      {'id': 51, 'iid': 1, 'title': title, 'state': 'active', 'project_id': 7},
  ],
});

class _Repository extends ReleasesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  GitLabRelease current = _release(['Existing target']);
  final edits = <List<String>>[];
  bool reject = false;
  @override
  Future<GitLabRelease> get(int projectId, String tagName) async => current;
  @override
  Future<GitLabRelease> updateMilestones(
    int projectId,
    String tagName,
    List<String> titles,
  ) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    edits.add(List.of(titles));
    if (reject) throw const GitLabForbiddenException('Forbidden');
    return current = _release(titles);
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/releases/release%2F1',
    routes: [
      GoRoute(
        path: '/projects/:id/releases/:tagName',
        builder: (_, _) =>
            const ReleaseDetailScreen(projectId: 7, tagName: 'release/1'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Edit release milestones'));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('adds and removes associations at $width in $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        await _pump(tester, repository, width: width, brightness: brightness);
        expect(
          find.widgetWithText(InputChip, 'Existing target'),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextField), ' Release, candidate ');
        await tester.tap(find.text('Add milestone'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Remove Existing target'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save milestones'));
        await tester.pumpAndSettle();
        expect(repository.edits, [
          ['Release, candidate'],
        ]);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Release, candidate'), findsOneWidget);
        expect(repository.current.description, 'Original notes');
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('explicitly clears all associations', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Remove Existing target'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save milestones'));
    await tester.pumpAndSettle();
    expect(repository.edits, [<String>[]]);
    expect(find.text('Existing target'), findsNothing);
  });
  testWidgets('validates titles and retains rejected draft', (tester) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.text('Add milestone'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a milestone title.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Existing target');
    await tester.tap(find.text('Add milestone'));
    await tester.pumpAndSettle();
    expect(find.text('This milestone is already selected.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'New target');
    await tester.tap(find.text('Save milestones'));
    await tester.pumpAndSettle();
    expect(repository.edits, [
      ['Existing target', 'New target'],
    ]);
    expect(find.text('Could not update release milestones.'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'New target'), findsOneWidget);
  });
  testWidgets('cancel does not submit changed associations', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextField), 'New target');
    await tester.tap(find.text('Add milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.edits, isEmpty);
  });
}
