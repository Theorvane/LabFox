import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/releases/data/releases_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';
import 'package:labfox/features/releases/presentation/widgets/release_milestone_picker_dialog.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends ReleasesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final requests = <({String search, int page})>[];
  bool rejectFirst = false;
  bool rejectMore = false;
  Completer<void>? pendingPage;
  @override
  Future<Paginated<GitLabMilestone>> listMilestones(
    int projectId, {
    String search = '',
    int page = 1,
  }) async {
    expect(projectId, 7);
    requests.add((search: search, page: page));
    if (page == 4 && pendingPage != null) await pendingPage!.future;
    if (rejectFirst || (rejectMore && page == 4)) {
      throw const GitLabForbiddenException('Forbidden');
    }
    if (search == 'missing') return const Paginated(items: []);
    if (page == 4 || search == 'Sprint') {
      return const Paginated(
        items: [
          GitLabMilestone(
            id: 99,
            iid: 2,
            projectId: 7,
            title: 'Sprint 2',
            state: 'closed',
          ),
        ],
      );
    }
    return const Paginated(
      items: [
        GitLabMilestone(
          id: 55,
          iid: 1,
          projectId: 7,
          title: 'Release, phase 1',
          state: 'active',
        ),
      ],
      nextPage: 4,
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository,
  ValueChanged<List<String>?> result, {
  double width = 390,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result(
                await showDialog<List<String>>(
                  context: context,
                  builder: (_) => const ReleaseMilestonePickerDialog(
                    projectId: 7,
                    selectedTitles: ['Existing'],
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('late pagination cannot replace a newer search', (tester) async {
    final pending = Completer<void>();
    final repository = _Repository()..pendingPage = pending;
    await _pump(tester, repository, (_) {});
    await tester.tap(find.text('Load more milestones'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Sprint');
    await tester.tap(find.byTooltip('Search project milestones'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(CheckboxListTile, 'Release, phase 1'),
      findsNothing,
    );
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxListTile, 'Sprint 2'), findsOneWidget);
    expect(
      find.widgetWithText(CheckboxListTile, 'Release, phase 1'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('selection persists through search at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository();
        List<String>? result;
        await _pump(
          tester,
          repository,
          (value) => result = value,
          width: width,
          brightness: brightness,
        );
        await tester.tap(
          find.widgetWithText(CheckboxListTile, 'Release, phase 1'),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), ' Sprint ');
        await tester.tap(find.byTooltip('Search project milestones'));
        await tester.pumpAndSettle();
        expect(repository.requests.last, (search: 'Sprint', page: 1));
        await tester.tap(find.widgetWithText(CheckboxListTile, 'Sprint 2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Use milestones'));
        await tester.pumpAndSettle();
        expect(result, ['Existing', 'Release, phase 1', 'Sprint 2']);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('header page retry retains loaded rows and selection', (
    tester,
  ) async {
    final repository = _Repository()..rejectMore = true;
    List<String>? result;
    await _pump(tester, repository, (value) => result = value);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Release, phase 1'));
    await tester.tap(find.text('Load more milestones'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(CheckboxListTile, 'Release, phase 1'),
      findsOneWidget,
    );
    expect(find.text('Could not load milestones.'), findsOneWidget);
    repository.rejectMore = false;
    await tester.tap(find.text('Load more milestones'));
    await tester.pumpAndSettle();
    expect(repository.requests.last.page, 4);
    expect(find.widgetWithText(CheckboxListTile, 'Sprint 2'), findsOneWidget);
    await tester.tap(find.text('Use milestones'));
    await tester.pumpAndSettle();
    expect(result, ['Existing', 'Release, phase 1']);
  });
  testWidgets('first page retry, empty search, deselection and cancel', (
    tester,
  ) async {
    final repository = _Repository()..rejectFirst = true;
    List<String>? result = ['Sentinel'];
    await _pump(tester, repository, (value) => result = value);
    expect(find.text('Could not load milestones.'), findsOneWidget);
    repository.rejectFirst = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.tap(find.byTooltip('Search project milestones'));
    await tester.pumpAndSettle();
    expect(find.text('No project milestones found.'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove milestone Existing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
