import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
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
  final calls = <PipelineStatusFilter?>[];
  Completer<Paginated<Pipeline>>? pending;
  bool fail = false;
  bool paginate = false;
  final requests = <({int page, PipelineStatusFilter? status})>[];
  final pendingPages =
      <(PipelineStatusFilter?, int), Completer<Paginated<Pipeline>>>{};
  @override
  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    PipelineStatusFilter? status,
    String? ref,
    PipelineSourceFilter? source,
  }) async {
    calls.add(status);
    requests.add((page: page, status: status));
    if (pendingPages[(status, page)] case final request?) return request.future;
    if (pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('Private server response');
    if (paginate) {
      return Paginated(
        items: [
          Pipeline(
            id: page == 1 ? 33 : 32,
            status: status?.name ?? 'scheduled',
            ref: 'main',
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

void main() {
  for (final failOldPage in [false, true]) {
    testWidgets(
      'changing filters clears pagination busy state and ignores old page failure=$failOldPage',
      (tester) async {
        final repository = _Repository()..paginate = true;
        await _pump(tester, repository);
        final pending = Completer<Paginated<Pipeline>>();
        repository.pendingPages[(null, 4)] = pending;
        await tester.tap(find.text('Load more'));
        await tester.pump();
        await _choose(tester, 'Failed');
        if (failOldPage) {
          pending.completeError(
            const GitLabForbiddenException('Private server response'),
          );
        } else {
          pending.complete(
            const Paginated(items: [Pipeline(id: 999, status: 'scheduled')]),
          );
        }
        await tester.pumpAndSettle();
        expect(find.text('#999'), findsNothing);
        expect(find.text('Could not load more pipelines.'), findsNothing);
        expect(find.text('Retry'), findsNothing);
        await tester.tap(find.text('Load more'));
        await tester.pumpAndSettle();
        expect(find.text('#32'), findsOneWidget);
        expect(repository.requests, [
          (page: 1, status: null),
          (page: 4, status: null),
          (page: 1, status: PipelineStatusFilter.failed),
          (page: 4, status: PipelineStatusFilter.failed),
        ]);
      },
    );
  }

  for (final locale in AppLocalizations.supportedLocales) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('selects and clears at $width dark=$dark locale=$locale', (
          tester,
        ) async {
          final repository = _Repository();
          await _pump(
            tester,
            repository,
            width: width,
            dark: dark,
            locale: locale,
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(PipelinesScreen)),
          );
          final chip = find.byWidgetPredicate(
            (widget) =>
                widget is FilterMenuChip<({PipelineStatusFilter? status})>,
          );
          final bounds = tester.getRect(chip);
          expect(bounds.left, greaterThanOrEqualTo(0));
          expect(bounds.right, lessThanOrEqualTo(width));
          expect(
            bounds.height,
            greaterThanOrEqualTo(LabFoxSpacing.minTouchTarget),
          );
          await _choose(tester, l10n.pipelinesStatusFailed);
          expect(repository.calls.last, PipelineStatusFilter.failed);
          expect(find.text(l10n.pipelinesFilteredEmpty), findsOneWidget);
          await _choose(tester, l10n.pipelinesStatusAll);
          expect(repository.calls.last, isNull);
          expect(find.text(l10n.pipelinesEmpty), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('filter remains available while loading', (tester) async {
    final pending = Completer<Paginated<Pipeline>>();
    final repository = _Repository()..pending = pending;
    await _pump(tester, repository, settle: false);
    expect(find.text('All statuses'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is FilterMenuChip<({PipelineStatusFilter? status})>,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final option = find.ancestor(
      of: find.text('Running'),
      matching: find.byWidgetPredicate(
        (widget) => widget is CheckedPopupMenuItem,
      ),
    );
    await tester.tap(option);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.calls, [null, PipelineStatusFilter.running]);
    expect(find.text('Running'), findsOneWidget);
    repository.pending = null;
    pending.complete(const Paginated(items: []));
    await tester.pumpAndSettle();
    expect(find.text('No pipelines match these filters.'), findsOneWidget);
  });

  testWidgets('resizing retains the selected status and does not refetch', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await _choose(tester, 'Failed');
    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();
    expect(find.text('Failed'), findsOneWidget);
    expect(repository.calls, [null, PipelineStatusFilter.failed]);
    expect(find.text('No pipelines match these filters.'), findsOneWidget);
  });

  testWidgets(
    'the localized filter stays usable in empty and failed states and clearing retries',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      expect(find.text('All statuses'), findsOneWidget);
      expect(find.text('No pipelines yet.'), findsOneWidget);
      await _choose(tester, 'Failed');
      expect(repository.calls, [null, PipelineStatusFilter.failed]);
      expect(find.text('No pipelines match these filters.'), findsOneWidget);
      repository.fail = true;
      final context = tester.element(find.byType(PipelinesScreen));
      final container = ProviderScope.containerOf(context);
      container.invalidate(pipelinesControllerProvider(7));
      await tester.pumpAndSettle();
      expect(find.text('Could not load pipelines.'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Private server response'), findsNothing);
      repository.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(repository.calls.last, PipelineStatusFilter.failed);
      await _choose(tester, 'All statuses');
      expect(repository.calls.last, isNull);
      expect(find.text('No pipelines yet.'), findsOneWidget);
    },
  );
}
