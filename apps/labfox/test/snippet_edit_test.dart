import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/snippets/data/snippets_repository.dart';
import 'package:labfox/features/snippets/presentation/controllers/snippets_controller.dart';
import 'package:labfox/features/snippets/presentation/snippets_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FakeRepository extends SnippetsRepository {
  _FakeRepository()
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'x'));

  Snippet snippet = const Snippet(
    id: 73,
    title: 'Deploy helper',
    description: 'Old notes',
    visibility: 'private',
  );
  bool rejectUpdate = false;
  int getCalls = 0;
  int listCalls = 0;
  int updateCalls = 0;

  @override
  Future<List<Snippet>> list(int projectId) async {
    listCalls++;
    return [snippet];
  }

  @override
  Future<Snippet> get(int projectId, int snippetId) async {
    getCalls++;
    return snippet;
  }

  @override
  Future<String> raw(int projectId, int snippetId) async => 'echo ok';

  @override
  Future<Snippet> updateMetadata(
    int projectId,
    int snippetId, {
    required String title,
    required String description,
    String? visibility,
  }) async {
    updateCalls++;
    if (rejectUpdate) throw const GitLabForbiddenException('Forbidden');
    return snippet = snippet.copyWith(
      title: title,
      description: description,
      visibility: visibility ?? snippet.visibility,
    );
  }
}

void main() {
  test('metadata update refreshes snippet detail and project list', () async {
    final repository = _FakeRepository();
    const key = SnippetRef(42, 73);
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(
      (await container.read(projectSnippetsProvider(42).future)).single.title,
      'Deploy helper',
    );
    expect(
      (await container.read(projectSnippetProvider(key).future)).title,
      'Deploy helper',
    );

    await container
        .read(updateSnippetControllerProvider.notifier)
        .updateMetadata(
          projectId: 42,
          snippetId: 73,
          title: 'Revised',
          description: 'New notes',
        );

    expect(
      (await container.read(projectSnippetsProvider(42).future)).single.title,
      'Revised',
    );
    expect(
      (await container.read(projectSnippetProvider(key).future)).title,
      'Revised',
    );
    expect(repository.listCalls, 2);
    expect(repository.getCalls, 2);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('edits metadata from a direct detail link at width $width', (
      tester,
    ) async {
      final repository = _FakeRepository();
      await _pump(tester, repository, width);

      await tester.tap(find.byTooltip('Edit snippet'));
      await tester.pumpAndSettle();
      expect(find.text('Deploy helper'), findsWidgets);
      expect(find.text('Old notes'), findsWidgets);
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Revised',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'New notes',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(repository.snippet.title, 'Revised');
      expect(repository.snippet.description, 'New notes');
      expect(find.text('Revised'), findsWidgets);
      expect(find.text('New notes'), findsOneWidget);
    });
  }

  for (final width in [390.0, 1200.0]) {
    testWidgets(
      'changes visibility from a direct detail link at width $width',
      (tester) async {
        final repository = _FakeRepository();
        await _pump(tester, repository, width);
        await tester.tap(find.byTooltip('Edit snippet'));
        await tester.pumpAndSettle();

        final visibility = find.widgetWithText(
          DropdownButtonFormField<String>,
          'Visibility',
        );
        expect(visibility, findsOneWidget);
        expect(
          tester
              .widget<DropdownButtonFormField<String>>(visibility)
              .initialValue,
          'private',
        );
        await tester.tap(visibility);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Public').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();

        expect(repository.snippet.visibility, 'public');
        expect(repository.snippet.title, 'Deploy helper');
      },
    );
  }

  testWidgets('does not guess visibility when the API omits it', (
    tester,
  ) async {
    final repository = _FakeRepository();
    repository.snippet = repository.snippet.copyWith(visibility: null);
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Edit snippet'));
    await tester.pumpAndSettle();

    final visibility = find.widgetWithText(
      DropdownButtonFormField<String>,
      'Visibility',
    );
    expect(visibility, findsOneWidget);
    expect(
      tester.widget<DropdownButtonFormField<String>>(visibility).initialValue,
      isNull,
    );
    expect(find.text('Keep current visibility'), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(repository.snippet.visibility, isNull);
  });

  testWidgets('retains the edit draft after a forbidden update', (
    tester,
  ) async {
    final repository = _FakeRepository()..rejectUpdate = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Edit snippet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Draft');
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Visibility'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Public').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save the snippet.'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(repository.snippet.title, 'Deploy helper');
    expect(repository.snippet.visibility, 'private');
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.widgetWithText(DropdownButtonFormField<String>, 'Visibility'),
          )
          .initialValue,
      'public',
    );
  });

  testWidgets('rejects an empty title without calling the API', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Edit snippet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), '  ');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a title.'), findsOneWidget);
    expect(repository.updateCalls, 0);
  });
}

Future<void> _pump(
  WidgetTester tester,
  _FakeRepository repository,
  double width,
) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/projects/42/snippets/73',
    routes: [
      GoRoute(
        path: '/projects/:id/snippets/:snippetId',
        builder: (_, state) => SnippetDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          snippetId: int.parse(state.pathParameters['snippetId']!),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
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
