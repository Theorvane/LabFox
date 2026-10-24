import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/container_repository_screen.dart';
import 'package:labfox/features/container_registry/presentation/container_tag_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_delete_controller.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _parent = RegistryRef(projectId: 7, repositoryId: 3);
const _target = RegistryTagRef(repository: _parent, name: 'v1');
const _tag = RegistryTag(
  name: 'v1',
  path: 'team/app/service:v1',
  digest: 'sha256:abc',
);
const _other = RegistryTag(name: 'latest', path: 'team/app/service:latest');
const _repository = RegistryRepository(
  id: 3,
  name: 'service',
  path: 'team/app/service',
  projectId: 7,
);

class _Repository extends ContainerRegistryRepository {
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
  final tagPage = Completer<Paginated<RegistryTag>>();
  final repositoryPage = Completer<Paginated<RegistryRepository>>();
  final lists = <int, int>{};
  final tagLists = <int, int>{};
  int detailLoads = 0;

  @override
  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) async {
    lists.update(projectId, (value) => value + 1, ifAbsent: () => 1);
    if (page == 2) return repositoryPage.future;
    return Paginated(
      items: [_repository],
      nextPage: pagination && !deleted ? 2 : null,
    );
  }

  @override
  Future<Paginated<RegistryTag>> tags(
    int projectId,
    int repositoryId, {
    int page = 1,
  }) async {
    tagLists.update(repositoryId, (value) => value + 1, ifAbsent: () => 1);
    if (page == 2) return tagPage.future;
    return Paginated(
      items: [if (!deleted) _tag, _other],
      nextPage: pagination && !deleted ? 2 : null,
    );
  }

  @override
  Future<RegistryTag> tag(
    int projectId,
    int repositoryId,
    String tagName,
  ) async {
    detailLoads++;
    if (deleted) throw const GitLabNotFoundException('gone');
    return _tag;
  }

  @override
  Future<void> deleteTag(
    int projectId,
    int repositoryId,
    String tagName,
  ) async {
    expectSync((projectId, repositoryId, tagName), (7, 3, 'v1'));
    deletes++;
    if (reject) throw const GitLabForbiddenException('private server text');
    if (pending != null) await pending!.future;
    deleted = true;
  }
}

