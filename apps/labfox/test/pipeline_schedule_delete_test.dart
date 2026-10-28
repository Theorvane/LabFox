import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/pipeline_schedule_detail_screen.dart';
import 'package:labfox/features/pipeline_schedules/presentation/pipeline_schedules_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _schedule = PipelineSchedule(
  id: 13,
  description: 'Nightly build',
  ref: 'main',
  cron: '0 1 * * *',
  active: true,
);
const _key = PipelineScheduleRef(projectId: 7, scheduleId: 13);

class _Repository extends PipelineSchedulesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int deletes = 0;
  int gets = 0;
  bool deleted = false;
  Object? failure;
  Completer<void>? pending;
  final lists = <bool?>[];

  @override
  Future<PipelineSchedule> get(int projectId, int scheduleId) async {
    expect(projectId, 7);
    expect(scheduleId, 13);
    gets++;
    if (deleted) throw const GitLabNotFoundException('Not found');
    return _schedule;
  }

  @override
  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) async {
    lists.add(active);
    return Paginated(items: deleted ? [] : [_schedule]);
  }

  @override
  Future<void> delete(int projectId, int scheduleId) async {
    expect(projectId, 7);
    expect(scheduleId, 13);
    deletes++;
    await pending?.future;
    if (failure != null) throw failure!;
    deleted = true;
  }
}

Future<GoRouter> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 850);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/pipeline_schedules/13',
    routes: [
      GoRoute(
        path: '/projects/:projectId/pipeline_schedules',
        builder: (_, _) => const PipelineSchedulesScreen(projectId: 7),
      ),
      GoRoute(
        path: '/projects/:projectId/pipeline_schedules/:scheduleId',
        builder: (_, _) =>
            const PipelineScheduleDetailScreen(projectId: 7, scheduleId: 13),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
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
  await tester.tap(find.text('Delete schedule'));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('confirms deletion and leaves detail at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        final router = await _pump(
          tester,
          repository,
          width: width,
          brightness: brightness,
        );
        expect(find.text('Delete this pipeline schedule?'), findsOneWidget);
        expect(find.textContaining('Nightly build'), findsWidgets);
        expect(repository.deletes, 0);
        await tester.tap(find.widgetWithText(FilledButton, 'Delete schedule'));
        await tester.pumpAndSettle();
        expect(repository.deletes, 1);
        expect(
          router.routeInformationProvider.value.uri.path,
          '/projects/7/pipeline_schedules',
        );
        expect(find.text('No pipeline schedules found.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('cancel and dismiss make no delete request', (tester) async {
    final repository = _Repository();
    final router = await _pump(tester, repository);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete schedule'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(repository.deletes, 0);
    expect(
      router.routeInformationProvider.value.uri.path,
      '/projects/7/pipeline_schedules/13',
    );
  });

  for (final error in <Object>[
    const GitLabForbiddenException('Server-only private details'),
    const GitLabNotFoundException('Server-only private details'),
  ]) {
    testWidgets('retains rejected confirmation and retries $error', (
      tester,
    ) async {
      final repository = _Repository()..failure = error;
      final router = await _pump(tester, repository);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete schedule'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Could not delete this pipeline schedule. Check your permissions and try again.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Server-only private details'), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/projects/7/pipeline_schedules/13',
      );
      repository.failure = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Delete schedule'));
      await tester.pumpAndSettle();
      expect(repository.deletes, 2);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/projects/7/pipeline_schedules',
      );
    });
  }

  testWidgets('blocks repeated confirmation and dismissal while deleting', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer<void>();
    await _pump(tester, repository);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete schedule'));
    await tester.pump();
    await tester.pump();
    expect(repository.deletes, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Delete schedule'),
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
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(repository.deletes, 1);
  });

  test(
    'successful deletion refreshes detail and every schedule list filter',
    () async {
      final repository = _Repository();
      final container = ProviderContainer(
        overrides: [
          pipelineSchedulesRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(pipelineScheduleDetailProvider(_key).future);
      final providers = [
        for (final active in <bool?>[null, true, false])
          pipelineScheduleListControllerProvider(
            PipelineScheduleListRef(projectId: 7, active: active),
          ),
      ];
      for (final provider in providers) {
        await container.read(provider.future);
      }
      await container
          .read(pipelineScheduleDeleteControllerProvider(_key).notifier)
          .delete();
      await expectLater(
        container.read(pipelineScheduleDetailProvider(_key).future),
        throwsA(isA<GitLabNotFoundException>()),
      );
      expect(repository.gets, 2);
      for (final provider in providers) {
        expect((await container.read(provider.future)).items, isEmpty);
      }
      for (final active in <bool?>[null, true, false]) {
        expect(repository.lists.where((value) => value == active).length, 2);
      }
    },
  );

  test('failed deletion retains cached detail and all list filters', () async {
    final repository = _Repository()
      ..failure = const GitLabForbiddenException('Forbidden');
    final container = ProviderContainer(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(pipelineScheduleDetailProvider(_key).future);
    final providers = [
      for (final active in <bool?>[null, true, false])
        pipelineScheduleListControllerProvider(
          PipelineScheduleListRef(projectId: 7, active: active),
        ),
    ];
    for (final provider in providers) {
      await container.read(provider.future);
    }
    final command = container.read(
      pipelineScheduleDeleteControllerProvider(_key).notifier,
    );
    await expectLater(
      command.delete(),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      await container.read(pipelineScheduleDetailProvider(_key).future),
      _schedule,
    );
    for (final provider in providers) {
      expect((await container.read(provider.future)).items, [_schedule]);
    }
    expect(repository.gets, 1);
    expect(repository.lists.length, 3);
  });
}
