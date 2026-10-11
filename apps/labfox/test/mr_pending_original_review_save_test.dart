import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/gitlab_client_provider.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_original_review_controller.dart';

import '../../../packages/gitlab_api/test/mr_commits_api_test.dart' as api;
import 'mr_original_review_snapshot_test.dart' as original;
import 'mr_pending_review_save_test.dart' as pending;

class Details extends pending.Details {
  Details(super.client) {
    result = original.mr;
  }
  Object contextResult = original.context();
  int contexts = 0;
  @override
  Future<MrOriginalCommitContext?> originalCommitContext({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String commitId,
    required bool Function() isCurrent,
  }) async {
    contexts++;
    final value = contextResult;
    if (value is Future<MrOriginalCommitContext?>) return value;
    if (value is MrOriginalCommitContext) return value;
    throw value;
  }
}

class Fixture {
  Fixture() {
    client = api.client((o) {
      parentReads++;
      expect(o.method, 'GET');
      expect(o.path, '/projects/8/repository/commits/${original.parent}');
      if (parentResult is Future<Object>) {
        return (parentResult as Future<Object>).then((v) => api.response(v));
      }
      if (parentResult is GitLabException) return api.response({}, status: 404);
      return api.response(parentResult);
    });
    details = Details(client);
    mockDrafts = CommitDrafts(client);
    comments = pending.Comments(client);
    c = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(events),
        currentAccountProvider.overrideWith(
          (ref) => ref.watch(pending.accountState),
        ),
        pending.clientState.overrideWith((ref) async => client),
        gitLabClientProvider.overrideWith(
          (ref) => ref.watch(pending.clientState),
        ),
        pending.sourceState.overrideWith((ref) async => details),
        mergeRequestsRepositoryProvider.overrideWith(
          (ref) => ref.watch(pending.sourceState),
        ),
        pending.draftState.overrideWith((ref) async => mockDrafts),
        mrDraftNotesRepositoryProvider.overrideWith(
          (ref) => ref.watch(pending.draftState),
        ),
        commentsRepositoryProvider.overrideWith((ref) async => comments),
      ],
    );
    subscription = c.listen(
      mrOriginalReviewControllerProvider(original.arg),
      (_, _) {},
    );
    addTearDown(() {
      subscription.close();
      c.dispose();
      client.close();
    });
  }
  late final GitLabClient client;
  late final Details details;
  late final CommitDrafts mockDrafts;
  late final pending.Comments comments;
  late final ProviderContainer c;
  late final ProviderSubscription<AsyncValue<MrOriginalReviewSnapshot>>
  subscription;
  final events = pending.Events();
  int parentReads = 0;
  Object parentResult = api.commit(id: original.parent);
  late DiffNotePosition position;
  MrDiscussionsController get controller =>
      c.read(mrDiscussionsControllerProvider(pending.resource).notifier);
  Future<void> ready() async {
    await c.read(mrDiscussionsControllerProvider(pending.resource).future);
    final s = await c.read(
      mrOriginalReviewControllerProvider(original.arg).future,
    );
    final file = s.files.single;
    position = s.positionFor(file, file.hunks.single.lines.last)!;
    mockDrafts.position = position;
  }

  Future<MergeRequestDraftNote?> save({
    bool Function()? current,
    MrOriginalReviewRef? query,
    String body = pending.markdown,
  }) => controller.savePendingCommitNote(
    body,
    original: query ?? original.arg,
    position: position,
    isCurrent: current,
  );
}

class CommitDrafts extends pending.Drafts {
  CommitDrafts(super.client);
  late DiffNotePosition position;
  final commits = <(int, int, int, String, String, DiffNotePosition)>[];
  Object? outcome;
  MergeRequestDraftNote get saved => pending
      .draft(7)
      .copyWith(
        commitId: original.head,
        position: position,
        resolveDiscussion: false,
      );
  @override
  Future<MergeRequestDraftNote> createCommit({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String commitId,
    required String note,
    required DiffNotePosition position,
  }) async {
    commits.add((projectId, iid, mergeRequestId, commitId, note, position));
    final v = outcome;
    if (v is Future<MergeRequestDraftNote>) return v;
    if (v is MergeRequestDraftNote) return v;
    if (v != null) throw v;
    return saved;
  }
}

