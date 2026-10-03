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
  final sources = <PipelineSourceFilter?>[];
  final refs = <String?>[];
  final calls = <PipelineStatusFilter?>[];
  Completer<Paginated<Pipeline>>? pending;
  bool fail = false;
  bool paginate = false;
  final requests = <({int page, PipelineStatusFilter? status})>[];
  final pendingPages =
      <(PipelineSourceFilter?, int), Completer<Paginated<Pipeline>>>{};
  @override
  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    PipelineStatusFilter? status,
    String? ref,
    PipelineSourceFilter? source,
  }) async {
    calls.add(status);
    refs.add(ref);
    sources.add(source);
    requests.add((page: page, status: status));
    if (pendingPages[(source, page)] case final request?) return request.future;
    if (pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('Private server response');
    if (paginate) {
      return Paginated(
        items: [
          Pipeline(
            id: page == 1 ? 33 : 32,
            status: status?.name ?? 'scheduled',
            ref: ref ?? 'main',
            source: source?.apiValue ?? 'push',
          ),
        ],
        nextPage: page == 1 ? 4 : null,
      );
    }
    return const Paginated(items: []);
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  bool dark = false,
  Locale locale = const Locale('en'),
  bool settle = true,
}) async {
  tester.view.physicalSize = Size(width, 900);
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
        home: const PipelinesScreen(projectId: 7),
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
  await tester.tap(
    find.byWidgetPredicate(
      (widget) => widget is FilterMenuChip<({PipelineStatusFilter? status})>,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  final option = find.ancestor(
    of: find.text(label).last,
    matching: find.byWidgetPredicate(
      (widget) => widget is CheckedPopupMenuItem,
    ),
  );
  await tester.ensureVisible(option);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _chooseSource(
  WidgetTester tester,
  String label, {
  bool settle = true,
}) async {
  final chip = find.byKey(const ValueKey('pipeline-source-filter'));
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  final option = find.ancestor(
    of: find.text(label).last,
    matching: find.byWidgetPredicate(
      (widget) => widget is CheckedPopupMenuItem,
    ),
  );
  await tester.ensureVisible(option);
  await tester.tap(option);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets(
    'source combines with status and ref; clearing source preserves both',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      await _choose(tester, 'Failed');
      await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'release/v1');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      await _chooseSource(tester, 'Child pipelines');
      expect(repository.sources.last, PipelineSourceFilter.parentPipeline);
      expect(repository.calls.last, PipelineStatusFilter.failed);
      expect(repository.refs.last, 'release/v1');
      expect(
        find.text('Child pipeline discovery requires GitLab 17.0 or later.'),
        findsOneWidget,
      );
      await _chooseSource(tester, 'All top-level sources');
      expect(repository.sources.last, isNull);
      expect(repository.calls.last, PipelineStatusFilter.failed);
      expect(repository.refs.last, 'release/v1');
      expect(
        find.text('Child pipeline discovery requires GitLab 17.0 or later.'),
        findsNothing,
      );
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets(
          'child selection and clearing at $width in $locale dark=$dark',
          (tester) async {
            final repository = _Repository();
            await _pump(
              tester,
              repository,
              width: width,
              locale: Locale(locale),
              dark: dark,
            );
            final l10n = AppLocalizations.of(
              tester.element(find.byType(PipelinesScreen)),
            );
            await _chooseSource(tester, l10n.pipelinesSourceChild);
            expect(
              repository.sources.last,
              PipelineSourceFilter.parentPipeline,
            );
            expect(find.text(l10n.pipelinesChildHint), findsOneWidget);
            expect(find.text(l10n.pipelinesFilteredEmpty), findsOneWidget);
            final bounds = tester.getRect(
              find.byKey(const ValueKey('pipeline-source-filter')),
            );
            expect(
              bounds.height,
              greaterThanOrEqualTo(LabFoxSpacing.minTouchTarget),
            );
            expect(tester.takeException(), isNull);
            tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 900);
            await tester.pumpAndSettle();
            expect(repository.sources.length, 2);
            await _chooseSource(tester, l10n.pipelinesSourceAll);
            expect(repository.sources.last, isNull);
            expect(find.text(l10n.pipelinesEmpty), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets('source remains available while loading and after errors', (
    tester,
  ) async {
    final repository = _Repository()..pending = Completer();
    final pending = repository.pending!;
    await _pump(tester, repository, settle: false);
    repository.pending = null;
    await _chooseSource(tester, 'Child pipelines');
    pending.complete(const Paginated(items: []));
    await tester.pumpAndSettle();
    expect(repository.sources, [null, PipelineSourceFilter.parentPipeline]);
    repository.fail = true;
    await _chooseSource(tester, 'Schedule');
    expect(find.text('Private server response'), findsNothing);
    repository.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.sources.last, PipelineSourceFilter.schedule);
  });
  for (final fails in [false, true]) {
    testWidgets('source reset ignores old footer completion failure=$fails', (
      tester,
    ) async {
      final repository = _Repository()..paginate = true;
      await _pump(tester, repository);
      final pending = Completer<Paginated<Pipeline>>();
      repository.pendingPages[(null, 4)] = pending;
      await tester.tap(find.text('Load more'));
      await tester.pump();
      await _chooseSource(tester, 'Child pipelines');
      if (fails) {
        pending.completeError(
          const GitLabForbiddenException('Private server response'),
        );
      } else {
        pending.complete(
          const Paginated(items: [Pipeline(id: 999, status: 'success')]),
        );
      }
      await tester.pumpAndSettle();
      expect(find.text('#999'), findsNothing);
      expect(find.text('Could not load more pipelines.'), findsNothing);
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      expect(find.text('#32'), findsOneWidget);
      expect(repository.sources.last, PipelineSourceFilter.parentPipeline);
    });
  }
  testWidgets('child rows navigate using project and pipeline identifiers', (
    tester,
  ) async {
    final repository = _Repository()..paginate = true;
    String? destination;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const PipelinesScreen(projectId: 7),
        ),
        GoRoute(
          path: '/projects/:projectId/pipelines/:pipelineId',
          builder: (_, state) {
            destination = state.uri.path;
            return Scaffold(body: Text(state.pathParameters['pipelineId']!));
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
    await _chooseSource(tester, 'Child pipelines');
    await tester.tap(find.text('#33'));
    await tester.pumpAndSettle();
    expect(destination, '/projects/7/pipelines/33');
    expect(find.text('33'), findsOneWidget);
  });
}
