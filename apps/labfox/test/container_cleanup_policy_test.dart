import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/core/ads/ads_providers.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/auth_state.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/container_cleanup_policy_screen.dart';
import 'package:labfox/features/container_registry/presentation/container_registry_screen.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_cleanup_policy_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

final _policy = ContainerCleanupPolicy(
  enabled: true,
  cadence: '7d',
  keepN: 10,
  olderThan: '14d',
  nameRegexDelete: 'release.+',
  nameRegex: 'legacy-unused',
  nameRegexKeep: 'stable',
  nextRunAt: DateTime.utc(2026, 9, 30, 10),
);

class _Repository extends ContainerRegistryRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ContainerCleanupPolicy? policy = _policy;
  Object? failure;
  Completer<ContainerCleanupPolicy?>? pending;
  final calls = <int>[];
  @override
  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async {
    calls.add(projectId);
    if (failure != null) throw failure!;
    return pending == null ? policy : pending!.future;
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
      instanceUrl: 'https://gitlab.example.com',
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
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: entry
        ? Routes.containerRegistry(7)
        : Routes.containerCleanupPolicy(7),
    routes: [
      GoRoute(
        path: '/projects/:id/container_registry',
        builder: (_, state) => ContainerRegistryScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/container_registry/cleanup_policy',
        builder: (_, state) => ContainerCleanupPolicyScreen(
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
  test('account repository changes replace cached policy', () async {
    var repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = containerCleanupPolicyControllerProvider(7);
    expect((await container.read(provider.future))!.enabled, isTrue);
    repository = _Repository()
      ..policy = const ContainerCleanupPolicy(enabled: false);
    container.invalidate(containerRegistryRepositoryProvider);
    expect((await container.read(provider.future))!.enabled, isFalse);
  });
  testWidgets('empty timing settings are visible rather than inferred', (
    tester,
  ) async {
    final repository = _Repository()
      ..policy = const ContainerCleanupPolicy(cadence: '', olderThan: '');
    await _pump(tester, repository);
    expect(find.text('Empty setting'), findsNWidgets(2));
    expect(find.text('7 days'), findsNothing);
  });
  test('missing account is an error, not an absent policy', () async {
    final container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(containerCleanupPolicyControllerProvider(7).future),
      throwsStateError,
    );
  });
  test('loads and refreshes the selected project only', () async {
    final repository = _Repository();
    final container = _container(repository);
    expect(
      await container.read(containerCleanupPolicyControllerProvider(7).future),
      _policy,
    );
    await container.read(containerCleanupPolicyControllerProvider(8).future);
    container.invalidate(containerCleanupPolicyControllerProvider(7));
    await container.read(containerCleanupPolicyControllerProvider(7).future);
    expect(repository.calls, [7, 8, 7]);
  });
  test(
    'production router matches static cleanup route before repositories',
    () async {
      final container = _container(_Repository());
      await container.read(authControllerProvider.future);
      final router = container.read(routerProvider);
      addTearDown(router.dispose);
      final match = router.configuration.findMatch(
        Uri.parse(Routes.containerCleanupPolicy(7)),
      );
      expect(match.isError, isFalse);
      expect(match.pathParameters['id'], '7');
      expect(match.pathParameters.containsKey('repositoryId'), isFalse);
    },
  );
  test('cleanup route analytics excludes the project and policy patterns', () {
    expect(
      sanitizeRoute(Routes.containerCleanupPolicy(7)),
      '/projects/:id/container_registry/cleanup_policy',
    );
  });

  for (final width in [320.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('policy detail fits $width dark=$dark', (tester) async {
        await _pump(tester, _Repository(), width: width, dark: dark);
        expect(find.text('Enabled'), findsOneWidget);
        expect(find.text('7 days'), findsOneWidget);
        expect(find.text('14 days'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('release.+'), 100);
        expect(find.text('release.+'), findsOneWidget);
        expect(find.text('legacy-unused'), findsNothing);
        await tester.scrollUntilVisible(find.text('stable'), 100);
        expect(find.text('stable'), findsOneWidget);
        final date = DateFormat.yMd(
          'en',
        ).add_jm().format(_policy.nextRunAt!.toLocal());
        await tester.scrollUntilVisible(find.text(date), 100);
        expect(find.text(date), findsOneWidget);
        expect(find.byType(Switch), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('registry entry navigates by ID and returns', (tester) async {
    final router = await _pump(tester, _Repository(), entry: true);
    await tester.tap(find.byTooltip('Cleanup policy'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ContainerCleanupPolicyScreen>(
            find.byType(ContainerCleanupPolicyScreen),
          )
          .projectId,
      7,
    );
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      Routes.containerCleanupPolicy(7),
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ContainerRegistryScreen), findsOneWidget);
  });
  testWidgets('restored policy route returns to registry without a stack', (
    tester,
  ) async {
    final router = await _pump(tester, _Repository());
    expect(router.canPop(), isFalse);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ContainerRegistryScreen), findsOneWidget);
  });
  testWidgets('absent policy is refreshable without claiming disabled', (
    tester,
  ) async {
    final repository = _Repository()..policy = null;
    await _pump(tester, repository);
    expect(
      find.text('GitLab did not report a cleanup policy.'),
      findsOneWidget,
    );
    expect(find.text('Disabled'), findsNothing);
    repository.policy = _policy;
    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(find.text('Enabled'), findsOneWidget);
    expect(repository.calls, [7, 7]);
  });

  for (final enabled in [null, false]) {
    testWidgets('nullable status $enabled is not inferred from a timestamp', (
      tester,
    ) async {
      final repository = _Repository()
        ..policy = ContainerCleanupPolicy(
          enabled: enabled,
          nextRunAt: _policy.nextRunAt,
        );
      await _pump(tester, repository);
      expect(
        find.text(enabled == false ? 'Disabled' : 'Not reported'),
        findsWidgets,
      );
      expect(find.text('Enabled'), findsNothing);
    });
  }
  testWidgets('preserves legacy patterns and unknown timing without defaults', (
    tester,
  ) async {
    final repository = _Repository()
      ..policy = const ContainerCleanupPolicy(
        cadence: 'future-cadence',
        olderThan: 'future-age',
        keepN: 0,
        nameRegex: 'legacy-pattern',
      );
    await _pump(tester, repository, width: 1200);
    expect(find.text('future-cadence'), findsOneWidget);
    expect(find.text('future-age'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Delete pattern (legacy)'), findsOneWidget);
    expect(find.text('legacy-pattern'), findsOneWidget);
  });
  testWidgets('modern empty pattern does not fall back to legacy', (
    tester,
  ) async {
    final repository = _Repository()
      ..policy = const ContainerCleanupPolicy(
        nameRegexDelete: '',
        nameRegex: 'legacy-unused',
        cadence: '3month',
      );
    await _pump(tester, repository, width: 1200);
    expect(find.text('Empty pattern'), findsOneWidget);
    expect(find.text('legacy-unused'), findsNothing);
    expect(find.text('3 months'), findsOneWidget);
  });

  for (final error in [
    const GitLabForbiddenException('private server text'),
    const GitLabNotFoundException('private server text'),
    const GitLabServerException('private server text', statusCode: 500),
  ]) {
    testWidgets('typed ${error.runtimeType} failure has safe retry', (
      tester,
    ) async {
      final repository = _Repository()..failure = error;
      await _pump(tester, repository);
      expect(find.textContaining('private server'), findsNothing);
      expect(
        find.text(switch (error) {
          GitLabForbiddenException() =>
            'You do not have permission to view this project cleanup policy.',
          GitLabNotFoundException() =>
            'The project is not accessible, or cleanup policy information is unavailable.',
          _ => 'Could not load the cleanup policy.',
        }),
        findsOneWidget,
      );
      repository.failure = null;
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Enabled'), findsOneWidget);
    });
  }
  testWidgets('loading is not interpreted as an absent policy', (tester) async {
    final repository = _Repository()
      ..pending = Completer<ContainerCleanupPolicy?>();
    await _pump(tester, repository, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('GitLab did not report a cleanup policy.'), findsNothing);
    repository.pending!.complete(_policy);
    await tester.pumpAndSettle();
  });
  testWidgets('refresh failure renders retry without an uncaught error', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    repository.failure = const GitLabForbiddenException('private server text');
    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(find.textContaining('do not have permission'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
