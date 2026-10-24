import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/home/presentation/home_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

void main() {
  testWidgets('home shows the My Work launcher into the account lists', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Signed out keeps the project sections empty without touching prefs.
          currentAccountProvider.overrideWithValue(null),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My work'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Merge requests'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('To-do list'), findsOneWidget);
    // Home is a launcher: the app bar carries search.
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
