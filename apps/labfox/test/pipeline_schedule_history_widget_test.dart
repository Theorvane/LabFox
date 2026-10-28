import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/widgets/pipeline_schedule_history.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends PipelineSchedulesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  bool fail = false;
  bool empty = false;
  Completer<void>? pending;
  final pages = <int>[];
  @override
  Future<Paginated<Pipeline>> listPipelines(
    int projectId,
    int scheduleId, {
    int page = 1,
  }) async {
    expect(projectId, 7);
    expect(scheduleId, 13);
    pages.add(page);
    if (fail) throw StateError('Private server response');
    await pending?.future;
    if (empty) return const Paginated(items: []);
    return Paginated(
      items: [
        Pipeline(
          id: page == 1 ? 332 : 331,
          status: page == 1 ? 'success' : 'failed',
          ref: 'main',
        ),
      ],
      nextPage: page == 1 ? 4 : null,
    );
  }
}

Future<GoRouter> _pump(
  WidgetTester tester,
  _Repository repository, {
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(
        path: '/history',
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(
            child: PipelineScheduleHistory(
              scheduleRef: PipelineScheduleRef(projectId: 7, scheduleId: 13),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/pipelines/:pipelineId',
        builder: (_, state) => Scaffold(
          body: Text(
            'Opened ${state.pathParameters['projectId']}/${state.pathParameters['pipelineId']}',
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
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
  if (settle) await tester.pumpAndSettle();
  return router;
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('history layout and navigation at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        final router = await _pump(
          tester,
          repository,
          size: Size(width, 844),
          brightness: brightness,
        );
        expect(find.text('Execution history'), findsOneWidget);
        expect(find.text('Pipeline #332'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Pipeline #332'));
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          '/projects/7/pipelines/332',
        );
        expect(find.text('Opened 7/332'), findsOneWidget);
      });
    }
  }
  testWidgets(
    'next page failure retains rows, shows localized error and retries',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      repository.fail = true;
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      expect(find.text('Pipeline #332'), findsOneWidget);
      expect(find.text('Could not load execution history.'), findsOneWidget);
      expect(find.textContaining('Private server'), findsNothing);
      repository.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(repository.pages, [1, 4, 4]);
      expect(find.text('Pipeline #331'), findsOneWidget);
      expect(find.text('Load more'), findsNothing);
    },
  );
  testWidgets('initial error is retryable and empty state is explicit', (
    tester,
  ) async {
    final repository = _Repository()..fail = true;
    await _pump(tester, repository);
    expect(find.text('Could not load execution history.'), findsOneWidget);
    repository
      ..fail = false
      ..empty = true;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.pages, [1, 1]);
    expect(
      find.text('No pipelines have run for this schedule yet.'),
      findsOneWidget,
    );
  });
  testWidgets('loading and duplicate load-more blocking', (tester) async {
    final repository = _Repository()..pending = Completer<void>();
    await _pump(tester, repository, settle: false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    repository.pending = Completer<void>();
    await tester.tap(find.text('Load more'));
    await tester.pump();
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
    expect(repository.pages, [1, 4]);
    repository.pending!.complete();
    await tester.pumpAndSettle();
  });
}
