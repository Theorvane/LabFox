import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/milestones/data/milestones_repository.dart';
import 'package:labfox/features/milestones/presentation/controllers/milestones_controller.dart';
import 'package:labfox/features/milestones/presentation/milestone_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends MilestonesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  GitLabMilestone current = GitLabMilestone(
    id: 12,
    iid: 3,
    title: '10.0',
    state: 'active',
    description: 'Original scope',
    startDate: DateTime(2026, 10, 1),
    dueDate: DateTime(2026, 10, 31),
  );
  bool rejectUpdate = false;
  int updateCount = 0;
  String? lastTitle;
  String? lastDescription;
  DateTime? lastStartDate;
  DateTime? lastDueDate;
  bool? lastClearStartDate;
  bool? lastClearDueDate;

  @override
  Future<GitLabMilestone> update(
    int projectId,
    int milestoneId, {
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? dueDate,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) async {
    updateCount++;
    expect(projectId, 7);
    expect(milestoneId, 12);
    if (rejectUpdate) throw const GitLabForbiddenException('Forbidden');
    lastTitle = title;
    lastDescription = description;
    lastStartDate = startDate;
    lastDueDate = dueDate;
    lastClearStartDate = clearStartDate;
    lastClearDueDate = clearDueDate;
    current = current.copyWith(
      title: title,
      description: description,
      startDate: startDate,
      dueDate: dueDate,
    );
    return current;
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  bool group = false,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: group
        ? '/groups/8/milestones/12'
        : '/projects/7/milestones/12',
    routes: [
      GoRoute(
        path: '/projects/:id/milestones/:milestoneId',
        builder: (_, _) =>
            const MilestoneDetailScreen(projectId: 7, milestoneId: 12),
      ),
      GoRoute(
        path: '/groups/:id/milestones/:milestoneId',
        builder: (_, _) =>
            const MilestoneDetailScreen.group(groupId: 8, milestoneId: 12),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        milestonesRepositoryProvider.overrideWith((ref) async => repository),
        milestoneDetailProvider.overrideWith(
          (ref, key) async => repository.current,
        ),
        groupMilestoneDetailProvider.overrideWith(
          (ref, key) async => repository.current,
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('rejects blank titles and reversed dates before writing', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        milestonesRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final edit = container.read(
      milestoneEditControllerProvider(
        const MilestoneRef(projectId: 7, milestoneId: 12),
      ).notifier,
    );
    await expectLater(
      edit.save(title: ' ', description: ''),
      throwsA(isA<ArgumentError>()),
    );
    await expectLater(
      edit.save(
        title: '11.0',
        description: '',
        startDate: DateTime(2026, 11, 2),
        dueDate: DateTime(2026, 11, 1),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(repository.updateCount, 0);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('edits a project milestone at width $width', (tester) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.byTooltip('Edit milestone'));
      await tester.pumpAndSettle();
      expect(find.text('Original scope'), findsWidgets);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), '11.0');
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Updated scope',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(repository.lastTitle, '11.0');
      expect(repository.lastDescription, 'Updated scope');
      expect(repository.lastStartDate, DateTime(2026, 10, 1));
      expect(repository.lastDueDate, DateTime(2026, 10, 31));
      expect(find.text('11.0'), findsWidgets);
      expect(
        tester.widget<MarkdownViewer>(find.byType(MarkdownViewer)).data,
        'Updated scope',
      );
    });
  }

  testWidgets('preserves the edit draft after permission denial', (
    tester,
  ) async {
    final repository = _Repository()..rejectUpdate = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Draft');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Could not update the milestone.'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(repository.updateCount, 1);
  });

  testWidgets('validates title and date order before a write', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), ' ');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a milestone title.'), findsOneWidget);
    expect(repository.updateCount, 0);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), '11.0');
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.event_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(
      find.text('Start date must be on or before due date.'),
      findsOneWidget,
    );
    expect(repository.updateCount, 0);
  });

  testWidgets('sends newly selected dates to the repository', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(repository.lastStartDate, DateTime(2026, 10, 5));
  });

  testWidgets('clears only the start date and keeps the due date', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear start date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(repository.lastClearStartDate, isTrue);
    expect(repository.lastClearDueDate, isFalse);
    expect(repository.lastStartDate, isNull);
    expect(repository.lastDueDate, DateTime(2026, 10, 31));
    expect(repository.current.startDate, isNull);
    expect(repository.current.dueDate, DateTime(2026, 10, 31));
  });

  testWidgets('clears only the due date and keeps the start date', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(repository.lastClearStartDate, isFalse);
    expect(repository.lastClearDueDate, isTrue);
    expect(repository.lastStartDate, DateTime(2026, 10, 1));
    expect(repository.lastDueDate, isNull);
    expect(repository.current.startDate, DateTime(2026, 10, 1));
    expect(repository.current.dueDate, isNull);
  });

  testWidgets('does not offer project editing for group milestones', (
    tester,
  ) async {
    await _pump(tester, _Repository(), group: true);
    expect(find.byTooltip('Edit milestone'), findsNothing);
  });
}
