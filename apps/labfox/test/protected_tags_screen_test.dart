import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/protected_tags/presentation/controllers/protected_tags_controller.dart';
import 'package:labfox/features/protected_tags/presentation/protected_tag_detail_screen.dart';
import 'package:labfox/features/protected_tags/presentation/protected_tags_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _rule = ProtectedTag(
  name: 'release/*',
  createAccessLevels: [
    ProtectedBranchAccess(accessLevel: 40, description: 'Maintainers'),
    ProtectedBranchAccess(groupId: 20, description: 'Release team'),
  ],
);

class _List extends ProtectedTagsController {
  @override
  Future<Paginated<ProtectedTag>> build(int projectId) async =>
      const Paginated(items: [_rule]);
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/protected_tags',
    routes: [
      GoRoute(
        path: '/projects/:id/protected_tags',
        builder: (_, state) => ProtectedTagsScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: ':name',
            builder: (_, state) => ProtectedTagDetailScreen(
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
        protectedTagsControllerProvider.overrideWith(_List.new),
        protectedTagDetailProvider.overrideWith((ref, key) async => _rule),
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
  testWidgets('opens wildcard rule and shows create permissions on mobile', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));
    expect(find.text('Protected tags'), findsOneWidget);
    await tester.tap(find.text('release/*'));
    await tester.pumpAndSettle();
    expect(find.text('Allowed to create'), findsOneWidget);
    expect(find.text('Maintainers'), findsOneWidget);
    expect(find.text('Release team'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits the rule detail on wide screens', (tester) async {
    await _pump(tester, const Size(1200, 800));
    await tester.tap(find.text('release/*'));
    await tester.pumpAndSettle();
    expect(find.text('Release team'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
