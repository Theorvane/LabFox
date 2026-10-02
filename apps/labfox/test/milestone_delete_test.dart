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

  bool deleted = false;
  bool reject = false;
  int? deletedId;

  @override
  Future<void> delete(int projectId, int milestoneId) async {
    if (reject) throw const GitLabForbiddenException('Forbidden');
    deleted = true;
    deletedId = milestoneId;
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  bool group = false,
  double width = 390,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: group
        ? '/groups/8/milestones/42'
        : '/projects/7/milestones/42',
    routes: [
      GoRoute(
        path: '/projects/:id/milestones/:milestoneId',
        builder: (_, _) =>
            const MilestoneDetailScreen(projectId: 7, milestoneId: 42),
      ),
      GoRoute(
        path: '/groups/:id/milestones/:milestoneId',
        builder: (_, _) =>
            const MilestoneDetailScreen.group(groupId: 8, milestoneId: 42),
      ),
      GoRoute(
        path: '/projects/:id/milestones',
        builder: (_, _) => const Scaffold(body: Text('Milestone list')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        milestonesRepositoryProvider.overrideWith((ref) async => repository),
        milestoneDetailProvider.overrideWith(
          (ref, key) async => const GitLabMilestone(
            id: 42,
            iid: 4,
            title: 'Release 1',
            state: 'active',
          ),
        ),
        groupMilestoneDetailProvider.overrideWith(
          (ref, key) async => const GitLabMilestone(
            id: 42,
            iid: 4,
            title: 'Release 1',
            state: 'active',
          ),
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
  for (final width in [390.0, 1200.0]) {
    testWidgets(
      'requires confirmation before project milestone deletion at width $width',
      (tester) async {
        final repository = _Repository();
        await _pump(tester, repository, width: width);
        await tester.tap(find.byTooltip('Delete milestone'));
        await tester.pumpAndSettle();
        expect(find.text('Delete this milestone?'), findsOneWidget);
        expect(repository.deleted, isFalse);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(repository.deleted, isFalse);
        await tester.tap(find.byTooltip('Delete milestone'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete milestone').last);
        await tester.pumpAndSettle();
        expect(repository.deletedId, 42);
        expect(find.text('Milestone list'), findsOneWidget);
      },
    );
  }

  testWidgets('keeps the detail visible after deletion is forbidden', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Delete milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete milestone').last);
    await tester.pumpAndSettle();
    expect(find.text('Could not delete the milestone.'), findsOneWidget);
    expect(find.byType(MilestoneDetailScreen), findsOneWidget);
    expect(repository.deleted, isFalse);
  });
}
