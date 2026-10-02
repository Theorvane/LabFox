import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/package_registry/data/package_overview.dart';
import 'package:labfox/features/package_registry/data/package_registry_repository.dart';
import 'package:labfox/features/package_registry/presentation/controllers/package_controllers.dart';
import 'package:labfox/features/package_registry/presentation/controllers/package_delete_controller.dart';
import 'package:labfox/features/package_registry/presentation/package_detail_screen.dart';
import 'package:labfox/features/package_registry/presentation/package_list_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _package = GitLabPackage(
  id: 4,
  name: '@team/tool',
  packageType: 'npm',
  version: '1.2.0',
);

class _Repository extends PackageRegistryRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int deletes = 0;
  bool reject = false;
  bool deleted = false;
  Completer<void>? pending;
  Completer<void>? pendingListPage;
  Completer<void>? pendingFilePage;
  bool pagination = false;
  final lists = <int, int>{};
  int loads = 0;
  @override
  Future<Paginated<GitLabPackage>> list(int projectId, {int page = 1}) async {
    lists.update(projectId, (value) => value + 1, ifAbsent: () => 1);
    final result = Paginated<GitLabPackage>(
      items: deleted && projectId == 7 ? [] : [_package],
      nextPage: pagination && page == 1 ? 2 : null,
    );
    if (page > 1) await pendingListPage?.future;
    return result;
  }

  @override
  Future<PackageOverview> load(int projectId, int packageId) async {
    loads++;
    if (pagination && deleted) throw const GitLabNotFoundException('Deleted');
    return PackageOverview(
      package: _package,
      files: Paginated(items: const [], nextPage: pagination ? 2 : null),
    );
  }

  @override
  Future<Paginated<PackageFile>> files(
    int projectId,
    int packageId, {
    int page = 1,
  }) async {
    await pendingFilePage?.future;
    return const Paginated(
      items: [PackageFile(id: 9, packageId: 4, fileName: 'tool.tgz')],
    );
  }

  @override
  Future<void> delete(int projectId, int packageId) async {
    expectSync(projectId, 7);
    expectSync(packageId, 4);
    deletes++;
    if (reject) throw const GitLabForbiddenException('Private server response');
    await pending?.future;
    deleted = true;
  }
}

void main() {
  const key = PackageRef(projectId: 7, packageId: 4);
  final provider = packageDeleteControllerProvider(key);
  late _Repository repository;
  late ProviderContainer container;
  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [
        packageRegistryRepositoryProvider.overrideWith((_) async => repository),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> watchViews() async {
    for (final projectId in [7, 8]) {
      container.listen(packageListControllerProvider(projectId), (_, _) {});
      await container.read(packageListControllerProvider(projectId).future);
    }
    container.listen(packageDetailControllerProvider(key), (_, _) {});
    await container.read(packageDetailControllerProvider(key).future);
  }

  test('success invalidates only the affected list and detail', () async {
    await watchViews();
    await container.read(provider.notifier).delete();
    await container.read(packageListControllerProvider(7).future);
    await container.read(packageDetailControllerProvider(key).future);
    expect(repository.lists, {7: 2, 8: 1});
    expect(repository.loads, 2);
    expect(
      container.read(packageListControllerProvider(7)).requireValue.items,
      isEmpty,
    );
  });
  test('failure preserves caches and supports a real retry', () async {
    await watchViews();
    repository.reject = true;
    await expectLater(
      container.read(provider.notifier).delete(),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(repository.lists, {7: 1, 8: 1});
    expect(repository.loads, 1);
    repository.reject = false;
    await container.read(provider.notifier).delete();
    expect(repository.deletes, 2);
    expect(container.read(provider).hasError, false);
  });
  test('blocks repeated deletion while pending', () async {
    repository.pending = Completer<void>();
    final first = container.read(provider.notifier).delete();
    await Future<void>.delayed(Duration.zero);
    await expectLater(
      container.read(provider.notifier).delete(),
      throwsStateError,
    );
    expect(repository.deletes, 1);
    repository.pending!.complete();
    await first;
  });

  test('late package/file pages cannot resurrect deleted caches', () async {
    repository.pagination = true;
    await watchViews();
    repository.pendingListPage = Completer<void>();
    repository.pendingFilePage = Completer<void>();
    final oldList = container
        .read(packageListControllerProvider(7).notifier)
        .loadMore();
    final oldFiles = container
        .read(packageDetailControllerProvider(key).notifier)
        .loadMoreFiles();
    await Future<void>.delayed(Duration.zero);
    await container.read(provider.notifier).delete();
    await container.read(packageListControllerProvider(7).future);
    await expectLater(
      container.read(packageDetailControllerProvider(key).future),
      throwsA(isA<GitLabNotFoundException>()),
    );
    repository.pendingListPage!.complete();
    repository.pendingFilePage!.complete();
    await Future.wait([oldList, oldFiles]);
    expect(
      container.read(packageListControllerProvider(7)).requireValue.items,
      isEmpty,
    );
    expect(container.read(packageDetailControllerProvider(key)).hasError, true);
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    double width = 390,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/projects/7/packages/4',
      routes: [
        GoRoute(
          path: '/projects/:projectId/packages',
          builder: (_, state) => PackageListScreen(
            projectId: int.parse(state.pathParameters['projectId']!),
          ),
        ),
        GoRoute(
          path: '/projects/:projectId/packages/:packageId',
          builder: (_, state) => PackageDetailScreen(
            projectId: int.parse(state.pathParameters['projectId']!),
            packageId: int.parse(state.pathParameters['packageId']!),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageRegistryRepositoryProvider.overrideWith(
            (_) async => repository,
          ),
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
    await tester.tap(find.byTooltip('Delete package'));
    await tester.pumpAndSettle();
    return router;
  }

  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'confirms exact package and returns to list at $width $brightness',
        (tester) async {
          final router = await pumpScreen(
            tester,
            width: width,
            brightness: brightness,
          );
          expect(repository.deletes, 0);
          expect(
            find.text(
              'Delete @team/tool and all its files? This cannot be undone.',
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.text('1.2.0'),
            ),
            findsOneWidget,
          );
          expect(find.textContaining('dependency confusion'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.widgetWithText(FilledButton, 'Delete package'));
          await tester.pumpAndSettle();
          expect(repository.deletes, 1);
          expect(
            router.routerDelegate.currentConfiguration.last.matchedLocation,
            '/projects/7/packages',
          );
          expect(router.canPop(), false);
          expect(find.byType(PackageListScreen), findsOneWidget);
          expect(find.byType(PackageDetailScreen), findsNothing);
        },
      );
    }
  }
  testWidgets('cancel and barrier dismissal never delete', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(repository.deletes, 0);
    await tester.tap(find.byTooltip('Delete package'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(repository.deletes, 0);
  });
  testWidgets('protected package rejection keeps confirmation for retry', (
    tester,
  ) async {
    final router = await pumpScreen(tester);
    repository.reject = true;
    await tester.tap(find.widgetWithText(FilledButton, 'Delete package'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text(
        'This package may be protected, or you may not have permission to delete it.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Private server'), findsNothing);
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/projects/7/packages/4',
    );
    repository.reject = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Delete package'));
    await tester.pumpAndSettle();
    expect(repository.deletes, 2);
    expect(find.byType(PackageListScreen), findsOneWidget);
  });
  testWidgets('pending delete blocks confirm, cancel, barrier and back', (
    tester,
  ) async {
    await pumpScreen(tester);
    repository.pending = Completer<void>();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete package'));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(repository.deletes, 1);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(PackageListScreen), findsOneWidget);
  });
}
