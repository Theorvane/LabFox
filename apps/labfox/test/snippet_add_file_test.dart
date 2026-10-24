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

  final files = <SnippetFile>[const SnippetFile(path: 'deploy.sh')];
  bool rejectAdd = false;
  int addCalls = 0;
  int getCalls = 0;
  int listCalls = 0;
  String? addedPath;
  String? addedContent;

  Snippet get snippet => Snippet(
    id: 73,
    title: 'Deploy helper',
    fileName: 'deploy.sh',
    files: List.of(files),
  );

  @override
  Future<Snippet> get(int projectId, int snippetId) async {
    getCalls++;
    return snippet;
  }

  @override
  Future<List<Snippet>> list(int projectId) async {
    listCalls++;
    return [snippet];
  }

  @override
  Future<String> raw(int projectId, int snippetId) async => 'echo old';

  @override
  Future<Snippet> addFile(
    int projectId,
    int snippetId, {
    required String filePath,
    required String content,
  }) async {
    addCalls++;
    if (rejectAdd) throw const GitLabForbiddenException('Forbidden');
    addedPath = filePath;
    addedContent = content;
    files.add(SnippetFile(path: filePath));
    return snippet;
  }
}

void main() {
  test('adding a file refreshes project snippet detail and list', () async {
    final repository = _FakeRepository();
    const key = SnippetRef(42, 73);
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(
      (await container.read(projectSnippetProvider(key).future)).files,
      hasLength(1),
    );
    expect(
      (await container.read(projectSnippetsProvider(42).future)).single.files,
      hasLength(1),
    );

    await container
        .read(addSnippetFileControllerProvider.notifier)
        .addFile(
          projectId: 42,
          snippetId: 73,
          filePath: 'scripts/release.sh',
          content: 'echo release',
        );

    expect(
      (await container.read(projectSnippetProvider(key).future)).files,
      hasLength(2),
    );
    expect(
      (await container.read(projectSnippetsProvider(42).future)).single.files,
      hasLength(2),
    );
    expect(repository.getCalls, 2);
    expect(repository.listCalls, 2);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('adds a file from a direct snippet link at width $width', (
      tester,
    ) async {
      final repository = _FakeRepository();
      await _pump(tester, repository, width);

      await tester.tap(find.byTooltip('Add file'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'File path'),
        'scripts/release.sh',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Content'),
        'echo release',
      );
      await tester.tap(find.text('Add file').last);
      await tester.pumpAndSettle();

      expect(repository.addedPath, 'scripts/release.sh');
      expect(repository.addedContent, 'echo release');
      expect(find.text('deploy.sh'), findsOneWidget);
      expect(find.text('scripts/release.sh'), findsOneWidget);
    });
  }

  testWidgets('rejects duplicate and unsafe paths before calling the API', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Add file'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'File path'),
      'new.sh',
    );
    await tester.tap(find.text('Add file').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a unique relative file path and content.'),
      findsOneWidget,
    );
    await tester.enterText(find.widgetWithText(TextField, 'Content'), 'hello');

    for (final path in ['deploy.sh', '../bad', '/bad', 'a\\b', 'a//b']) {
      await tester.enterText(find.widgetWithText(TextField, 'File path'), path);
      await tester.tap(find.text('Add file').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a unique relative file path and content.'),
        findsOneWidget,
      );
    }
    expect(repository.addCalls, 0);
  });

  testWidgets('retains the draft after a forbidden file addition', (
    tester,
  ) async {
    final repository = _FakeRepository()..rejectAdd = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Add file'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'File path'),
      'new.sh',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Content'), 'draft');
    await tester.tap(find.text('Add file').last);
    await tester.pumpAndSettle();

    expect(find.text('Could not add the file.'), findsOneWidget);
    expect(find.text('draft'), findsOneWidget);
    expect(repository.files, hasLength(1));
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
