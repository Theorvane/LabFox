import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/settings/app_settings_providers.dart';
import 'package:labfox/core/ui/link_opener.dart';
import 'package:labfox/features/settings/presentation/settings_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps the settings screen.
///
/// Returns the container, so a test can read what the screen persisted, and the
/// list recording every link the screen asked to open.
Future<({ProviderContainer container, List<Uri> opened})> _pump(
  WidgetTester tester,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final opened = <Uri>[];
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appVersionProvider.overrideWith((ref) async => '1.2.3 (45)'),
      linkOpenerProvider.overrideWithValue((uri) async => opened.add(uri)),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (container: container, opened: opened);
}

void main() {
  testWidgets('lists the licenses entry', (tester) async {
    await _pump(tester);

    // The settings list is taller than one screen, and a ListView only builds
    // what is visible, so the entry has to be scrolled to before it exists.
    await tester.scrollUntilVisible(find.text('Open source licenses'), 100);

    expect(find.text('Open source licenses'), findsOneWidget);
  });

  testWidgets('lists the privacy policy entry', (tester) async {
    await _pump(tester);
    expect(find.text('Privacy policy'), findsOneWidget);
  });

  testWidgets('opens the license page, satisfying the notice obligation', (
    tester,
  ) async {
    await _pump(tester);

    // The merged settings list is taller than one screen, so scroll the entry
    // fully into view before tapping it.
    await tester.scrollUntilVisible(find.text('Open source licenses'), 100);
    await tester.ensureVisible(find.text('Open source licenses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open source licenses'));
    await tester.pumpAndSettle();

    // Flutter's LicensePage lists every pub dependency's license.
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('terms of service opens the company terms page', (tester) async {
    final opened = (await _pump(tester)).opened;

    await tester.tap(find.text('Terms of service'));
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse('https://www.sloki9637.com/terms')]);
  });

  testWidgets('the theme choice persists and applies app-wide', (tester) async {
    final container = (await _pump(tester)).container;

    // System is the default until the user chooses.
    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });

  testWidgets('shows the app version', (tester) async {
    await _pump(tester);
    expect(find.textContaining('1.2.3'), findsOneWidget);
  });

  testWidgets('settings do not offer a subscription', (tester) async {
    await _pump(tester);

    expect(find.text('LabFox subscription'), findsNothing);
  });
}
