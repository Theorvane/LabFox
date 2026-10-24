import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/activity/presentation/controllers/project_activity_controller.dart';
import 'package:labfox/features/activity/presentation/project_activity_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Activity extends ProjectActivityController {
  @override
  Future<Paginated<ProjectEvent>> build(ProjectActivityRef arg) async {
    final items = arg.targetType == 'merge_request'
        ? const [
            ProjectEvent(
              id: 2,
              projectId: 7,
              actionName: 'merged',
              targetType: 'MergeRequest',
              targetIid: 12,
              targetTitle: 'Ship feature',
            ),
          ]
        : const [
            ProjectEvent(
              id: 1,
              projectId: 7,
              actionName: 'opened',
              targetType: 'Issue',
              targetIid: 53,
              targetTitle: 'Fix login',
              author: EventActor(id: 25, name: 'Test User', username: 'tester'),
            ),
          ];
    return Paginated(items: items);
  }
}

Future<GoRouter> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/activity',
    routes: [
      GoRoute(
        path: '/projects/:id/activity',
        builder: (_, state) => ProjectActivityScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/issues/:iid',
        builder: (_, state) =>
            Scaffold(body: Text('Issue ${state.pathParameters['iid']}')),
      ),
      GoRoute(
        path: '/projects/:id/merge_requests/:iid',
        builder: (_, state) => Scaffold(
          body: Text('Merge request ${state.pathParameters['iid']}'),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectActivityControllerProvider.overrideWith(_Activity.new),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('opens an issue using its iid from the mobile activity feed', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));
    expect(find.text('Fix login'), findsOneWidget);
    await tester.tap(find.text('Fix login'));
    await tester.pumpAndSettle();
    expect(find.text('Issue 53'), findsOneWidget);
  });

  testWidgets('shows filtered activity without overflow on wide screens', (
    tester,
  ) async {
    await _pump(tester, const Size(1200, 800));
    await tester.tap(find.text('Merge requests'));
    await tester.pumpAndSettle();
    expect(find.text('Ship feature'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Ship feature'));
    await tester.pumpAndSettle();
    expect(find.text('Merge request 12'), findsOneWidget);
  });
}
