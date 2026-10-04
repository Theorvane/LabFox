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
        inspectionResult ?? (pages[1] as Paginated<Discussion>).items.single;
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
Future<void> _openApplication(WidgetTester tester) async {
  final open = find.byKey(const ValueKey('mr-suggestion-open-301-7'));
  await tester.ensureVisible(open);
  await tester.tap(open);
  await tester.pumpAndSettle();
  final apply = find.byKey(const ValueKey('mr-suggestion-apply-301-7'));
  expect(apply, findsOneWidget);
  await tester.ensureVisible(apply);
  await tester.tap(apply);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'application requires explicit confirmation and cancellation never writes',
    (tester) async {
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            _suggestions([_suggestion()]),
          ],
        );
      await _pump(tester, repo);
      await _openApplication(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(repo.inspections, isEmpty);
      expect(repo.applications, isEmpty);
      await tester.tap(
        find.byKey(const ValueKey('mr-suggestion-apply-cancel')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(repo.applications, isEmpty);
    },
  );

  testWidgets('confirmation forwards exact draft and only then applies once', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    await _pump(tester, repo);
    await _openApplication(tester);
    await tester.enterText(
      find.byKey(const ValueKey('mr-suggestion-commit-message')),
      '  Custom\nMessage  ',
    );
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-confirm')));
    await tester.pumpAndSettle();
    expect(repo.applications, [(7, '  Custom\nMessage  ')]);
    expect(repo.inspections.length, 1);
    expect(find.byType(AlertDialog), findsNothing);
    expect(repo.reads.length, 2);
  });
  for (final error in [
    const GitLabServerException('Uncertain'),
    const GitLabForbiddenException('Denied'),
    const GitLabConflictException('Changed'),
  ]) {
    testWidgets(
      'failed application retains draft and requires explicit reload $error',
      (tester) async {
        final repo = _Repository()
          ..pages[1] = Paginated(
            items: [
              _suggestions([_suggestion()]),
            ],
          )
          ..applicationResult = error;
        await _pump(tester, repo);
        await _openApplication(tester);
        await tester.enterText(
          find.byKey(const ValueKey('mr-suggestion-commit-message')),
          'Keep draft',
        );
        await tester.tap(
          find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextButton>(
                find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<TextField>(
                find.byKey(const ValueKey('mr-suggestion-commit-message')),
              )
              .controller!
              .text,
          'Keep draft',
        );
        repo.inspectionResult = _suggestions([_suggestion(applied: true)]);
        await tester.tap(
          find.byKey(const ValueKey('mr-suggestion-apply-reload')),
        );
        await tester.pumpAndSettle();
        expect(repo.applications.length, 1);
        expect(repo.inspections.length, 2);
        expect(
          tester
              .widget<TextButton>(
                find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
              )
              .onPressed,
          isNull,
        );
      },
    );
  }
  testWidgets('changed patch requires reload and a new confirmation', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      )
      ..inspectionResult = _suggestions([
        _suggestion(replacement: 'Changed code'),
      ]);
    await _pump(tester, repo);
    await _openApplication(tester);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-confirm')));
    await tester.pumpAndSettle();
    expect(repo.applications, isEmpty);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-reload')));
    await tester.pumpAndSettle();
    expect(find.text('Changed code'), findsWidgets);
    expect(repo.applications, isEmpty);
    repo.applicationResult = Suggestion.fromJson(
      _suggestion(replacement: 'Changed code', applied: true),
    );
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-confirm')));
    await tester.pumpAndSettle();
    expect(repo.applications, [(7, null)]);
  });
  testWidgets('reload failure retains draft and never retries a write', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      )
      ..applicationResult = const GitLabServerException('Uncertain');
    await _pump(tester, repo);
    await _openApplication(tester);
    await tester.enterText(
      find.byKey(const ValueKey('mr-suggestion-commit-message')),
      'Keep',
    );
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-confirm')));
    await tester.pumpAndSettle();
    repo.inspectionResult = const GitLabServerException('Read failed');
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-reload')));
    await tester.pumpAndSettle();
    expect(repo.applications.length, 1);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('mr-suggestion-commit-message')),
          )
          .controller!
          .text,
      'Keep',
    );
    repo.inspectionResult = _suggestions([]);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-reload')));
    await tester.pumpAndSettle();
    expect(repo.applications.length, 1);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets('pending preflight blocks dismissal and duplicate confirmation', (
    tester,
  ) async {
    final pending = Completer<Discussion>();
    final group = _suggestions([_suggestion()]);
    final repo = _Repository()
      ..pages[1] = Paginated(items: [group])
      ..inspectionResult = pending.future;
    await _pump(tester, repo);
    await _openApplication(tester);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-confirm')));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestion-apply-cancel')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('mr-suggestion-commit-message')),
          )
          .enabled,
      false,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(repo.applications, isEmpty);
    pending.complete(group);
    await tester.pumpAndSettle();
    expect(repo.applications.length, 1);
  });
  testWidgets('account switch hides old patch and cancels pending preflight', (
    tester,
  ) async {
    final pending = Completer<Discussion>();
    final group = _suggestions([_suggestion()]);
    final repo = _Repository()
      ..pages[1] = Paginated(items: [group])
      ..inspectionResult = pending.future;
    final next = _Repository();
    addTearDown(next.client.close);
    final c = _container(repo, _Analytics());
    await _pump(tester, repo, container: c);
    await _openApplication(tester);
    await tester.tap(find.byKey(const ValueKey('mr-suggestion-apply-confirm')));
    await tester.pump();
    c.read(_session.notifier).state = Future.value(next);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('  old();\n'), findsNothing);
    pending.complete(group);
    await tester.pumpAndSettle();
    expect(repo.applications, isEmpty);
    expect(next.applications, isEmpty);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
          )
          .onPressed,
      isNull,
    );
  });
  for (final locale in AppLocalizations.supportedLocales) {
    for (final width in [390.0, 800.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets(
          'confirmation layout ${locale.languageCode} $width dark=$dark',
          (tester) async {
            final repo = _Repository()
              ..pages[1] = Paginated(
                items: [
                  _suggestions([_suggestion()]),
                ],
              );
            await _pump(
              tester,
              repo,
              width: width,
              height: 900,
              locale: locale,
              dark: dark,
            );
            await _openApplication(tester);
            expect(find.byType(AlertDialog), findsOneWidget);
            expect(tester.takeException(), isNull);
            expect(repo.applications, isEmpty);
          },
        );
      }
    }
  }
  testWidgets('compact confirmation scrolls with keyboard and large text', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    await _pump(tester, repo, width: 320, height: 600, textScale: 2);
    await _openApplication(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
          )
          .onPressed,
      isNotNull,
    );
  });
  testWidgets('resource replacement hides old patch and blocks confirmation', (
    tester,
  ) async {
    final repo = _Repository()
      ..pages[1] = Paginated(
        items: [
          _suggestions([_suggestion()]),
        ],
      );
    final c = _container(repo, _Analytics());
    await _pump(tester, repo, container: c);
    await _openApplication(tester);
    await _pump(tester, repo, container: c, iid: 143);
    expect(find.text('  old();\n'), findsNothing);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('mr-suggestion-apply-confirm')),
          )
          .onPressed,
      isNull,
    );
    expect(repo.applications, isEmpty);
  });
  test(
    'pending pagination blocks application and recovery inspection',
    () async {
      final group = _suggestions([_suggestion()]);
      final repo = _Repository()
        ..pages[1] = Paginated(items: [group], nextPage: 2);
      final pending = Completer<Paginated<Discussion>>();
      repo.pages[2] = pending.future;
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final ctrl = c.read(mrDiscussionsControllerProvider(_key).notifier);
      final loading = ctrl.loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(
        await ctrl.applySuggestion(
          discussionId: group.id,
          note: group.notes.single,
          suggestion: group.notes.single.suggestions!.single,
        ),
        false,
      );
      expect(await ctrl.inspectDiscussion(group.id), isNull);
      expect(repo.inspections, isEmpty);
      expect(repo.applications, isEmpty);
      pending.complete(const Paginated(items: []));
      await loading;
    },
  );
  for (final returned in [
    Suggestion.fromJson(_suggestion(applied: false)),
    Suggestion.fromJson(_suggestion(applied: null)),
    Suggestion.fromJson(_suggestion(applied: true, id: 8)),
    Suggestion.fromJson(_suggestion(applied: true, original: 'Other')),
    Suggestion.fromJson(_suggestion(applied: true, replacement: 'Other')),
    Suggestion.fromJson(_suggestion(applied: true)).copyWith(fromLine: 11),
    Suggestion.fromJson(_suggestion(applied: true)).copyWith(toLine: 13),
  ]) {
    test(
      'unconfirmed returned state fails without reload or analytics $returned',
      () async {
        final group = _suggestions([_suggestion()]);
        final repo = _Repository()
          ..pages[1] = Paginated(items: [group])
          ..applicationResult = returned;
        final analytics = _Analytics();
        final c = _container(repo, analytics);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        await expectLater(
          c
              .read(mrDiscussionsControllerProvider(_key).notifier)
              .applySuggestion(
                discussionId: group.id,
                note: group.notes.single,
                suggestion: group.notes.single.suggestions!.single,
              ),
          throwsA(isA<GitLabServerException>()),
        );
        expect(repo.applications.length, 1);
        expect(repo.reads.length, 1);
        expect(analytics.events, isEmpty);
      },
    );
  }
  test('matching sparse applied response confirms application', () async {
    final group = _suggestions([_suggestion()]);
    final repo = _Repository()
      ..pages[1] = Paginated(items: [group])
      ..applicationResult = const Suggestion(id: 7, applied: true);
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    expect(
      await c
          .read(mrDiscussionsControllerProvider(_key).notifier)
          .applySuggestion(
            discussionId: group.id,
            note: group.notes.single,
            suggestion: group.notes.single.suggestions!.single,
          ),
      true,
    );
  });
  for (final confirmed in [true, false]) {
    test(
      'only confirmed application refreshes detail and latest review snapshot $confirmed',
      () async {
        var detailReads = 0, snapshotReads = 0;
        final group = _suggestions([_suggestion()]);
        final repo = _Repository()
          ..pages[1] = Paginated(items: [group])
          ..applicationResult = Suggestion(id: 7, applied: confirmed);
        final c = ProviderContainer(
          overrides: [
            commentsRepositoryProvider.overrideWith((ref) async => repo),
            analyticsProvider.overrideWithValue(_Analytics()),
            mergeRequestControllerProvider.overrideWith(
              () => _Detail(() => detailReads++),
            ),
            mrReviewSnapshotControllerProvider.overrideWith(
              () => _Snapshot(() => snapshotReads++),
            ),
          ],
        );
        addTearDown(c.dispose);
        addTearDown(repo.client.close);
        final sub = c.listen(
          mrReviewSnapshotControllerProvider(_key),
          (_, _) {},
        );
        addTearDown(sub.close);
        await c.read(mergeRequestControllerProvider(_key).future);
        await c.read(mrReviewSnapshotControllerProvider(_key).future);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        final future = c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .applySuggestion(
              discussionId: group.id,
              note: group.notes.single,
              suggestion: group.notes.single.suggestions!.single,
            );
        if (confirmed) {
          expect(await future, true);
        } else {
          await expectLater(future, throwsA(isA<GitLabServerException>()));
        }
        await c.read(mergeRequestControllerProvider(_key).future);
        await c.read(mrReviewSnapshotControllerProvider(_key).future);
        expect(detailReads, confirmed ? 2 : 1);
        expect(snapshotReads, confirmed ? 2 : 1);
      },
    );
  }
  test(
    'fresh matching target applies exactly once without comment analytics',
    () async {
      final group = _suggestions([_suggestion()]);
      final note = group.notes.single;
      final suggestion = note.suggestions!.single;
      final repo = _Repository()..pages[1] = Paginated(items: [group]);
      final analytics = _Analytics();
      final c = _container(repo, analytics);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final applied = await c
          .read(mrDiscussionsControllerProvider(_key).notifier)
          .applySuggestion(
            discussionId: group.id,
            note: note,
            suggestion: suggestion,
            commitMessage: '  Custom\nMessage  ',
          );
      expect(applied, true);
      expect(repo.inspections, [(8, 142, group.id)]);
      expect(repo.applications, [(7, '  Custom\nMessage  ')]);
      expect(analytics.events, isEmpty);
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(repo.reads.length, 2);
    },
  );
  for (final change in [
    (Suggestion s) => s.copyWith(id: 0),
    (Suggestion s) => s.copyWith(applied: true),
    (Suggestion s) => s.copyWith(applied: null),
    (Suggestion s) => s.copyWith(applicable: false),
    (Suggestion s) => s.copyWith(applicable: null),
    (Suggestion s) => s.copyWith(fromContent: null),
    (Suggestion s) => s.copyWith(toContent: null),
    (Suggestion s) => s.copyWith(fromLine: null),
    (Suggestion s) => s.copyWith(fromLine: 0),
    (Suggestion s) => s.copyWith(toLine: null),
    (Suggestion s) => s.copyWith(toLine: 9),
  ]) {
    test(
      'unknown or ineligible target rejects before preflight ${change(Suggestion.fromJson(_suggestion()))}',
      () async {
        final note = _suggestions([_suggestion()]).notes.single.copyWith(
          suggestions: [change(Suggestion.fromJson(_suggestion()))],
        );
        final group = Discussion(
          id: 'suggestion-thread',
          individualNote: false,
          notes: [note],
        );
        final repo = _Repository()..pages[1] = Paginated(items: [group]);
        final c = _container(repo, _Analytics());
        await c.read(mrDiscussionsControllerProvider(_key).future);
        expect(
          await c
              .read(mrDiscussionsControllerProvider(_key).notifier)
              .applySuggestion(
                discussionId: group.id,
                note: note,
                suggestion: note.suggestions!.single,
              ),
          false,
        );
        expect(repo.inspections, isEmpty);
        expect(repo.applications, isEmpty);
      },
    );
  }
  for (final change in [
    (Note n) => n.copyWith(id: 999),
    (Note n) => n.copyWith(isSystem: true),
    (Note n) => n.copyWith(type: null),
    (Note n) =>
        n.copyWith(position: const DiffNotePosition(positionType: 'image')),
    (Note n) => n.copyWith(
      suggestions: [n.suggestions!.single.copyWith(toContent: 'changed')],
    ),
    (Note n) =>
        n.copyWith(suggestions: [n.suggestions!.single.copyWith(fromLine: 11)]),
    (Note n) => n.copyWith(
      suggestions: [n.suggestions!.single.copyWith(applied: true)],
    ),
    (Note n) => n.copyWith(
      suggestions: [n.suggestions!.single.copyWith(applicable: false)],
    ),
    (Note n) => n.copyWith(suggestions: []),
  ]) {
    test(
      'changed authoritative target blocks application ${change(_suggestions([_suggestion()]).notes.single)}',
      () async {
        final group = _suggestions([_suggestion()]);
        final note = group.notes.single;
        final repo = _Repository()
          ..pages[1] = Paginated(items: [group])
          ..inspectionResult = group.copyWith(notes: [change(note)]);
        final c = _container(repo, _Analytics());
        await c.read(mrDiscussionsControllerProvider(_key).future);
        await expectLater(
          c
              .read(mrDiscussionsControllerProvider(_key).notifier)
              .applySuggestion(
                discussionId: group.id,
                note: note,
                suggestion: note.suggestions!.single,
              ),
          throwsA(isA<GitLabConflictException>()),
        );
        expect(repo.inspections.length, 1);
        expect(repo.applications, isEmpty);
      },
    );
  }
  test(
    'duplicate identities across loaded groups reject before preflight',
    () async {
      final group = _suggestions([_suggestion()]);
      final note = group.notes.single;
      final repo = _Repository()
        ..pages[1] = Paginated(
          items: [
            group,
            group.copyWith(id: 'other'),
          ],
        );
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(
        await c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .applySuggestion(
              discussionId: group.id,
              note: note,
              suggestion: note.suggestions!.single,
            ),
        false,
      );
      expect(repo.inspections, isEmpty);
      expect(repo.applications, isEmpty);
    },
  );
  test(
    'application reservation blocks duplicate application and other discussion writes',
    () async {
      final group = _suggestions([_suggestion()]);
      final note = group.notes.single;
      final pending = Completer<Discussion>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: [group])
        ..inspectionResult = pending.future;
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      final controller = c.read(mrDiscussionsControllerProvider(_key).notifier);
      final first = controller.applySuggestion(
        discussionId: group.id,
        note: note,
        suggestion: note.suggestions!.single,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        await controller.applySuggestion(
          discussionId: group.id,
          note: note,
          suggestion: note.suggestions!.single,
        ),
        false,
      );
      expect(await controller.post('Other'), false);
      expect(
        await controller.reply(discussionId: group.id, body: 'Reply'),
        false,
      );
      expect(
        await controller.setResolved(discussionId: group.id, resolved: true),
        false,
      );
      expect(repo.posts, isEmpty);
      expect(repo.applications, isEmpty);
      pending.complete(group);
      expect(await first, true);
      expect(repo.applications.length, 1);
    },
  );
  test('pending ordinary comment blocks application', () async {
    final group = _suggestions([_suggestion()]);
    final note = group.notes.single;
    final pending = Completer<Note>();
    final repo = _Repository()
      ..pages[1] = Paginated(items: [group])
      ..postResult = pending.future;
    final c = _container(repo, _Analytics());
    await c.read(mrDiscussionsControllerProvider(_key).future);
    final controller = c.read(mrDiscussionsControllerProvider(_key).notifier);
    final first = controller.post('Other');
    await Future<void>.delayed(Duration.zero);
    expect(
      await controller.applySuggestion(
        discussionId: group.id,
        note: note,
        suggestion: note.suggestions!.single,
      ),
      false,
    );
    expect(repo.inspections, isEmpty);
    pending.complete(const Note(id: 999, body: 'Posted'));
    expect(await first, true);
  });
  for (final failed in [false, true]) {
    test(
      'account change during preflight prevents write failed=$failed',
      () async {
        final group = _suggestions([_suggestion()]);
        final note = group.notes.single;
        final pending = Completer<Discussion>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: [group])
          ..inspectionResult = pending.future;
        final c = _container(repo, _Analytics());
        await c.read(mrDiscussionsControllerProvider(_key).future);
        final controller = c.read(
          mrDiscussionsControllerProvider(_key).notifier,
        );
        final first = controller.applySuggestion(
          discussionId: group.id,
          note: note,
          suggestion: note.suggestions!.single,
        );
        await Future<void>.delayed(Duration.zero);
        c.read(_session.notifier).state = Future.value(null);
        await Future<void>.delayed(Duration.zero);
        if (failed) {
          pending.completeError(
            const GitLabServerException('private-content-marker'),
          );
        } else {
          pending.complete(group);
        }
        expect(await first, false);
        expect(repo.applications, isEmpty);
      },
    );
    test(
      'account change suppresses late application effects failed=$failed',
      () async {
        final group = _suggestions([_suggestion()]);
        final note = group.notes.single;
        final pending = Completer<Suggestion>();
        final repo = _Repository()
          ..pages[1] = Paginated(items: [group])
          ..applicationResult = pending.future;
        final analytics = _Analytics();
        final c = _container(repo, analytics);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        final first = c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .applySuggestion(
              discussionId: group.id,
              note: note,
              suggestion: note.suggestions!.single,
            );
        await Future<void>.delayed(Duration.zero);
        final next = _Repository()..pages[1] = Paginated(items: [group]);
        addTearDown(next.client.close);
        c.read(_session.notifier).state = Future.value(next);
        await c.read(mrDiscussionsControllerProvider(_key).future);
        if (failed) {
          pending.completeError(
            const GitLabServerException('private-content-marker'),
          );
        } else {
          pending.complete(note.suggestions!.single.copyWith(applied: true));
        }
        expect(await first, false);
        expect(next.reads.length, 1);
        expect(next.applications, isEmpty);
        expect(analytics.events, isEmpty);
      },
    );
  }
  test(
    'dismissed view cancels after authoritative read before dispatch',
    () async {
      final group = _suggestions([_suggestion()]);
      final note = group.notes.single;
      final pending = Completer<Discussion>();
      final repo = _Repository()
        ..pages[1] = Paginated(items: [group])
        ..inspectionResult = pending.future;
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      var current = true;
      final first = c
          .read(mrDiscussionsControllerProvider(_key).notifier)
          .applySuggestion(
            discussionId: group.id,
            note: note,
            suggestion: note.suggestions!.single,
            isCurrent: () => current,
          );
      await Future<void>.delayed(Duration.zero);
      current = false;
      pending.complete(group);
      expect(await first, false);
      expect(repo.applications, isEmpty);
    },
  );
  test(
    'explicit inspection updates loaded group without automatic application',
    () async {
      final group = _suggestions([_suggestion()]);
      final fresh = group.copyWith(
        notes: [
          group.notes.single.copyWith(
            suggestions: [
              group.notes.single.suggestions!.single.copyWith(applied: true),
            ],
          ),
        ],
      );
      final repo = _Repository()
        ..pages[1] = Paginated(items: [group], nextPage: 2)
        ..inspectionResult = fresh;
      final c = _container(repo, _Analytics());
      await c.read(mrDiscussionsControllerProvider(_key).future);
      expect(
        await c
            .read(mrDiscussionsControllerProvider(_key).notifier)
            .inspectDiscussion(group.id),
        fresh,
      );
      final state = c.read(mrDiscussionsControllerProvider(_key)).requireValue;
      expect(state.items.single, fresh);
      expect(state.nextPage, 2);
      expect(repo.applications, isEmpty);
    },
  );
  if (Platform.environment['LABFOX_SUGGESTION_APPLY_CAPTURE']
      case final String directory) {
    for (final width in [390.0, 1200.0]) {
      for (final dark in [false, true]) {
        testWidgets('synthetic application confirmation capture $width $dark', (
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
            theme: captureTheme,
          );
          await _openApplication(tester);
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
              '$directory/apply-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
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
