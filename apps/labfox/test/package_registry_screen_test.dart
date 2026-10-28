import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/features/package_registry/data/package_overview.dart';
import 'package:labfox/features/package_registry/presentation/controllers/package_controllers.dart';
import 'package:labfox/features/package_registry/presentation/package_detail_screen.dart';
import 'package:labfox/features/package_registry/presentation/package_list_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubList extends PackageListController {
  _StubList(this.value);

  final AsyncValue<Paginated<GitLabPackage>> value;

  @override
  Future<Paginated<GitLabPackage>> build(int arg) => value.when(
    data: Future.value,
    loading: () => Completer<Paginated<GitLabPackage>>().future,
    error: Future.error,
  );
}

class _StubDetail extends PackageDetailController {
  _StubDetail(this.value);

  final AsyncValue<PackageOverview> value;

  @override
  Future<PackageOverview> build(PackageRef arg) => value.when(
    data: Future.value,
    loading: () => Completer<PackageOverview>().future,
    error: Future.error,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required AsyncValue<Paginated<GitLabPackage>> list,
  required AsyncValue<PackageOverview> detail,
  String initialLocation = '/projects/7/packages',
  Size? size,
  bool dark = false,
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
        path: '/projects/:id/packages',
        builder: (_, state) => PackageListScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/packages/:packageId',
        builder: (_, state) => PackageDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          packageId: int.parse(state.pathParameters['packageId']!),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        packageListControllerProvider.overrideWith(() => _StubList(list)),
        packageDetailControllerProvider.overrideWith(() => _StubDetail(detail)),
      ],
      child: MaterialApp.router(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

const _package = GitLabPackage(
  id: 4,
  name: '@team/tool',
  packageType: 'npm',
  version: '1.2.0',
);
const _list = Paginated<GitLabPackage>(items: [_package]);
const _detail = PackageOverview(
  package: _package,
  files: Paginated<PackageFile>(
    items: [PackageFile(id: 9, packageId: 4, fileName: 'tool.tgz', size: 512)],
  ),
);

void main() {
  testWidgets('lists packages and opens details inside the app', (
    tester,
  ) async {
    await _pump(
      tester,
      list: const AsyncData(_list),
      detail: const AsyncData(_detail),
    );
    await tester.pumpAndSettle();

    expect(find.text('@team/tool'), findsOneWidget);
    expect(find.text('1.2.0'), findsOneWidget);
    await tester.tap(find.text('@team/tool'));
    await tester.pumpAndSettle();

    expect(find.text('tool.tgz'), findsOneWidget);
    expect(
      tester
          .widget<PackageDetailScreen>(find.byType(PackageDetailScreen))
          .packageId,
      4,
    );
  });

  testWidgets('shows an empty registry message', (tester) async {
    await _pump(
      tester,
      list: const AsyncData(Paginated<GitLabPackage>(items: [])),
      detail: const AsyncData(_detail),
    );
    await tester.pumpAndSettle();

    expect(find.text('No packages yet.'), findsOneWidget);
  });

  testWidgets('shows a retry action on list errors', (tester) async {
    await _pump(
      tester,
      list: AsyncError(Exception('failed'), StackTrace.current),
      detail: const AsyncData(_detail),
    );
    await tester.pump();

    expect(find.text('Could not load packages.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('places package metadata beside files on wide screens', (
    tester,
  ) async {
    await _pump(
      tester,
      list: const AsyncData(_list),
      detail: const AsyncData(_detail),
      initialLocation: Routes.packageDetail(7, 4),
      size: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('tool.tgz')).dx,
      greaterThan(tester.getTopLeft(find.text('npm')).dx + 200),
    );
  });

  testWidgets('shows the package list on a narrow dark screen', (tester) async {
    await _pump(
      tester,
      list: const AsyncData(_list),
      detail: const AsyncData(_detail),
      size: const Size(390, 844),
      dark: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('@team/tool'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
