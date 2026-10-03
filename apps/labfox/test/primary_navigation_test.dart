import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/core/ads/ads_providers.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/auth/auth_state.dart';
import 'package:labfox/core/settings/app_settings_providers.dart';
import 'package:labfox/features/inbox/presentation/controllers/inbox_controllers.dart';
import 'package:labfox/features/inbox/presentation/inbox_screen.dart';
import 'package:labfox/features/settings/presentation/settings_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async => const SignedIn(
    Account(
      instanceUrl: 'https://gitlab.example.com',
      user: User(id: 1, username: 'tester', name: 'Test User'),
    ),
  );
}

Future<GoRouter> _pump(WidgetTester tester, double width, bool dark) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      currentAccountProvider.overrideWithValue(null),
      sharedPreferencesProvider.overrideWithValue(prefs),
      adsEnabledProvider.overrideWithValue(false),
      inboxRepositoryProvider.overrideWith((ref) async => null),
      appVersionProvider.overrideWith((ref) async => '1.0.0'),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authControllerProvider.future);
  final router = container.read(routerProvider);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets(
    'resizing keeps Settings selected and preserves its theme choice',
    (tester) async {
      final router = await _pump(tester, 390, false);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1200, 900);
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        Routes.settings,
      );
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        1,
      );
      final context = tester.element(find.byType(SettingsScreen));
      expect(
        ProviderScope.containerOf(context).read(themeModeProvider),
        ThemeMode.dark,
      );
      expect(find.byType(BackButton), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [390.0, 800.0, 1200.0]) {
    for (final dark in [false, true]) {
      testWidgets('Settings is primary and To-do stacks at $width dark=$dark', (
        tester,
      ) async {
        final router = await _pump(tester, width, dark);
        expect(find.text('Projects'), findsOneWidget);
        expect(find.text('Groups'), findsOneWidget);
        expect(find.text('To-do list'), findsOneWidget);
        expect(find.text('Inbox'), findsNothing);

        await tester.tap(find.text('To-do list'));
        await tester.pumpAndSettle();
        expect(find.byType(InboxScreen), findsOneWidget);
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          Routes.inbox,
        );
        expect(router.canPop(), isTrue);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(NavigationRail), findsNothing);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          Routes.home,
        );
        expect(find.text('Projects'), findsOneWidget);

        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          Routes.projects,
        );
        expect(router.canPop(), isTrue);
        router.pop();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          Routes.settings,
        );
        expect(router.canPop(), isFalse);
        expect(find.byType(BackButton), findsNothing);
        if (width < 600) {
          expect(
            tester
                .widget<NavigationBar>(find.byType(NavigationBar))
                .selectedIndex,
            1,
          );
        } else {
          expect(
            tester
                .widget<NavigationRail>(find.byType(NavigationRail))
                .selectedIndex,
            1,
          );
        }
        await tester.tap(find.text('Privacy policy'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          Routes.privacy,
        );
        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          Routes.home,
        );
        router.go(Routes.inbox);
        await tester.pumpAndSettle();
        expect(find.byType(InboxScreen), findsOneWidget);
        expect(router.canPop(), isFalse);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('My work'), findsOneWidget);
      });
    }
  }
}
