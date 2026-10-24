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
        ),
      ],
      sources: [
        ReleaseSource(format: 'zip', url: 'https://example.com/source.zip'),
      ],
    ),
  );
  int? deletedLinkId;
  bool reject = false;

  @override
  Future<GitLabRelease> get(int projectId, String tagName) async => current;

  @override
  Future<void> deleteAssetLink(
    int projectId,
    String tagName,
    int linkId,
  ) async {
    expect(projectId, 7);
    expect(tagName, 'release/1');
    if (reject) throw const GitLabForbiddenException('Forbidden');
    deletedLinkId = linkId;
    current = current.copyWith(assets: current.assets!.copyWith(links: []));
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
    testWidgets('confirms asset link deletion at width $width', (tester) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      expect(find.byTooltip('Delete asset link'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete asset link'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this asset link?'), findsOneWidget);
      expect(repository.deletedLinkId, isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.deletedLinkId, isNull);
      await tester.tap(find.byTooltip('Delete asset link'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete link'));
      await tester.pumpAndSettle();
      expect(repository.deletedLinkId, 12);
      expect(find.text('Desktop package'), findsNothing);
      expect(find.text('zip'), findsOneWidget);
      expect(find.byType(ReleaseDetailScreen), findsOneWidget);
    });
  }

  testWidgets('keeps the link after forbidden deletion', (tester) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Delete asset link'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete link'));
    await tester.pumpAndSettle();
    expect(find.text('Could not delete the asset link.'), findsOneWidget);
    expect(find.text('Desktop package'), findsOneWidget);
    expect(repository.deletedLinkId, isNull);
  });
}
