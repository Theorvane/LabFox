import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/deployments/presentation/controllers/deployments_controller.dart';
import 'package:labfox/features/deployments/presentation/deployment_detail_screen.dart';
import 'package:labfox/features/deployments/presentation/deployments_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _List extends DeploymentListController {
  @override
  Future<Paginated<GitLabDeployment>> build(DeploymentListRef arg) async =>
      Paginated(
        items: [
          GitLabDeployment(
            id: 42,
            iid: 2,
            status: arg.status ?? 'success',
            environment: const DeploymentEnvironment(id: 9, name: 'production'),
          ),
        ],
      );
}

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/deployments?environment=production',
    routes: [
      GoRoute(
        path: '/projects/:id/deployments',
        builder: (_, state) => DeploymentsScreen(
          projectId: int.parse(state.pathParameters['id']!),
          initialEnvironment: state.uri.queryParameters['environment'],
        ),
      ),
      GoRoute(
        path: '/projects/:id/deployments/:deploymentId',
        builder: (_, state) => DeploymentDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          deploymentId: int.parse(state.pathParameters['deploymentId']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/pipelines/:pipelineId',
        builder: (_, state) => Scaffold(
          body: Text('Pipeline ${state.pathParameters['pipelineId']}'),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deploymentListControllerProvider.overrideWith(_List.new),
        deploymentDetailProvider.overrideWith(
          (ref, key) async => const GitLabDeployment(
            id: 42,
            iid: 2,
            status: 'success',
            ref: 'main',
            sha: 'a91957a8',
            environment: DeploymentEnvironment(id: 9, name: 'production'),
            deployable: DeploymentJob(
              id: 664,
              name: 'deploy',
              pipeline: DeploymentPipeline(id: 37, status: 'success'),
            ),
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
}

void main() {
  testWidgets('opens deployment detail by global id on mobile', (tester) async {
    await _pump(tester, const Size(390, 844));
    final tile = find.ancestor(
      of: find.text('production'),
      matching: find.byType(ListTile),
    );
    expect(tile, findsOneWidget);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('Deployment #2'), findsOneWidget);
    expect(find.text('Pipeline'), findsOneWidget);
  });

  testWidgets('shows deployment detail and pipeline link on wide screens', (
    tester,
  ) async {
    await _pump(tester, const Size(1200, 800));
    await tester.tap(
      find.ancestor(
        of: find.text('production'),
        matching: find.byType(ListTile),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Pipeline'));
    await tester.pumpAndSettle();
    expect(find.text('Pipeline 37'), findsOneWidget);
  });
}
