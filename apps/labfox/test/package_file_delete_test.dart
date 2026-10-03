import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/features/package_registry/data/package_overview.dart';
import 'package:labfox/features/package_registry/data/package_registry_repository.dart';
import 'package:labfox/features/package_registry/presentation/controllers/package_controllers.dart';
import 'package:labfox/features/package_registry/presentation/controllers/package_file_delete_controller.dart';
import 'package:labfox/features/package_registry/presentation/package_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _package = GitLabPackage(
  id: 4,
  name: '@team/tool',
  packageType: 'npm',
  version: '1.2.0',
);
const _file = PackageFile(id: 9, packageId: 4, fileName: 'tool.tgz');
const _otherFile = PackageFile(id: 10, packageId: 4, fileName: 'manifest.json');
const _parent = PackageRef(projectId: 7, packageId: 4);
const _target = PackageFileRef(projectId: 7, packageId: 4, fileId: 9);

class _Repository extends PackageRegistryRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int deletes = 0;
  bool deleted = false;
  bool reject = false;
  bool pagination = false;
  Completer<void>? pending;
  final filePage = Completer<Paginated<PackageFile>>();
  final listPage = Completer<Paginated<GitLabPackage>>();
  final lists = <int, int>{};
  final loads = <int, int>{};

  @override
  Future<Paginated<GitLabPackage>> list(int projectId, {int page = 1}) async {
    lists.update(projectId, (value) => value + 1, ifAbsent: () => 1);
    if (page == 2) return listPage.future;
    return Paginated(
      items: [_package],
      nextPage: pagination && !deleted ? 2 : null,
    );
  }

  @override
  Future<PackageOverview> load(int projectId, int packageId) async {
    loads.update(packageId, (value) => value + 1, ifAbsent: () => 1);
    return PackageOverview(
      package: _package,
      files: Paginated(
        items: [if (!deleted) _file, _otherFile],
        nextPage: pagination && !deleted ? 2 : null,
      ),
    );
  }

  @override
  Future<Paginated<PackageFile>> files(
    int projectId,
    int packageId, {
    int page = 1,
  }) => filePage.future;

  @override
  Future<void> deleteFile(int projectId, int packageId, int fileId) async {
    expectSync((projectId, packageId, fileId), (7, 4, 9));
    deletes++;
    if (reject) throw const GitLabForbiddenException('private server message');
    if (pending != null) await pending!.future;
    deleted = true;
  }
}

