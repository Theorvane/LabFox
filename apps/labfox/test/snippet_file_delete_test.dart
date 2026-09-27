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
  bool rejectDelete = false;
  String? deletedPath;
  int detailCalls = 0;

  @override
  Future<Snippet> get(int projectId, int snippetId) async {
    detailCalls++;
    return Snippet(
      id: 73,
      title: 'Deploy helper',
      files: [
        const SnippetFile(path: 'scripts/deploy.sh'),
        if (!singleFile && deletedPath == null)
          const SnippetFile(path: 'README.md'),
      ],
    );
  }

  @override
  Future<String> file(int projectId, int snippetId, SnippetFile file) async =>
      'echo ready';

  @override
  Future<Snippet> deleteFile(
    int projectId,
    int snippetId, {
    required String filePath,
  }) async {
    if (rejectDelete) throw const GitLabForbiddenException('Forbidden');
    deletedPath = filePath;
    return get(projectId, snippetId);
  }
}

void main() {
  test('successful file deletion refreshes snippet detail', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    const key = SnippetRef(42, 73);
    expect(
      (await container.read(projectSnippetProvider(key).future)).files,
      hasLength(2),
    );

    await container
        .read(deleteSnippetFileControllerProvider.notifier)
        .delete(projectId: 42, snippetId: 73, filePath: 'README.md');

    expect(repository.deletedPath, 'README.md');
    expect(
      (await container.read(projectSnippetProvider(key).future)).files,
      hasLength(1),
    );
    expect(repository.detailCalls, greaterThanOrEqualTo(2));
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('confirms file deletion at width $width', (tester) async {
      final repository = _FakeRepository();
      await _pump(tester, repository, width);

      expect(find.byTooltip('Delete file'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete file'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this file?'), findsOneWidget);
      expect(find.text('scripts/deploy.sh'), findsOneWidget);
      expect(repository.deletedPath, isNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.deletedPath, isNull);

      await tester.tap(find.byTooltip('Delete file'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete file').last);
      await tester.pumpAndSettle();

      expect(repository.deletedPath, 'scripts/deploy.sh');
      expect(find.byType(SnippetDetailScreen), findsOneWidget);
    });
  }

  testWidgets('does not offer deletion for the last file', (tester) async {
    await _pump(tester, _FakeRepository(singleFile: true), 390);
    expect(find.byTooltip('Delete file'), findsNothing);
  });

  testWidgets('keeps file and dialog open on forbidden response', (
    tester,
  ) async {
    final repository = _FakeRepository()..rejectDelete = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Delete file'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete file').last);
    await tester.pumpAndSettle();

    expect(find.text('Could not delete the file.'), findsOneWidget);
    expect(find.byType(SnippetFileScreen), findsOneWidget);
    expect(repository.deletedPath, isNull);
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
    initialLocation: '/projects/42/snippets/73/files/scripts%2Fdeploy.sh',
    routes: [
      GoRoute(
        path: '/projects/:id/snippets/:snippetId',
        builder: (_, state) => SnippetDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
          snippetId: int.parse(state.pathParameters['snippetId']!),
        ),
        routes: [
          GoRoute(
            path: 'files/:path',
            builder: (_, state) => SnippetFileScreen(
              projectId: int.parse(state.pathParameters['id']!),
              snippetId: int.parse(state.pathParameters['snippetId']!),
              path: state.pathParameters['path']!,
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
