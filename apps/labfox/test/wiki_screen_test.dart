import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/features/wiki/data/wiki_repository.dart';
import 'package:labfox/features/wiki/presentation/controllers/wiki_controllers.dart';
import 'package:labfox/features/wiki/presentation/wiki_page_screen.dart';
import 'package:labfox/features/wiki/presentation/wiki_pages_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubPages extends WikiPagesController {
  _StubPages(this.value);

  final AsyncValue<List<WikiPage>> value;
  String? lastCreatedTitle;
  String? lastCreatedContent;
  bool rejectCreate = false;

  @override
  Future<List<WikiPage>> build(int projectId) => value.when(
    data: Future.value,
    loading: () => Completer<List<WikiPage>>().future,
    error: Future.error,
  );

  @override
  Future<WikiPage> create({
    required String title,
    required String content,
  }) async {
    if (rejectCreate) throw const GitLabForbiddenException('Forbidden');
    lastCreatedTitle = title;
    lastCreatedContent = content;
    return WikiPage(
      title: title,
      slug: 'Getting-Started',
      content: content,
      format: 'markdown',
    );
  }
}

class _StubPage extends WikiPageController {
  _StubPage(this.value);

  final AsyncValue<WikiPage> value;
  WikiPageRef? lastLoadedRef;
  String? lastSavedTitle;
  String? lastSavedContent;
  bool rejectSave = false;
  bool conflictOnSave = false;

  @override
  Future<WikiPage> build(WikiPageRef arg) {
    lastLoadedRef = arg;
    return value.when(
      data: Future.value,
      loading: () => Completer<WikiPage>().future,
      error: Future.error,
    );
  }

  @override
  Future<WikiPage> save({
    required WikiPage original,
    required String title,
    required String content,
  }) async {
    if (conflictOnSave) throw const WikiEditConflictException();
    if (rejectSave) throw const GitLabForbiddenException('Forbidden');
    lastSavedTitle = title;
    lastSavedContent = content;
    final updated = WikiPage(
      title: title,
      slug: title == original.title ? original.slug : 'docs/new-title',
      content: content,
      format: original.format,
    );
    state = AsyncData(updated);
    return updated;
  }
}

