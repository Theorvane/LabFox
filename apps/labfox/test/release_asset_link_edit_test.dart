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
    assets: ReleaseAssets(
      links: [
        ReleaseAssetLink(
          id: 12,
          name: 'Desktop package',
          url: 'https://example.com/app.zip',
          directAssetUrl: 'https://example.com/download',
          linkType: 'package',
        ),
      ],
    ),
  );
  final edits = <({int linkId, String name, String url})>[];
  bool reject = false;
  @override
  Future<GitLabRelease> get(int projectId, String tagName) async => current;
  @override
  Future<ReleaseAssetLink> updateAssetLink(
    int projectId,
    String tagName,
    int linkId, {
    required String name,
    required String url,
  }) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    edits.add((linkId: linkId, name: name, url: url));
    if (reject) throw const GitLabForbiddenException('Forbidden');
    final link = current.assets!.links.single.copyWith(name: name, url: url);
    current = current.copyWith(assets: current.assets!.copyWith(links: [link]));
    return link;
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
  testWidgets('rejects the name of another asset link', (tester) async {
    final repository = _Repository();
    repository.current = repository.current.copyWith(
      assets: ReleaseAssets(
        links: [
          repository.current.assets!.links.single,
          const ReleaseAssetLink(
            id: 13,
            name: 'Other package',
            url: 'https://example.com/other.zip',
          ),
        ],
      ),
    );
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit asset link').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Other package');
    await tester.tap(find.text('Save link'));
    await tester.pumpAndSettle();
    expect(find.text('A link with this name already exists.'), findsOneWidget);
    expect(repository.edits, isEmpty);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('edits an asset link at width $width', (tester) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.byTooltip('Edit asset link'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        'Desktop package',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        'https://example.com/app.zip',
      );
      await tester.enterText(find.byType(TextField).at(0), ' New package ');
      await tester.enterText(
        find.byType(TextField).at(1),
        ' https://example.com/new.zip ',
      );
      await tester.tap(find.text('Save link'));
      await tester.pumpAndSettle();
      expect(repository.edits.single, (
        linkId: 12,
        name: 'New package',
        url: 'https://example.com/new.zip',
      ));
      expect(find.text('New package'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(repository.current.assets!.links.single.linkType, 'package');
    });
  }
  testWidgets('validates fields and preserves a rejected edit draft', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit asset link'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), ' ');
    await tester.tap(find.text('Save link'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a link name.'), findsOneWidget);
    expect(repository.edits, isEmpty);
    await tester.enterText(find.byType(TextField).at(0), 'Draft package');
    await tester.enterText(find.byType(TextField).at(1), 'not-a-url');
    await tester.tap(find.text('Save link'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an HTTP or HTTPS URL.'), findsOneWidget);
    expect(repository.edits, isEmpty);
    await tester.enterText(
      find.byType(TextField).at(1),
      'https://example.com/new.zip',
    );
    await tester.tap(find.text('Save link'));
    await tester.pumpAndSettle();
    expect(find.text('Could not update the asset link.'), findsOneWidget);
    expect(find.text('Draft package'), findsOneWidget);
    expect(find.text('https://example.com/new.zip'), findsOneWidget);
    expect(find.text('Desktop package'), findsOneWidget);
  });
}
