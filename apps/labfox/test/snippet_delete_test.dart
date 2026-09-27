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

  bool deleted = false;
  bool rejectDelete = false;
  int? deletedId;
  int listCalls = 0;

  @override
  Future<List<Snippet>> list(int projectId) async {
    listCalls++;
    return deleted ? [] : [const Snippet(id: 73, title: 'Deploy helper')];
  }

  @override
  Future<Snippet> get(int projectId, int snippetId) async =>
      const Snippet(id: 73, title: 'Deploy helper');

  @override
  Future<String> raw(int projectId, int snippetId) async => 'echo ok';

  @override
  Future<void> delete(int projectId, int snippetId) async {
    if (rejectDelete) throw const GitLabForbiddenException('Forbidden');
    deletedId = snippetId;
    deleted = true;
  }
}

void main() {
  test('successful deletion refreshes the project snippet list', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(projectSnippetsProvider(42).future),
      hasLength(1),
    );

    await container
        .read(deleteSnippetControllerProvider.notifier)
        .delete(projectId: 42, snippetId: 73);

    expect(repository.deletedId, 73);
    expect(await container.read(projectSnippetsProvider(42).future), isEmpty);
    expect(repository.listCalls, 2);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('requires confirmation before deletion at width $width', (
      tester,
    ) async {
      final repository = _FakeRepository();
      await _pump(tester, repository, width);

      await tester.tap(find.text('Deploy helper').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete snippet'));
      await tester.pumpAndSettle();
      expect(repository.deleted, isFalse);
      expect(find.text('Delete this snippet?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.deleted, isFalse);

      await tester.tap(find.byTooltip('Delete snippet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(repository.deletedId, 73);
      expect(find.byType(SnippetsScreen), findsOneWidget);
      expect(find.text('No snippets yet'), findsOneWidget);
    });
  }

  testWidgets('keeps detail open after deletion is forbidden', (tester) async {
    final repository = _FakeRepository()..rejectDelete = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.text('Deploy helper').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete snippet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Could not delete the snippet.'), findsOneWidget);
    expect(find.byType(SnippetDetailScreen), findsOneWidget);
    expect(repository.deleted, isFalse);
  });

  testWidgets('returns to the snippet list from a direct detail link', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await _pump(tester, repository, 390, directDetail: true);
    await tester.tap(find.byTooltip('Delete snippet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.byType(SnippetsScreen), findsOneWidget);
    expect(find.text('No snippets yet'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  _FakeRepository repository,
  double width, {
  bool directDetail = false,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: directDetail
        ? '/projects/42/snippets/73'
        : '/projects/42/snippets',
    routes: [
      GoRoute(
        path: '/projects/:id/snippets',
        builder: (_, state) =>
            SnippetsScreen(projectId: int.parse(state.pathParameters['id']!)),
      ),
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
