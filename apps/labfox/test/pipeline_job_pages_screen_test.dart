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
  final attempts = <bool>[];
  bool fail = false;
  Completer<Paginated<Job>>? pending;
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
  final pages = <int>[];
  bool emptyFirst = false;
  @override
  Future<Paginated<Job>> jobsPage({
    required int projectId,
    required int pipelineId,
    int page = 1,
    PipelineJobStatusFilter? status,
    bool includeRetried = false,
  }) async {
    calls.add(status);
    attempts.add(includeRetried);
    pages.add(page);
    if (page != 1 && pending != null) return pending!.future;
    if (page != 1 && fail) {
      throw const GitLabForbiddenException('Private server text');
    }
    return switch (page) {
      1 => Paginated(
        items: emptyFirst
            ? const []
            : const [
                Job(
                  id: 902,
                  name: 'latest-job',
                  status: 'failed',
                  stage: 'test',
                ),
              ],
        nextPage: 4,
      ),
      4 => const Paginated(items: [], nextPage: 9),
      _ => const Paginated(
        items: [
          Job(id: 902, name: 'latest-job', status: 'failed', stage: 'test'),
          Job(id: 901, name: 'earlier-job', status: 'failed', stage: 'test'),
        ],
      ),
    };
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

Future<void> _choose(
  WidgetTester tester,
  String label, {
  String key = 'pipeline-job-status-filter',
}) async {
  await tester.tap(find.byKey(ValueKey(key)));
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

Future<void> _more(WidgetTester tester, String label) async {
  final button = find.widgetWithText(OutlinedButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('incremental jobs $locale $width dark=$dark', (
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
          expect(repo.pages, [1]);
          expect(find.text('latest-job'), findsOneWidget);
          expect(find.text('earlier-job'), findsNothing);
          await _choose(tester, l10n.pipelinesStatusFailed);
          await _choose(
            tester,
            l10n.pipelineJobsAttemptsAll,
            key: 'pipeline-job-attempts-filter',
          );
          tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 1000);
          await tester.pumpAndSettle();
          expect(repo.pages, [1, 1, 1]);
          await _more(tester, l10n.pipelinesLoadMore);
          expect(repo.pages.last, 4);
          expect(find.text('latest-job'), findsOneWidget);
          await _more(tester, l10n.pipelinesLoadMore);
          expect(repo.pages, [1, 1, 1, 4, 9]);
          expect(repo.calls.last, PipelineJobStatusFilter.failed);
          expect(repo.attempts.last, true);
          expect(find.text('earlier-job'), findsOneWidget);
          expect(
            find.widgetWithText(OutlinedButton, l10n.pipelinesLoadMore),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'failed continuation preserves rows and retries the exact selected page',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      await _choose(tester, 'Failed');
      await _choose(
        tester,
        'All attempts',
        key: 'pipeline-job-attempts-filter',
      );
      repo.fail = true;
      await _more(tester, 'Load more');
      expect(find.text('latest-job'), findsOneWidget);
      expect(find.text('Could not load more jobs.'), findsOneWidget);
      expect(find.text('Private server text'), findsNothing);
      expect(find.text('No pipeline triggers.'), findsOneWidget);
      repo.fail = false;
      await _more(tester, 'Retry');
      expect(repo.pages, [1, 1, 1, 4, 4]);
      expect(repo.calls.last, PipelineJobStatusFilter.failed);
      expect(repo.attempts.last, true);
    },
  );
  testWidgets(
    'empty initial and continuation pages remain loadable without claiming a complete empty set',
    (tester) async {
      final repo = _Repository()..emptyFirst = true;
      await _pump(tester, repo);
      expect(find.text('This pipeline has no jobs.'), findsNothing);
      await _more(tester, 'Load more');
      expect(repo.pages, [1, 4]);
      await _more(tester, 'Load more');
      expect(find.text('earlier-job'), findsOneWidget);
      expect(repo.pages, [1, 4, 9]);
    },
  );
  testWidgets(
    'real pull refresh resets pagination while retaining both filters',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      await _choose(tester, 'Failed');
      await _choose(
        tester,
        'All attempts',
        key: 'pipeline-job-attempts-filter',
      );
      await _more(tester, 'Load more');
      await _more(tester, 'Load more');
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(repo.pages.last, 1);
      expect(repo.calls.last, PipelineJobStatusFilter.failed);
      expect(repo.attempts.last, true);
      expect(find.text('earlier-job'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Load more'), findsOneWidget);
    },
  );
  testWidgets(
    'pending continuation is disabled and an obsolete error cannot mark a new filter failed',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      repo.pending = Completer();
      final pending = repo.pending!;
      await tester.tap(find.widgetWithText(OutlinedButton, 'Load more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('latest-job'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(find.byType(OutlinedButton).first)
            .onPressed,
        isNull,
      );
      expect(repo.pages, [1, 4]);
      await _choose(tester, 'Failed');
      pending.completeError(const GitLabForbiddenException('obsolete'));
      await tester.pumpAndSettle();
      expect(find.text('Could not load more jobs.'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Load more'), findsOneWidget);
      expect(find.text('latest-job'), findsOneWidget);
    },
  );
  testWidgets(
    'a later page job opens the exact job ID in its current project',
    (tester) async {
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
      await _more(tester, 'Load more');
      await _more(tester, 'Load more');
      await tester.tap(find.text('Job #901'));
      await tester.pumpAndSettle();
      expect(destination, '/projects/7/jobs/901');
    },
  );
}
