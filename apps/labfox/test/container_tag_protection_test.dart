import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/core/ads/ads_providers.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/auth_state.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/container_tag_protection_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_controller.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _rules = [
  ContainerTagProtectionRule(
    id: 2,
    projectId: 7,
    tagNamePattern: 'v*-release',
    minimumAccessLevelForPush: 'maintainer',
    minimumAccessLevelForDelete: 'owner',
  ),
  ContainerTagProtectionRule(
    id: 3,
    projectId: 7,
    tagNamePattern: 'latest',
    minimumAccessLevelForDelete: 'admin',
  ),
  ContainerTagProtectionRule(
    id: 4,
    projectId: 7,
    tagNamePattern: 'future-*',
    minimumAccessLevelForPush: 'future_role',
  ),
];

class _Repository extends ContainerRegistryRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  List<ContainerTagProtectionRule> rules = _rules;
  Object? failure;
  Completer<List<ContainerTagProtectionRule>>? pending;
  final calls = <int>[];

  @override
  Future<List<ContainerTagProtectionRule>> tagProtectionRules(
    int projectId,
  ) async {
    expectSync(projectId, anyOf(7, 8));
    calls.add(projectId);
    if (failure != null) throw failure!;
    return pending == null ? rules : pending!.future;
  }

  @override
  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) async => const Paginated(items: []);
}

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async => const SignedIn(
    Account(
      instanceUrl: 'https://example.com',
      user: User(id: 1, username: 'tester', name: 'Test User'),
    ),
  );
}

class _Analytics implements Analytics {
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {}
}

ProviderContainer _container(_Repository repository) {
  final container = ProviderContainer(
    overrides: [
      containerRegistryRepositoryProvider.overrideWith(
        (ref) async => repository,
      ),
      authControllerProvider.overrideWith(_Auth.new),
      analyticsProvider.overrideWithValue(_Analytics()),
      adsEnabledProvider.overrideWithValue(false),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<GoRouter> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  bool dark = false,
  bool entry = false,
  bool settle = true,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: entry
        ? Routes.containerRegistry(7)
        : Routes.containerTagProtectionRules(7),
    routes: [
      GoRoute(
        path: '/projects/:id/container_registry',
        builder: (_, state) => ContainerRegistryScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/container_registry/protection/tags',
        builder: (_, state) => ContainerTagProtectionScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
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
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return router;
}

void main() {
  test('missing account is an error rather than an empty rule set', () async {
    final container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(containerTagProtectionControllerProvider(7).future),
      throwsStateError,
    );
  });

  testWidgets(
    'restored protection route returns to the registry without a prior stack',
    (tester) async {
      final router = await _pump(tester, _Repository());
      expect(router.canPop(), isFalse);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ContainerRegistryScreen), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        Routes.containerRegistry(7),
      );
    },
  );
  test('loads and refreshes only the selected project', () async {
    final repository = _Repository();
    final container = _container(repository);
    expect(
      await container.read(containerTagProtectionControllerProvider(7).future),
      _rules,
    );
    await container.read(containerTagProtectionControllerProvider(8).future);
    container.invalidate(containerTagProtectionControllerProvider(7));
    await container.read(containerTagProtectionControllerProvider(7).future);
    expect(repository.calls, [7, 8, 7]);
  });

  test(
    'production router matches protection before numeric repository routes',
    () async {
      final container = _container(_Repository());
      await container.read(authControllerProvider.future);
      final router = container.read(routerProvider);
      final match = router.configuration.findMatch(
        Uri.parse(Routes.containerTagProtectionRules(7)),
      );
      expect(match.isError, isFalse);
      expect(match.pathParameters['id'], '7');
      expect(match.pathParameters.containsKey('repositoryId'), isFalse);
      expect(
        match.matches.last.matchedLocation,
        Routes.containerTagProtectionRules(7),
      );
      router.dispose();
    },
  );

  test('protection route analytics contains no project ID or rule pattern', () {
    expect(
      sanitizeRoute(Routes.containerTagProtectionRules(7)),
      '/projects/:id/container_registry/protection/tags',
    );
  });

  for (final width in [320.0, 390.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'reads nullable and unknown minimum roles at $width dark=$dark',
        (tester) async {
          final repository = _Repository();
          await _pump(tester, repository, width: width, dark: dark);
          expect(find.text('v*-release'), findsOneWidget);
          expect(find.text('Minimum push role: Maintainer'), findsOneWidget);
          expect(find.text('Minimum delete role: Owner'), findsOneWidget);
          expect(
            find.text('Minimum delete role: Administrator'),
            findsOneWidget,
          );
          expect(find.text('Minimum push role: Unknown role'), findsOneWidget);
          expect(
            find.text('Minimum push role: Not specified by rule'),
            findsOneWidget,
          );
          expect(find.text('future_role'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'registry entry opens ID-restorable protection screen and returns',
    (tester) async {
      final repository = _Repository();
      final router = await _pump(tester, repository, entry: true);
      await tester.tap(find.byTooltip('Tag protection rules'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ContainerTagProtectionScreen>(
              find.byType(ContainerTagProtectionScreen),
            )
            .projectId,
        7,
      );
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        Routes.containerTagProtectionRules(7),
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ContainerRegistryScreen), findsOneWidget);
    },
  );

  testWidgets('empty rules are refreshable', (tester) async {
    final repository = _Repository()..rules = [];
    await _pump(tester, repository);
    expect(find.text('No tag protection rules.'), findsOneWidget);
    expect(find.textContaining('not Git tags'), findsOneWidget);
    expect(find.textContaining('GitLab 18.7 or later'), findsOneWidget);
    repository.rules = _rules;
    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(find.text('v*-release'), findsOneWidget);
    expect(repository.calls, [7, 7]);
  });

  for (final error in [
    const GitLabForbiddenException('private server text'),
    const GitLabNotFoundException('private server text'),
    const GitLabServerException('private server text', statusCode: 500),
  ]) {
    testWidgets(
      'typed ${error.runtimeType} error retains retry without server text',
      (tester) async {
        final repository = _Repository()..failure = error;
        await _pump(tester, repository);
        expect(find.textContaining('private server'), findsNothing);
        expect(
          find.text(switch (error) {
            GitLabForbiddenException() =>
              'You do not have permission to view tag protection rules.',
            GitLabNotFoundException() =>
              'Tag protection rules are unavailable on this instance, or the project is not accessible.',
            _ => 'Could not load tag protection rules.',
          }),
          findsOneWidget,
        );
        repository.failure = null;
        await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
        await tester.pumpAndSettle();
        expect(find.text('v*-release'), findsOneWidget);
        expect(repository.calls, [7, 7]);
      },
    );
  }

  testWidgets('shows loading without treating it as an empty rule set', (
    tester,
  ) async {
    final repository = _Repository()
      ..pending = Completer<List<ContainerTagProtectionRule>>();
    await _pump(tester, repository, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No tag protection rules.'), findsNothing);
    repository.pending!.complete(_rules);
    await tester.pumpAndSettle();
    expect(find.text('v*-release'), findsOneWidget);
  });

  testWidgets(
    'refresh rejection shows retry without an uncaught future error',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      repository.failure = const GitLabForbiddenException(
        'private server text',
      );
      final refresh = tester
          .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
          .show();
      await tester.pumpAndSettle();
      await refresh;
      expect(find.textContaining('do not have permission'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
