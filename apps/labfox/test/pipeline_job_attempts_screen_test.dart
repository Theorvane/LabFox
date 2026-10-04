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
    bool includeRetried = false,
  }) async {
    calls.add(status);
    attempts.add(includeRetried);
    if (pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('Private server text');
    if (empty) return [];
    return [
      const Job(id: 902, name: 'verify-job', status: 'failed', stage: 'test'),
      if (includeRetried)
        const Job(id: 901, name: 'verify-job', status: 'failed', stage: 'test'),
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

const labels = {
  'en': (latest: 'Latest jobs', all: 'All attempts', old: 'Job #901'),
  'ko': (latest: '최신 작업', all: '모든 실행 이력', old: '작업 #901'),
  'ja': (latest: '最新のジョブ', all: 'すべての実行履歴', old: 'ジョブ #901'),
  'hi': (latest: 'नवीनतम जॉब', all: 'सभी प्रयास', old: 'जॉब #901'),
  'zh': (latest: '最新作业', all: '所有尝试', old: '作业 #901'),
};
void main() {
  for (final locale in labels.keys) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('attempt browsing $locale $width dark=$dark', (
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
          expect(find.text(labels[locale]!.latest), findsOneWidget);
          expect(find.text('verify-job'), findsOneWidget);
          await _choose(
            tester,
            labels[locale]!.all,
            key: 'pipeline-job-attempts-filter',
          );
          expect(repo.attempts, [false, true]);
          expect(find.text('verify-job'), findsNWidgets(2));
          expect(find.text(labels[locale]!.old), findsOneWidget);
          final l10n = AppLocalizations.of(
            tester.element(find.byType(PipelineDetailScreen)),
          );
          await _choose(tester, l10n.pipelinesStatusFailed);
          expect(repo.attempts.last, true);
          expect(repo.calls.last, PipelineJobStatusFilter.failed);
          tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 1000);
          await tester.pumpAndSettle();
          expect(repo.attempts.length, 3);
          expect(tester.takeException(), isNull);
          await _choose(
            tester,
            labels[locale]!.latest,
            key: 'pipeline-job-attempts-filter',
          );
          expect(repo.calls.last, PipelineJobStatusFilter.failed);
          expect(repo.attempts.last, false);
          expect(find.text('verify-job'), findsOneWidget);
        });
      }
    }
  }
  testWidgets(
    'all attempts failure retries combined selection without private errors',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      await _choose(tester, 'Failed');
      repo.fail = true;
      await _choose(
        tester,
        'All attempts',
        key: 'pipeline-job-attempts-filter',
      );
      expect(find.text('Could not load jobs.'), findsOneWidget);
      expect(find.text('Private server text'), findsNothing);
      expect(find.text('No pipeline triggers.'), findsOneWidget);
      repo.fail = false;
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();
      expect(repo.attempts, [false, false, true, true]);
      expect(repo.calls.last, PipelineJobStatusFilter.failed);
      expect(find.text('verify-job'), findsNWidgets(2));
    },
  );
  testWidgets(
    'empty attempts refresh and clearing status retain attempt visibility',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      await _choose(tester, 'Failed');
      repo.empty = true;
      await _choose(
        tester,
        'All attempts',
        key: 'pipeline-job-attempts-filter',
      );
      expect(find.text('No jobs match this status.'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(repo.attempts, [false, false, true, true]);
      expect(repo.calls.last, PipelineJobStatusFilter.failed);
      repo.empty = false;
      await _choose(tester, 'All job statuses');
      expect(repo.calls.last, isNull);
      expect(repo.attempts.last, true);
      expect(find.text('verify-job'), findsNWidgets(2));
    },
  );
  testWidgets(
    'attempt menu dismissal preserves selection without extra requests',
    (tester) async {
      final repo = _Repository();
      await _pump(tester, repo);
      await _choose(
        tester,
        'All attempts',
        key: 'pipeline-job-attempts-filter',
      );
      await tester.tap(
        find.byKey(const ValueKey('pipeline-job-attempts-filter')),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(repo.attempts, [false, true]);
      expect(find.text('All attempts'), findsOneWidget);
    },
  );
  testWidgets('identical jobs open the exact selected attempt by ID', (
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
    await _choose(tester, 'All attempts', key: 'pipeline-job-attempts-filter');
    await tester.tap(find.text('Job #901'));
    await tester.pumpAndSettle();
    expect(destination, '/projects/7/jobs/901');
  });
  testWidgets('pending attempt selection hides latest-only cached rows', (
    tester,
  ) async {
    final repo = _Repository();
    await _pump(tester, repo);
    repo.pending = Completer();
    final pending = repo.pending!;
    await tester.tap(
      find.byKey(const ValueKey('pipeline-job-attempts-filter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('All attempts').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('verify-job'), findsNothing);
    pending.complete(const [
      Job(id: 902, name: 'verify-job', status: 'failed', stage: 'test'),
      Job(id: 901, name: 'verify-job', status: 'failed', stage: 'test'),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Job #901'), findsOneWidget);
    expect(repo.attempts.last, true);
  });
}
