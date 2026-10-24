import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_repository_delete_controller.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _target = RegistryRef(projectId: 7, repositoryId: 3);
const _repository = RegistryRepository(
  id: 3,
  name: 'service',
  path: 'team/app/service',
  projectId: 7,
);
const _tag = RegistryTag(name: 'v1', path: 'team/app/service:v1');

class _Repository extends ContainerRegistryRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int deletes = 0;
  bool scheduled = false;
  bool reject = false;
  bool pagination = false;
  String? status;
  Completer<void>? pending;
  final repositoryPage = Completer<Paginated<RegistryRepository>>();
  final tagPage = Completer<Paginated<RegistryTag>>();
  final lists = <int, int>{};
  final tagLists = <int, int>{};

  @override
  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) async {
    lists.update(projectId, (value) => value + 1, ifAbsent: () => 1);
    if (page == 2) return repositoryPage.future;
    // A 202 does not mean the repository is already absent from the server.
    return Paginated(
      items: [_repository.copyWith(status: status)],
      nextPage: pagination && !scheduled ? 2 : null,
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
      items: [_tag],
      nextPage: pagination && !scheduled ? 2 : null,
    );
  }

  @override
  Future<void> deleteRepository(int projectId, int repositoryId) async {
    expectSync((projectId, repositoryId), (7, 3));
    deletes++;
    if (reject) throw const GitLabForbiddenException('private server text');
    if (pending != null) await pending!.future;
    scheduled = true;
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

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ContainerRegistryScreen(projectId: 7),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Delete repository'));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'acceptance refreshes only project and parent tags without claiming completion',
    () async {
      final repository = _Repository();
      final container = _container(repository);
      await container.read(containerRepositoriesControllerProvider(7).future);
      await container.read(containerRepositoriesControllerProvider(8).future);
      await container.read(containerTagsControllerProvider(_target).future);
      await container.read(
        containerTagsControllerProvider(
          const RegistryRef(projectId: 7, repositoryId: 4),
        ).future,
      );
      final command = container.read(
        containerRepositoryDeleteControllerProvider(_target).notifier,
      );
      await command.delete();
      expect(
        container
            .read(containerRepositoryDeleteControllerProvider(_target))
            .requireValue,
        isTrue,
      );
      expect(
        (await container.read(
          containerRepositoriesControllerProvider(7).future,
        )).items,
        [_repository],
      );
      expect(
        (await container.read(
          containerTagsControllerProvider(_target).future,
        )).items,
        [_tag],
      );
      expect(repository.lists, {7: 2, 8: 1});
      expect(repository.tagLists, {3: 2, 4: 1});
      await expectLater(command.delete(), throwsStateError);
      expect(repository.deletes, 1);
    },
  );

  test('rejection retains caches and supports retry', () async {
    final repository = _Repository()..reject = true;
    final container = _container(repository);
    await container.read(containerRepositoriesControllerProvider(7).future);
    final command = container.read(
      containerRepositoryDeleteControllerProvider(_target).notifier,
    );
    await expectLater(
      command.delete(),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container
          .read(containerRepositoriesControllerProvider(7))
          .requireValue
          .items,
      [_repository],
    );
    expect(repository.lists[7], 1);
    repository.reject = false;
    await command.delete();
    expect(repository.deletes, 2);
  });

  test(
    'pending request blocks duplicates before resolving the repository',
    () async {
      final repository = _Repository()..pending = Completer<void>();
      final container = _container(repository);
      final command = container.read(
        containerRepositoryDeleteControllerProvider(_target).notifier,
      );
      final first = command.delete();
      await expectLater(command.delete(), throwsStateError);
      repository.pending!.complete();
      await first;
      expect(repository.deletes, 1);
    },
  );

  for (final fail in [false, true]) {
    test(
      'late pagination ${fail ? 'error' : 'success'} cannot overwrite refreshed data',
      () async {
        final repository = _Repository()..pagination = true;
        final container = _container(repository);
        await container.read(containerRepositoriesControllerProvider(7).future);
        await container.read(containerTagsControllerProvider(_target).future);
        final repositories = container
            .read(containerRepositoriesControllerProvider(7).notifier)
            .loadMore();
        final tags = container
            .read(containerTagsControllerProvider(_target).notifier)
            .loadMore();
        await container
            .read(containerRepositoryDeleteControllerProvider(_target).notifier)
            .delete();
        await container.read(containerRepositoriesControllerProvider(7).future);
        await container.read(containerTagsControllerProvider(_target).future);
        if (fail) {
          repository.repositoryPage.completeError(
            const GitLabNotFoundException('gone'),
          );
          repository.tagPage.completeError(
            const GitLabNotFoundException('gone'),
          );
        } else {
          repository.repositoryPage.complete(
            const Paginated(items: [_repository]),
          );
          repository.tagPage.complete(const Paginated(items: [_tag]));
        }
        await Future.wait([repositories, tags]);
        expect(
          container.read(containerRepositoriesControllerProvider(7)).hasError,
          isFalse,
        );
        expect(
          container.read(containerTagsControllerProvider(_target)).hasError,
          isFalse,
        );
        expect(
          container
              .read(containerRepositoriesControllerProvider(7))
              .requireValue
              .items,
          [_repository],
        );
        expect(
          container
              .read(containerTagsControllerProvider(_target))
              .requireValue
              .items,
          [_tag],
        );
      },
    );
  }

  for (final width in [320.0, 390.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('confirms asynchronous deletion at $width dark=$dark', (
        tester,
      ) async {
        final repository = _Repository();
        await _pump(tester, repository, width: width, dark: dark);
        await _open(tester);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.textContaining('team/app/service'),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('all its tags'), findsOneWidget);
        expect(find.textContaining('take time'), findsOneWidget);
        expect(repository.deletes, 0);
        await tester.tap(
          find.widgetWithText(FilledButton, 'Delete repository'),
        );
        await tester.pumpAndSettle();
        expect(repository.deletes, 1);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('team/app/service'), findsOneWidget);
        expect(find.text('Deletion scheduled'), findsOneWidget);
        expect(
          tester
              .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.delete_outline),
              )
              .onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final status in ['delete_scheduled', 'delete_ongoing']) {
    testWidgets('server $status blocks rescheduling', (tester) async {
      final repository = _Repository()..status = status;
      await _pump(tester, repository);
      expect(find.text('Deletion scheduled'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.delete_outline),
            )
            .onPressed,
        isNull,
      );
      expect(repository.deletes, 0);
    });
  }

  testWidgets('cancel and barrier dismissal do not schedule deletion', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await _open(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    await _open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(repository.deletes, 0);
  });

  testWidgets('forbidden errors remain retryable without server text', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await _open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete repository'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('permission'), findsOneWidget);
    expect(find.textContaining('private server'), findsNothing);
    repository.reject = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Delete repository'));
    await tester.pumpAndSettle();
    expect(repository.deletes, 2);
  });

  testWidgets(
    'pending confirmation blocks cancel, duplicates, barrier and back',
    (tester) async {
      final repository = _Repository()..pending = Completer<void>();
      await _pump(tester, repository);
      await _open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete repository'));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Delete repository'),
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
      expect(find.text('Deletion scheduled'), findsOneWidget);
    },
  );
}
