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
  _FakeRepository({this.files = const [SnippetFile(path: 'deploy.sh')]})
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'x'));

  final List<SnippetFile> files;
  String content = 'echo old';
  final Map<String, String> fileContents = {
    'a.sh': 'echo a',
    'nested/b.sh': 'echo b',
  };
  String? updatedPath;
  bool rejectUpdate = false;
  int rawCalls = 0;
  int fileCalls = 0;
  bool rejectFileLoad = false;

  Snippet get snippet => Snippet(
    id: 73,
    title: 'Deploy helper',
    fileName: files.isEmpty ? 'legacy.sh' : files.first.path,
    files: files,
  );

  @override
  Future<List<Snippet>> list(int projectId) async => [snippet];

  @override
  Future<Snippet> get(int projectId, int snippetId) async => snippet;

  @override
  Future<String> raw(int projectId, int snippetId) async {
    rawCalls++;
    return content;
  }

  @override
  Future<String> file(int projectId, int snippetId, SnippetFile file) async {
    fileCalls++;
    if (rejectFileLoad) throw const GitLabForbiddenException('Forbidden');
    return fileContents[file.path]!;
  }

  @override
  Future<Snippet> updateFileContent(
    int projectId,
    int snippetId, {
    required String filePath,
    required String content,
  }) async {
    if (rejectUpdate) throw const GitLabForbiddenException('Forbidden');
    updatedPath = filePath;
    this.content = content;
    if (fileContents.containsKey(filePath)) fileContents[filePath] = content;
    return snippet;
  }
}

