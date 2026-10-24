import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/app/app_lifecycle.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/auth_state.dart';

/// Records event names instead of posting anywhere.
class _RecordingAnalytics implements Analytics {
  final List<String> events = [];
  final List<String?> routes = [];

  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    events.add(name);
    if (name == 'screen_view') {
      routes.add(properties?['route'] as String?);
    }
  }
}

/// Lets a test drive auth transitions without any storage or network.
class _StubAuth extends AuthController {
  @override
  Future<AuthState> build() async => const SignedOut();

  void emit(AuthState next) => state = AsyncData(next);
}

const _account = Account(
  instanceUrl: 'https://gitlab.com',
  user: User(id: 1, username: 'jungwon', name: 'Jungwon'),
);

void main() {
  test('app_open counts launches, not auth transitions', () async {
    final analytics = _RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        authControllerProvider.overrideWith(_StubAuth.new),
      ],
    );
    addTearDown(container.dispose);

    // Launch: the lifecycle owner opens the app once.
    container.read(appLifecycleProvider).appOpened();
    await container.read(authControllerProvider.future);
    container.read(routerProvider);

    // Sign in, switch account, sign out. Each rebuilds the router, which is
    // exactly what used to re-emit app_open.
    final auth = container.read(authControllerProvider.notifier) as _StubAuth;
    auth.emit(const SignedIn(_account));
    container.read(routerProvider);
    auth.emit(const SignedIn(_account));
    container.read(routerProvider);
    auth.emit(const SignedOut());
    container.read(routerProvider);

    expect(analytics.events.where((e) => e == 'app_open'), hasLength(1));
  });

  test(
    'appOpened is idempotent, so a re-entrant bootstrap cannot inflate it',
    () async {
      final analytics = _RecordingAnalytics();
      final container = ProviderContainer(
        overrides: [analyticsProvider.overrideWithValue(analytics)],
      );
      addTearDown(container.dispose);

      final lifecycle = container.read(appLifecycleProvider);
      lifecycle.appOpened();
      lifecycle.appOpened();
      lifecycle.appOpened();

      expect(analytics.events.where((e) => e == 'app_open'), hasLength(1));
    },
  );

  test('screen_view dedupe survives a router rebuild', () async {
    final analytics = _RecordingAnalytics();
    final container = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(analytics),
        authControllerProvider.overrideWith(_StubAuth.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    container.read(routerProvider);

    final tracker = container.read(routeTrackerProvider);
    tracker.visit('/inbox', routeTemplate: '/inbox');

    // An auth change rebuilds the router. The tracker must not be rebuilt with
    // it, or the screen the user is already on is counted a second time.
    final auth = container.read(authControllerProvider.notifier) as _StubAuth;
    auth.emit(const SignedIn(_account));
    container.read(routerProvider);

    final afterRebuild = container.read(routeTrackerProvider);
    expect(identical(tracker, afterRebuild), isTrue);

    afterRebuild.visit('/inbox', routeTemplate: '/inbox');

    expect(analytics.events.where((e) => e == 'screen_view'), hasLength(1));
  });

  test('screen views send a template without private route values', () {
    final analytics = _RecordingAnalytics();
    final tracker = RouteTracker(analytics);

    tracker.visit(
      Routes.protectedBranch(42, 'customer-secret'),
      routeTemplate: '/projects/:id/protected_branches/:name',
    );

    expect(analytics.routes, ['/projects/:id/protected_branches/:name']);
  });
}
