import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';
import 'package:labfox/features/protected_environments/presentation/protected_environment_detail_screen.dart';
import 'package:labfox/features/protected_environments/presentation/protected_environments_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _rule = ProtectedEnvironment(
  name: 'review/production',
  requiredApprovalCount: 2,
  deployAccessLevels: [ProtectedEnvironmentAccess(description: 'Maintainers')],
  approvalRules: [
    ProtectedEnvironmentAccess(
      description: 'Release team',
      requiredApprovals: 2,
    ),
  ],
);

const _groupRule = ProtectedEnvironment(
  name: 'production',
  requiredApprovalCount: 2,
  deployAccessLevels: [ProtectedEnvironmentAccess(description: 'Maintainers')],
  approvalRules: [
    ProtectedEnvironmentAccess(
      description: 'Security team',
      requiredApprovals: 2,
    ),
  ],
);

class _List extends ProtectedEnvironmentsController {
  @override
  Future<Paginated<ProtectedEnvironment>> build(int projectId) async =>
      const Paginated(items: [_rule]);
}

class _Forbidden extends ProtectedEnvironmentsController {
  @override
  Future<Paginated<ProtectedEnvironment>> build(int projectId) async =>
      throw const GitLabForbiddenException('Forbidden', statusCode: 403);
}

class _GroupList extends GroupProtectedEnvironmentsController {
  @override
  Future<Paginated<ProtectedEnvironment>> build(int groupId) async =>
      const Paginated(items: [_groupRule]);
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/protected_environments',
    routes: [
      GoRoute(
        path: '/projects/:id/protected_environments',
        builder: (_, state) => ProtectedEnvironmentsScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: ':name',
            builder: (_, state) => ProtectedEnvironmentDetailScreen(
              projectId: int.parse(state.pathParameters['id']!),
              name: state.pathParameters['name']!,
            ),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        protectedEnvironmentsControllerProvider.overrideWith(_List.new),
        protectedEnvironmentDetailProvider.overrideWith(
          (ref, key) async => _rule,
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final size in [const Size(320, 720), const Size(1200, 800)]) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        testWidgets(
          'creation dialog fits $language ${size.width} $brightness',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(ProviderScope(
              overrides: [
                protectedEnvironmentsControllerProvider.overrideWith(_List.new),
              ],
              child: MaterialApp(
                locale: Locale(language),
                theme: ThemeData(brightness: brightness),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const ProtectedEnvironmentsScreen(projectId: 7),
              ),
            ));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(
              const ValueKey('protected-environment-create-open'),
            ));
            await tester.pumpAndSettle();
            expect(find.byKey(
              const ValueKey('protected-environment-create-name'),
            ), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets(
    'project creation requires an exact name, role and acknowledgement',
    (tester) async {
      await _pump(tester, const Size(390, 844));
      await tester.tap(
        find.byKey(const ValueKey('protected-environment-create-open')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Protect environment'), findsWidgets);
      expect(
        find.byKey(const ValueKey('protected-environment-create-save')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-environment-create-save')),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('protected-environment-create-name')),
        'production',
      );
      await tester.tap(
        find.byKey(const ValueKey('protected-environment-create-role-40')),
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('protected-environment-create-save')),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  for (final size in [const Size(390, 844), const Size(1200, 800)]) {
    testWidgets('opens group deployment rules at ${size.width}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        initialLocation: '/groups/5/protected_environments',
        routes: [
          GoRoute(
            path: '/groups/:id/protected_environments',
            builder: (_, state) => ProtectedEnvironmentsScreen.group(
              groupId: int.parse(state.pathParameters['id']!),
            ),
            routes: [
              GoRoute(
                path: ':name',
                builder: (_, state) => ProtectedEnvironmentDetailScreen.group(
                  groupId: int.parse(state.pathParameters['id']!),
                  name: state.pathParameters['name']!,
                ),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupProtectedEnvironmentsControllerProvider.overrideWith(
              _GroupList.new,
            ),
            groupProtectedEnvironmentDetailProvider.overrideWith(
              (ref, key) async => _groupRule,
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('production'));
      await tester.pumpAndSettle();
      expect(find.text('Allowed to deploy'), findsOneWidget);
      expect(find.text('Approval rules'), findsOneWidget);
      expect(find.text('Security team'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('explains unavailable or forbidden protected environments', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          protectedEnvironmentsControllerProvider.overrideWith(_Forbidden.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProtectedEnvironmentsScreen(projectId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Protected environments are unavailable or you don't have access.",
      ),
      findsOneWidget,
    );
  });

  for (final size in [const Size(390, 844), const Size(1200, 800)]) {
    testWidgets('shows deploy and approval rules at ${size.width}', (
      tester,
    ) async {
      await _pump(tester, size);
      expect(find.text('Protected environments'), findsOneWidget);
      await tester.tap(find.text('review/production'));
      await tester.pumpAndSettle();
      expect(find.text('Allowed to deploy'), findsOneWidget);
      expect(find.text('Maintainers'), findsOneWidget);
      expect(find.text('Approval rules'), findsOneWidget);
      expect(find.text('Release team'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
