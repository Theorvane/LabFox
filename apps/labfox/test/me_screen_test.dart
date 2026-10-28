import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/profile/presentation/me_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
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
        home: MeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the signed-in user and the account actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
          home: MeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jungwon'), findsOneWidget);
    expect(find.text('@jungwon'), findsOneWidget);
    expect(find.text('gitlab.com'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Switch account'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    // The profile can be shared, like GitHub Mobile's Share profile.
    expect(find.text('Share profile'), findsOneWidget);
  });

  testWidgets('Me does not show a subscription offer or state', (tester) async {
    await _pump(tester);
    expect(find.text('LabFox subscription'), findsNothing);
    expect(find.text('Subscribed'), findsNothing);
  });
}
