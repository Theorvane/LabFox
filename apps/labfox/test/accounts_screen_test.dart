import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/account_store.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/auth/auth_repository.dart';
import 'package:labfox/core/storage/local_projects_store.dart';
import 'package:labfox/features/auth/presentation/accounts_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Account _account(String host, int id, String username) => Account(
  instanceUrl: 'https://$host',
  user: User(id: id, username: username, name: username),
);

Future<AccountStore> _seed(List<Account> accounts) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final store = AccountStore(prefs);
  for (final a in accounts) {
    await store.add(a);
  }
  return store;
}

Future<void> _pump(WidgetTester tester, AccountStore store) async {
  FlutterSecureStorage.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          AuthRepository(
            accountStore: store,
            credentialStore: CredentialStore(),
            projectsStore: LocalProjectsStore(prefs),
          ),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AccountsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists accounts and marks the active one', (tester) async {
    final store = await _seed([
      _account('gitlab.com', 1, 'jungwon'),
      _account('git.company.com', 1, 'jungwon'),
    ]);
    await _pump(tester, store);

    expect(find.text('jungwon'), findsNWidgets(2));
    expect(find.text('gitlab.com'), findsOneWidget);
    expect(find.text('git.company.com'), findsOneWidget);
    // The most recently added (git.company.com) is active.
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('tapping an inactive account switches to it', (tester) async {
    final first = _account('gitlab.com', 1, 'a');
    final store = await _seed([first, _account('git.company.com', 1, 'b')]);
    await _pump(tester, store);

    // b is active; tapping a switches.
    await tester.tap(find.text('a'));
    await tester.pumpAndSettle();

    expect(store.readActive()?.id, first.id);
  });

  testWidgets('removing an account drops it from the list', (tester) async {
    final store = await _seed([
      _account('gitlab.com', 1, 'a'),
      _account('git.company.com', 1, 'b'),
    ]);
    await _pump(tester, store);

    // Remove the active account (b) via its logout button.
    await tester.tap(find.byIcon(Icons.logout).last);
    await tester.pumpAndSettle();

    expect(store.readAccounts(), hasLength(1));
    expect(find.text('b'), findsNothing);
  });

  testWidgets(
    'the add-account action remains available with an existing account',
    (tester) async {
      final store = await _seed([_account('gitlab.com', 1, 'jungwon')]);
      await _pump(tester, store);

      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Add account'))
            .onTap,
        isNotNull,
      );
      expect(find.textContaining('One account is free'), findsNothing);
    },
  );
}
