import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/container_repository_screen.dart';
import 'package:labfox/features/container_registry/presentation/container_tag_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repositories extends ContainerRepositoriesController {
  @override
  Future<Paginated<RegistryRepository>> build(int arg) async => const Paginated(
    items: [
      RegistryRepository(
        id: 3,
        name: 'service',
        path: 'team/app/service',
        projectId: 7,
      ),
    ],
  );
}

class _Tags extends ContainerTagsController {
  @override
  Future<Paginated<RegistryTag>> build(RegistryRef arg) async =>
      const Paginated(
        items: [
          RegistryTag(name: 'release/1', path: 'team/app/service:release/1'),
        ],
      );
}

Future<void> _pump(WidgetTester tester, {Size? size, bool dark = false}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: '/projects/7/container_registry',
    routes: [
      GoRoute(
        path: '/projects/:id/container_registry',
        builder: (_, state) => ContainerRegistryScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/container_registry/:repositoryId',
        builder: (_, state) => ContainerRepositoryScreen(
          projectId: int.parse(state.pathParameters['id']!),
          repositoryId: int.parse(state.pathParameters['repositoryId']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/container_registry/:repositoryId/tags/:tagName',
        builder: (_, state) => ContainerTagScreen(
          projectId: int.parse(state.pathParameters['id']!),
          repositoryId: int.parse(state.pathParameters['repositoryId']!),
          tagName: state.pathParameters['tagName']!,
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRepositoriesControllerProvider.overrideWith(_Repositories.new),
        containerTagsControllerProvider.overrideWith(_Tags.new),
        containerTagProvider.overrideWith(
          (ref, key) async => const RegistryTag(
            name: 'release/1',
            path: 'team/app/service:release/1',
            digest: 'sha256:abc',
            totalSize: 42,
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
  for (final width in [320.0, 800.0, 1200.0]) {
    testWidgets('all registry toolbar actions fit width $width', (
      tester,
    ) async {
      await _pump(tester, size: Size(width, 844));
      expect(tester.takeException(), isNull);
      final toolbarButtons = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(IconButton),
      );
      expect(toolbarButtons.evaluate().length, greaterThanOrEqualTo(7));
      for (final button in toolbarButtons.evaluate()) {
        final finder = find.byWidget(button.widget);
        final bounds = tester.getRect(finder);
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(width));
        expect(finder.hitTestable(), findsOneWidget);
      }
      expect(find.text('team/app/service'), findsOneWidget);
    });
  }

  testWidgets('navigates from image repository to tag details', (tester) async {
    await _pump(tester);
    expect(find.text('team/app/service'), findsOneWidget);
    await tester.tap(find.text('team/app/service'));
    await tester.pumpAndSettle();
    expect(find.text('release/1'), findsOneWidget);
    await tester.tap(find.text('release/1'));
    await tester.pumpAndSettle();
    expect(find.text('sha256:abc'), findsOneWidget);
    expect(find.text('Size (bytes)'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('renders repository list on a compact screen', (tester) async {
    await _pump(tester, size: const Size(390, 844), dark: true);
    expect(find.text('team/app/service'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