ProviderContainer _container(_Repository repository) {
  final container = ProviderContainer(
    overrides: [
      packageRegistryRepositoryProvider.overrideWith((ref) async => repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<GoRouter> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: Routes.packageDetail(7, 4),
    routes: [
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
          (ref) async => repository,
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
  return router;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.widgetWithText(ListTile, 'tool.tgz'),
      matching: find.byType(IconButton),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('success refreshes only parent package and project list', () async {
    final repository = _Repository();
    final container = _container(repository);
    await container.read(packageListControllerProvider(7).future);
    await container.read(packageListControllerProvider(8).future);
    await container.read(packageDetailControllerProvider(_parent).future);
    await container.read(
      packageDetailControllerProvider(
        const PackageRef(projectId: 7, packageId: 5),
      ).future,
    );
    await container
        .read(packageFileDeleteControllerProvider(_target).notifier)
        .delete();
    final detail = await container.read(
      packageDetailControllerProvider(_parent).future,
    );
    await container.read(packageListControllerProvider(7).future);
    expect(detail.files.items.map((file) => file.id), [10]);
    expect(repository.lists, {7: 2, 8: 1});
    expect(repository.loads, {4: 2, 5: 1});
  });

  test(
    'forbidden deletion keeps cached files and supports a real retry',
    () async {
      final repository = _Repository()..reject = true;
      final container = _container(repository);
      await container.read(packageDetailControllerProvider(_parent).future);
      final command = container.read(
        packageFileDeleteControllerProvider(_target).notifier,
      );
      await expectLater(
        command.delete(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(
        container
            .read(packageDetailControllerProvider(_parent))
            .requireValue
            .files
            .items,
        [_file, _otherFile],
      );
      expect(repository.loads[4], 1);
      repository.reject = false;
      await command.delete();
      expect(repository.deletes, 2);
    },
  );

  test('pending deletion rejects duplicate requests', () async {
    final repository = _Repository()..pending = Completer<void>();
    final container = _container(repository);
    final command = container.read(
      packageFileDeleteControllerProvider(_target).notifier,
    );
    final first = command.delete();
    await expectLater(command.delete(), throwsStateError);
    repository.pending!.complete();
    await first;
    expect(repository.deletes, 1);
  });

  for (final fail in [false, true]) {
    test(
      'late pagination ${fail ? 'failure' : 'success'} cannot restore deleted files',
      () async {
        final repository = _Repository()..pagination = true;
        final container = _container(repository);
        await container.read(packageDetailControllerProvider(_parent).future);
        await container.read(packageListControllerProvider(7).future);
        final files = container
            .read(packageDetailControllerProvider(_parent).notifier)
            .loadMoreFiles();
        final packages = container
            .read(packageListControllerProvider(7).notifier)
            .loadMore();
        await container
            .read(packageFileDeleteControllerProvider(_target).notifier)
            .delete();
        await container.read(packageDetailControllerProvider(_parent).future);
        await container.read(packageListControllerProvider(7).future);
        if (fail) {
          repository.filePage.completeError(
            const GitLabNotFoundException('gone'),
          );
          repository.listPage.completeError(
            const GitLabNotFoundException('gone'),
          );
        } else {
          repository.filePage.complete(const Paginated(items: [_file]));
          repository.listPage.complete(const Paginated(items: [_package]));
        }
        await Future.wait([files, packages]);
        expect(
          container.read(packageDetailControllerProvider(_parent)).hasError,
          isFalse,
        );
        expect(
          container.read(packageListControllerProvider(7)).hasError,
          isFalse,
        );
        expect(
          container
              .read(packageDetailControllerProvider(_parent))
              .requireValue
              .files
              .items,
          [_otherFile],
        );
        expect(
          container.read(packageListControllerProvider(7)).requireValue.items,
          [_package],
        );
      },
    );
  }

  for (final width in [320.0, 390.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'confirmed deletion stays on package detail at $width dark=$dark',
        (tester) async {
          final repository = _Repository();
          final router = await _pump(
            tester,
            repository,
            width: width,
            dark: dark,
          );
          await _open(tester);
          final dialog = find.byType(AlertDialog);
          expect(
            find.descendant(
              of: dialog,
              matching: find.textContaining('tool.tgz'),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: dialog,
              matching: find.textContaining('@team/tool'),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(of: dialog, matching: find.text('1.2.0')),
            findsOneWidget,
          );
          expect(find.textContaining('corrupt'), findsOneWidget);
          expect(repository.deletes, 0);
          await tester.tap(find.widgetWithText(FilledButton, 'Delete file'));
          await tester.pumpAndSettle();
          expect(repository.deletes, 1);
          expect(find.byType(AlertDialog), findsNothing);
          expect(find.text('tool.tgz'), findsNothing);
          expect(find.text('manifest.json'), findsOneWidget);
          expect(find.byType(PackageDetailScreen), findsOneWidget);
          expect(
            router.routerDelegate.currentConfiguration.last.matchedLocation,
            Routes.packageDetail(7, 4),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('cancel and dismiss make no request', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await _open(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    await _open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(repository.deletes, 0);
  });

  testWidgets(
    'protected or forbidden errors remain retryable without server text',
    (tester) async {
      final repository = _Repository()..reject = true;
      await _pump(tester, repository);
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete file'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('protected'), findsOneWidget);
      expect(find.textContaining('private server'), findsNothing);
      expect(find.text('tool.tgz'), findsOneWidget);
      repository.reject = false;
      await tester.tap(find.widgetWithText(FilledButton, 'Delete file'));
      await tester.pumpAndSettle();
      expect(repository.deletes, 2);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'pending confirmation blocks repeats, cancellation, barrier and back',
    (tester) async {
      final repository = _Repository()..pending = Completer<void>();
      await _pump(tester, repository);
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete file'));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Delete file'),
            )
            .onPressed,
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
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
}
