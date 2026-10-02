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

  GitLabMilestone current = const GitLabMilestone(
    id: 42,
    iid: 4,
    title: 'Release 1',
    state: 'active',
  );
  final events = <String>[];
  bool reject = false;

  @override
  Future<GitLabMilestone> setStateEvent(
    int projectId,
    int milestoneId, {
    required String stateEvent,
  }) async {
    expect(projectId, 7);
    expect(milestoneId, 42);
    events.add(stateEvent);
    if (reject) throw const GitLabForbiddenException('Forbidden');
    current = current.copyWith(
      state: stateEvent == 'close' ? 'closed' : 'active',
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
  for (final width in [390.0, 1200.0]) {
    testWidgets('confirms close then reactivates at width $width', (
      tester,
    ) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.byTooltip('Close milestone'));
      await tester.pumpAndSettle();
      expect(find.text('Close this milestone?'), findsOneWidget);
      expect(repository.events, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.events, isEmpty);

      await tester.tap(find.byTooltip('Close milestone'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close milestone').last);
      await tester.pumpAndSettle();
      expect(repository.events, ['close']);
      expect(find.byTooltip('Reactivate milestone'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);

      await tester.tap(find.byTooltip('Reactivate milestone'));
      await tester.pumpAndSettle();
      expect(repository.events, ['close', 'activate']);
      expect(find.byTooltip('Close milestone'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });
  }

  testWidgets('keeps current state and offers retry after permission denial', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.byTooltip('Close milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close milestone').last);
    await tester.pumpAndSettle();
    expect(repository.events, ['close']);
    expect(find.text('Could not change the milestone state.'), findsOneWidget);
    expect(find.byTooltip('Close milestone'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });
}
