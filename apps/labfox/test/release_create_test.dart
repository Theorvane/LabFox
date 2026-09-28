import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/releases/data/releases_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';
import 'package:labfox/features/releases/presentation/releases_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _Repository extends ReleasesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final creates =
      <({String tagName, String? ref, String? name, String? description})>[];
  bool reject = false;
  final milestoneSelections = <List<String>?>[];

  @override
  Future<Paginated<GitLabRelease>> list(int projectId, {int page = 1}) async =>
      const Paginated(items: []);

  @override
  Future<GitLabRelease> create(
    int projectId, {
    required String tagName,
    String? ref,
    String? name,
    String? description,
    List<String>? milestones,
  }) async {
    expect(projectId, 7);
    milestoneSelections.add(milestones == null ? null : List.of(milestones));
    creates.add((
      tagName: tagName,
      ref: ref,
      name: name,
      description: description,
    ));
    if (reject) throw const GitLabForbiddenException('Forbidden');
    return GitLabRelease(name: name ?? tagName, tagName: tagName);
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  double width = 390,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/7/releases',
    routes: [
      GoRoute(
        path: '/projects/:id/releases',
        builder: (_, _) => const ReleasesScreen(projectId: 7),
      ),
      GoRoute(
        path: '/projects/:id/releases/:tagName',
        builder: (_, state) => Scaffold(
          body: Text('Created release ${state.pathParameters['tagName']}'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
      ],
      child: MaterialApp.router(
        theme: ThemeData(brightness: brightness),
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('creates with milestone titles at $width $brightness', (
        tester,
      ) async {
        final repository = _Repository()..reject = true;
        await _pump(tester, repository, width: width, brightness: brightness);
        await tester.tap(find.text('New release'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'v2');
        final title = find.widgetWithText(
          TextField,
          'Milestone title (optional)',
        );
        await tester.ensureVisible(title);
        await tester.enterText(title, ' Release, phase 1 ');
        await tester.ensureVisible(find.text('Add milestone'));
        await tester.tap(find.text('Add milestone'));
        await tester.pumpAndSettle();
        await tester.enterText(title, 'Sprint 2');
        await tester.tap(find.text('Create release'));
        await tester.pumpAndSettle();
        expect(repository.milestoneSelections.single, [
          'Release, phase 1',
          'Sprint 2',
        ]);
        expect(find.text('Could not create the release.'), findsOneWidget);
        expect(
          find.widgetWithText(InputChip, 'Release, phase 1'),
          findsOneWidget,
        );
        expect(find.widgetWithText(InputChip, 'Sprint 2'), findsOneWidget);
        repository.reject = false;
        await tester.tap(find.text('Create release'));
        await tester.pumpAndSettle();
        expect(
          repository.milestoneSelections.last,
          repository.milestoneSelections.first,
        );
        expect(find.text('Created release v2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('validates blank and duplicate titles and removes selections', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('New release'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'v2');
    final title = find.widgetWithText(TextField, 'Milestone title (optional)');
    await tester.ensureVisible(title);
    await tester.enterText(title, ' ');
    await tester.ensureVisible(find.text('Add milestone'));
    await tester.tap(find.text('Add milestone'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a milestone title.'), findsOneWidget);
    await tester.enterText(title, 'Sprint 2');
    await tester.tap(find.text('Add milestone'));
    await tester.pumpAndSettle();
    await tester.enterText(title, ' Sprint 2 ');
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(find.text('This milestone is already selected.'), findsOneWidget);
    expect(repository.creates, isEmpty);
    await tester.enterText(title, '');
    await tester.ensureVisible(find.byTooltip('Remove milestone Sprint 2'));
    await tester.tap(find.byTooltip('Remove milestone Sprint 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(repository.milestoneSelections.single, isNull);
  });

  testWidgets('cancel with a pending milestone never creates a release', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('New release'));
    await tester.pumpAndSettle();
    final title = find.widgetWithText(TextField, 'Milestone title (optional)');
    await tester.ensureVisible(title);
    await tester.enterText(title, 'Sprint 2');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.creates, isEmpty);
  });
  for (final width in [390.0, 1200.0]) {
    testWidgets('creates a release from an empty list at width $width', (
      tester,
    ) async {
      final repository = _Repository();
      await _pump(tester, repository, width: width);
      await tester.tap(find.text('New release'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a tag name.'), findsOneWidget);
      expect(repository.creates, isEmpty);

      await tester.enterText(find.byType(TextField).at(0), ' release/2 ');
      await tester.enterText(find.byType(TextField).at(1), ' main ');
      await tester.enterText(find.byType(TextField).at(2), ' Version 2 ');
      await tester.enterText(find.byType(TextField).at(3), '## Changes');
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();
      expect(repository.creates.single, (
        tagName: 'release/2',
        ref: 'main',
        name: 'Version 2',
        description: '## Changes',
      ));
      expect(find.text('Created release release/2'), findsOneWidget);
    });
  }

  testWidgets('keeps a release draft after a forbidden response', (
    tester,
  ) async {
    final repository = _Repository()..reject = true;
    await _pump(tester, repository);
    await tester.tap(find.text('New release'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'v2');
    await tester.enterText(find.byType(TextField).at(3), '## Notes');
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(find.text('Could not create the release.'), findsOneWidget);
    expect(find.text('v2'), findsOneWidget);
    expect(find.text('## Notes'), findsOneWidget);
    repository.reject = false;
    await tester.tap(find.text('Create release'));
    await tester.pumpAndSettle();
    expect(repository.creates.last, (
      tagName: 'v2',
      ref: null,
      name: null,
      description: '## Notes',
    ));
    expect(find.text('Created release v2'), findsOneWidget);
  });
}
