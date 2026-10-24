import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/storage/local_projects_providers.dart';
import 'package:labfox/features/projects/presentation/controllers/projects_controller.dart';
import 'package:labfox/features/projects/presentation/projects_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A controller stub that emits a fixed AsyncValue, so each state can be tested
/// without a client or network.
class _StubController extends ProjectsController {
  _StubController(this._value);

  final AsyncValue<List<Project>> _value;

  @override
  Future<List<Project>> build() async {
    return _value.when(
      data: (items) => items,
      // A future that never completes keeps the notifier in AsyncLoading
      // without scheduling a timer that the test clock would flag as pending.
      loading: () => Completer<List<Project>>().future,
      error: (error, stack) => Future<List<Project>>.error(error, stack),
    );
  }
}

Future<void> _pump(WidgetTester tester, AsyncValue<List<Project>> value) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectsControllerProvider.overrideWith(() => _StubController(value)),
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentAccountProvider.overrideWithValue(
          const Account(
            instanceUrl: 'https://gitlab.com',
            user: User(id: 1, username: 'jungwon', name: 'Jungwon'),
          ),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProjectsScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  const projects = [
    Project(
      id: 1,
      name: 'backend',
      pathWithNamespace: 'youthpick/backend',
      starCount: 12,
    ),
    Project(id: 2, name: 'web', pathWithNamespace: 'youthpick/web'),
  ];

  testWidgets('shows a spinner while loading', (tester) async {
    await _pump(tester, const AsyncLoading());
    // A second frame lets the localization delegate resolve before asserting.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lists projects with their namespace', (tester) async {
    await _pump(tester, const AsyncData(projects));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectTile), findsNWidgets(2));
    expect(find.text('backend'), findsOneWidget);
    expect(find.text('youthpick/backend'), findsOneWidget);
  });

  testWidgets('shows an empty message, not an error, for zero projects', (
    tester,
  ) async {
    // Zero projects is a valid state and must read differently from a failure.
    await _pump(tester, const AsyncData(<Project>[]));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectTile), findsNothing);
    expect(find.textContaining('not a member of any projects'), findsOneWidget);
  });

  testWidgets('shows an error with a retry action on failure', (tester) async {
    await _pump(tester, AsyncError(Exception('boom'), StackTrace.current));
    await tester.pump();

    expect(find.textContaining('Could not load'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('a row star toggles the favorite in place', (tester) async {
    await _pump(tester, const AsyncData(projects));
    await tester.pumpAndSettle();

    // Every row carries an outline star toggle; none is a favorite yet.
    // (The footer's star-count glyph is not a button, so it stays excluded.)
    expect(
      find.widgetWithIcon(IconButton, Icons.star_border),
      findsNWidgets(2),
    );

    await tester.tap(find.widgetWithIcon(IconButton, Icons.star_border).first);
    await tester.pumpAndSettle();

    // The first row's star fills without leaving the list.
    expect(find.widgetWithIcon(IconButton, Icons.star), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.star_border), findsOneWidget);
  });

  testWidgets('favorites can grow beyond the old limit', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectsControllerProvider.overrideWith(
            () => _StubController(const AsyncData(projects)),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentAccountProvider.overrideWithValue(
            const Account(
              instanceUrl: 'https://gitlab.com',
              user: User(id: 1, username: 'jungwon', name: 'Jungwon'),
            ),
          ),
          favoriteProjectsProvider.overrideWith(() => _FullFavorites()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProjectsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.star_border).first);
    await tester.pumpAndSettle();

    expect(find.widgetWithIcon(IconButton, Icons.star), findsOneWidget);
    expect(find.text('Not now'), findsNothing);
  });
}

/// Three existing favorites exercise the former free-tier ceiling.
class _FullFavorites extends FavoriteProjectsController {
  @override
  List<Project> build() => const [
    Project(id: 90, name: 'a', pathWithNamespace: 'g/a'),
    Project(id: 91, name: 'b', pathWithNamespace: 'g/b'),
    Project(id: 92, name: 'c', pathWithNamespace: 'g/c'),
  ];
}
