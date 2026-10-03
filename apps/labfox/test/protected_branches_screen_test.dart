import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';
import 'package:labfox/features/protected_branches/presentation/protected_branch_detail_screen.dart';
import 'package:labfox/features/protected_branches/presentation/protected_branches_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _rule = ProtectedBranch(
  id: 100,
  name: 'release/*',
  codeOwnerApprovalRequired: true,
  inherited: true,
  pushAccessLevels: [
    ProtectedBranchAccess(accessLevel: 40, description: 'Maintainers'),
  ],
  mergeAccessLevels: [
    ProtectedBranchAccess(groupId: 1234, description: 'Release team'),
  ],
);

class _List extends ProtectedBranchesController {
  @override
  Future<Paginated<ProtectedBranch>> build(int projectId) async =>
      const Paginated(items: [_rule]);
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/protected_branches',
    routes: [
      GoRoute(
        path: '/projects/:id/protected_branches',
        builder: (_, state) => ProtectedBranchesScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: ':name',
            builder: (_, state) => ProtectedBranchDetailScreen(
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
        protectedBranchesControllerProvider.overrideWith(_List.new),
        protectedBranchDetailProvider.overrideWith((ref, key) async => _rule),
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
  testWidgets('opens a wildcard rule and shows its permissions on mobile', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));
    expect(find.text('Protected branches'), findsOneWidget);
    await tester.tap(find.text('release/*'));
    await tester.pumpAndSettle();
    expect(find.text('Maintainers'), findsOneWidget);
    expect(find.text('Release team'), findsOneWidget);
    expect(find.text('Code owner approval'), findsOneWidget);
    expect(find.text('Unprotect branch rule'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits detail panels on a wide screen', (tester) async {
    await _pump(tester, const Size(1200, 800));
    await tester.tap(find.text('release/*'));
    await tester.pumpAndSettle();
    expect(find.text('Maintainers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
