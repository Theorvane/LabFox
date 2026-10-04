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
  final calls = <PipelineRef>[];
  bool fail = false;
  Completer<PipelineUpstream?>? pending;
  PipelineUpstream? value = const PipelineUpstream(
    id: 'gid://gitlab/Ci::Pipeline/33',
    status: 'RUNNING',
    ref: 'release/v1',
    project: PipelineUpstreamProject(id: 'gid://gitlab/Project/8'),
  );
  @override
  Future<PipelineUpstream?> upstream({
    required int projectId,
    required int pipelineId,
  }) async {
    calls.add(PipelineRef(projectId: projectId, pipelineId: pipelineId));
    if (pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('private server text');
    return value;
  }

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

void main() {
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('upstream at $width in $locale dark=$dark', (tester) async {
          final repo = _Repository();
          await _pump(
            tester,
            repo,
            width: width,
            dark: dark,
            locale: Locale(locale),
          );
          expect(find.text('release/v1'), findsOneWidget);
          expect(find.widgetWithText(WorkTile, 'release/v1'), findsOneWidget);
          expect(tester.takeException(), isNull);
          tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 1000);
          await tester.pumpAndSettle();
          expect(repo.calls.length, 1);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'upstream loading/error retry is independent of regular and downstream jobs',
    (tester) async {
      final repo = _Repository()..pending = Completer();
      final pending = repo.pending!;
      await _pump(tester, repo, settle: false);
      await tester.pump();
      expect(find.text('unit-tests'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repo.pending = null;
      pending.completeError(
        const GitLabForbiddenException('private server text'),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Could not load the upstream pipeline.'),
        findsOneWidget,
      );
      expect(find.text('private server text'), findsNothing);
      expect(find.text('No pipeline triggers.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('release/v1'), findsOneWidget);
      expect(repo.calls.length, 2);
    },
  );
  testWidgets(
    'null upstream describes availability and refresh reloads the relationship',
    (tester) async {
      final repo = _Repository()..value = null;
      await _pump(tester, repo);
      expect(find.text('No upstream pipeline available.'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(repo.calls.length, 2);
    },
  );
  testWidgets(
    'null target project shows metadata without an inferred navigation',
    (tester) async {
      final repo = _Repository()
        ..value = const PipelineUpstream(
          id: 'gid://gitlab/Ci::Pipeline/33',
          status: 'RUNNING',
          ref: 'release/v1',
        );
      await _pump(tester, repo);
      final tile = tester.widget<WorkTile>(
        find.widgetWithText(WorkTile, 'release/v1'),
      );
      expect(tile.onTap, isNull);
      expect(tile.trailing, isNull);
      expect(
        find.text('Upstream pipeline unavailable to open.'),
        findsOneWidget,
      );
    },
  );
  for (final targetProject in [7, 8]) {
    testWidgets(
      'upstream navigation uses project $targetProject and global pipeline ID',
      (tester) async {
        final repo = _Repository()
          ..value = PipelineUpstream(
            id: 'gid://gitlab/Ci::Pipeline/33',
            status: 'RUNNING',
            ref: 'release/v1',
            project: PipelineUpstreamProject(
              id: 'gid://gitlab/Project/$targetProject',
            ),
          );
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
        await tester.tap(find.text('release/v1'));
        await tester.pumpAndSettle();
        expect(destination, '/projects/$targetProject/pipelines/33');
      },
    );
  }
}
