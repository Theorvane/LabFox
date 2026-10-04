import 'dart:async';
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
  final calls = <PipelineJobStatusFilter?>[];
  bool fail = false;
  bool empty = false;
  Completer<List<Job>>? pending;
  @override
  Future<PipelineUpstream?> upstream({
    required int projectId,
    required int pipelineId,
  }) async => null;
  @override
  Future<Paginated<PipelineTriggerJob>> triggerJobs({
    required int projectId,
    required int pipelineId,
    int page = 1,
  }) async => const Paginated(items: []);
  @override
  Future<Pipeline> get({
    required int projectId,
    required int pipelineId,
  }) async => Pipeline(id: pipelineId, status: 'skipped', ref: 'main');
  @override
  Future<List<Job>> jobs({
    required int projectId,
    required int pipelineId,
    PipelineJobStatusFilter? status,
  }) async {
    calls.add(status);
    if (pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('Private server text');
    if (empty) return [];
    return status == null
        ? const [
            Job(id: 1, name: 'compile', status: 'success', stage: 'build'),
            Job(id: 2, name: 'failed-job', status: 'failed', stage: 'test'),
            Job(
              id: 3,
              name: 'callback-job',
              status: 'waiting_for_callback',
              stage: 'deploy',
            ),
          ]
        : [
            Job(
              id: 2,
              name: '${status.name}-job',
              status: status.name,
              stage: 'test',
            ),
          ];
  }
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
        theme: ThemeData(
          brightness: dark ? Brightness.dark : Brightness.light,
          platform: platform,
        ),
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

Future<void> _choose(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const ValueKey('pipeline-job-status-filter')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  final option = find.ancestor(
    of: find.text(label).last,
    matching: find.byWidgetPredicate((w) => w is CheckedPopupMenuItem),
  );
  await tester.ensureVisible(option);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('job filter at $width in $locale dark=$dark', (
          tester,
        ) async {
          final repo = _Repository();
          await _pump(
            tester,
            repo,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(PipelineDetailScreen)),
          );
          await _choose(tester, l10n.pipelinesStatusFailed);
          expect(repo.calls, [null, PipelineJobStatusFilter.failed]);
          expect(find.text('failed-job'), findsOneWidget);
          expect(find.text('compile'), findsNothing);
          expect(tester.takeException(), isNull);
          tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 1000);
          await tester.pumpAndSettle();
          expect(repo.calls.length, 2);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'filtered failure can retry without clearing the status or hiding relationships',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      repo.fail = true;
      await _choose(tester, 'Failed');
      expect(find.text('Could not load jobs.'), findsOneWidget);
      expect(find.text('Private server text'), findsNothing);
      expect(find.text('No pipeline triggers.'), findsOneWidget);
      expect(find.text('No upstream pipeline available.'), findsOneWidget);
      repo.fail = false;
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();
      expect(repo.calls, [
        null,
        PipelineJobStatusFilter.failed,
        PipelineJobStatusFilter.failed,
      ]);
      expect(find.text('failed-job'), findsOneWidget);
    },
  );
  testWidgets(
    'filtered empty refresh retains scope and clear restores all server statuses',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      repo.empty = true;
      await _choose(tester, 'Failed');
      expect(find.text('No jobs match this status.'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(repo.calls, [
        null,
        PipelineJobStatusFilter.failed,
        PipelineJobStatusFilter.failed,
      ]);
      repo.empty = false;
      await _choose(tester, 'All job statuses');
      expect(repo.calls.last, isNull);
      expect(find.text('compile'), findsOneWidget);
      expect(find.text('callback-job'), findsOneWidget);
    },
  );
  testWidgets(
    'all eight choices are available and menu cancellation keeps scope',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      for (final entry in [
        ('Created', PipelineJobStatusFilter.created),
        ('Pending', PipelineJobStatusFilter.pending),
        ('Running', PipelineJobStatusFilter.running),
        ('Success', PipelineJobStatusFilter.success),
        ('Failed', PipelineJobStatusFilter.failed),
        ('Canceled', PipelineJobStatusFilter.canceled),
        ('Skipped', PipelineJobStatusFilter.skipped),
        ('Manual', PipelineJobStatusFilter.manual),
      ]) {
        await _choose(tester, entry.$1);
        expect(repo.calls.last, entry.$2);
      }
      final count = repo.calls.length;
      await tester.tap(
        find.byKey(const ValueKey('pipeline-job-status-filter')),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(repo.calls.length, count);
      expect(repo.calls.last, PipelineJobStatusFilter.manual);
    },
  );
  testWidgets('filtered job navigation uses the job ID and current project', (
    tester,
  ) async {
    final repo = _Repository();
    String? destination;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const PipelineDetailScreen(projectId: 7, pipelineId: 944),
        ),
        GoRoute(
          path: '/projects/:projectId/jobs/:jobId',
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
          pipelinesRepositoryProvider.overrideWith((_) async => repo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _choose(tester, 'Failed');
    await tester.tap(find.text('failed-job'));
    await tester.pumpAndSettle();
    expect(destination, '/projects/7/jobs/2');
  });
  testWidgets(
    'refresh loading hides cached filtered rows until the new request completes',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      await _choose(tester, 'Failed');
      repo.pending = Completer();
      final pending = repo.pending!;
      unawaited(
        tester
            .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
            .show(),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('failed-job'), findsNothing);
      pending.complete(const [
        Job(id: 4, name: 'fresh-job', status: 'failed', stage: 'test'),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('fresh-job'), findsOneWidget);
      expect(repo.calls.last, PipelineJobStatusFilter.failed);
    },
  );
}
