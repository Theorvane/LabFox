import 'package:design_system/design_system.dart';
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

class _Repository extends ReleasesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  GitLabRelease current = const GitLabRelease(
    name: 'Version 1',
    tagName: 'release/1',
    description: 'Original notes',
  );
  final edits = <({String name, String description})>[];
  bool reject = false;

  @override
  Future<GitLabRelease> get(int projectId, String tagName) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    return current;
  }

  @override
  Future<GitLabRelease> update(
    int projectId,
    String tagName, {
    required String name,
    required String description,
  }) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    edits.add((name: name, description: description));
    if (reject) throw const GitLabForbiddenException('Forbidden');
    current = current.copyWith(name: name, description: description);
    return current;
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 1200.0]) {
    testWidgets('edits release metadata at width $width', (tester) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.byTooltip('Edit release'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), ' Version 2 ');
      await tester.enterText(find.byType(TextField).at(1), 'Updated notes');
      await tester.tap(find.text('Save release'));
      await tester.pumpAndSettle();
      expect(repository.edits.single, (
        name: 'Version 2',
        description: 'Updated notes',
      ));
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Version 2'), findsWidgets);
      expect(
        tester.widget<MarkdownViewer>(find.byType(MarkdownViewer)).data,
        'Updated notes',
      );
    });
  }

  testWidgets('keeps draft on forbidden edit and validates name', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit release'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), ' ');
    await tester.tap(find.text('Save release'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a release name.'), findsOneWidget);
    expect(repository.edits, isEmpty);

    await tester.enterText(find.byType(TextField).at(0), 'Version 3');
    await tester.enterText(find.byType(TextField).at(1), 'Draft notes');
    await tester.tap(find.text('Save release'));
    await tester.pumpAndSettle();
    expect(find.text('Could not update the release.'), findsOneWidget);
    expect(find.text('Version 3'), findsOneWidget);
    expect(find.text('Draft notes'), findsOneWidget);
    repository.reject = false;
    await tester.tap(find.text('Save release'));
    await tester.pumpAndSettle();
    expect(repository.edits.last, (
      name: 'Version 3',
      description: 'Draft notes',
    ));
  });
}
