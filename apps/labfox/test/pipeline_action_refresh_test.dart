import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';
import 'package:labfox/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:labfox/features/pipelines/presentation/pipelines_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Analytics implements Analytics {
  final events = <(String, Map<String, Object?>)>[];
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    events.add((name, properties ?? {}));
  }
}

class _Subscribed extends EntitlementController {
  @override
  Entitlement build() => Entitlement.subscribed;
}

class _Repository extends PipelinesRepository {
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
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  String status = 'failed';
  bool reject = false;
  Completer<void>? pending;
  final commands = <String>[];
  final lists = <int, int>{};
  final listStatuses = <int, List<PipelineStatusFilter?>>{};
  final details = <int, int>{};
  final jobLoads = <int, int>{};
  @override
  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    PipelineStatusFilter? status,
    String? ref,
    PipelineSourceFilter? source,
  }) async {
    lists.update(projectId, (value) => value + 1, ifAbsent: () => 1);
    listStatuses.putIfAbsent(projectId, () => []).add(status);
    return Paginated(
      items: [
        if (status == null || status.name == this.status)
          Pipeline(id: 944, status: this.status, ref: 'main'),
      ],
    );
  }

  @override
  Future<Pipeline> get({
    required int projectId,
    required int pipelineId,
  }) async {
    details.update(pipelineId, (value) => value + 1, ifAbsent: () => 1);
    return Pipeline(id: pipelineId, status: status, ref: 'main');
  }

  @override
  Future<List<Job>> jobs({
    required int projectId,
    required int pipelineId,
    PipelineJobStatusFilter? status,
  }) async {
    jobLoads.update(pipelineId, (value) => value + 1, ifAbsent: () => 1);
    return [Job(id: 1, name: 'test', status: this.status)];
  }

  Future<Pipeline> _run(String command, int projectId, int pipelineId) async {
    expectSync(projectId, 7);
    expectSync(pipelineId, 944);
    commands.add(command);
    if (reject) throw const GitLabForbiddenException('Private server response');
    await pending?.future;
    status = command == 'retry' ? 'pending' : 'canceled';
    return Pipeline(id: pipelineId, status: status);
  }

  @override
  Future<Pipeline> retry({required int projectId, required int pipelineId}) =>
      _run('retry', projectId, pipelineId);
  @override
  Future<Pipeline> cancel({required int projectId, required int pipelineId}) =>
      _run('cancel', projectId, pipelineId);
}

