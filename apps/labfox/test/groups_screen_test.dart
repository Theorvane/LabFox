import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/groups/presentation/controllers/groups_controller.dart';
import 'package:labfox/features/groups/presentation/groups_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubController extends GroupsController {
  _StubController(this._value);

  final AsyncValue<List<Group>> _value;

  @override
  Future<List<Group>> build() {
    return _value.when(
      data: (items) => Future.value(items),
      loading: () => Completer<List<Group>>().future,
      error: (error, stack) => Future.error(error, stack),
    );
  }
}

Future<GoRouter> _pump(
  WidgetTester tester,
  AsyncValue<List<Group>> value,
) async {
  final router = GoRouter(
    initialLocation: '/groups',
    routes: [
      GoRoute(path: '/groups', builder: (_, _) => const GroupsScreen()),
      GoRoute(
        path: '/groups/:id',
        builder: (_, state) =>
            Scaffold(body: Text('Group ${state.pathParameters['id']}')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        groupsControllerProvider.overrideWith(() => _StubController(value)),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  return router;
}

const _groups = [
  Group(
    id: 42,
    name: 'YouthPick',
    fullPath: 'youthpick',
    description: 'The team',
    visibility: 'private',
    webUrl: 'https://gitlab.com/groups/youthpick',
  ),
  Group(id: 7, name: 'Infra', fullPath: 'youthpick/infra'),
];

void main() {
  testWidgets('shows a spinner while loading', (tester) async {
    await _pump(tester, const AsyncLoading());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lists the groups with their paths', (tester) async {
    await _pump(tester, const AsyncData(_groups));
    await tester.pumpAndSettle();

    expect(find.text('YouthPick'), findsOneWidget);
    expect(find.text('youthpick'), findsOneWidget);
    expect(find.text('Infra'), findsOneWidget);
    expect(find.text('youthpick/infra'), findsOneWidget);
  });

  testWidgets('a group opens its in-app route', (tester) async {
    await _pump(tester, const AsyncData(_groups));
    await tester.pumpAndSettle();

    await tester.tap(find.text('YouthPick'));
    await tester.pumpAndSettle();

    expect(find.text('Group 42'), findsOneWidget);
  });

  testWidgets('shows an empty message', (tester) async {
    await _pump(tester, const AsyncData(<Group>[]));
    await tester.pumpAndSettle();
    expect(find.textContaining('not a member of any groups'), findsOneWidget);
  });

  testWidgets('shows an error with retry', (tester) async {
    await _pump(tester, AsyncError(Exception('x'), StackTrace.current));
    await tester.pump();
    expect(find.textContaining('Could not load your groups'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('carries its own back affordance', (tester) async {
    await _pump(tester, const AsyncData(<Group>[]));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
  });
}
