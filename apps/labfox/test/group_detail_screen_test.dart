import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/groups/data/group_overview.dart';
import 'package:labfox/features/groups/presentation/controllers/group_detail_controller.dart';
import 'package:labfox/features/groups/presentation/group_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubController extends GroupDetailController {
  _StubController(this.value);

  final AsyncValue<GroupOverview> value;

  @override
  Future<GroupOverview> build(int groupId) => value.when(
    data: Future.value,
    loading: () => Completer<GroupOverview>().future,
    error: Future.error,
  );
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<GroupOverview> value, {
  Size? size,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: '/groups/42',
    routes: [
      GoRoute(
        path: '/groups/:id',
        builder: (_, state) =>
            GroupDetailScreen(groupId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (_, state) =>
            Scaffold(body: Text('Project ${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/groups/:id/labels',
        builder: (_, state) =>
            Scaffold(body: Text('Labels of ${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/groups/:id/members',
        builder: (_, state) =>
            Scaffold(body: Text('Members of ${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/groups/:id/protected_environments',
        builder: (_, state) => Scaffold(
          body: Text('Protected environments of ${state.pathParameters['id']}'),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupDetailControllerProvider.overrideWith(
          () => _StubController(value),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

const _overview = GroupOverview(
  group: Group(id: 42, name: 'Team', fullPath: 'parent/team'),
  projects: Paginated(
    items: [Project(id: 7, name: 'App', pathWithNamespace: 'parent/team/app')],
  ),
  subgroups: Paginated(
    items: [Group(id: 9, name: 'Infra', fullPath: 'parent/team/infra')],
  ),
);

void main() {
  testWidgets('shows the group and its direct projects and subgroups', (
    tester,
  ) async {
    await _pump(tester, const AsyncData(_overview));
    await tester.pumpAndSettle();

    expect(find.text('parent/team'), findsOneWidget);
    expect(find.text('Infra'), findsOneWidget);
    expect(find.text('App'), findsOneWidget);
  });

  testWidgets('opens group protected environments from the overview', (
    tester,
  ) async {
    await _pump(tester, const AsyncData(_overview), size: const Size(390, 844));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Protected environments'));
    await tester.pumpAndSettle();
    expect(find.text('Protected environments of 42'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens a project in the app', (tester) async {
    await _pump(tester, const AsyncData(_overview));
    await tester.pumpAndSettle();

    await tester.tap(find.text('App'));
    await tester.pumpAndSettle();

    expect(find.text('Project 7'), findsOneWidget);
  });

  testWidgets('opens group labels', (tester) async {
    await _pump(tester, const AsyncData(_overview));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Group labels'));
    await tester.pumpAndSettle();
    expect(find.text('Labels of 42'), findsOneWidget);
  });

  testWidgets('opens effective group members', (tester) async {
    await _pump(tester, const AsyncData(_overview));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Group members'));
    await tester.pumpAndSettle();

    expect(find.text('Members of 42'), findsOneWidget);
  });

  testWidgets('opens a subgroup in the app', (tester) async {
    await _pump(tester, const AsyncData(_overview));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Infra'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<GroupDetailScreen>(find.byType(GroupDetailScreen)).groupId,
      9,
    );
  });

  testWidgets('stacks group sections on narrow screens', (tester) async {
    await _pump(tester, const AsyncData(_overview), size: const Size(390, 800));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('App')).dy,
      greaterThan(tester.getTopLeft(find.text('Infra')).dy),
    );
  });

  testWidgets('places group sections side by side on wide screens', (
    tester,
  ) async {
    await _pump(
      tester,
      const AsyncData(_overview),
      size: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    final subgroup = tester.getTopLeft(find.text('Infra'));
    final project = tester.getTopLeft(find.text('App'));
    expect(project.dx, greaterThan(subgroup.dx + 250));
    expect((project.dy - subgroup.dy).abs(), lessThan(100));
  });

  testWidgets('shows an error and a retry action', (tester) async {
    await _pump(tester, AsyncError(Exception('failed'), StackTrace.current));
    await tester.pump();

    expect(find.text('Could not load this group.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
