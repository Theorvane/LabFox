import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/data/suggestion_application.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_review_snapshot_controller.dart';
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
  final inspectionResults = <String, Object>{};
  Object? batchResult;
  final batches = <(List<int>, String?)>[];
  Object? inspectionResult;
  Object? applicationResult;
  final inspections = <(int, int, String)>[];
  final applications = <(int, String?)>[];
  @override
  Future<Discussion> discussion({
    required int projectId,
    required int iid,
    required String discussionId,
  }) async {
    inspections.add((projectId, iid, discussionId));
    final result =
        inspectionResults[discussionId] ??
        inspectionResult ??
        (pages[1] as Paginated<Discussion>).items.firstWhere(
          (g) => g.id == discussionId,
        );
    if (result is Future<Discussion>) return result;
    if (result is Discussion) return result;
    throw result;
  }

  @override
  Future<Suggestion> applySuggestion({
    required int suggestionId,
    String? commitMessage,
  }) async {
    applications.add((suggestionId, commitMessage));
    final result =
        applicationResult ??
        Suggestion.fromJson(_suggestion()).copyWith(applied: true);
    if (result is Future<Suggestion>) return result;
    if (result is Suggestion) return result;
    throw result;
  }

  @override
  Future<List<Suggestion>> applySuggestions({
    required List<int> suggestionIds,
    String? commitMessage,
  }) async {
    batches.add((List.of(suggestionIds), commitMessage));
    final result = batchResult;
    if (result is Future<List<Suggestion>>) return result;
    if (result is List<Suggestion>) return result;
    if (result != null) throw result;
    final all = (pages[1] as Paginated<Discussion>).items
        .expand((g) => g.notes)
        .expand((n) => n.suggestions ?? <Suggestion>[]);
    return [
      for (final id in suggestionIds)
        all.firstWhere((s) => s.id == id).copyWith(applied: true),
    ];
  }

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

class _Detail extends MergeRequestController {
  _Detail(this.reads);
  final void Function() reads;
  @override
  Future<MergeRequest> build(MergeRequestRef arg) async {
    reads();
    return const MergeRequest(
      id: 99,
      iid: 142,
      title: 'Review',
      state: 'opened',
      sourceBranch: 'feature',
      targetBranch: 'dev',
    );
  }
}