class _FakeWikiRepository extends WikiRepository {
  _FakeWikiRepository()
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'x'));

  int listCalls = 0;
  WikiPage? created;

  @override
  Future<List<WikiPage>> pages(int projectId) async {
    listCalls++;
    return [?created];
  }

  @override
  Future<WikiPage> create(
    int projectId, {
    required String title,
    required String content,
  }) async {
    created = WikiPage(title: title, slug: 'server-slug', content: content);
    return created!;
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required AsyncValue<List<WikiPage>> pages,
  required AsyncValue<WikiPage> page,
  String initialLocation = '/projects/1/wikis',
  Size? size,
  _StubPages? pagesController,
  _StubPage? pageController,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: initialLocation,
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
        wikiPagesControllerProvider.overrideWith(
          () => pagesController ?? _StubPages(pages),
        ),
        wikiPageControllerProvider.overrideWith(
          () => pageController ?? _StubPage(page),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

const _pages = <WikiPage>[
  WikiPage(title: 'Home', slug: 'home'),
  WikiPage(title: 'Install', slug: 'docs/install'),
];
const _pagesWithTemplates = <WikiPage>[
  ..._pages,
  WikiPage(title: 'Starter', slug: 'templates/starter', format: 'markdown'),
  WikiPage(title: 'Other format', slug: 'templates/other', format: 'asciidoc'),
];
const _template = WikiPage(
  title: 'Starter',
  slug: 'templates/starter',
  content: '# Template body',
  format: 'markdown',
);
const _page = WikiPage(
  title: 'Install',
  slug: 'docs/install',
  content: '# Install\n\nRun the setup.',
  format: 'markdown',
);

void main() {
  test('creating a wiki page reloads the project page list', () async {
    final repository = _FakeWikiRepository();
    final container = ProviderContainer(
      overrides: [
        wikiRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(wikiPagesControllerProvider(7).future),
      isEmpty,
    );

    final created = await container
        .read(wikiPagesControllerProvider(7).notifier)
        .create(title: 'New page', content: '# Body');
    expect(created.slug, 'server-slug');
    expect(
      (await container.read(wikiPagesControllerProvider(7).future)).single.slug,
      'server-slug',
    );
    expect(repository.listCalls, 2);
  });

  testWidgets('lists wiki pages and opens a nested page inside the app', (
    tester,
  ) async {
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(_page),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Install'), findsOneWidget);
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownViewer), findsOneWidget);
    expect(
      tester.widget<WikiPageScreen>(find.byType(WikiPageScreen)).slug,
      'docs/install',
    );
  });

  testWidgets('shows an empty wiki message', (tester) async {
    await _pump(
      tester,
      pages: const AsyncData(<WikiPage>[]),
      page: const AsyncData(_page),
    );
    await tester.pumpAndSettle();

    expect(find.text('No wiki pages yet.'), findsOneWidget);
  });

  testWidgets('shows a retry action on list errors', (tester) async {
    await _pump(
      tester,
      pages: AsyncError(Exception('failed'), StackTrace.current),
      page: const AsyncData(_page),
    );
    await tester.pump();

    expect(find.text('Could not load wiki pages.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('shows the page list beside content on wide screens', (
    tester,
  ) async {
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(_page),
      initialLocation: Routes.wikiPage(1, 'docs/install'),
      size: const Size(1200, 800),
    );
    await tester.pumpAndSettle();

    final sidebar = tester.getTopLeft(find.text('Home'));
    final content = tester.getTopLeft(find.byType(MarkdownViewer));
    expect(content.dx, greaterThan(sidebar.dx + 200));
  });

  testWidgets('opens a relative wiki link inside the app', (tester) async {
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(
        WikiPage(
          title: 'Install',
          slug: 'docs/install',
          content: '[Overview](../home)',
          format: 'markdown',
        ),
      ),
      initialLocation: Routes.wikiPage(1, 'docs/install'),
      size: const Size(390, 800),
    );
    await tester.pumpAndSettle();

    final richText = tester.widget<RichText>(
      find
          .descendant(
            of: find.byType(MarkdownViewer),
            matching: find.byType(RichText),
          )
          .first,
    );
    TapGestureRecognizer? link;
    (richText.text as TextSpan).visitChildren((span) {
      if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
        link = span.recognizer! as TapGestureRecognizer;
        return false;
      }
      return true;
    });
    expect(link, isNotNull);
    link!.onTap!();
    await tester.pumpAndSettle();

    expect(
      tester.widget<WikiPageScreen>(find.byType(WikiPageScreen)).slug,
      'home',
    );
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('creates a page from a Markdown template at width $width', (
      tester,
    ) async {
      final controller = _StubPages(const AsyncData(_pagesWithTemplates));
      final templateController = _StubPage(const AsyncData(_template));
      await _pump(
        tester,
        pages: const AsyncData(_pagesWithTemplates),
        page: const AsyncData(_template),
        pagesController: controller,
        pageController: templateController,
        size: Size(width, 800),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('New page'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a template'), findsOneWidget);
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(DropdownMenuItem<String>, 'Other format'),
        findsNothing,
      );
      await tester.tap(find.text('Starter').last);
      await tester.pumpAndSettle();
      expect(templateController.lastLoadedRef?.slug, 'templates/starter');
      expect(find.text('# Template body'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'New guide',
      );
      await tester.tap(find.text('Create page'));
      await tester.pumpAndSettle();
      expect(controller.lastCreatedTitle, 'New guide');
      expect(controller.lastCreatedContent, '# Template body');
    });

    testWidgets('creates a page from an empty wiki at width $width', (
      tester,
    ) async {
      final controller = _StubPages(const AsyncData(<WikiPage>[]));
      await _pump(
        tester,
        pages: const AsyncData(<WikiPage>[]),
        page: const AsyncData(_page),
        pagesController: controller,
        size: Size(width, 800),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('New page'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create page'));
      await tester.pumpAndSettle();
      expect(controller.lastCreatedTitle, isNull);
      expect(find.text('Enter a title and content.'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Getting Started',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Content'),
        '# Hello',
      );
      await tester.tap(find.text('Create page'));
      await tester.pumpAndSettle();

      expect(controller.lastCreatedTitle, 'Getting Started');
      expect(controller.lastCreatedContent, '# Hello');
      expect(
        tester.widget<WikiPageScreen>(find.byType(WikiPageScreen)).slug,
        'Getting-Started',
      );
    });

    testWidgets('edits a wiki page at width $width', (tester) async {
      final controller = _StubPage(const AsyncData(_page));
      await _pump(
        tester,
        pages: const AsyncData(_pages),
        page: const AsyncData(_page),
        pageController: controller,
        initialLocation: Routes.wikiPage(1, 'docs/install'),
        size: Size(width, 800),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'New title',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Content'),
        '# Revised',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(controller.lastSavedTitle, 'New title');
      expect(controller.lastSavedContent, '# Revised');
      expect(
        tester.widget<WikiPageScreen>(find.byType(WikiPageScreen)).slug,
        'docs/new-title',
      );
    });
  }

  testWidgets('confirms before a template replaces an existing draft', (
    tester,
  ) async {
    await _pump(
      tester,
      pages: const AsyncData(_pagesWithTemplates),
      page: const AsyncData(_template),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New page'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Content'),
      'My draft',
    );
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Starter').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Replace the current content with this template?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(find.text('My draft'), findsOneWidget);

    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Starter').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply template'));
    await tester.pumpAndSettle();
    expect(find.text('# Template body'), findsOneWidget);
  });

  testWidgets('preserves draft when loading a template fails', (tester) async {
    await _pump(
      tester,
      pages: const AsyncData(_pagesWithTemplates),
      page: AsyncError(
        const GitLabForbiddenException('Forbidden'),
        StackTrace.current,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New page'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Content'),
      'My draft',
    );
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Starter').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply template'));
    await tester.pumpAndSettle();

    expect(find.text('My draft'), findsOneWidget);
    expect(find.text('Could not load the template.'), findsOneWidget);
  });

  testWidgets('keeps the wiki draft after a permission error', (tester) async {
    final controller = _StubPages(const AsyncData(_pages))..rejectCreate = true;
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(_page),
      pagesController: controller,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New page'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Draft');
    await tester.enterText(
      find.widgetWithText(TextField, 'Content'),
      'Keep me',
    );
    await tester.tap(find.text('Create page'));
    await tester.pumpAndSettle();

    expect(find.text('Could not create the wiki page.'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Keep me'), findsOneWidget);
    expect(find.text('Create page'), findsOneWidget);
  });

  testWidgets('keeps a stale wiki draft and offers reload', (tester) async {
    final controller = _StubPage(const AsyncData(_page))..conflictOnSave = true;
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(_page),
      pageController: controller,
      initialLocation: Routes.wikiPage(1, 'docs/install'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Content'),
      'My draft',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('This page changed on GitLab'), findsOneWidget);
    expect(find.text('My draft'), findsOneWidget);
    expect(find.text('Reload page'), findsOneWidget);
  });

  testWidgets('keeps a wiki draft on permission denial', (tester) async {
    final controller = _StubPage(const AsyncData(_page))..rejectSave = true;
    await _pump(
      tester,
      pages: const AsyncData(_pages),
      page: const AsyncData(_page),
      pageController: controller,
      initialLocation: Routes.wikiPage(1, 'docs/install'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Content'),
      'My draft',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save the wiki page.'), findsOneWidget);
    expect(find.text('My draft'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });
}
