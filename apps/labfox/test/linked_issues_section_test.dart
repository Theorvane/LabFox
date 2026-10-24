import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/controllers/linked_issues_controller.dart';
import 'package:labfox/features/issues/presentation/widgets/linked_issues_section.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Links extends LinkedIssuesController {
  @override
  Future<Paginated<IssueLink>> build(IssueRef arg) async => const Paginated(
    items: [
      IssueLink(
        id: 84,
        iid: 14,
        projectId: 4,
        title: 'Fix authentication',
        state: 'opened',
        linkType: 'blocks',
      ),
    ],
  );
}

void main() {
  testWidgets('shows the relationship and opens a cross-project issue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/source',
      routes: [
        GoRoute(
          path: '/source',
          builder: (_, _) =>
              const Scaffold(body: LinkedIssuesSection(projectId: 1, iid: 7)),
        ),
        GoRoute(
          path: '/projects/:id/issues/:iid',
          builder: (_, state) => Scaffold(
            body: Text(
              'Issue ${state.pathParameters['id']} #${state.pathParameters['iid']}',
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [linkedIssuesControllerProvider.overrideWith(_Links.new)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Linked issues'), findsOneWidget);
    expect(find.textContaining('Blocks'), findsOneWidget);
    expect(find.text('Fix authentication'), findsOneWidget);
    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpAndSettle();
    expect(find.text('Fix authentication'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Fix authentication'));
    await tester.pumpAndSettle();
    expect(find.text('Issue 4 #14'), findsOneWidget);
  });
}
