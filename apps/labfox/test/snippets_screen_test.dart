import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/features/snippets/data/snippets_repository.dart';
import 'package:labfox/features/snippets/presentation/controllers/snippets_controller.dart';
import 'package:labfox/features/snippets/presentation/snippets_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FakeSnippetRepository extends SnippetsRepository {
  _FakeSnippetRepository()
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'x'));

  Snippet? created;
  String? lastTitle;
  String? lastDescription;
  String? lastVisibility;
  String? lastFilePath;
  String? lastContent;
  bool rejectCreate = false;
  int listCalls = 0;

  @override
  Future<List<Snippet>> list(int projectId) async {
    listCalls++;
    return [?created];
  }

  @override
  Future<Snippet> get(int projectId, int snippetId) async => created!;

  @override
  Future<String> raw(int projectId, int snippetId) async => lastContent ?? '';

  @override
  Future<Snippet> create(
    int projectId, {
    required String title,
    required String description,
    required String visibility,
    required String filePath,
    required String content,
  }) async {
    if (rejectCreate) throw const GitLabForbiddenException('Forbidden');
    lastTitle = title;
    lastDescription = description;
    lastVisibility = visibility;
    lastFilePath = filePath;
    lastContent = content;
    return created = Snippet(id: 73, title: title, fileName: filePath);
  }
}

Future<void> _pumpSnippetCreation(
  WidgetTester tester,
  _FakeSnippetRepository repository, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: Routes.snippets(42),
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpSnippets(WidgetTester tester, List<Snippet> snippets) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectSnippetsProvider.overrideWith((ref, id) async => snippets),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SnippetsScreen(projectId: 42),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('snippet creation refreshes the project list', () async {
    final repository = _FakeSnippetRepository();
    final container = ProviderContainer(
      overrides: [
        snippetsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(projectSnippetsProvider(42).future), isEmpty);

    await container
        .read(createSnippetControllerProvider.notifier)
        .create(
          projectId: 42,
          title: 'Example',
          description: '',
          visibility: 'private',
          filePath: 'example.txt',
          content: 'hello',
        );

    expect(
      (await container.read(projectSnippetsProvider(42).future)).single.id,
      73,
    );
    expect(repository.listCalls, 2);
  });

  for (final width in [390.0, 1200.0]) {
    testWidgets('creates a snippet from an empty project at width $width', (
      tester,
    ) async {
      final repository = _FakeSnippetRepository();
      await _pumpSnippetCreation(tester, repository, size: Size(width, 800));
      await tester.tap(find.text('New snippet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create snippet'));
      await tester.pumpAndSettle();
      expect(repository.created, isNull);
      expect(
        find.text('Enter a title, file path, and content.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Deploy helper',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Release command',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'File path'),
        'scripts/deploy.sh',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Content'),
        'echo ok',
      );
      if (width > 1000) {
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Public').last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Create snippet'));
      await tester.pumpAndSettle();

      expect(repository.lastTitle, 'Deploy helper');
      expect(repository.lastDescription, 'Release command');
      expect(repository.lastVisibility, width > 1000 ? 'public' : 'private');
      expect(repository.lastFilePath, 'scripts/deploy.sh');
      expect(repository.lastContent, 'echo ok');
      expect(
        tester
            .widget<SnippetDetailScreen>(find.byType(SnippetDetailScreen))
            .snippetId,
        73,
      );
    });
  }

  testWidgets('preserves snippet draft when permission is denied', (
    tester,
  ) async {
    final repository = _FakeSnippetRepository()..rejectCreate = true;
    await _pumpSnippetCreation(tester, repository, size: const Size(390, 800));
    await tester.tap(find.text('New snippet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Draft');
    await tester.enterText(
      find.widgetWithText(TextField, 'File path'),
      'draft.txt',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Content'),
      'Keep me',
    );
    await tester.tap(find.text('Create snippet'));
    await tester.pumpAndSettle();

    expect(find.text('Could not create the snippet.'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Keep me'), findsOneWidget);
    expect(find.text('Create snippet'), findsOneWidget);
  });

  testWidgets('renders a legacy snippet without a files array', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectSnippetProvider.overrideWith(
            (ref, item) async => const Snippet(id: 7, title: 'Legacy snippet'),
          ),
          snippetRawProvider.overrideWith((ref, item) async => 'raw content'),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SnippetDetailScreen(projectId: 42, snippetId: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Legacy snippet'), findsWidgets);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('raw content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'lists multiple files without requesting single-file raw content',
    (tester) async {
      var rawRequests = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectSnippetProvider.overrideWith(
              (ref, item) async => const Snippet(
                id: 8,
                title: 'Multi-file snippet',
                files: [
                  SnippetFile(path: 'first.dart'),
                  SnippetFile(path: 'second.dart'),
                ],
              ),
            ),
            snippetRawProvider.overrideWith((ref, item) async {
              rawRequests++;
              return 'unexpected';
            }),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SnippetDetailScreen(projectId: 42, snippetId: 8),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('first.dart'), findsOneWidget);
      expect(find.text('second.dart'), findsOneWidget);
      expect(rawRequests, 0);
    },
  );

  testWidgets('lists project snippets with title and description', (
    tester,
  ) async {
    await pumpSnippets(tester, const [
      Snippet(id: 7, title: 'Deploy script', description: 'Release helper'),
    ]);

    expect(find.text('Deploy script'), findsOneWidget);
    expect(find.text('Release helper'), findsOneWidget);
  });

  testWidgets('shows an empty state when the project has no snippets', (
    tester,
  ) async {
    await pumpSnippets(tester, const []);
    expect(find.text('No snippets yet'), findsOneWidget);
  });
}
