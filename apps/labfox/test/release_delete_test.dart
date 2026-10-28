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

  String? deletedTag;
  bool reject = false;

  @override
  Future<void> delete(int projectId, String tagName) async {
    expect(projectId, 7);
    if (reject) throw const GitLabForbiddenException('Forbidden');
    deletedTag = tagName;
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
    initialLocation: '/projects/7/releases/release%2F2',
    routes: [
      GoRoute(
        path: '/projects/:id/releases',
        builder: (_, _) => const Scaffold(body: Text('Release list')),
      ),
      GoRoute(
        path: '/projects/:id/releases/:tagName',
        builder: (_, _) =>
            const ReleaseDetailScreen(projectId: 7, tagName: 'release/2'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
        releaseDetailProvider.overrideWith(
          (ref, key) async =>
              const GitLabRelease(name: 'Version 2', tagName: 'release/2'),
        ),
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
    testWidgets('confirms release deletion at width $width', (tester) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.byTooltip('Delete release'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this release?'), findsOneWidget);
      expect(repository.deletedTag, isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.deletedTag, isNull);
      await tester.tap(find.byTooltip('Delete release'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete release').last);
      await tester.pumpAndSettle();
      expect(repository.deletedTag, 'release/2');
      expect(find.text('Release list'), findsOneWidget);
    });
  }

  testWidgets('keeps release detail when deletion is forbidden', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Delete release'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete release').last);
    await tester.pumpAndSettle();
    expect(find.text('Could not delete the release.'), findsOneWidget);
    expect(find.byType(ReleaseDetailScreen), findsOneWidget);
    expect(repository.deletedTag, isNull);
  });
}
