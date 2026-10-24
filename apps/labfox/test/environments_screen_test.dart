import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/environments/presentation/controllers/environments_controller.dart';
import 'package:labfox/features/environments/presentation/environment_detail_screen.dart';
import 'package:labfox/features/environments/presentation/environments_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _List extends EnvironmentListController {
  @override
  Future<Paginated<GitLabEnvironment>> build(EnvironmentListRef arg) async =>
      Paginated(
        items: [
          GitLabEnvironment(
            id: 9,
            name: 'production',
            state: arg.state ?? 'available',
          ),
        ],
      );
}

void main() {
  testWidgets('filters environments and opens detail on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/projects/7/environments',
      routes: [
        GoRoute(
          path: '/projects/:id/environments',
          builder: (_, state) => EnvironmentsScreen(
            projectId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/projects/:id/environments/:environmentId',
          builder: (_, state) => EnvironmentDetailScreen(
            projectId: int.parse(state.pathParameters['id']!),
            environmentId: int.parse(state.pathParameters['environmentId']!),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          environmentListControllerProvider.overrideWith(_List.new),
          environmentDetailProvider.overrideWith(
            (ref, key) async => const GitLabEnvironment(
              id: 9,
              name: 'production',
              state: 'available',
              externalUrl: 'https://example.com',
              lastDeployment: EnvironmentDeployment(id: 42, status: 'success'),
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('production'), findsOneWidget);
    await tester.drag(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListView && widget.scrollDirection == Axis.horizontal,
      ),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stopped'));
    await tester.pumpAndSettle();
    expect(find.text('production'), findsOneWidget);
    await tester.tap(find.text('production'));
    await tester.pumpAndSettle();
    expect(find.text('Latest deployment'), findsOneWidget);
  });
}