void main() {
  test(
    'real captured repositories read target context and parent before one private POST',
    () async {
      final calls = <String>[];
      late DiffNotePosition position;
      final client = api.client((o) {
        calls.add('${o.method} ${o.path}');
        if (o.method == 'POST') {
          expect(o.path, '/projects/8/merge_requests/142/draft_notes');
          expect(o.extra['labfox_no_auth_retry'], true);
          expect(o.followRedirects, false);
          final body = o.data as Map<String, dynamic>;
          expect(body['note'], pending.markdown);
          expect(body['commit_id'], original.head);
          expect(body['resolve_discussion'], false);
          expect(
            body['position'],
            position.toJson()..removeWhere((k, v) => v == null),
          );
          return api.response({
            'id': 7,
            'author_id': 23,
            'merge_request_id': 1100,
            'note': pending.markdown,
            'commit_id': original.head,
            'resolve_discussion': false,
            'position': position.toJson(),
          }, status: 201);
        }
        if (o.path.endsWith('/discussions')) return api.response([]);
        if (o.path == '/projects/8/merge_requests/142') {
          return api.response(original.mr.toJson());
        }
        if (o.path.endsWith('/merge_requests/142/commits')) {
          return api.response([
            {
              ...api.commit(),
              'parent_ids': [original.parent],
            },
          ]);
        }
        if (o.path.endsWith('/diff')) {
          return api.response([original.literal.toJson()]);
        }
        if (o.path.endsWith(original.parent)) {
          return api.response(api.commit(id: original.parent));
        }
        return api.response({
          ...api.commit(),
          'parent_ids': [original.parent],
        });
      });
      addTearDown(client.close);
      final c = ProviderContainer(
        overrides: [
          currentAccountProvider.overrideWithValue(pending.account),
          gitLabClientProvider.overrideWith((ref) async => client),
          mergeRequestsRepositoryProvider.overrideWith(
            (ref) async => MergeRequestsRepository(client),
          ),
          commentsRepositoryProvider.overrideWith(
            (ref) async => pending.Comments(client),
          ),
          mrDraftNotesRepositoryProvider.overrideWith(
            (ref) async => MrDraftNotesRepository(client, authorId: 23),
          ),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(
        mrOriginalReviewControllerProvider(original.arg),
        (_, _) {},
      );
      addTearDown(sub.close);
      await c.read(mrDiscussionsControllerProvider(pending.resource).future);
      final snapshot = await c.read(
        mrOriginalReviewControllerProvider(original.arg).future,
      );
      final file = snapshot.files.single;
      position = snapshot.positionFor(file, file.hunks.single.lines.last)!;
      calls.clear();
      final saved = await c
          .read(mrDiscussionsControllerProvider(pending.resource).notifier)
          .savePendingCommitNote(
            pending.markdown,
            original: original.arg,
            position: position,
          );
      expect(saved!.commitId, original.head);
      expect(calls.length, 9);
      expect(
        calls.take(7).every((s) => s.startsWith('GET /projects/8/')),
        true,
      );
      expect(calls[7], 'GET /projects/8/repository/commits/${original.parent}');
      expect(calls.last, 'POST /projects/8/merge_requests/142/draft_notes');
    },
  );
  test(
    'multiline original selection preserves canonical range in one save',
    () async {
      final f = Fixture();
      await f.ready();
      final s = f.c
          .read(mrOriginalReviewControllerProvider(original.arg))
          .value!;
      final file = s.files.single;
      f.position = s.rangePositionFor(
        file,
        file.hunks.single.lines.first,
        file.hunks.single.lines.last,
      )!;
      f.mockDrafts.position = f.position;
      expect(await f.save(), f.mockDrafts.saved);
      expect(f.mockDrafts.commits.single.$6.lineRange, f.position.lineRange);
    },
  );
  test(
    'fresh context typed failure never sets uncertain-write inspection',
    () async {
      final f = Fixture();
      await f.ready();
      f.details.contextResult = const GitLabForbiddenException('Forbidden');
      await expectLater(f.save(), throwsA(isA<GitLabForbiddenException>()));
      expect(f.parentReads, 0);
      expect(f.controller.pendingSaveNeedsInspection, false);
    },
  );
  test('view already obsolete dispatches no reads', () async {
    final f = Fixture();
    await f.ready();
    expect(await f.save(current: () => false), null);
    expect(f.details.contexts, 1);
    expect(f.parentReads, 0);
  });
  test(
    'snapshot reload cancels unresolved fresh context and discards late failure',
    () async {
      final f = Fixture();
      await f.ready();
      final context = Completer<MrOriginalCommitContext?>();
      f.details.contextResult = context.future;
      final save = f.save();
      await pumpEventQueue();
      f.c.invalidate(mrOriginalReviewControllerProvider(original.arg));
      expect(await save.timeout(const Duration(seconds: 2)), null);
      context.completeError(const GitLabServerException('Late'));
      await pumpEventQueue();
      expect(f.parentReads, 0);
      expect(f.mockDrafts.commits, isEmpty);
    },
  );
  for (final wrong in [
    original.mr.copyWith(id: 1101),
    original.mr.copyWith(targetProjectId: 9),
    original.mr.copyWith(sourceProjectId: 20),
    original.mr.copyWith(sourceBranch: 'changed'),
    original.mr.copyWith(targetBranch: 'changed'),
  ]) {
    test(
      'fresh private detail cannot substitute original identity $wrong',
      () async {
        final f = Fixture();
        await f.ready();
        f.details.result = wrong;
        await expectLater(f.save(), throwsA(isA<GitLabConflictException>()));
        expect(f.parentReads, 0);
        expect(f.mockDrafts.commits, isEmpty);
      },
    );
  }

  test(
    'fresh original selection and parent read precede one exact private write',
    () async {
      final f = Fixture();
      await f.ready();
      expect(await f.save(), f.mockDrafts.saved);
      expect(f.details.contexts, 2);
      expect(f.parentReads, 1);
      expect(f.mockDrafts.commits, [
        (8, 142, 1100, original.head, pending.markdown, f.position),
      ]);
      expect(f.mockDrafts.writes, isEmpty);
      expect(f.comments.posts, isEmpty);
      expect(f.events.names, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
    },
  );
  for (final body in ['', '  \n ']) {
    test('blank original note never reads or writes', () async {
      final f = Fixture();
      await f.ready();
      expect(await f.save(body: body), null);
      expect(f.details.contexts, 1);
      expect(f.parentReads, 0);
      expect(f.mockDrafts.commits, isEmpty);
    });
  }
  for (final value in [
    original.context(parents: null),
    original.context(parents: []),
    original.context(parents: [original.parent, original.other]),
    original.context(parents: [original.other]),
    original.context(
      files: [
        original.literal.copyWith(
          diff: original.raw.replaceFirst('same', 'changed'),
        ),
      ],
    ),
    original.context(detail: original.mr.copyWith(sourceProjectId: 20)),
  ]) {
    test(
      'changed original context rejects before parent or write: $value',
      () async {
        final f = Fixture();
        await f.ready();
        f.details.contextResult = value;
        await expectLater(f.save(), throwsA(isA<GitLabConflictException>()));
        expect(f.parentReads, 0);
        expect(f.mockDrafts.commits, isEmpty);
      },
    );
  }
  test('wrong MR route is rejected without reads', () async {
    final f = Fixture();
    await f.ready();
    expect(
      await f.save(
        query: (
          projectId: 9,
          iid: 142,
          mergeRequestId: 1100,
          commitId: original.head,
        ),
      ),
      null,
    );
    expect(f.details.contexts, 1);
    expect(f.parentReads, 0);
  });
  test(
    'parent unavailable propagates typed failure without write or recovery gate',
    () async {
      final f = Fixture();
      await f.ready();
      f.parentResult = const GitLabNotFoundException('Missing');
      await expectLater(f.save(), throwsA(isA<GitLabNotFoundException>()));
      expect(f.mockDrafts.commits, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
    },
  );
  test(
    'original reservation blocks public, private and pagination while parent resolves',
    () async {
      final f = Fixture();
      await f.ready();
      final parent = Completer<Object>();
      f.parentResult = parent.future;
      final save = f.save();
      await pumpEventQueue();
      expect(f.parentReads, 1);
      expect(await f.controller.savePendingNote(pending.markdown), null);
      await f.controller.post('Public');
      await f.controller.loadMore();
      expect(f.comments.posts, isEmpty);
      expect(f.comments.pages, [1]);
      parent.complete(api.commit(id: original.parent));
      expect(await save, isNotNull);
    },
  );
  for (final cancel in ['account', 'client', 'source', 'reload', 'view']) {
    test(
      '$cancel cancellation before dispatch releases unresolved save',
      () async {
        final f = Fixture();
        await f.ready();
        final parent = Completer<Object>();
        f.parentResult = parent.future;
        var active = true;
        final save = f.save(current: () => active);
        await pumpEventQueue();
        switch (cancel) {
          case 'account':
            f.c.read(pending.accountState.notifier).state = null;
          case 'client':
            f.c.read(pending.clientState.notifier).state = Future.value(null);
          case 'source':
            f.c.read(pending.sourceState.notifier).state = Future.value(null);
          case 'reload':
            f.c.invalidate(mrOriginalReviewControllerProvider(original.arg));
          case 'view':
            active = false;
            parent.complete(api.commit(id: original.parent));
        }
        expect(await save.timeout(const Duration(seconds: 2)), null);
        expect(f.mockDrafts.commits, isEmpty);
        if (!parent.isCompleted) {
          parent.complete(api.commit(id: original.parent));
        }
        await pumpEventQueue();
        expect(f.mockDrafts.commits, isEmpty);
      },
    );
  }
  for (final bad in [
    'error',
    'commit',
    'position',
    'author',
    'global',
    'body',
    'public',
  ]) {
    test(
      'uncertain $bad requires explicit read-only inspection and no replay',
      () async {
        final f = Fixture();
        await f.ready();
        final d = f.mockDrafts.saved;
        f.mockDrafts.outcome = switch (bad) {
          'error' => const GitLabServerException('Uncertain'),
          'commit' => d.copyWith(commitId: original.other),
          'position' => d.copyWith(position: f.position.copyWith(newLine: 10)),
          'author' => d.copyWith(authorId: 24),
          'global' => d.copyWith(mergeRequestId: 1101),
          'body' => d.copyWith(note: 'different'),
          _ => d.copyWith(resolveDiscussion: true),
        };
        await expectLater(f.save(), throwsA(isA<GitLabServerException>()));
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(await f.save(), null);
        f.mockDrafts.pages[1] = pending.page([d], next: 2);
        f.mockDrafts.pages[2] = pending.page([]);
        expect(await f.controller.inspectPendingNotes(), [d]);
        expect(f.mockDrafts.reads, [(8, 142, 1, 20), (8, 142, 2, 20)]);
        expect(f.mockDrafts.commits.length, 1);
        expect(f.comments.posts, isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
  }
  test(
    'late cancelled write must settle before complete read-only inspection',
    () async {
      final f = Fixture();
      await f.ready();
      final write = Completer<MergeRequestDraftNote>();
      f.mockDrafts.outcome = write.future;
      final save = f.save();
      await pumpEventQueue();
      expect(f.mockDrafts.commits.length, 1);
      f.c.invalidate(mrOriginalReviewControllerProvider(original.arg));
      expect(await save, null);
      expect(f.controller.pendingSaveNeedsInspection, true);
      final inspect = f.controller.inspectPendingNotes();
      await pumpEventQueue();
      expect(f.mockDrafts.reads, isEmpty);
      write.complete(f.mockDrafts.saved);
      expect(await inspect, isEmpty);
      expect(f.mockDrafts.reads, [(8, 142, 1, 20)]);
      expect(f.mockDrafts.commits.length, 1);
    },
  );
}
