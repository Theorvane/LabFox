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
void main() {
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
}
