import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/widgets/mr_discussion_thread.dart';
import 'package:labfox/l10n/app_localizations.dart';

const _key = MergeRequestRef(projectId: 8, iid: 142);

class _Repository extends CommentsRepository {
  _Repository()
    : this._(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  _Repository._(this.client) : super(client);
  final GitLabClient client;
  final pages = <int, Object>{1: const Paginated<Discussion>(items: [])};
  final reads = <(int, int, int)>[];
  final posts = <String>[];
  Future<Note>? postResult;
  @override
  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    reads.add((projectId, iid, page));
    final result = pages[page]!;
    if (result is Future<Paginated<Discussion>>) return result;
    if (result is Paginated<Discussion>) return result;
    throw result;
  }

  @override
  Future<Note> post({
    required NoteableType type,
    required int projectId,
    required int iid,
    required String body,
  }) async {
    expect(type, NoteableType.mergeRequest);
    posts.add(body);
    return postResult ?? const Note(id: 999, body: 'Posted');
  }

  @override
  Future<List<Note>> list({
    required NoteableType type,
    required int projectId,
    required int iid,
  }) async => throw StateError('MRs must read grouped discussions');
}

class _Analytics implements Analytics {
  final events = <String>[];
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async =>
      events.add(name);
}

final _session = StateProvider<Future<CommentsRepository?>>(
  (ref) async => null,
);
ProviderContainer _container(_Repository repo, _Analytics analytics) {
  final container = ProviderContainer(
    overrides: [
      _session.overrideWith((ref) async => repo),
      commentsRepositoryProvider.overrideWith((ref) => ref.watch(_session)),
      analyticsProvider.overrideWithValue(analytics),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(repo.client.close);
  return container;
}

final _captureKey = GlobalKey();
Future<AppLocalizations> _pump(
  WidgetTester tester,
  _Repository repo, {
  double width = 390,
  bool dark = false,
  double height = 1400,
  double textScale = 1,
  Locale locale = const Locale('en'),
  bool settle = true,
  ProviderContainer? container,
  ThemeData? theme,
  int iid = 142,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final scope = container ?? _container(repo, _Analytics());
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child: RepaintBoundary(
        key: _captureKey,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          theme: theme ?? (dark ? LabFoxTheme.dark : LabFoxTheme.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MrDiscussionThread(projectId: 8, iid: iid),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  return AppLocalizations.of(tester.element(find.byType(MrDiscussionThread)));
}

Discussion _suggestions(
  List<Map<String, Object?>>? suggestions, {
  bool system = false,
  int noteId = 301,
}) => Discussion(
  id: 'suggestion-thread',
  individualNote: false,
  notes: [
    Note.fromJson({
      'id': noteId,
      'body': 'Review this patch',
      'system': system,
      'suggestions': suggestions,
    }),
  ],
);
Map<String, Object?> _suggestion({
  int id = 7,
  Object? original = '  old();\n',
  Object? replacement = '  new();\n',
  bool? applied = false,
  bool? applicable = true,
}) => {
  'id': id,
  'from_line': 10,
  'to_line': 12,
  'from_content': original,
  'to_content': replacement,
  'applied': applied,
  'applicable': applicable,
};
void main() {
  testWidgets(
    'server suggestions expose literal selectable original and replacement',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _suggestions([
              _suggestion(
                original: '  <script>old();</script>\n',
                replacement: '  **new();**\n',
              ),
            ]),
          ],
        );
      final analytics = _Analytics();
      final container = _container(repo, analytics);
      await _pump(tester, repo, container: container);
      await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-7')));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is SelectableText && w.data == '  <script>old();</script>\n',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SelectableText && w.data == '  **new();**\n',
        ),
        findsOneWidget,
      );
      expect(repo.reads, [(8, 142, 1)]);
      expect(repo.posts, isEmpty);
      expect(analytics.events, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  for (final locale in ['en', 'ko', 'ja', 'hi', 'zh']) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets(
          'preview keeps long literal code bounded $locale $width $dark',
          (tester) async {
            final content = '    ' + List.filled(300, 'x').join() + '\n';
            final repo = _Repository()
              ..pages[1] = Paginated(
                items: [
                  _suggestions([
                    _suggestion(
                      original: content,
                      replacement: List.filled(100, content).join(),
                    ),
                  ]),
                ],
              );
            await _pump(
              tester,
              repo,
              locale: Locale(locale),
              width: width,
              dark: dark,
            );
            await tester.tap(
              find.byKey(const ValueKey('mr-suggestion-open-301-7')),
            );
            await tester.pumpAndSettle();
            expect(find.byType(SelectableText), findsNWidgets(2));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets('null and empty collections expose no invented preview', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_suggestions(null)]);
    final container = _container(repo, _Analytics());
    await _pump(tester, repo, container: container);
    expect(
      find.byKey(const ValueKey('mr-suggestion-open-301-7')),
      findsNothing,
    );
    repo.pages[1] = Paginated(items: [_suggestions([])]);
    container.invalidate(mrDiscussionsControllerProvider(_key));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.text('Suggestion 7'), findsNothing);
  });
  testWidgets('system notes never expose code suggestions', (tester) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()], system: true),
        ],
      );
    await _pump(tester, repo);
    expect(
      find.byKey(const ValueKey('mr-suggestion-open-301-7')),
      findsNothing,
    );
  });

  for (final state in [true, false, null]) {
    testWidgets('application and patch state remain independent $state', (
      tester,
    ) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _suggestions([
              _suggestion(
                applied: state,
                applicable: state == null ? null : !state,
              ),
            ]),
          ],
        );
      final l10n = await _pump(tester, repo);
      expect(
        find.text(
          state == true
              ? l10n.mrSuggestionApplied
              : state == false
              ? l10n.mrSuggestionNotApplied
              : l10n.mrSuggestionAppliedUnknown,
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          state == false
              ? l10n.mrSuggestionApplicable
              : state == true
              ? l10n.mrSuggestionNotApplicable
              : l10n.mrSuggestionApplicableUnknown,
        ),
        findsOneWidget,
      );
      expect(find.byType(SelectableText), findsNothing);
    });
  }
  testWidgets('empty insertion deletion and missing content stay distinct', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion(original: '', replacement: null)]),
        ],
      );
    final l10n = await _pump(tester, repo);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-7')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.mrSuggestionContentEmpty), findsOneWidget);
    expect(find.text(l10n.mrSuggestionContentUnknown), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing);
  });
  testWidgets(
    'sparse coordinates stay unavailable without guessed line numbers',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _suggestions([
              {'id': 7, 'from_line': 10},
            ]),
          ],
        );
      final l10n = await _pump(tester, repo);
      expect(find.text(l10n.mrSuggestionRangeUnknown), findsOneWidget);
      expect(find.text(l10n.mrSuggestionAppliedUnknown), findsOneWidget);
    },
  );
  testWidgets(
    'legacy spelling renders and conflicting model aliases stay unknown',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _suggestions([
              {'id': 7, 'appliable': true},
              {'id': 8, 'appliable': true, 'applicable': false},
            ]),
          ],
        );
      final l10n = await _pump(tester, repo);
      expect(find.text(l10n.mrSuggestionApplicable), findsOneWidget);
      expect(find.text(l10n.mrSuggestionApplicableUnknown), findsOneWidget);
    },
  );
  testWidgets('expansion and top draft survive resize and theme change', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    final container = _container(repo, _Analytics());
    await _pump(tester, repo, container: container);
    await tester.enterText(find.byType(TextField), 'Retained draft');
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-7')));
    await tester.pumpAndSettle();
    await _pump(tester, repo, container: container, width: 1200, dark: true);
    expect(
      find.byKey(const ValueKey('mr-suggestion-hide-301-7')),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Retained draft',
    );
    expect(repo.reads, [(8, 142, 1)]);
    expect(tester.takeException(), isNull);
  });
  testWidgets('account replacement removes old code and resets expansion', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    final container = _container(repo, _Analytics());
    await _pump(tester, repo, container: container);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-7')));
    await tester.pumpAndSettle();
    final next = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion(replacement: 'Other account code')]),
        ],
      );
    addTearDown(next.client.close);
    container.read(_session.notifier).state = Future.value(next);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mr-suggestion-open-301-7')),
      findsOneWidget,
    );
    expect(find.byType(SelectableText), findsNothing);
    expect(repo.posts, isEmpty);
    expect(next.posts, isEmpty);
  });
  testWidgets('updated server metadata resets the old expanded preview', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    final container = _container(repo, _Analytics());
    await _pump(tester, repo, container: container);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-7')));
    await tester.pumpAndSettle();
    repo.pages[1] = Paginated(
      items: [
        _suggestions([_suggestion(replacement: 'New server code')]),
      ],
    );
    container.invalidate(mrDiscussionsControllerProvider(_key));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('mr-suggestion-open-301-7')),
      findsOneWidget,
    );
    expect(find.byType(SelectableText), findsNothing);
  });
  testWidgets(
    'multiple suggestions stay in server order and expand separately',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _suggestions([_suggestion(id: 9), _suggestion(id: 7)]),
          ],
        );
      final l10n = await _pump(tester, repo);
      expect(
        tester.getTopLeft(find.text(l10n.mrSuggestionTitle('9'))).dy,
        lessThan(tester.getTopLeft(find.text(l10n.mrSuggestionTitle('7'))).dy),
      );
      await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-9')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('mr-suggestion-open-301-7')),
        findsOneWidget,
      );
      expect(find.byType(SelectableText), findsNWidgets(2));
    },
  );

  testWidgets('resource replacement resets expansion without old code', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    final container = _container(repo, _Analytics());
    await _pump(tester, repo, container: container);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-7')));
    await tester.pumpAndSettle();
    await _pump(tester, repo, container: container, iid: 143);
    expect(
      find.byKey(const ValueKey('mr-suggestion-open-301-7')),
      findsOneWidget,
    );
    expect(find.byType(SelectableText), findsNothing);
    expect(repo.reads, [(8, 142, 1), (8, 143, 1)]);
  });
  testWidgets('large text stays readable on a narrow viewport', (tester) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    await _pump(tester, repo, width: 320, textScale: 2);
    await tester.ensureVisible(
      find.byKey(const ValueKey('mr-suggestion-open-301-7')),
    );
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-open-301-7')));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
  if (Platform.environment['LABFOX_PREVIEW_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('synthetic preview capture $width $dark', (tester) async {
          final sdk = Platform.environment['FLUTTER_ROOT']!;
          for (final (family, name) in [
            ('Roboto', 'Roboto-Regular.ttf'),
            ('monospace', 'Roboto-Regular.ttf'),
            ('MaterialIcons', 'MaterialIcons-Regular.otf'),
          ]) {
            final loader = FontLoader(family)
              ..addFont(
                Future.value(
                  ByteData.sublistView(
                    File(
                      '$sdk/bin/cache/artifacts/material_fonts/$name',
                    ).readAsBytesSync(),
                  ),
                ),
              );
            await loader.load();
          }
          final repo = _Repository()
            ..pages[1] = Paginated(
              items: [
                _suggestions([
                  _suggestion(
                    original: '  return oldValue;\n',
                    replacement: '  return reviewedValue;\n',
                  ),
                ]),
              ],
            );
          await _pump(
            tester,
            repo,
            width: width,
            height: width < 600 ? 844 : 900,
            dark: dark,
          );
          await tester.tap(
            find.byKey(const ValueKey('mr-suggestion-open-301-7')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(_captureKey),
          );
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await tester.runAsync(() async {
            final file = File(
              '$directory/preview-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
          });
          image.dispose();
        });
      }
    }
  }
}
