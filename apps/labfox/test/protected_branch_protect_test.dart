import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';
import 'package:labfox/features/protected_branches/presentation/protected_branches_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

import 'protected_branch_protect_controller_test.dart'
    show ProtectBranchRepository;

Future<void> pumpProtectBranch(
  WidgetTester tester,
  ProtectBranchRepository repository, {
  double width = 390,
  bool dark = false,
  String locale = 'en',
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/protected_branches',
    routes: [
      GoRoute(
        path: '/projects/:id/protected_branches',
        builder: (_, state) => const ProtectedBranchesScreen(projectId: 7),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        protectedBranchesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('entry opens a draft without writing', (tester) async {
    final repository = ProtectBranchRepository();
    await pumpProtectBranch(tester, repository);
    await tester.tap(find.byKey(const ValueKey('protected-branch-protect')));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(find.byKey(const ValueKey('protected-branch-name')), findsOneWidget);
  });
  testWidgets('acknowledgement creates conservative 0 push and 40 merge rule', (
    tester,
  ) async {
    final repository = ProtectBranchRepository();
    await pumpProtectBranch(tester, repository);
    await tester.tap(find.byKey(const ValueKey('protected-branch-protect')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('protected-branch-name')),
      'release/*',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('protected-branch-submit')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('protected-branch-ack')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-branch-submit')));
    await tester.pumpAndSettle();
    expect(repository.writes.single, (name: 'release/*', push: 0, merge: 40));
  });
  testWidgets('uncertain write needs a fresh inventory before retry', (
    tester,
  ) async {
    final repository = ProtectBranchRepository()
      ..writeFailure = const GitLabConnectionException('network');
    await pumpProtectBranch(tester, repository);
    await tester.tap(find.byKey(const ValueKey('protected-branch-protect')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('protected-branch-name')),
      'v*',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-branch-ack')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-branch-submit')));
    await tester.pumpAndSettle();
    expect(repository.writes, hasLength(1));
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('protected-branch-submit')),
          )
          .onPressed,
      isNull,
    );
    repository.writeFailure = null;
    await tester.ensureVisible(
      find.byKey(const ValueKey('protected-branch-reload')),
    );
    await tester.tap(find.byKey(const ValueKey('protected-branch-reload')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('protected-branch-ack')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-branch-submit')));
    await tester.pumpAndSettle();
    expect(repository.writes, hasLength(2));
  });
  testWidgets('second-page exact duplicate blocks creation', (tester) async {
    final repository = ProtectBranchRepository();
    repository.pages[1] = const Paginated(items: [], nextPage: 2);
    repository.pages[2] = const Paginated(items: [ProtectedBranch(name: 'v*')]);
    await pumpProtectBranch(tester, repository);
    await tester.tap(find.byKey(const ValueKey('protected-branch-protect')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('protected-branch-name')),
      'v*',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-branch-ack')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('protected-branch-submit')));
    await tester.pumpAndSettle();
    expect(repository.reads, contains(2));
    expect(repository.writes, isEmpty);
  });
  testWidgets(
    'changing either role resets acknowledgement and sends both exact choices',
    (tester) async {
      final repository = ProtectBranchRepository();
      await pumpProtectBranch(tester, repository);
      await tester.tap(find.byKey(const ValueKey('protected-branch-protect')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('protected-branch-name')),
        'main',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('protected-branch-ack')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('protected-branch-push')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developers and Maintainers').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-branch-submit')),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const ValueKey('protected-branch-merge')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No one').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('protected-branch-ack')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('protected-branch-submit')));
      await tester.pumpAndSettle();
      expect(repository.writes.single, (name: 'main', push: 30, merge: 0));
    },
  );
  for (final width in [320.0, 800.0, 1200.0]) {
    for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
      for (final dark in [false, true]) {
        testWidgets('draft fits $width in $locale ${dark ? 'dark' : 'light'}', (
          tester,
        ) async {
          await pumpProtectBranch(
            tester,
            ProtectBranchRepository(),
            width: width,
            locale: locale,
            dark: dark,
          );
          await tester.tap(
            find.byKey(const ValueKey('protected-branch-protect')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('protected-branch-submit')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
