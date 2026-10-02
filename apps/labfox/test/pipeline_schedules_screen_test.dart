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

class _FakeRepository extends PipelineSchedulesRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  int playCount = 0;
  bool? requestedActive;

  @override
  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) async {
    requestedActive = active;
    return const Paginated(
      items: [
        PipelineSchedule(
          id: 13,
          description: 'Nightly build',
          ref: 'main',
          cron: '0 1 * * *',
          active: true,
        ),
      ],
    );
  }

  @override
  Future<PipelineSchedule> get(int projectId, int scheduleId) async =>
      const PipelineSchedule(
        id: 13,
        description: 'Nightly build',
        ref: 'main',
        cron: '0 1 * * *',
        active: true,
        lastPipeline: ScheduleLastPipeline(id: 332, status: 'success'),
      );

  @override
  Future<void> play(int projectId, int scheduleId) async {
    playCount++;
  }
}

Future<_FakeRepository> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repository = _FakeRepository();
  final router = GoRouter(
    initialLocation: '/projects/7/pipeline_schedules',
    routes: [
      GoRoute(
        path: '/projects/:id/pipeline_schedules',
        builder: (_, state) => PipelineSchedulesScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/pipeline_schedules/:scheduleId',
        builder: (_, state) => PipelineScheduleDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          scheduleId: int.parse(state.pathParameters['scheduleId']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/pipelines/:pipelineId',
        builder: (_, state) => Scaffold(
          body: Text('Pipeline ${state.pathParameters['pipelineId']}'),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (ref) async => repository,
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
  return repository;
}

void main() {
  testWidgets('filters active schedules and opens detail on mobile', (
    tester,
  ) async {
    final repository = await _pump(tester, const Size(390, 844));
    await tester.tap(
      find.ancestor(
        of: find.text('Active').first,
        matching: find.byType(ChoiceChip),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.requestedActive, true);
    await tester.tap(find.text('Nightly build'));
    await tester.pumpAndSettle();
    expect(find.text('Run now'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit schedule'));
    await tester.pumpAndSettle();
    expect(find.text('Nightly build').last, findsOneWidget);
    expect(find.widgetWithText(TextFormField, '0 1 * * *'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run now'));
    await tester.pumpAndSettle();
    expect(repository.playCount, 1);
  });

  testWidgets('shows linked last pipeline on wide screen', (tester) async {
    await _pump(tester, const Size(1200, 800));
    await tester.tap(find.text('Nightly build'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Pipeline #332'));
    await tester.pumpAndSettle();
    expect(find.text('Pipeline 332'), findsOneWidget);
  });
}