class _Snapshot extends MrReviewSnapshotController {
  _Snapshot(this.reads);
  final void Function() reads;
  @override
  Future<MrReviewSnapshot> build(MergeRequestRef arg) async {
    reads();
    return MrReviewSnapshot();
  }
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
          debugShowCheckedModeBanner: false,
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
      'type': 'DiffNote',
      'resolvable': true,
      'resolved': false,
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

Discussion _group(
  int id, {
  String? discussionId,
  int? noteId,
  String? content,
  int? line,
}) => _suggestions([
  {
    ..._suggestion(id: id, replacement: content ?? 'new $id'),
    'from_line': line ?? id * 10,
    'to_line': (line ?? id * 10) + 2,
  },
], noteId: noteId ?? id * 100).copyWith(id: discussionId ?? 'thread-$id');
List<SuggestionTarget> _targets(List<Discussion> groups) => [
  for (final g in groups)
    for (final n in g.notes)
      for (final s in n.suggestions ?? <Suggestion>[])
        (discussionId: g.id, note: n, suggestion: s),
];
Future<MrDiscussionsController> _controller(ProviderContainer c) async {
  await c.read(mrDiscussionsControllerProvider(_key).future);
  return c.read(mrDiscussionsControllerProvider(_key).notifier);
}

Future<void> _openBatch(WidgetTester tester, {bool review = true}) async {
  final open = find.byKey(const ValueKey('mr-suggestions-batch-open'));
  expect(open, findsOneWidget);
  await tester.ensureVisible(open);
  await tester.tap(open);
  await tester.pumpAndSettle();
  if (!review) return;
  for (final id in [7, 8]) {
    final check = find.byKey(ValueKey('mr-suggestions-select-$id'));
    await tester.ensureVisible(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(const ValueKey('mr-suggestions-batch-review')));
  await tester.pumpAndSettle();
}

void main() {
  for (final confirmed in [false, true]) {
    test(
      'refresh effects occur only after a fully confirmed batch $confirmed',
      () async {
        final repo = _Repository()
          ..pages[1] = Paginated(items: [_group(7), _group(8)]);
        if (!confirmed) repo.batchResult = <Suggestion>[];
        var details = 0, snapshots = 0;
        final c = ProviderContainer(
          overrides: [
            _session.overrideWith((ref) async => repo),
            commentsRepositoryProvider.overrideWith(
              (ref) => ref.watch(_session),
            ),
            analyticsProvider.overrideWithValue(_Analytics()),
            mergeRequestControllerProvider.overrideWith(
              () => _Detail(() => details++),
            ),
            mrReviewSnapshotControllerProvider.overrideWith(
              () => _Snapshot(() => snapshots++),
            ),
          ],
        );
        addTearDown(c.dispose);
        addTearDown(repo.client.close);
        final d = c.listen(mergeRequestControllerProvider(_key), (_, _) {});
        final v = c.listen(mrReviewSnapshotControllerProvider(_key), (_, _) {});
        addTearDown(d.close);
        addTearDown(v.close);
        await c.read(mergeRequestControllerProvider(_key).future);
        await c.read(mrReviewSnapshotControllerProvider(_key).future);
        final notifier = await _controller(c);
        final result = notifier.applySuggestions(
          _targets((repo.pages[1] as Paginated<Discussion>).items),
        );
        if (confirmed) {
          expect(await result, true);
        } else {
          await expectLater(result, throwsA(isA<GitLabServerException>()));
        }
        await c.read(mergeRequestControllerProvider(_key).future);
        await c.read(mrReviewSnapshotControllerProvider(_key).future);
        expect(details, confirmed ? 2 : 1);
        expect(snapshots, confirmed ? 2 : 1);
      },
    );
  }
  test('selection is snapshotted before awaiting the repository', () async {
    final groups = [_group(7), _group(8)];
    final repo = _Repository()..pages[1] = Paginated(items: groups);
    final c = _container(repo, _Analytics());
    final notifier = await _controller(c);
    final selection = _targets(groups).toList();
    final result = notifier.applySuggestions(selection);
    selection.clear();
    expect(await result, true);
    expect(repo.batches.single.$1, [7, 8]);
  });
  for (final endAccount in [false, true]) {
    test(
      'ended recovery never replaces part of the old cache account=$endAccount',
      () async {
        final groups = [_group(7), _group(8)];
        final pending = Completer<Discussion>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: groups)
          ..inspectionResults['thread-7'] = pending.future;
        final c = _container(repo, _Analytics());
        final notifier = await _controller(c);
        var current = true;
        final result = notifier.inspectDiscussions([
          'thread-7',
          'thread-8',
        ], isCurrent: () => current);
        await Future<void>.delayed(Duration.zero);
        if (endAccount) {
          final next = _Repository();
          addTearDown(next.client.close);
          c.read(_session.notifier).state = Future.value(next);
          await c.read(mrDiscussionsControllerProvider(_key).future);
        } else {
          current = false;
        }
        pending.complete(_group(7, content: 'Unseen new patch'));
        expect(await result, isNull);
        expect(repo.inspections.length, 1);
        expect(repo.batches, isEmpty);
        if (!endAccount) {
          expect(
            c.read(mrDiscussionsControllerProvider(_key)).requireValue.items,
            groups,
          );
        }
      },
    );
  }
  testWidgets(
    'missing selected suggestion stays explicit after complete recovery',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _group(7, content: 'Removed old patch'),
            _group(8),
          ],
        )
        ..batchResult = const GitLabServerException('Unconfirmed');
      await _pump(tester, repo);
      await _openBatch(tester);
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
      );
      await tester.pumpAndSettle();
      repo.inspectionResults['thread-7'] = _group(7).copyWith(notes: []);
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-reload')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Removed old patch'), findsNothing);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('mr-suggestions-batch-back')),
            )
            .onPressed,
        isNotNull,
      );
      expect(repo.batches.length, 1);
    },
  );
  for (final duplicate in [false, true]) {
    testWidgets(
      'batch action excludes unknown and ambiguous suggestions duplicate=$duplicate',
      (tester) async {
        final first = _group(7);
        final second = duplicate
            ? _group(7, discussionId: 'other', noteId: 800)
            : _group(8).copyWith(
                notes: [
                  first.notes.single.copyWith(
                    id: 800,
                    suggestions: [const Suggestion(id: 8)],
                  ),
                ],
              );
        final repo = _Repository()
          ..pages[1] = Paginated(items: [first, second]);
        await _pump(tester, repo);
        expect(
          find.byKey(const ValueKey('mr-suggestions-batch-open')),
          findsNothing,
        );
      },
    );
  }

  testWidgets('batch selection and patch review never write until confirmed', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_group(7), _group(8), _group(9)]);
    await _pump(tester, repo);
    await _openBatch(tester, review: false);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestions-batch-review')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('mr-suggestions-select-7')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestions-batch-review')),
          )
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('mr-suggestions-select-8')),
    );
    await tester.tap(find.byKey(const ValueKey('mr-suggestions-select-8')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mr-suggestions-batch-review')));
    await tester.pumpAndSettle();
    expect(repo.inspections, isEmpty);
    expect(repo.batches, isEmpty);
    await tester.tap(find.byKey(const ValueKey('mr-suggestions-batch-cancel')));
    await tester.pumpAndSettle();
    expect(repo.batches, isEmpty);
  });
  testWidgets(
    'selected subset sends exactly one batch and preserves message and root draft',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_group(7), _group(8), _group(9)]);
      await _pump(tester, repo);
      final root = find.byType(TextField).first;
      await tester.enterText(root, 'Root draft');
      await _openBatch(tester);
      final input = find.byKey(const ValueKey('mr-suggestions-batch-message'));
      await tester.ensureVisible(input);
      await tester.enterText(input, '  Exact\nMessage  ');
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
      );
      await tester.pumpAndSettle();
      expect(repo.batches.map((b) => b.$1), [
        [7, 8],
      ]);
      expect(repo.batches.single.$2, '  Exact\nMessage  ');
      expect(repo.inspections.map((r) => r.$3), ['thread-7', 'thread-8']);
      expect(repo.applications, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Root draft',
      );
    },
  );
  for (final error in [
    const GitLabServerException('Uncertain'),
    const GitLabForbiddenException('Denied'),
    const GitLabConflictException('Changed'),
  ]) {
    testWidgets(
      'batch failure preserves draft and requires every selected thread reload $error',
      (tester) async {
        final repo = _Repository()
          ..pages[1] = Paginated(items: [_group(7), _group(8)])
          ..batchResult = error;
        await _pump(tester, repo);
        await _openBatch(tester);
        final input = find.byKey(
          const ValueKey('mr-suggestions-batch-message'),
        );
        await tester.ensureVisible(input);
        await tester.enterText(input, 'Keep draft');
        await tester.tap(
          find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextButton>(
                find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<TextButton>(
                find.byKey(const ValueKey('mr-suggestions-batch-back')),
              )
              .onPressed,
          isNull,
        );
        expect(tester.widget<TextField>(input).controller!.text, 'Keep draft');
        repo.inspectionResults['thread-7'] = _group(7).copyWith(
          notes: [
            _group(7).notes.single.copyWith(
              suggestions: [
                _group(
                  7,
                ).notes.single.suggestions!.single.copyWith(applied: true),
              ],
            ),
          ],
        );
        await tester.tap(
          find.byKey(const ValueKey('mr-suggestions-batch-reload')),
        );
        await tester.pumpAndSettle();
        expect(repo.inspections.length, 4);
        expect(repo.batches.length, 1);
        expect(
          tester
              .widget<TextButton>(
                find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<TextButton>(
                find.byKey(const ValueKey('mr-suggestions-batch-back')),
              )
              .onPressed,
          isNotNull,
        );
      },
    );
  }
  testWidgets(
    'incomplete recovery cannot unlock confirmation or selection changes',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_group(7), _group(8)])
        ..batchResult = const GitLabServerException('Uncertain');
      await _pump(tester, repo);
      await _openBatch(tester);
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
      );
      await tester.pumpAndSettle();
      repo.inspectionResults['thread-7'] = _group(7, content: 'Reloaded 7');
      repo.inspectionResults['thread-8'] = const GitLabServerException(
        'Read failed',
      );
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-reload')),
      );
      await tester.pumpAndSettle();
      expect(repo.batches.length, 1);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('mr-suggestions-batch-back')),
            )
            .onPressed,
        isNull,
      );
      repo.inspectionResults['thread-8'] = _group(8, content: 'Reloaded 8');
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-reload')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reloaded 7'), findsWidgets);
      expect(find.text('Reloaded 8'), findsWidgets);
      expect(repo.batches.length, 1);
      repo.batchResult = [
        _group(
          7,
          content: 'Reloaded 7',
        ).notes.single.suggestions!.single.copyWith(applied: true),
        _group(
          8,
          content: 'Reloaded 8',
        ).notes.single.suggestions!.single.copyWith(applied: true),
      ];
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
      );
      await tester.pumpAndSettle();
      expect(repo.batches.length, 2);
    },
  );
  testWidgets(
    'pending batch preflight blocks input back cancel and duplicate writes',
    (tester) async {
      final pending = Completer<Discussion>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_group(7), _group(8)])
        ..inspectionResults['thread-7'] = pending.future;
      await _pump(tester, repo);
      await _openBatch(tester);
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
      );
      await tester.pump();
      for (final key in ['confirm', 'back', 'cancel']) {
        expect(
          tester
              .widget<TextButton>(
                find.byKey(ValueKey('mr-suggestions-batch-$key')),
              )
              .onPressed,
          isNull,
        );
      }
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('mr-suggestions-batch-message')),
            )
            .enabled,
        false,
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      pending.complete(_group(7));
      await tester.pumpAndSettle();
      expect(repo.batches.length, 1);
    },
  );
  testWidgets(
    'resource replacement hides selected old code and disables batch',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _group(7, content: 'Private old 7'),
            _group(8, content: 'Private old 8'),
          ],
        );
      final c = _container(repo, _Analytics());
      await _pump(tester, repo, container: c);
      await _openBatch(tester);
      await _pump(tester, repo, container: c, iid: 143);
      expect(find.text('Private old 7'), findsNothing);
      expect(find.text('Private old 8'), findsNothing);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
            )
            .onPressed,
        isNull,
      );
      expect(repo.batches, isEmpty);
    },
  );
  testWidgets(
    'account switch during first read hides patches and cancels following reads',
    (tester) async {
      final pending = Completer<Discussion>();
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _group(7, content: 'Private old'),
            _group(8),
          ],
        )
        ..inspectionResults['thread-7'] = pending.future;
      final c = _container(repo, _Analytics());
      await _pump(tester, repo, container: c);
      await _openBatch(tester);
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
      );
      await tester.pump();
      final next = _Repository();
      addTearDown(next.client.close);
      c.read(_session.notifier).state = Future.value(next);
      await tester.pump();
      expect(find.text('Private old'), findsNothing);
      pending.complete(_group(7));
      await tester.pumpAndSettle();
      expect(repo.inspections.length, 1);
      expect(repo.batches, isEmpty);
      expect(next.batches, isEmpty);
    },
  );
  testWidgets('resize and theme change preserve selection and commit draft', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(items: [_group(7), _group(8)]);
    final c = _container(repo, _Analytics());
    await _pump(tester, repo, container: c);
    await _openBatch(tester);
    final input = find.byKey(const ValueKey('mr-suggestions-batch-message'));
    await tester.ensureVisible(input);
    await tester.enterText(input, 'Keep across resize');
    await _pump(tester, repo, container: c, width: 1200, dark: true);
    expect(
      tester.widget<TextField>(input).controller!.text,
      'Keep across resize',
    );
    expect(repo.batches, isEmpty);
  });
  for (final locale in AppLocalizations.supportedLocales) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets(
          'batch selection and confirmation layout ${locale.languageCode} $width $dark',
          (tester) async {
            final repo = _Repository()
              ..pages[1] = Paginated(items: [_group(7), _group(8)]);
            await _pump(
              tester,
              repo,
              locale: locale,
              width: width,
              dark: dark,
              height: 900,
            );
            await _openBatch(tester);
            expect(tester.takeException(), isNull);
            expect(find.byType(AlertDialog), findsOneWidget);
            expect(repo.batches, isEmpty);
          },
        );
      }
    }
  }
  testWidgets(
    'batch confirmation fits keyboard and doubled text at compact width',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(items: [_group(7), _group(8)]);
      await _pump(tester, repo, width: 320, height: 600, textScale: 2);
      await _openBatch(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('mr-suggestions-batch-confirm')),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  test(
    'multi-thread preflight confirms all before exactly one batch write',
    () async {
      final groups = [_group(7), _group(8)];
      final repo = _Repository()..pages[1] = Paginated(items: groups);
      final analytics = _Analytics();
      final c = _container(repo, analytics);
      expect(
        await (await _controller(c)).applySuggestions(
          _targets(groups),
          commitMessage: '  Exact\nDraft  ',
        ),
        true,
      );
      expect(repo.inspections, [(8, 142, 'thread-7'), (8, 142, 'thread-8')]);
      expect(repo.batches.map((b) => b.$1), [
        [7, 8],
      ]);
      expect(repo.batches.single.$2, '  Exact\nDraft  ');
      expect(repo.applications, isEmpty);
      expect(analytics.events, isEmpty);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(repo.reads.length, 2);
    },
  );
  test('same-thread suggestions inspect the thread once', () async {
    final a = _group(7);
    final b = _group(8, discussionId: a.id);
    final group = a.copyWith(notes: [...a.notes, ...b.notes]);
    final repo = _Repository()..pages[1] = Paginated(items: [group]);
    final c = _container(repo, _Analytics());
    expect(
      await (await _controller(c)).applySuggestions(_targets([group])),
      true,
    );
    expect(repo.inspections.length, 1);
    expect(repo.batches.map((b) => b.$1), [
      [7, 8],
    ]);
    expect(repo.batches.single.$2, isNull);
  });
  for (final size in [0, 1, 3]) {
    test(
      'empty single or duplicate selections reject before reads size=$size',
      () async {
        final groups = [_group(7), _group(8)];
        final repo = _Repository()..pages[1] = Paginated(items: groups);
        final c = _container(repo, _Analytics());
        final targets = _targets(groups);
        final selected = size == 3
            ? [...targets, targets.first]
            : targets.take(size).toList();
        expect(await (await _controller(c)).applySuggestions(selected), false);
        expect(repo.inspections, isEmpty);
        expect(repo.batches, isEmpty);
      },
    );
  }
  for (final changed in [
    (Suggestion s) => s.copyWith(applied: true),
    (Suggestion s) => s.copyWith(applied: null),
    (Suggestion s) => s.copyWith(applicable: false),
    (Suggestion s) => s.copyWith(fromContent: null),
    (Suggestion s) => s.copyWith(toContent: 'Changed'),
    (Suggestion s) => s.copyWith(fromLine: 99),
  ]) {
    test(
      'changed selected patch prevents the whole batch ${changed(Suggestion.fromJson(_suggestion()))}',
      () async {
        final groups = [_group(7), _group(8)];
        final last = groups.last;
        final repo = _Repository()
          ..pages[1] = Paginated(items: groups)
          ..inspectionResults[last.id] = last.copyWith(
            notes: [
              last.notes.single.copyWith(
                suggestions: [changed(last.notes.single.suggestions!.single)],
              ),
            ],
          );
        final c = _container(repo, _Analytics());
        await expectLater(
          (await _controller(c)).applySuggestions(_targets(groups)),
          throwsA(isA<GitLabConflictException>()),
        );
        expect(repo.batches, isEmpty);
        expect(repo.applications, isEmpty);
      },
    );
  }
  test('preflight read failure never writes a subset', () async {
    final groups = [_group(7), _group(8)];
    final repo = _Repository()
      ..pages[1] = Paginated(items: groups)
      ..inspectionResults['thread-8'] = const GitLabServerException(
        'Read failed',
      );
    final c = _container(repo, _Analytics());
    await expectLater(
      (await _controller(c)).applySuggestions(_targets(groups)),
      throwsA(isA<GitLabServerException>()),
    );
    expect(repo.batches, isEmpty);
  });
  test(
    'response-wide duplicate suggestion across fresh threads prevents write',
    () async {
      final groups = [_group(7), _group(8)];
      final repo = _Repository()
        ..pages[1] = Paginated(items: groups)
        ..inspectionResults['thread-8'] = groups.last.copyWith(
          notes: [
            ...groups.last.notes,
            groups.first.notes.single.copyWith(id: 999),
          ],
        );
      final c = _container(repo, _Analytics());
      await expectLater(
        (await _controller(c)).applySuggestions(_targets(groups)),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repo.batches, isEmpty);
    },
  );
  for (final bad in <List<Suggestion>>[
    [],
    [const Suggestion(id: 7, applied: true)],
    [
      const Suggestion(id: 7, applied: true),
      const Suggestion(id: 7, applied: true),
    ],
    [
      const Suggestion(id: 7, applied: true),
      const Suggestion(id: 9, applied: true),
    ],
    [
      const Suggestion(id: 7, applied: true),
      const Suggestion(id: 8, applied: false),
    ],
    [
      const Suggestion(id: 7, applied: true),
      const Suggestion(id: 8, applied: true, toContent: 'Changed'),
    ],
  ]) {
    test(
      'unconfirmed response retains state and emits no success effects $bad',
      () async {
        final groups = [_group(7), _group(8)];
        final repo = _Repository()
          ..pages[1] = Paginated(items: groups)
          ..batchResult = bad;
        final analytics = _Analytics();
        final c = _container(repo, analytics);
        await expectLater(
          (await _controller(c)).applySuggestions(_targets(groups)),
          throwsA(isA<GitLabServerException>()),
        );
        expect(repo.batches.length, 1);
        expect(repo.reads.length, 1);
        expect(analytics.events, isEmpty);
      },
    );
  }
  test('reordered sparse applied response is accepted', () async {
    final groups = [_group(7), _group(8)];
    final repo = _Repository()
      ..pages[1] = Paginated(items: groups)
      ..batchResult = [
        const Suggestion(id: 8, applied: true),
        const Suggestion(id: 7, applied: true),
      ];
    final c = _container(repo, _Analytics());
    expect(
      await (await _controller(c)).applySuggestions(_targets(groups)),
      true,
    );
  });
  test('reservation spans every preflight and batch completion', () async {
    final groups = [_group(7), _group(8)];
    final pending = Completer<Discussion>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: groups, nextPage: 2)
      ..inspectionResults['thread-7'] = pending.future;
    final c = _container(repo, _Analytics());
    final ctrl = await _controller(c);
    final first = ctrl.applySuggestions(_targets(groups));
    await Future<void>.delayed(Duration.zero);
    expect(await ctrl.applySuggestions(_targets(groups)), false);
    expect(
      await ctrl.applySuggestion(
        discussionId: groups.first.id,
        note: groups.first.notes.single,
        suggestion: groups.first.notes.single.suggestions!.single,
      ),
      false,
    );
    expect(await ctrl.post('Other'), false);
    expect(
      await ctrl.reply(discussionId: groups.first.id, body: 'Other'),
      false,
    );
    expect(
      await ctrl.setResolved(discussionId: groups.first.id, resolved: true),
      false,
    );
    expect(await ctrl.inspectDiscussions(['thread-7', 'thread-8']), isNull);
    await ctrl.loadMore();
    expect(repo.reads.length, 1);
    pending.complete(groups.first);
    expect(await first, true);
    expect(repo.batches.length, 1);
  });
  test(
    'pending pagination blocks batch and multi-discussion inspection',
    () async {
      final groups = [_group(7), _group(8)];
      final pending = Completer<Paginated<Discussion>>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: groups, nextPage: 2)
        ..pages[2] = pending.future;
      final c = _container(repo, _Analytics());
      final ctrl = await _controller(c);
      final load = ctrl.loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(await ctrl.applySuggestions(_targets(groups)), false);
      expect(await ctrl.inspectDiscussions(['thread-7', 'thread-8']), isNull);
      expect(repo.inspections, isEmpty);
      pending.complete(const Paginated(items: []));
      await load;
    },
  );
  for (final failed in [false, true]) {
    test(
      'account change stops follow-up preflight and write failed=$failed',
      () async {
        final groups = [_group(7), _group(8)];
        final pending = Completer<Discussion>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: groups)
          ..inspectionResults['thread-7'] = pending.future;
        final c = _container(repo, _Analytics());
        final future = (await _controller(
          c,
        )).applySuggestions(_targets(groups));
        await Future<void>.delayed(Duration.zero);
        final next = _Repository();
        addTearDown(next.client.close);
        c.read(_session.notifier).state = Future.value(next);
        await Future<void>.delayed(Duration.zero);
        if (failed) {
          pending.completeError(const GitLabServerException('Late'));
        } else {
          pending.complete(groups.first);
        }
        expect(await future, false);
        expect(repo.inspections.length, 1);
        expect(repo.batches, isEmpty);
        expect(next.batches, isEmpty);
      },
    );
    test(
      'account change isolates late batch completion failed=$failed',
      () async {
        final groups = [_group(7), _group(8)];
        final pending = Completer<List<Suggestion>>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: groups)
          ..batchResult = pending.future;
        final c = _container(repo, _Analytics());
        final future = (await _controller(
          c,
        )).applySuggestions(_targets(groups));
        await Future<void>.delayed(Duration.zero);
        final next = _Repository();
        addTearDown(next.client.close);
        c.read(_session.notifier).state = Future.value(next);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        if (failed) {
          pending.completeError(const GitLabServerException('Late'));
        } else {
          pending.complete([
            const Suggestion(id: 7, applied: true),
            const Suggestion(id: 8, applied: true),
          ]);
        }
        expect(await future, false);
        expect(next.reads.length, 1);
        expect(next.batches, isEmpty);
      },
    );
  }
  test(
    'originating view ends after first preflight and cancels remaining reads',
    () async {
      var active = true;
      final groups = [_group(7), _group(8)];
      final pending = Completer<Discussion>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: groups)
        ..inspectionResults['thread-7'] = pending.future;
      final c = _container(repo, _Analytics());
      final future = (await _controller(
        c,
      )).applySuggestions(_targets(groups), isCurrent: () => active);
      await Future<void>.delayed(Duration.zero);
      active = false;
      pending.complete(groups.first);
      expect(await future, false);
      expect(repo.inspections.length, 1);
      expect(repo.batches, isEmpty);
    },
  );
  test(
    'complete recovery replaces all groups atomically and preserves pagination',
    () async {
      final groups = [_group(7), _group(8)];
      final fresh = [
        _group(7, content: 'Fresh 7'),
        _group(8, content: 'Fresh 8'),
      ];
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: groups,
          nextPage: 4,
          total: 12,
          totalPages: 6,
        )
        ..inspectionResults['thread-7'] = fresh.first
        ..inspectionResults['thread-8'] = fresh.last;
      final c = _container(repo, _Analytics());
      final result = await (await _controller(
        c,
      )).inspectDiscussions(['thread-7', 'thread-8']);
      expect(result, fresh);
      final state = c.read(mrDiscussionsControllerProvider(_key)).value!;
      expect(state.items, fresh);
      expect(state.nextPage, 4);
      expect(state.total, 12);
      expect(state.totalPages, 6);
      expect(repo.batches, isEmpty);
    },
  );
  test(
    'failed recovery preserves every cached group without partial refresh',
    () async {
      final groups = [_group(7), _group(8)];
      final repo = _Repository()
        ..pages[1] = Paginated(items: groups)
        ..inspectionResults['thread-7'] = _group(7, content: 'Fresh 7')
        ..inspectionResults['thread-8'] = const GitLabServerException('Failed');
      final c = _container(repo, _Analytics());
      await expectLater(
        (await _controller(c)).inspectDiscussions(['thread-7', 'thread-8']),
        throwsA(isA<GitLabServerException>()),
      );
      expect(
        c.read(mrDiscussionsControllerProvider(_key)).value!.items,
        groups,
      );
      expect(repo.batches, isEmpty);
    },
  );
  if (Platform.environment['LABFOX_BATCH_UI_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('synthetic batch confirmation capture $width $dark', (
          tester,
        ) async {
          final sdk = Platform.environment['FLUTTER_ROOT']!;
          await tester.runAsync(() async {
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
              if (family == 'Roboto') {
                for (final weight in ['Medium', 'Bold']) {
                  loader.addFont(
                    Future.value(
                      ByteData.sublistView(
                        File(
                          '$sdk/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
                        ).readAsBytesSync(),
                      ),
                    ),
                  );
                }
              }
              await loader.load();
            }
          });
          final baseTheme = dark ? LabFoxTheme.dark : LabFoxTheme.light;
          final buttonStyle = baseTheme.filledButtonTheme.style!;
          final captureTheme = baseTheme.copyWith(
            filledButtonTheme: FilledButtonThemeData(
              style: buttonStyle.copyWith(
                textStyle: WidgetStatePropertyAll(
                  buttonStyle.textStyle!
                      .resolve({})!
                      .copyWith(fontFamily: 'Roboto'),
                ),
              ),
            ),
          );
          final repo = _Repository()
            ..pages[1] = Paginated(
              items: [
                _group(7, content: '  return reviewedValue;\n'),
                _group(8, content: '  notifyReviewers();\n'),
              ],
            );
          await _pump(
            tester,
            repo,
            width: width,
            height: width < 600 ? 844 : 900,
            dark: dark,
            theme: captureTheme,
          );
          await _openBatch(tester);
          expect(tester.takeException(), isNull);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(_captureKey),
          );
          final image = (await tester.runAsync(boundary.toImage))!;
          final data = await tester.runAsync(
            () => image.toByteData(format: ui.ImageByteFormat.png),
          );
          await tester.runAsync(() async {
            final file = File(
              '$directory/batch-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
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
