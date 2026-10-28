import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/project_overview/data/project_overview.dart';
import 'package:labfox/features/project_overview/presentation/controllers/project_overview_controller.dart';
import 'package:labfox/features/project_overview/presentation/project_overview_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubController extends ProjectOverviewController {
  _StubController(this._value);

  final AsyncValue<ProjectOverview> _value;

  @override
  Future<ProjectOverview> build(int projectId) {
    return _value.when(
      data: (d) => Future.value(d),
      loading: () => Completer<ProjectOverview>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<ProjectOverview> value, {
  Size? size,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectOverviewControllerProvider.overrideWith(
          () => _StubController(value),
        ),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        darkTheme: ThemeData.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProjectOverviewScreen(projectId: 1),
      ),
    ),
  );
  await tester.pump();
}

ProjectOverview _overview({String? readme, Project? project}) =>
    ProjectOverview(
      project:
          project ??
          const Project(
            id: 1,
            name: 'backend',
            pathWithNamespace: 'youthpick/backend',
            visibility: 'private',
            starCount: 12,
          ),
      readme: readme,
    );

void main() {
  testWidgets('shows a spinner while loading', (tester) async {
    await _pump(tester, const AsyncLoading());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the header and renders the README', (tester) async {
    await _pump(
      tester,
      AsyncData(_overview(readme: '# Backend\n\nThe service.')),
    );
    await tester.pumpAndSettle();

    expect(find.text('youthpick/backend'), findsOneWidget);
    expect(find.text('private'), findsOneWidget);
    expect(find.byType(MarkdownViewer), findsOneWidget);
    // The section shortcuts render as category tiles.
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Merge requests'), findsOneWidget);
    expect(find.text('Pipelines'), findsOneWidget);
    expect(find.text('Releases'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Wiki'), findsOneWidget);
    expect(find.text('Package registry'), findsOneWidget);
    expect(find.text('Milestones'), findsOneWidget);
  });

  testWidgets('shows a no-README message, not a blank, when there is none', (
    tester,
  ) async {
    await _pump(tester, AsyncData(_overview(readme: null)));
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownViewer), findsNothing);
    expect(find.textContaining('no README'), findsOneWidget);
  });

  testWidgets('shows an error with retry on failure', (tester) async {
    await _pump(tester, AsyncError(Exception('boom'), StackTrace.current));
    await tester.pump();

    expect(find.textContaining('Could not load this project'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('shows counts, the code section, and flat category rows', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(
        _overview(
          project: const Project(
            id: 1,
            name: 'backend',
            pathWithNamespace: 'youthpick/backend',
            visibility: 'private',
            starCount: 12,
            defaultBranch: 'main',
            openIssuesCount: 6,
            forksCount: 3,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The open-issue count sits on the Issues row, the fork count in the
    // header next to the stars.
    expect(find.text('6'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    // The code section shows the default branch and a browse entry, replacing
    // the old Repository / Branches rows.
    expect(find.text('main'), findsOneWidget);
    expect(find.text('Browse code'), findsOneWidget);
    expect(find.text('Repository'), findsNothing);
    expect(find.text('Branches'), findsNothing);
    // Rows are flat launcher rows, not chevroned list tiles.
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('hides counts and the code section on a reduced payload', (
    tester,
  ) async {
    // No default branch (empty repo) and no counts: the rows still render,
    // without dead entries or false zeros.
    await _pump(tester, AsyncData(_overview()));
    await tester.pumpAndSettle();

    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Browse code'), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('hides container registry when GitLab disables it', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(
        _overview(
          project: const Project(
            id: 1,
            name: 'backend',
            pathWithNamespace: 'youthpick/backend',
            containerRegistryAccessLevel: 'disabled',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Container registry'), findsNothing);
  });

  testWidgets('hides the wiki entry when the project disables it', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(
        _overview(
          project: const Project(
            id: 1,
            name: 'backend',
            pathWithNamespace: 'team/backend',
            wikiAccessLevel: 'disabled',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wiki'), findsNothing);
  });

  testWidgets('hides the package entry when the registry is disabled', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(
        _overview(
          project: const Project(
            id: 1,
            name: 'tools',
            pathWithNamespace: 'team/tools',
            packageRegistryAccessLevel: 'disabled',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Package registry'), findsNothing);
  });

  testWidgets('shows the project description beneath its identity', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(
        _overview(
          project: const Project(
            id: 1,
            name: 'backend',
            pathWithNamespace: 'youthpick/backend',
            description: 'Backend service',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backend service'), findsOneWidget);
  });

  testWidgets('stacks navigation above README on a phone', (tester) async {
    await _pump(
      tester,
      AsyncData(_overview(readme: '# Backend')),
      size: const Size(390, 1200),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byType(MarkdownViewer)).dy,
      greaterThan(tester.getTopLeft(find.text('Issues')).dy),
    );
  });

  testWidgets('places navigation beside README on a wide screen', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(_overview(readme: '# Backend')),
      size: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    final navigation = tester.getTopLeft(find.text('Issues'));
    final readme = tester.getTopLeft(find.byType(MarkdownViewer));
    expect(readme.dx, greaterThan(navigation.dx + 250));
    expect((readme.dy - navigation.dy).abs(), lessThan(200));
  });

  testWidgets('fits the two-pane layout on a compact dark tablet', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(_overview(readme: '# Backend')),
      size: const Size(600, 800),
      themeMode: ThemeMode.dark,
    );
    await tester.pumpAndSettle();

    final navigation = tester.getRect(find.text('Issues'));
    final readme = tester.getRect(find.byType(MarkdownViewer));
    expect(readme.left, greaterThan(navigation.right));
    expect(readme.width, greaterThan(260));
    expect(readme.right, lessThanOrEqualTo(600));
    expect(tester.takeException(), isNull);
  });
}