ProviderContainer _container(_Repository repository) {
  final container = ProviderContainer(
    overrides: [
      containerRegistryRepositoryProvider.overrideWith(
        (ref) async => repository,
      ),
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
    initialLocation: Routes.containerTag(7, 3, 'v1'),
    routes: [
      GoRoute(
        path: '/projects/:projectId/container_registry/:repositoryId',
        builder: (_, state) => ContainerRepositoryScreen(
          projectId: int.parse(state.pathParameters['projectId']!),
          repositoryId: int.parse(state.pathParameters['repositoryId']!),
        ),
      ),
      GoRoute(
        path:
            '/projects/:projectId/container_registry/:repositoryId/tags/:name',
        builder: (_, state) => ContainerTagScreen(
          projectId: int.parse(state.pathParameters['projectId']!),
          repositoryId: int.parse(state.pathParameters['repositoryId']!),
          tagName: state.pathParameters['name']!,
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
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
  await tester.tap(find.byTooltip('Delete tag'));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'confirmed success invalidates only the parent and project caches',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      await container.read(containerRepositoriesControllerProvider(7).future);
      await container.read(containerRepositoriesControllerProvider(8).future);
      await container.read(containerTagsControllerProvider(_parent).future);
      await container.read(
        containerTagsControllerProvider(
          const RegistryRef(projectId: 7, repositoryId: 4),
        ).future,
      );
      await container.read(containerTagProvider(_target).future);
      await container
          .read(containerTagDeleteControllerProvider(_target).notifier)
          .delete();
      await container.read(containerRepositoriesControllerProvider(7).future);
      expect(
        (await container.read(
          containerTagsControllerProvider(_parent).future,
        )).items,
        [_other],
      );
      await expectLater(
        container.read(containerTagProvider(_target).future),
        throwsA(isA<GitLabNotFoundException>()),
      );
      expect(repository.lists, {7: 2, 8: 1});
      expect(repository.tagLists, {3: 2, 4: 1});
      expect(repository.detailLoads, 2);
    },
  );

  test('forbidden deletion retains caches and allows retry', () async {
    final repository = _Repository()..reject = true;
    final container = _container(repository);
    await container.read(containerTagsControllerProvider(_parent).future);
    final command = container.read(
      containerTagDeleteControllerProvider(_target).notifier,
    );
    await expectLater(
      command.delete(),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container
          .read(containerTagsControllerProvider(_parent))
          .requireValue
          .items,
      [_tag, _other],
    );
    expect(repository.tagLists[3], 1);
    repository.reject = false;
    await command.delete();
    expect(repository.deletes, 2);
  });

  test('duplicate deletion is blocked before repository resolution', () async {
    final repository = _Repository()..pending = Completer<void>();
    final container = _container(repository);
    final command = container.read(
      containerTagDeleteControllerProvider(_target).notifier,
    );
    final first = command.delete();
    await expectLater(command.delete(), throwsStateError);
    repository.pending!.complete();
    await first;
    expect(repository.deletes, 1);
  });

  for (final fail in [false, true]) {
    test(
      'old pagination ${fail ? 'error' : 'success'} cannot overwrite refreshed tags',
      () async {
        final repository = _Repository()..pagination = true;
        final container = _container(repository);
        await container.read(containerRepositoriesControllerProvider(7).future);
        await container.read(containerTagsControllerProvider(_parent).future);
        final tags = container
            .read(containerTagsControllerProvider(_parent).notifier)
            .loadMore();
        final repos = container
            .read(containerRepositoriesControllerProvider(7).notifier)
            .loadMore();
        await container
            .read(containerTagDeleteControllerProvider(_target).notifier)
            .delete();
        await container.read(containerTagsControllerProvider(_parent).future);
        await container.read(containerRepositoriesControllerProvider(7).future);
        if (fail) {
          repository.tagPage.completeError(
            const GitLabNotFoundException('gone'),
          );
          repository.repositoryPage.completeError(
            const GitLabNotFoundException('gone'),
          );
        } else {
          repository.tagPage.complete(const Paginated(items: [_tag]));
          repository.repositoryPage.complete(
            const Paginated(items: [_repository]),
          );
        }
        await Future.wait([tags, repos]);
        expect(
          container.read(containerTagsControllerProvider(_parent)).hasError,
          isFalse,
        );
        expect(
          container.read(containerRepositoriesControllerProvider(7)).hasError,
          isFalse,
        );
        expect(
          container
              .read(containerTagsControllerProvider(_parent))
              .requireValue
              .items,
          [_other],
        );
        expect(
          container
              .read(containerRepositoriesControllerProvider(7))
              .requireValue
              .items,
          [_repository],
        );
      },
    );
  }

  for (final width in [320.0, 390.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('confirm and return to repository at $width dark=$dark', (
        tester,
      ) async {
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
          find.descendant(of: dialog, matching: find.textContaining('v1')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: dialog,
            matching: find.textContaining('team/app/service'),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('blobs'), findsOneWidget);
        expect(repository.deletes, 0);
        await tester.tap(find.widgetWithText(FilledButton, 'Delete tag'));
        await tester.pumpAndSettle();
        expect(repository.deletes, 1);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(ContainerRepositoryScreen), findsOneWidget);
        expect(find.text('v1'), findsNothing);
        expect(find.text('latest'), findsOneWidget);
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          Routes.containerRepository(7, 3),
        );
        expect(router.canPop(), isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('cancel and barrier dismissal do not delete', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await _open(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    await _open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(repository.deletes, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('protected tag error remains retryable without server text', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await _open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete tag'));
    await tester.pumpAndSettle();
    expect(find.textContaining('protected'), findsOneWidget);
    expect(find.textContaining('private server'), findsNothing);
    expect(find.byType(AlertDialog), findsOneWidget);
    repository.reject = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Delete tag'));
    await tester.pumpAndSettle();
    expect(repository.deletes, 2);
    expect(find.byType(ContainerRepositoryScreen), findsOneWidget);
  });

  testWidgets(
    'pending confirmation blocks cancel, duplicate, barrier and back',
    (tester) async {
      final repository = _Repository()..pending = Completer<void>();
      await _pump(tester, repository);
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete tag'));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Delete tag'),
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
      expect(find.byType(ContainerRepositoryScreen), findsOneWidget);
    },
  );
}
