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
  _FakeRepository({this.singleFile = false})
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'x'));

  final bool singleFile;
  bool rejectMove = false;
  String? previousPath;
  String? movedPath;
  int detailCalls = 0;

  @override
  Future<Snippet> get(int projectId, int snippetId) async {
    detailCalls++;
    return Snippet(
      id: 73,
      title: 'Deploy helper',
      files: [
        SnippetFile(path: movedPath ?? 'scripts/deploy.sh'),
        if (!singleFile) const SnippetFile(path: 'README.md'),
      ],
    );
  }

  @override
  Future<String> file(int projectId, int snippetId, SnippetFile file) async =>
      'echo ready';

  @override
  Future<String> raw(int projectId, int snippetId) async => 'echo ready';

  @override
  Future<Snippet> moveFile(
    int projectId,
    int snippetId, {
    required String previousPath,
    required String filePath,
  }) async {
    if (rejectMove) throw const GitLabForbiddenException('Forbidden');
    this.previousPath = previousPath;
    movedPath = filePath;
    return get(projectId, snippetId);
  }
}

void main() {
  test('a successful move refreshes snippet detail', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    const key = SnippetRef(42, 73);
    expect(
      (await container.read(
        projectSnippetProvider(key).future,
      )).files.first.path,
      'scripts/deploy.sh',
    );

    await container
        .read(moveSnippetFileControllerProvider.notifier)
        .move(
          projectId: 42,
          snippetId: 73,
          previousPath: 'scripts/deploy.sh',
          filePath: 'bin/deploy.sh',
        );

    expect(repository.previousPath, 'scripts/deploy.sh');
    expect(
      (await container.read(
        projectSnippetProvider(key).future,
      )).files.first.path,
      'bin/deploy.sh',
    );
  });

  test('rejects a conflicting destination before sending a write', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(moveSnippetFileControllerProvider.notifier)
          .move(
            projectId: 42,
            snippetId: 73,
            previousPath: 'scripts/deploy.sh',
            filePath: 'README.md',
          ),
      throwsStateError,
    );
    expect(repository.movedPath, isNull);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('moves a file from its deep link at width $width', (
      tester,
    ) async {
      final repository = _FakeRepository();
      await _pump(tester, repository, width);
      await tester.tap(find.byTooltip('Move file'));
      await tester.pumpAndSettle();
      expect(find.text('scripts/deploy.sh'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'bin/deploy.sh');
      await tester.tap(find.text('Move file').last);
      await tester.pumpAndSettle();

      expect(repository.previousPath, 'scripts/deploy.sh');
      expect(repository.movedPath, 'bin/deploy.sh');
      expect(find.byType(SnippetFileScreen), findsOneWidget);
      expect(find.text('bin/deploy.sh'), findsWidgets);
    });
  }

  testWidgets('rejects invalid and duplicate paths without moving', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Move file'));
    await tester.pumpAndSettle();
    for (final path in ['scripts/deploy.sh', '../escape.sh', 'README.md']) {
      await tester.enterText(find.byType(TextField), path);
      await tester.tap(find.text('Move file').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a different, unused relative file path.'),
        findsOneWidget,
      );
      expect(repository.movedPath, isNull);
    }
  });

  testWidgets('keeps the draft open after a forbidden move', (tester) async {
    final repository = _FakeRepository()..rejectMove = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Move file'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'bin/deploy.sh');
    await tester.tap(find.text('Move file').last);
    await tester.pumpAndSettle();

    expect(find.text('Could not move the file.'), findsOneWidget);
    expect(find.text('bin/deploy.sh'), findsOneWidget);
    expect(repository.movedPath, isNull);
  });

  testWidgets('renames a single-file snippet from its detail screen', (
    tester,
  ) async {
    final repository = _FakeRepository(singleFile: true);
    await _pump(tester, repository, 390, directFile: false);
    await tester.tap(find.byTooltip('Move file'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'renamed.sh');
    await tester.tap(find.text('Move file').last);
    await tester.pumpAndSettle();

    expect(repository.movedPath, 'renamed.sh');
    expect(find.text('renamed.sh'), findsOneWidget);
    expect(find.byType(SnippetDetailScreen), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  _FakeRepository repository,
  double width, {
  bool directFile = true,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: directFile
        ? '/projects/42/snippets/73/file?path=scripts%2Fdeploy.sh'
        : '/projects/42/snippets/73',
    routes: [
      GoRoute(
        path: '/projects/:id/snippets/:snippetId',
        builder: (_, state) => SnippetDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          snippetId: int.parse(state.pathParameters['snippetId']!),
        ),
        routes: [
          GoRoute(
            path: 'file',
            builder: (_, state) => SnippetFileScreen(
              projectId: int.parse(state.pathParameters['id']!),
              snippetId: int.parse(state.pathParameters['snippetId']!),
              path: state.uri.queryParameters['path']!,
            ),
          ),
        ],
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
