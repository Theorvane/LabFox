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
import 'package:labfox/features/pipelines/presentation/pipelines_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends PipelinesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final pages = <int>[];
  int? failPage;
  bool empty = false;
  bool emptyFirstPage = false;
  Completer<void>? pending;
  int? openedPipelineId;
  @override
  Future<Paginated<Pipeline>> list(int projectId, {int page = 1}) async {
    expectSync(projectId, 7);
    pages.add(page);
    if (page == failPage) throw StateError('Private server response');
    await pending?.future;
    if (empty) return const Paginated(items: []);
    if (emptyFirstPage && page == 1) {
      return const Paginated(items: [], nextPage: 4);
    }
    return Paginated(
      items: [
        Pipeline(
          id: page == 1 ? 332 : 331,
          status: 'skipped',
          ref: page == 1 ? 'main' : 'release',
        ),
      ],
      nextPage: page == 1 ? 4 : null,
    );
  }

  @override
  Future<Pipeline> get({
    required int projectId,
    required int pipelineId,
  }) async {
    expectSync(projectId, 7);
    openedPipelineId = pipelineId;
    return Pipeline(id: pipelineId, status: 'skipped', ref: 'release');
  }

  @override
  Future<List<Job>> jobs({
    required int projectId,
    required int pipelineId,
  }) async => [];
}

Future<GoRouter> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
  bool settle = true,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/pipelines',
    routes: [
      GoRoute(
        path: '/projects/:projectId/pipelines',
        builder: (_, state) => PipelinesScreen(
          projectId: int.parse(state.pathParameters['projectId']!),
        ),
      ),
      GoRoute(
        path: '/projects/:projectId/pipelines/:pipelineId',
        builder: (_, state) => PipelineDetailScreen(
          projectId: int.parse(state.pathParameters['projectId']!),
          pipelineId: int.parse(state.pathParameters['pipelineId']!),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelinesRepositoryProvider.overrideWith((_) async => repository),
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
  testWidgets('empty page with a next-page header still offers load more', (
    tester,
  ) async {
    final repository = _Repository()..emptyFirstPage = true;
    await _pump(tester, repository);
    expect(find.text('No pipelines yet.'), findsOneWidget);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(repository.pages, [1, 4]);
    expect(find.text('#331'), findsOneWidget);
  });
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'loads older pipelines and opens real detail at $width $brightness',
        (tester) async {
          final repository = _Repository();
          final router = await _pump(
            tester,
            repository,
            width: width,
            brightness: brightness,
          );
          await tester.tap(find.text('Load more'));
          await tester.pumpAndSettle();
          expect(repository.pages, [1, 4]);
          expect(find.text('#332'), findsOneWidget);
          expect(find.text('#331'), findsOneWidget);
          expect(find.text('Load more'), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('release'));
          await tester.pumpAndSettle();
          expect(
            router.routerDelegate.currentConfiguration.last.matchedLocation,
            '/projects/7/pipelines/331',
          );
          expect(find.byType(PipelineDetailScreen), findsOneWidget);
          expect(repository.openedPipelineId, 331);
        },
      );
    }
  }
  testWidgets('page failure keeps rows and cursor for retry', (tester) async {
    final repository = _Repository()..failPage = 4;
    await _pump(tester, repository);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('#332'), findsOneWidget);
    expect(find.text('Could not load more pipelines.'), findsOneWidget);
    expect(find.textContaining('Private server'), findsNothing);
    repository.failPage = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.pages, [1, 4, 4]);
    expect(find.text('#331'), findsOneWidget);
  });
  testWidgets('shows loading and blocks duplicate footer requests', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer<void>();
    await _pump(tester, repository, settle: false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    repository.pending = Completer<void>();
    await tester.tap(find.text('Load more'));
    await tester.pump();
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(repository.pages, [1, 4]);
    repository.pending!.complete();
    await tester.pumpAndSettle();
  });
  testWidgets('initial error retries into a refreshable empty list', (
    tester,
  ) async {
    final repository = _Repository()..failPage = 1;
    await _pump(tester, repository);
    expect(find.text('Could not load pipelines.'), findsOneWidget);
    repository
      ..failPage = null
      ..empty = true;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No pipelines yet.'), findsOneWidget);
    repository.empty = false;
    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(repository.pages, [1, 1, 1]);
    expect(find.text('#332'), findsOneWidget);
  });
  testWidgets('refresh rejection is contained in the initial error state', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    repository.failPage = 1;
    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(tester.takeException(), isNull);
    expect(find.text('Could not load pipelines.'), findsOneWidget);
  });
}
