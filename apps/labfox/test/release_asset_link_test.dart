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
          id: 1,
          name: 'Existing',
          url: 'https://example.com/old',
        ),
      ],
    ),
  );
  final creates = <({String name, String url})>[];
  bool reject = false;

  @override
  Future<GitLabRelease> get(int projectId, String tagName) async => current;

  @override
  Future<ReleaseAssetLink> createAssetLink(
    int projectId,
    String tagName, {
    required String name,
    required String url,
  }) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    creates.add((name: name, url: url));
    if (reject) throw const GitLabForbiddenException('Forbidden');
    final link = ReleaseAssetLink(id: 2, name: name, url: url);
    current = current.copyWith(
      assets: current.assets!.copyWith(links: [...current.assets!.links, link]),
    );
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
  testWidgets('offers asset link creation when a release has no assets', (
    tester,
  ) async {
    final repository = _Repository()
      ..current = const GitLabRelease(name: 'Version 1', tagName: 'release/1');
    await _pump(tester, repository);
    expect(find.text('No assets yet.'), findsOneWidget);
    await tester.tap(find.byTooltip('Add asset link'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add link'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a link name.'), findsOneWidget);
    expect(repository.creates, isEmpty);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('adds release asset link at width $width', (tester) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.byTooltip('Add asset link'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), ' Desktop package ');
      await tester.enterText(
        find.byType(TextField).at(1),
        ' https://example.com/app.zip ',
      );
      await tester.tap(find.text('Add link'));
      await tester.pumpAndSettle();
      expect(repository.creates.single, (
        name: 'Desktop package',
        url: 'https://example.com/app.zip',
      ));
      expect(find.text('Desktop package'), findsOneWidget);
    });
  }

  testWidgets('validates link fields and preserves draft on forbidden write', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Add asset link'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Existing');
    await tester.enterText(find.byType(TextField).at(1), 'not-a-url');
    await tester.tap(find.text('Add link'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an HTTP or HTTPS URL.'), findsOneWidget);
    expect(repository.creates, isEmpty);
    await tester.enterText(
      find.byType(TextField).at(1),
      'https://example.com/new',
    );
    await tester.tap(find.text('Add link'));
    await tester.pumpAndSettle();
    expect(find.text('A link with this name already exists.'), findsOneWidget);
    expect(repository.creates, isEmpty);
    await tester.enterText(find.byType(TextField).at(0), 'New package');
    await tester.tap(find.text('Add link'));
    await tester.pumpAndSettle();
    expect(find.text('Could not add the asset link.'), findsOneWidget);
    expect(find.text('New package'), findsOneWidget);
  });
}
