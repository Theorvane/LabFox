import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';
import 'package:labfox/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends PipelinesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final calls = <int>[];
  bool fail = false;
  bool empty = false;
  int? pendingPage;
  Completer<Paginated<PipelineTriggerJob>>? pending;
  @override
  Future<Paginated<PipelineTriggerJob>> triggerJobs({
    required int projectId,
    required int pipelineId,
    int page = 1,
  }) async {
    calls.add(page);
    if (pending != null && (pendingPage == null || page == pendingPage)) {
      return pending!.future;
    }
    if (fail) throw const GitLabForbiddenException('Private response');
    if (empty) return const Paginated(items: []);
    if (page != 1) {
      return const Paginated(
        items: [
          PipelineTriggerJob(
            id: 12,
            name: 'child-next',
            status: 'success',
            downstreamPipeline: Pipeline(
              id: 34,
              projectId: 7,
              status: 'success',
              ref: 'main',
            ),
          ),
        ],
      );
    }
    return const Paginated(
      items: [
        PipelineTriggerJob(
          id: 10,
          name: 'deploy-release',
          status: 'success',
          stage: 'deploy',
          downstreamPipeline: Pipeline(
            id: 33,
            projectId: 8,
            status: 'running',
            ref: 'release/v1',
            webUrl: 'https://outside.example/unsafe',
          ),
        ),
        PipelineTriggerJob(id: 11, name: 'not-started', status: 'pending'),
        PipelineTriggerJob(
          id: 13,
          name: 'missing-project',
          status: 'success',
          downstreamPipeline: Pipeline(
            id: 35,
            status: 'success',
            webUrl: 'https://outside.example/unsafe',
          ),
        ),
      ],
      nextPage: 4,
    );
  }

  @override
  Future<Pipeline> get({
    required int projectId,
    required int pipelineId,
  }) async => Pipeline(id: pipelineId, status: 'skipped', ref: 'main');
  @override
  Future<List<Job>> jobs({
    required int projectId,
    required int pipelineId,
  }) async => const [
    Job(id: 1, name: 'unit-tests', status: 'success', stage: 'test'),
  ];
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  bool dark = false,
  Locale locale = const Locale('en'),
  bool settle = true,
  TargetPlatform? platform,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelinesRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PipelineDetailScreen(projectId: 7, pipelineId: 944),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('downstream rows at $width in $locale dark=$dark', (
          tester,
        ) async {
          final repository = _Repository();
          await _pump(
            tester,
            repository,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(PipelineDetailScreen)),
          );
          await tester.ensureVisible(find.text(l10n.pipelineDownstreamTitle));
          expect(
            find.text(l10n.pipelineDownstreamTarget(8, 33)),
            findsOneWidget,
          );
          final unavailable = find.widgetWithText(
            WorkTile,
            l10n.pipelineDownstreamUnavailable,
          );
          expect(unavailable, findsNWidgets(2));
          for (final row in tester.widgetList<WorkTile>(unavailable)) {
            expect(row.onTap, isNull);
          }
          expect(tester.takeException(), isNull);
          tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 1000);
          await tester.pumpAndSettle();
          expect(repository.calls, [1]);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'loading and failure do not hide jobs; retry and empty state recover',
    (tester) async {
      final repository = _Repository()..pending = Completer();
      final pending = repository.pending!;
      await _pump(tester, repository, settle: false);
      await tester.pump();
      expect(find.text('unit-tests'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repository.pending = null;
      repository.fail = true;
      pending.completeError(const GitLabForbiddenException('Private response'));
      await tester.pumpAndSettle();
      expect(find.text('unit-tests'), findsOneWidget);
      expect(find.text('Private response'), findsNothing);
      expect(find.text('Could not load downstream pipelines.'), findsOneWidget);
      repository.fail = false;
      repository.empty = true;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No pipeline triggers.'), findsOneWidget);
    },
  );
  testWidgets(
    'failed continuation keeps rows and retries its cursor; refresh reloads page one',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      repository.fail = true;
      await tester.ensureVisible(find.text('Load more'));
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      expect(find.text('deploy-release'), findsOneWidget);
      expect(
        find.text('Could not load more downstream pipelines.'),
        findsOneWidget,
      );
      repository.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('child-next'), findsOneWidget);
      expect(repository.calls, [1, 4, 4]);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(repository.calls, [1, 4, 4, 1]);
    },
  );
  testWidgets(
    'navigates to the downstream project ID rather than the parent or web URL',
    (tester) async {
      final repository = _Repository();
      String? destination;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const PipelineDetailScreen(projectId: 7, pipelineId: 944),
          ),
          GoRoute(
            path: '/projects/:projectId/pipelines/:pipelineId',
            builder: (_, state) {
              destination = state.uri.path;
              return const Scaffold(body: Text('Destination'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pipelinesRepositoryProvider.overrideWith((ref) async => repository),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('deploy-release'));
      await tester.tap(find.text('deploy-release'));
      await tester.pumpAndSettle();
      expect(destination, '/projects/8/pipelines/33');
    },
  );
  for (final fails in [false, true]) {
    testWidgets('refresh isolates stale footer completion failure=$fails', (
      tester,
    ) async {
      final repository = _Repository();
      await _pump(tester, repository);
      final pending = Completer<Paginated<PipelineTriggerJob>>();
      repository.pending = pending;
      repository.pendingPage = 4;
      await tester.ensureVisible(find.text('Load more'));
      await tester.tap(find.text('Load more'));
      await tester.pump();
      repository.pending = null;
      final refresh = tester
          .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
          .show();
      await tester.pumpAndSettle();
      await refresh;
      if (fails) {
        pending.completeError(
          const GitLabForbiddenException('Private response'),
        );
      } else {
        pending.complete(
          const Paginated(
            items: [
              PipelineTriggerJob(
                id: 999,
                name: 'stale-trigger',
                status: 'success',
              ),
            ],
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(find.text('stale-trigger'), findsNothing);
      expect(
        find.text('Could not load more downstream pipelines.'),
        findsNothing,
      );
      await tester.ensureVisible(find.text('Load more'));
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      expect(find.text('child-next'), findsOneWidget);
      expect(repository.calls, [1, 4, 1, 4]);
    });
  }
  testWidgets(
    'an empty downstream list still supports pull to refresh',
    (tester) async {
      final repository = _Repository()..empty = true;
      await _pump(
        tester,
        repository,
        width: 1200,
        platform: TargetPlatform.macOS,
      );
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(repository.calls, [1, 1]);
    },
    variant: const TargetPlatformVariant({TargetPlatform.macOS}),
  );
}
