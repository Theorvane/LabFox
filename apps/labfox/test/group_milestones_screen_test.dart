import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/milestones/presentation/controllers/milestones_controller.dart';
import 'package:labfox/features/milestones/presentation/milestone_detail_screen.dart';
import 'package:labfox/features/milestones/presentation/milestones_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _GroupList extends GroupMilestoneListController {
  String? createdTitle;
  String? createdDescription;
  DateTime? createdStartDate;
  DateTime? createdDueDate;
  bool rejectCreate = false;

  @override
  Future<Paginated<GitLabMilestone>> build(GroupMilestoneListRef arg) async =>
      Paginated(
        items: [
          GitLabMilestone(
            id: arg.state == 'active' ? 12 : 13,
            iid: arg.state == 'active' ? 3 : 4,
            groupId: arg.groupId,
            title: arg.state == 'active' ? '10.0' : '9.0',
            state: arg.state,
          ),
        ],
      );

  @override
  Future<GitLabMilestone> create({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    if (rejectCreate) throw const GitLabForbiddenException('Forbidden');
    createdTitle = title;
    createdDescription = description;
    createdStartDate = startDate;
    createdDueDate = dueDate;
    return GitLabMilestone(
      id: 55,
      iid: 9,
      groupId: 7,
      title: title,
      state: 'active',
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  Size size, {
  _GroupList? listController,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/groups/7/milestones',
    routes: [
      GoRoute(
        path: '/groups/:id/milestones',
        builder: (_, state) => MilestonesScreen.group(
          groupId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/groups/:id/milestones/:milestoneId',
        builder: (_, state) => MilestoneDetailScreen.group(
          groupId: int.parse(state.pathParameters['id']!),
          milestoneId: int.parse(state.pathParameters['milestoneId']!),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupMilestoneListControllerProvider.overrideWith(
          () => listController ?? _GroupList(),
        ),
        groupMilestoneDetailProvider.overrideWith(
          (ref, key) async => const GitLabMilestone(
            id: 12,
            iid: 3,
            groupId: 7,
            title: '10.0',
            state: 'active',
            description: '## Group plan',
          ),
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
  testWidgets('filters and opens a group milestone by global ID on mobile', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));
    expect(find.text('10.0'), findsOneWidget);
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(find.text('9.0'), findsOneWidget);
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10.0'));
    await tester.pumpAndSettle();
    final detail = tester.widget<MilestoneDetailScreen>(
      find.byType(MilestoneDetailScreen),
    );
    expect(detail.groupId, 7);
    expect(detail.milestoneId, 12);
    expect(find.text('Group plan'), findsOneWidget);
  });

  testWidgets('fits a wide group milestone list', (tester) async {
    await _pump(tester, const Size(1200, 800));
    expect(find.text('10.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('creates a group milestone at width $width', (tester) async {
      final controller = _GroupList();
      await _pump(tester, Size(width, 800), listController: controller);
      await tester.tap(find.text('New milestone'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create milestone'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a milestone title.'), findsOneWidget);
      expect(controller.createdTitle, isNull);
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Release 1',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Shipping scope',
      );
      await tester.tap(find.text('Create milestone'));
      await tester.pumpAndSettle();
      expect(controller.createdTitle, 'Release 1');
      expect(controller.createdDescription, 'Shipping scope');
      final detail = tester.widget<MilestoneDetailScreen>(
        find.byType(MilestoneDetailScreen),
      );
      expect(detail.groupId, 7);
      expect(detail.milestoneId, 55);
    });
  }

  testWidgets('keeps the group milestone draft on permission denial', (
    tester,
  ) async {
    final controller = _GroupList()..rejectCreate = true;
    await _pump(tester, const Size(390, 844), listController: controller);
    await tester.tap(find.text('New milestone'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Release 1',
    );
    await tester.tap(find.text('Create milestone'));
    await tester.pumpAndSettle();
    expect(find.text('Could not create the milestone.'), findsOneWidget);
    expect(find.text('Release 1'), findsOneWidget);
  });

  testWidgets('passes selected dates to group milestone creation', (
    tester,
  ) async {
    final controller = _GroupList();
    await _pump(tester, const Size(390, 844), listController: controller);
    await tester.tap(find.text('New milestone'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Release 1',
    );

    await tester.tap(find.text('Choose date').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create milestone'));
    await tester.pumpAndSettle();

    final today = DateUtils.dateOnly(DateTime.now());
    expect(controller.createdStartDate, today);
    expect(controller.createdDueDate, today);
  });
}
