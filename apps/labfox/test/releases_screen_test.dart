import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';
import 'package:labfox/features/releases/presentation/release_detail_screen.dart';
import 'package:labfox/features/releases/presentation/releases_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _List extends ReleaseListController {
  @override
  Future<Paginated<GitLabRelease>> build(int arg) async => const Paginated(
    items: [GitLabRelease(name: 'Version 1', tagName: 'release/1')],
  );
}

Future<void> _pump(
  WidgetTester tester, {
  Size? size,
  bool dark = false,
  String initialLocation = '/projects/7/releases',
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/projects/:id/releases',
        builder: (_, state) =>
            ReleasesScreen(projectId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/projects/:id/releases/:tagName',
        builder: (_, state) => ReleaseDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          tagName: state.pathParameters['tagName']!,
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releaseListControllerProvider.overrideWith(_List.new),
        releaseDetailProvider.overrideWith(
          (ref, key) async => const GitLabRelease(
            name: 'Version 1',
            tagName: 'release/1',
            description: '## Changes',
            assets: ReleaseAssets(
              links: [
                ReleaseAssetLink(
                  id: 3,
                  name: 'Binary',
                  url: 'https://example.com/bin',
                ),
              ],
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens release notes and assets by tag', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Version 1'));
    await tester.pumpAndSettle();
    expect(find.byType(MarkdownViewer), findsOneWidget);
    expect(find.text('Binary'), findsOneWidget);
    expect(find.byType(ReleaseDetailScreen), findsOneWidget);
    expect(
      tester
          .widget<ReleaseDetailScreen>(find.byType(ReleaseDetailScreen))
          .tagName,
      'release/1',
    );
  });

  testWidgets('shows releases on a narrow dark screen', (tester) async {
    await _pump(tester, size: const Size(390, 844), dark: true);
    expect(find.text('Version 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('places release notes beside metadata on wide screens', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(1200, 800),
      initialLocation: '/projects/7/releases/release%2F1',
    );
    expect(
      tester.getTopLeft(find.byType(MarkdownViewer)).dx,
      greaterThan(tester.getTopLeft(find.text('release/1')).dx + 150),
    );
  });
}
