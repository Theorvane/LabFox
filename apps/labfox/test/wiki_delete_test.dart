import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/features/wiki/data/wiki_repository.dart';
import 'package:labfox/features/wiki/presentation/controllers/wiki_controllers.dart';
import 'package:labfox/features/wiki/presentation/wiki_page_screen.dart';
import 'package:labfox/features/wiki/presentation/wiki_pages_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _page = WikiPage(
  title: 'Install',
  slug: 'docs/install',
  content: '# Install',
  format: 'markdown',
);

class _FakeRepository extends WikiRepository {
  _FakeRepository()
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'x'));

  bool deleted = false;
  bool rejectDelete = false;
  bool changed = false;
  int listCalls = 0;
  String? deletedSlug;

  @override
  Future<List<WikiPage>> pages(int projectId) async {
    listCalls++;
    return deleted ? [] : [_page];
  }

  @override
  Future<WikiPage> page(int projectId, String slug) async => _page;

  @override
  Future<void> delete({
    required int projectId,
    required WikiPage original,
  }) async {
    if (changed) throw const WikiEditConflictException();
    if (rejectDelete) throw const GitLabForbiddenException('Forbidden');
    deletedSlug = original.slug;
    deleted = true;
  }
}

void main() {
  test('deleting a page refreshes the project wiki list', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        wikiRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(wikiPagesControllerProvider(7).future),
      hasLength(1),
    );
    const key = WikiPageRef(projectId: 7, slug: 'docs/install');
    await container.read(wikiPageControllerProvider(key).future);

    await container
        .read(wikiPageControllerProvider(key).notifier)
        .delete(original: _page);

    expect(repository.deletedSlug, 'docs/install');
    expect(
      await container.read(wikiPagesControllerProvider(7).future),
      isEmpty,
    );
    expect(repository.listCalls, 2);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('confirms deletion from a direct page link at width $width', (
      tester,
    ) async {
      final repository = _FakeRepository();
      await _pump(tester, repository, width);
      await tester.tap(find.byTooltip('Delete page'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this wiki page?'), findsOneWidget);
      expect(repository.deleted, isFalse);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.deleted, isFalse);

      await tester.tap(find.byTooltip('Delete page'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete page').last);
      await tester.pumpAndSettle();

      expect(repository.deletedSlug, 'docs/install');
      expect(find.byType(WikiPagesScreen), findsOneWidget);
      expect(find.text('No wiki pages yet.'), findsOneWidget);
    });
  }

  testWidgets('keeps the page open after permission denial', (tester) async {
    final repository = _FakeRepository()..rejectDelete = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Delete page'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete page').last);
    await tester.pumpAndSettle();

    expect(find.text('Could not delete the wiki page.'), findsOneWidget);
    expect(find.byType(WikiPageScreen), findsOneWidget);
    expect(repository.deleted, isFalse);
  });

  testWidgets('requires reload when the page changed before deletion', (
    tester,
  ) async {
    final repository = _FakeRepository()..changed = true;
    await _pump(tester, repository, 390);
    await tester.tap(find.byTooltip('Delete page'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete page').last);
    await tester.pumpAndSettle();

    expect(
      find.text('This page changed. Reload it before deleting.'),
      findsOneWidget,
    );
    expect(repository.deleted, isFalse);
    expect(find.text('Reload page'), findsOneWidget);
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
    initialLocation: '/projects/7/wikis/page?slug=docs%2Finstall',
    routes: [
      GoRoute(
        path: '/projects/:id/wikis',
        builder: (_, state) =>
            WikiPagesScreen(projectId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/projects/:id/wikis/page',
        builder: (_, state) => WikiPageScreen(
          projectId: int.parse(state.pathParameters['id']!),
          slug: state.uri.queryParameters['slug']!,
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        wikiRepositoryProvider.overrideWith((ref) async => repository),
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
