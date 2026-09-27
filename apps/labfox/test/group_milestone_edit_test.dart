import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/milestones/data/group_milestones_repository.dart';
import 'package:labfox/features/milestones/presentation/controllers/milestones_controller.dart';
import 'package:labfox/features/milestones/presentation/milestone_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends GroupMilestonesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  GitLabMilestone current = GitLabMilestone(
    id: 55,
    iid: 9,
    groupId: 7,
    title: 'Release 1',
    state: 'active',
    description: 'Original scope',
    startDate: DateTime(2026, 10, 1),
    dueDate: DateTime(2026, 10, 31),
  );
  bool reject = false;
  int updateCount = 0;
  String? lastTitle;
  String? lastDescription;
  bool? lastClearStartDate;
  bool? lastClearDueDate;

  @override
  Future<GitLabMilestone> update(
    int groupId,
    int milestoneId, {
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? dueDate,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) async {
    updateCount++;
    expect(groupId, 7);
    expect(milestoneId, 55);
    if (reject) throw const GitLabForbiddenException('Forbidden');
    lastTitle = title;
    lastDescription = description;
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
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/groups/7/milestones/55',
    routes: [
      GoRoute(
        path: '/groups/:id/milestones/:milestoneId',
        builder: (_, _) =>
            const MilestoneDetailScreen.group(groupId: 7, milestoneId: 55),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupMilestonesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
        groupMilestoneDetailProvider.overrideWith(
          (ref, key) async => repository.current,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('rejects invalid group milestone edits before writing', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        groupMilestonesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final edit = container.read(
      groupMilestoneEditControllerProvider(
        const GroupMilestoneRef(groupId: 7, milestoneId: 55),
      ).notifier,
    );
    await expectLater(
      edit.save(title: ' ', description: ''),
      throwsArgumentError,
    );
    await expectLater(
      edit.save(
        title: 'Release 2',
        description: '',
        startDate: DateTime(2026, 11, 2),
        dueDate: DateTime(2026, 11, 1),
      ),
      throwsArgumentError,
    );
    expect(repository.updateCount, 0);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('edits a group milestone at width $width', (tester) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.byTooltip('Edit milestone'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Release 2',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Updated scope',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(repository.lastTitle, 'Release 2');
      expect(repository.lastDescription, 'Updated scope');
      expect(
        tester.widget<MarkdownViewer>(find.byType(MarkdownViewer)).data,
        'Updated scope',
      );
    });
  }

  testWidgets('keeps the group edit draft after permission denial', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Draft');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Could not update the milestone.'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('clears only the group milestone start date', (tester) async {
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
    expect(repository.current.startDate, isNull);
    expect(repository.current.dueDate, DateTime(2026, 10, 31));
  });
}
