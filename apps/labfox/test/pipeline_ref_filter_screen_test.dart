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
  final refs = <String?>[];
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
    refs.add(ref);
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
  testWidgets(
    'draft and cancellation do not fetch; apply and clear preserve status',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      await _choose(tester, 'Failed');
      await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'release/v1+fix');
      expect(repository.refs, [null, null]);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.refs, [null, null]);
      await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'release/v1+fix');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(repository.refs.last, 'release/v1+fix');
      expect(repository.calls.last, PipelineStatusFilter.failed);
      expect(find.text('Ref: release/v1+fix'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'release/v1+fix',
      );
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(repository.refs.last, isNull);
      expect(repository.calls.last, PipelineStatusFilter.failed);
    },
  );

  testWidgets('keyboard submit applies exact input; empty submit removes it', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    for (final text in ['feature/a+b', '']) {
      await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), text);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(repository.refs.last, text.isEmpty ? null : text);
    }
    expect(find.text('No pipelines yet.'), findsOneWidget);
  });
  testWidgets('a failed filtered request can be retried and cleared', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    repository.fail = true;
    await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'release/v1');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Private server response'), findsNothing);
    repository.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.refs.last, 'release/v1');
    await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(repository.refs.last, isNull);
  });
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [320.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('ref dialog works at $width in $locale dark=$dark', (
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
            tester.element(find.byType(PipelinesScreen)),
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('pipeline-ref-filter')),
          );
          await tester.tap(find.byKey(const ValueKey('pipeline-ref-filter')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byType(TextField),
            'release/very-long-branch-name-with-slashes/and+symbols',
          );
          await tester.tap(find.text(l10n.pipelinesRefApply));
          await tester.pumpAndSettle();
          expect(
            repository.refs.last,
            'release/very-long-branch-name-with-slashes/and+symbols',
          );
          expect(find.text(l10n.pipelinesFilteredEmpty), findsOneWidget);
          expect(tester.takeException(), isNull);
          tester.view.physicalSize = Size(width == 320 ? 1200 : 320, 900);
          await tester.pumpAndSettle();
          expect(repository.refs.length, 2);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
