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
import 'package:labfox/features/milestones/presentation/milestones_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _List extends MilestoneListController {
  String? createdTitle;
  String? createdDescription;
  DateTime? createdStartDate;
  DateTime? createdDueDate;
  bool rejectCreate = false;

  @override
  Future<Paginated<GitLabMilestone>> build(MilestoneListRef arg) async =>
      Paginated(
        items: [
          GitLabMilestone(
            id: arg.state == 'active' ? 12 : 13,
            iid: arg.state == 'active' ? 3 : 4,
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
    return GitLabMilestone(id: 55, iid: 9, title: title, state: 'active');
  }
}

class _Repository extends MilestonesRepository {
  _Repository()
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'x'));

  int createCalls = 0;

  @override
  Future<Paginated<GitLabMilestone>> list(
    int projectId, {
    required String state,
    int page = 1,
    bool includeAncestors = false,
  }) async => const Paginated(items: []);

  @override
  Future<GitLabMilestone> create(
    int projectId, {
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    createCalls++;
    return GitLabMilestone(id: 55, iid: 9, title: title, state: 'active');
  }
}

Future<void> _pump(
  WidgetTester tester, {
  Size? size,
  bool dark = false,
  String initialLocation = '/projects/7/milestones',
  _List? listController,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/projects/:id/milestones',
        builder: (_, state) =>
            MilestonesScreen(projectId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/projects/:id/milestones/:milestoneId',
        builder: (_, state) => MilestoneDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          milestoneId: int.parse(state.pathParameters['milestoneId']!),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        milestoneListControllerProvider.overrideWith(
          () => listController ?? _List(),
        ),
        milestoneDetailProvider.overrideWith(
          (ref, key) async => const GitLabMilestone(
            id: 12,
            iid: 3,
            title: '10.0',
            state: 'active',
            description: '## Planned work',
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'rejects reversed milestone dates before calling the repository',
    () async {
      final repository = _Repository();
      final container = ProviderContainer(
        overrides: [
          milestonesRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);
      const key = MilestoneListRef(projectId: 7, state: 'active');
      await container.read(milestoneListControllerProvider(key).future);
      await expectLater(
        container
            .read(milestoneListControllerProvider(key).notifier)
            .create(
              title: 'Release 1',
              startDate: DateTime(2026, 11, 1),
              dueDate: DateTime(2026, 10, 1),
            ),
        throwsArgumentError,
      );
      expect(repository.createCalls, 0);
    },
  );

  for (final width in [390.0, 1200.0]) {
    testWidgets('creates a project milestone at width $width', (tester) async {
      final controller = _List();
      await _pump(tester, size: Size(width, 800), listController: controller);
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
      expect(
        tester
            .widget<MilestoneDetailScreen>(find.byType(MilestoneDetailScreen))
            .milestoneId,
        55,
      );
    });
  }

  testWidgets('keeps the milestone draft on permission denial', (tester) async {
    final controller = _List()..rejectCreate = true;
    await _pump(tester, listController: controller);
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

  testWidgets('passes selected dates to project milestone creation', (
    tester,
  ) async {
    final controller = _List();
    await _pump(tester, listController: controller);
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

  testWidgets('filters active and closed milestones', (tester) async {
    await _pump(tester);
    expect(find.text('10.0'), findsOneWidget);
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(find.text('9.0'), findsOneWidget);
    expect(find.text('10.0'), findsNothing);
  });

  testWidgets('opens project milestone by global ID', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('10.0'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MilestoneDetailScreen>(find.byType(MilestoneDetailScreen))
          .milestoneId,
      12,
    );
    expect(find.byType(MarkdownViewer), findsOneWidget);
  });

  testWidgets('fits a narrow dark screen', (tester) async {
    await _pump(tester, size: const Size(390, 844), dark: true);
    expect(find.text('10.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('places description beside metadata on wide screens', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(1200, 800),
      initialLocation: '/projects/7/milestones/12',
    );
    expect(
      tester.getTopLeft(find.byType(MarkdownViewer)).dx,
      greaterThan(tester.getTopLeft(find.text('Active')).dx + 150),
    );
  });
}