void main() {
  test('saving content refreshes the raw snippet provider', () async {
    final repository = _FakeRepository();
    const key = SnippetRef(42, 73);
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(snippetRawProvider(key).future), 'echo old');

    await container
        .read(updateSnippetContentControllerProvider.notifier)
        .saveContent(
          projectId: 42,
          snippetId: 73,
          filePath: 'deploy.sh',
          content: 'echo ready',
        );

    expect(repository.updatedPath, 'deploy.sh');
    expect(await container.read(snippetRawProvider(key).future), 'echo ready');
    expect(repository.rawCalls, 2);
  });

  test('saving one multi-file content refreshes that file provider', () async {
    final repository = _FakeRepository(
      files: const [
        SnippetFile(path: 'a.sh'),
        SnippetFile(path: 'nested/b.sh'),
      ],
    );
    const key = SnippetFileRef(42, 73, 'nested/b.sh');
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(snippetFileProvider(key).future), 'echo b');

    await container
        .read(updateSnippetContentControllerProvider.notifier)
        .saveContent(
          projectId: 42,
          snippetId: 73,
          filePath: 'nested/b.sh',
          content: 'echo updated',
        );

    expect(repository.updatedPath, 'nested/b.sh');
    expect(
      await container.read(snippetFileProvider(key).future),
      'echo updated',
    );
    expect(repository.fileCalls, 2);
    expect(repository.fileContents['a.sh'], 'echo a');
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('edits single-file content at width $width', (tester) async {
      final repository = _FakeRepository();
      await _pump(tester, repository, width);

      await tester.tap(find.text('Edit content'));
      await tester.pumpAndSettle();
      expect(find.text('echo old'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'echo ready');
      await tester.tap(find.text('Save content'));
      await tester.pumpAndSettle();

      expect(repository.updatedPath, 'deploy.sh');
      expect(repository.content, 'echo ready');
      expect(find.text('echo ready'), findsOneWidget);
    });
  }

  testWidgets('retains a failed content draft', (tester) async {
    final repository = _FakeRepository()..rejectUpdate = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.text('Edit content'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'echo draft');
    await tester.tap(find.text('Save content'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save snippet content.'), findsOneWidget);
    expect(find.text('echo draft'), findsOneWidget);
    expect(repository.content, 'echo old');
  });

  testWidgets('uses the legacy file name when files are absent', (
    tester,
  ) async {
    final repository = _FakeRepository(files: const []);
    await _pump(tester, repository, 390);
    await tester.tap(find.text('Edit content'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save content'));
    await tester.pumpAndSettle();

    expect(repository.updatedPath, 'legacy.sh');
  });

  testWidgets('does not offer single-file editing for multi-file snippets', (
    tester,
  ) async {
    final repository = _FakeRepository(
      files: const [
        SnippetFile(path: 'a.sh'),
        SnippetFile(path: 'b.sh'),
      ],
    );
    await _pump(tester, repository, 390);

    expect(find.text('Edit content'), findsNothing);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets(
      'edits one file from a direct multi-file link at width $width',
      (tester) async {
        final repository = _FakeRepository(
          files: const [
            SnippetFile(path: 'a.sh'),
            SnippetFile(path: 'nested/b.sh'),
          ],
        );
        await _pump(
          tester,
          repository,
          width,
          initialLocation: '/projects/42/snippets/73/file?path=nested%2Fb.sh',
        );

        expect(find.text('echo b'), findsOneWidget);
        await tester.tap(find.byTooltip('Edit content'));
        await tester.pumpAndSettle();
        expect(find.text('nested/b.sh'), findsWidgets);
        await tester.enterText(find.byType(TextField), 'echo updated');
        await tester.tap(find.text('Save content'));
        await tester.pumpAndSettle();

        expect(repository.updatedPath, 'nested/b.sh');
        expect(find.text('echo updated'), findsOneWidget);
        expect(repository.fileContents['a.sh'], 'echo a');
      },
    );
  }

  testWidgets('retains a forbidden multi-file draft', (tester) async {
    final repository = _FakeRepository(
      files: const [
        SnippetFile(path: 'a.sh'),
        SnippetFile(path: 'nested/b.sh'),
      ],
    )..rejectUpdate = true;
    await _pump(
      tester,
      repository,
      390,
      initialLocation: '/projects/42/snippets/73/file?path=nested%2Fb.sh',
    );

    await tester.tap(find.byTooltip('Edit content'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'draft');
    await tester.tap(find.text('Save content'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save snippet content.'), findsOneWidget);
    expect(find.text('draft'), findsOneWidget);
    expect(repository.fileContents['nested/b.sh'], 'echo b');
  });

  testWidgets('does not offer editing when a file cannot load', (tester) async {
    final repository = _FakeRepository(
      files: const [
        SnippetFile(path: 'a.sh'),
        SnippetFile(path: 'nested/b.sh'),
      ],
    )..rejectFileLoad = true;
    await _pump(
      tester,
      repository,
      390,
      initialLocation: '/projects/42/snippets/73/file?path=nested%2Fb.sh',
    );

    expect(find.byTooltip('Edit content'), findsNothing);
    expect(find.text("Couldn't load snippet content."), findsOneWidget);
  });

  testWidgets('does not offer editing for a missing file path', (tester) async {
    final repository = _FakeRepository(
      files: const [
        SnippetFile(path: 'a.sh'),
        SnippetFile(path: 'nested/b.sh'),
      ],
    );
    await _pump(
      tester,
      repository,
      390,
      initialLocation: '/projects/42/snippets/73/file?path=missing.sh',
    );

    expect(find.byTooltip('Edit content'), findsNothing);
    expect(find.text("Couldn't load snippet content."), findsOneWidget);
    expect(repository.fileCalls, 0);
  });
}

Future<void> _pump(
  WidgetTester tester,
  _FakeRepository repository,
  double width, {
  String initialLocation = '/projects/42/snippets/73',
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/projects/:id/snippets/:snippetId',
        builder: (_, state) => SnippetDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          snippetId: int.parse(state.pathParameters['snippetId']!),
        ),
      ),
      GoRoute(
        path: '/projects/:id/snippets/:snippetId/file',
        builder: (_, state) => SnippetFileScreen(
          projectId: int.parse(state.pathParameters['id']!),
          snippetId: int.parse(state.pathParameters['snippetId']!),
          path: state.uri.queryParameters['path']!,
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