void main() {
  const key = PipelineRef(projectId: 7, pipelineId: 944);
  const otherKey = PipelineRef(projectId: 8, pipelineId: 945);
  final action = pipelineActionsControllerProvider(key);
  late _Repository repository;
  late _Analytics analytics;
  late ProviderContainer container;
  setUp(() {
    repository = _Repository();
    analytics = _Analytics();
    container = ProviderContainer(
      overrides: [
        pipelinesRepositoryProvider.overrideWith((_) async => repository),
        analyticsProvider.overrideWithValue(analytics),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> watchViews() async {
    for (final projectId in [7, 8]) {
      container.listen(pipelinesControllerProvider(projectId), (_, _) {});
    }
    for (final ref in [key, otherKey]) {
      container.listen(pipelineDetailProvider(ref), (_, _) {});
      container.listen(pipelineJobsControllerProvider(ref), (_, _) {});
    }
    await Future.wait([
      for (final projectId in [7, 8])
        container.read(pipelinesControllerProvider(projectId).future),
      for (final ref in [key, otherKey])
        container.read(pipelineDetailProvider(ref).future),
      for (final ref in [key, otherKey])
        container.read(pipelineJobsControllerProvider(ref).future),
    ]);
  }

  for (final command in ['retry', 'cancel']) {
    test(
      '$command refreshes only affected project, detail and jobs after success',
      () async {
        await watchViews();
        final controller = container.read(action.notifier);
        await container.read(action.future);
        await (command == 'retry' ? controller.retry() : controller.cancel());
        await Future.wait([
          container.read(pipelinesControllerProvider(7).future),
          container.read(pipelineDetailProvider(key).future),
          container.read(pipelineJobsControllerProvider(key).future),
        ]);
        expect(repository.lists, {7: 2, 8: 1});
        expect(repository.details, {944: 2, 945: 1});
        expect(repository.jobLoads, {944: 2, 945: 1});
        expect(
          container
              .read(pipelinesControllerProvider(7))
              .requireValue
              .items
              .single
              .status,
          command == 'retry' ? 'pending' : 'canceled',
        );
        expect(analytics.events.map((event) => event.$1), [
          command == 'retry' ? 'pipeline_retried' : 'pipeline_cancelled',
        ]);
        expect(analytics.events.single.$2, isEmpty);
        expect(container.read(action).hasError, false);
      },
    );
    test('$command retains the filtered project view after success', () async {
      container.read(pipelineStatusFilterProvider(7).notifier).state =
          PipelineStatusFilter.failed;
      await watchViews();
      final controller = container.read(action.notifier);
      await container.read(action.future);
      await (command == 'retry' ? controller.retry() : controller.cancel());
      final updated = await container.read(
        pipelinesControllerProvider(7).future,
      );
      expect(updated.items, isEmpty);
      expect(
        container.read(pipelineStatusFilterProvider(7)),
        PipelineStatusFilter.failed,
      );
      expect(repository.listStatuses[7], [
        PipelineStatusFilter.failed,
        PipelineStatusFilter.failed,
      ]);
      expect(repository.listStatuses[8], [null]);
    });
    test(
      'rejected $command preserves views and supports a real retry',
      () async {
        await watchViews();
        final controller = container.read(action.notifier);
        await container.read(action.future);
        repository.reject = true;
        await expectLater(
          command == 'retry' ? controller.retry() : controller.cancel(),
          throwsA(isA<GitLabForbiddenException>()),
        );
        expect(repository.lists, {7: 1, 8: 1});
        expect(repository.details, {944: 1, 945: 1});
        expect(repository.jobLoads, {944: 1, 945: 1});
        expect(analytics.events, isEmpty);
        expect(container.read(action).hasError, true);
        repository.reject = false;
        await (command == 'retry' ? controller.retry() : controller.cancel());
        expect(repository.commands, [command, command]);
        expect(container.read(action).hasError, false);
      },
    );
  }
  test(
    'blocks duplicate and opposite commands before repository resolution',
    () async {
      final resolver = Completer<PipelinesRepository?>();
      container.dispose();
      container = ProviderContainer(
        overrides: [
          pipelinesRepositoryProvider.overrideWith((_) => resolver.future),
          analyticsProvider.overrideWithValue(analytics),
        ],
      );
      final controller = container.read(action.notifier);
      await container.read(action.future);
      final first = controller.retry();
      final busy = container.read(action).isLoading;
      final duplicate = controller.retry();
      final opposite = controller.cancel();
      resolver.complete(repository);
      await Future.wait([first, duplicate, opposite]);
      expect(busy, true);
      expect(repository.commands, ['retry']);
      expect(analytics.events.length, 1);
    },
  );
  test(
    'a command can run immediately without awaiting provider initialization',
    () async {
      await container.read(action.notifier).retry();
      expect(repository.commands, ['retry']);
    },
  );
  test('repository resolution failure is captured in action state', () async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        pipelinesRepositoryProvider.overrideWith(
          (_) async => throw const GitLabAuthException('Rejected'),
        ),
        analyticsProvider.overrideWithValue(analytics),
      ],
    );
    final controller = container.read(action.notifier);
    await container.read(action.future);
    await expectLater(controller.retry(), throwsA(isA<GitLabAuthException>()));
    expect(container.read(action).hasError, true);
    expect(repository.commands, isEmpty);
    expect(analytics.events, isEmpty);
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    double width = 390,
    Brightness brightness = Brightness.light,
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
          analyticsProvider.overrideWithValue(analytics),
          entitlementProvider.overrideWith(_Subscribed.new),
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
    await tester.tap(find.text('main'));
    await tester.pumpAndSettle();
    return router;
  }

  for (final command in ['retry', 'cancel']) {
    for (final width in [320.0, 390.0, 1200.0]) {
      for (final brightness in Brightness.values) {
        testWidgets(
          '$command updates list after returning from detail at $width $brightness',
          (tester) async {
            repository.status = command == 'retry' ? 'failed' : 'running';
            final router = await pumpScreen(
              tester,
              width: width,
              brightness: brightness,
            );
            await tester.tap(
              find.widgetWithText(
                OutlinedButton,
                command == 'retry' ? 'Retry' : 'Cancel',
              ),
            );
            await tester.pumpAndSettle();
            expect(repository.commands, [command]);
            expect(repository.lists[7], 2);
            expect(repository.details[944], 2);
            expect(repository.jobLoads[944], 2);
            expect(tester.takeException(), isNull);
            router.pop();
            await tester.pumpAndSettle();
            expect(
              router.routerDelegate.currentConfiguration.last.matchedLocation,
              '/projects/7/pipelines',
            );
            expect(find.byType(PipelinesScreen), findsOneWidget);
            expect(
              find.text(command == 'retry' ? 'Pending' : 'Canceled'),
              findsOneWidget,
            );
          },
        );
      }
    }
    testWidgets('rejected $command keeps button usable for a real retry', (
      tester,
    ) async {
      repository.status = command == 'retry' ? 'failed' : 'running';
      await pumpScreen(tester);
      repository.reject = true;
      final button = find.widgetWithText(
        OutlinedButton,
        command == 'retry' ? 'Retry' : 'Cancel',
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(
        find.text('You do not have permission for this action.'),
        findsOneWidget,
      );
      expect(find.textContaining('Private server'), findsNothing);
      expect(tester.widget<OutlinedButton>(button).onPressed, isNotNull);
      expect(repository.lists[7], 1);
      expect(analytics.events, isEmpty);
      repository.reject = false;
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(repository.commands, [command, command]);
      expect(repository.lists[7], 2);
    });
    testWidgets('$command is disabled while its server request is pending', (
      tester,
    ) async {
      repository.status = command == 'retry' ? 'failed' : 'running';
      await pumpScreen(tester);
      repository.pending = Completer<void>();
      final button = find.widgetWithText(
        OutlinedButton,
        command == 'retry' ? 'Retry' : 'Cancel',
      );
      await tester.tap(button);
      await tester.pump();
      expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
      expect(repository.commands, [command]);
      expect(repository.lists[7], 1);
      repository.pending!.complete();
      await tester.pumpAndSettle();
      expect(repository.lists[7], 2);
    });
  }
}
