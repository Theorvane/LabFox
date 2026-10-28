import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/app/app.dart';
import 'package:labfox/core/auth/auth_providers.dart';
import 'package:labfox/core/auth/auth_repository.dart';
import 'package:labfox/features/issues/data/issues_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Starts already signed in, so the app boots straight into Home.
class _SignedInAuthRepository implements AuthRepository {
  final Account _account = const Account(
    instanceUrl: 'https://gitlab.com',
    user: User(id: 1, username: 'jungwon', name: 'Jungwon'),
  );

  @override
  Account? currentAccount() => _account;

  @override
  Future<Account> signInWithToken({
    required String instanceUrl,
    required String token,
  }) async => _account;

  @override
  Future<Account> signInWithOAuth({
    required String instanceUrl,
    required String clientId,
  }) async => _account;

  @override
  Future<String?> refreshOAuthAccessToken(Account account) async => null;

  @override
  Future<void> signOut([Account? account]) async {}

  @override
  List<Account> accounts() => [_account];

  @override
  Future<void> switchTo(Account account) async {}

  @override
  Future<String?> tokenFor(Account account) async => 'glpat-valid';
}

class _FakeIssues extends IssuesRepository {
  _FakeIssues()
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));

  @override
  Future<List<Issue>> listMine({
    required IssueScope scope,
    required IssueState state,
  }) async => const [];
}

class _FakeMrs extends MergeRequestsRepository {
  _FakeMrs() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));

  @override
  Future<List<MergeRequest>> listMine({
    required MergeRequestScope scope,
    required MergeRequestState state,
  }) async => const [];
}

Future<void> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
        issuesRepositoryProvider.overrideWith((ref) async => _FakeIssues()),
        mergeRequestsRepositoryProvider.overrideWith((ref) async => _FakeMrs()),
      ],
      child: const LabFoxApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('my issues has a back affordance that returns home', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('My work'), findsOneWidget);

    await tester.tap(find.text('Issues'));
    await tester.pumpAndSettle();

    // The dashboard route lives outside the shell, so without its own back
    // affordance a restored session would be stuck here (#149).
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('My work'), findsOneWidget);
  });

  testWidgets('my merge requests has a back affordance that returns home', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Merge requests'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('My work'), findsOneWidget);
  });

  // Secondary routes live outside the navigation shell, so they must be pushed
  // onto the stack. Otherwise Android system back exits the app.

  testWidgets('projects has a back affordance that returns home', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.text('Projects'), findsWidgets);

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('My work'), findsOneWidget);
  });

  testWidgets('system back returns from projects to home', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Me'), findsWidgets);
  });

  testWidgets('the Me settings shortcut selects the primary destination', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.byType(BackButton), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      1,
    );
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('My work'), findsOneWidget);
  });

  testWidgets('accounts back returns to me', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    // The entry on Me is labelled for the action, not the destination.
    await tester.tap(find.text('Switch account'));
    await tester.pumpAndSettle();
    expect(find.text('Accounts'), findsWidgets);

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Me'), findsWidgets);
  });
}
