import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';
import 'mr_pending_inline_save_test.dart' as b;

const thread = Discussion(
  id: 'thread',
  individualNote: false,
  notes: [
    Note(id: 1, body: 'Review this change', resolvable: true, resolved: false),
  ],
);
MergeRequestDraftNote reply() =>
    b.draft(7).copyWith(discussionId: thread.id, resolveDiscussion: false);

class Drafts extends b.Drafts {
  Drafts(super.client);
  final replies = <(int, int, int, String, String)>[];
  @override
  Future<MergeRequestDraftNote> createReply({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String discussionId,
    required String note,
  }) async {
    replies.add((projectId, iid, mergeRequestId, discussionId, note));
    final v = result;
    if (v is Future<MergeRequestDraftNote>) return v;
    if (v is MergeRequestDraftNote) return v;
    throw v;
  }

  @override
  Future<void> publish({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    String? summaryNote,
    ReviewerSubmissionState? reviewerState,
  }) async {
    throw const GitLabServerException('Uncertain publication');
  }

  @override
  Future<Paginated<MergeRequestReviewer>> reviewers({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async => const Paginated(items: []);
}

class Comments extends b.Comments {
  Comments(super.client);
  Object fresh = thread;
  final targets = <(int, int, String)>[];
  @override
  Future<Discussion> discussion({
    required int projectId,
    required int iid,
    required String discussionId,
  }) async {
    targets.add((projectId, iid, discussionId));
    final v = fresh;
    if (v is Future<Discussion>) return v;
    if (v is Discussion) return v;
    throw v;
  }
}

class Fixture extends b.Fixture {
  late final privateDrafts = Drafts(api)..result = reply();
  late final publicComments = Comments(api)
    ..pageResult = const Paginated<Discussion>(items: [thread], nextPage: 2);
  Future<void> init() async {
    c.read(b.draftState.notifier).state = Future.value(privateDrafts);
    c.read(b.commentsState.notifier).state = Future.value(publicComments);
    await ready();
  }

  Future<MergeRequestDraftNote?> saveReply({
    Discussion target = thread,
    String body = b.markdown,
    bool Function()? current,
  }) => controller.savePendingReply(target, body, isCurrent: current);
  Future<MrPendingReplyInspection?> inspectReply({bool Function()? current}) =>
      controller.inspectPendingReply(thread, isCurrent: current);
}

// Invalidates the captured view as the authoritative detail is validated.
class BoundaryDetail implements MergeRequest {
  BoundaryDetail(this.cancel);
  final void Function() cancel;
  @override
  int get id {
    scheduleMicrotask(cancel);
    return 1100;
  }

  @override
  int get iid => 142;
  @override
  int? get projectId => 8;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  for (final inspecting in [false, true]) {
    test(
      'cancelled detail boundary cannot dispatch a fresh public target read inspecting=$inspecting',
      () async {
        final f = Fixture();
        await f.init();
        var active = true;
        f.details.result = BoundaryDetail(() => active = false);
        final result = inspecting
            ? await f.inspectReply(current: () => active)
            : await f.saveReply(current: () => active);
        expect(result, isNull);
        expect(f.publicComments.targets, isEmpty);
        expect(f.privateDrafts.replies, isEmpty);
      },
    );
  }

  test(
    'same-account repository replacement recovery waits for dispatched write',
    () async {
      final f = Fixture();
      await f.init();
      final write = Completer<MergeRequestDraftNote>();
      f.privateDrafts.result = write.future;
      final saving = f.saveReply();
      await f.c.pump();
      expect(f.privateDrafts.replies.length, 1);
      final replacement = Drafts(f.api);
      f.c.read(b.draftState.notifier).state = Future.value(replacement);
      await f.c.pump();
      expect(await saving, isNull);
      final inspection = f.inspectReply();
      await f.c.pump();
      expect(replacement.reads, isEmpty);
      write.complete(reply());
      replacement.pages[1] = b.page([reply()]);
      expect((await inspection)!.notes, [reply()]);
      expect(replacement.replies, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
    },
  );
  for (final target in [
    thread.copyWith(id: 'another'),
    thread.copyWith(notes: []),
    thread.copyWith(notes: [const Note(id: 0, body: 'Invalid')]),
    thread.copyWith(notes: [thread.notes.first, thread.notes.first]),
    const GitLabForbiddenException('Denied'),
    const GitLabConnectionException('Offline'),
  ]) {
    test(
      'failed target inspection stages nothing and keeps shared uncertainty $target',
      () async {
        final f = Fixture();
        await f.init();
        f.privateDrafts.result = const GitLabConnectionException('Uncertain');
        await expectLater(f.saveReply(), throwsA(isA<GitLabException>()));
        f.privateDrafts.pages[1] = b.page([reply()]);
        f.publicComments.fresh = target;
        await expectLater(f.inspectReply(), throwsA(isA<GitLabException>()));
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(
          f.c.read(mrDiscussionsControllerProvider(b.resource)).value!.items,
          [thread],
        );
        expect(f.privateDrafts.replies.length, 1);
      },
    );
  }
  for (final target in [
    thread.copyWith(individualNote: true),
    thread.copyWith(notes: [const Note(id: 1, body: 'System', isSystem: true)]),
  ]) {
    test(
      'fresh nonreplyable context can be inspected but never retried $target',
      () async {
        final f = Fixture();
        await f.init();
        f.publicComments.fresh = target;
        final inspection = await f.inspectReply();
        expect(inspection!.target, target);
        expect(await f.saveReply(target: target), isNull);
        expect(f.privateDrafts.replies, isEmpty);
      },
    );
  }
  test(
    'reply to positioned thread reuses discussion identity without constructing an anchor',
    () async {
      final f = Fixture();
      final target = thread.copyWith(
        notes: [
          thread.notes.first.copyWith(
            position: const DiffNotePosition(
              positionType: 'image',
              newPath: 'image.png',
            ),
          ),
        ],
      );
      f.publicComments.pageResult = Paginated(items: [target]);
      f.publicComments.fresh = target;
      await f.init();
      expect(await f.saveReply(target: target), reply());
      expect(f.privateDrafts.replies.single.$4, 'thread');
      expect(f.privateDrafts.writes, isEmpty);
    },
  );
  test('blank reply is refused before fresh reads', () async {
    final f = Fixture();
    await f.init();
    expect(await f.saveReply(body: ' \n '), isNull);
    expect(f.publicComments.targets, isEmpty);
    expect(f.privateDrafts.replies, isEmpty);
  });

  test(
    'fresh selected public target confirms one private non-resolving reply',
    () async {
      final f = Fixture();
      await f.init();
      expect(await f.saveReply(), reply());
      expect(f.publicComments.targets, [(8, 142, 'thread')]);
      expect(f.privateDrafts.replies, [(8, 142, 1100, 'thread', b.markdown)]);
      expect(f.privateDrafts.writes, isEmpty);
      expect(f.publicComments.posts, isEmpty);
      expect(f.events.names, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
      expect(f.c.read(mrDraftNotesRevisionProvider(b.resource)), 1);
    },
  );
  for (final invalid in [
    thread.copyWith(id: ''),
    thread.copyWith(individualNote: true),
    thread.copyWith(notes: []),
    thread.copyWith(notes: [const Note(id: 1, body: 'System', isSystem: true)]),
    thread.copyWith(notes: [const Note(id: 0, body: 'Invalid')]),
    thread.copyWith(notes: [thread.notes.first, thread.notes.first]),
  ]) {
    test(
      'ineligible or forged displayed target prevents dispatch $invalid',
      () async {
        final f = Fixture();
        await f.init();
        expect(await f.saveReply(target: invalid), isNull);
        expect(f.privateDrafts.replies, isEmpty);
        expect(f.publicComments.targets, isEmpty);
      },
    );
  }
  for (final fresh in [
    thread.copyWith(notes: [thread.notes.first.copyWith(body: 'Changed')]),
    thread.copyWith(notes: [thread.notes.first.copyWith(resolved: true)]),
    thread.copyWith(
      notes: [
        ...thread.notes,
        const Note(id: 2, body: 'New reply'),
      ],
    ),
    thread.copyWith(id: 'another'),
    const GitLabNotFoundException('Missing'),
  ]) {
    test('changed or missing fresh target cannot dispatch $fresh', () async {
      final f = Fixture();
      await f.init();
      f.publicComments.fresh = fresh;
      await expectLater(f.saveReply(), throwsA(isA<GitLabException>()));
      expect(f.privateDrafts.replies, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
    });
  }
  test(
    'fresh target read reserves public and private commands and pagination',
    () async {
      final f = Fixture();
      await f.init();
      final read = Completer<Discussion>();
      f.publicComments.fresh = read.future;
      final saving = f.saveReply();
      await f.c.pump();
      expect(await f.controller.post('Public'), false);
      expect(await f.saveReply(), isNull);
      expect(await f.save(), isNull);
      await f.controller.loadMore();
      expect(f.publicComments.pages, [1]);
      read.complete(thread);
      expect(await saving, reply());
    },
  );
  for (final bad in [
    reply().copyWith(id: 0),
    reply().copyWith(authorId: 24),
    reply().copyWith(mergeRequestId: 142),
    reply().copyWith(discussionId: 'another'),
    reply().copyWith(note: 'Changed'),
    reply().copyWith(resolveDiscussion: true),
    reply().copyWith(resolveDiscussion: null),
    reply().copyWith(commitId: 'commit'),
    reply().copyWith(lineCode: 'anchor'),
    reply().copyWith(position: const DiffNotePosition(positionType: 'image')),
  ]) {
    test(
      'unconfirmed reply metadata retains shared inspection gate $bad',
      () async {
        final f = Fixture();
        await f.init();
        f.privateDrafts.result = bad;
        await expectLater(f.saveReply(), throwsA(isA<GitLabServerException>()));
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(await f.saveReply(), isNull);
        expect(await f.save(), isNull);
        expect(f.privateDrafts.replies.length, 1);
      },
    );
  }
  test(
    'recovery waits for actual write settlement then stages all private pages and original target',
    () async {
      final f = Fixture();
      await f.init();
      var active = true;
      final write = Completer<MergeRequestDraftNote>();
      f.privateDrafts.result = write.future;
      final saving = f.saveReply(current: () => active);
      await f.c.pump();
      active = false;
      // Caller-only cancellation completes at the write boundary.
      write.completeError(const GitLabConnectionException('Uncertain'));
      expect(await saving, isNull);
      expect(f.controller.pendingSaveNeedsInspection, true);
      f.privateDrafts.pages[1] = b.page([reply()], next: 2);
      f.privateDrafts.pages[2] = b.page([]);
      final changed = thread.copyWith(
        notes: [
          ...thread.notes,
          const Note(id: 2, body: 'New context'),
        ],
      );
      f.publicComments.fresh = changed;
      final inspection = await f.inspectReply();
      expect(inspection!.notes, [reply()]);
      expect(inspection.target, changed);
      expect(f.privateDrafts.reads.map((r) => r.$3), [1, 2]);
      expect(
        f.c.read(mrDiscussionsControllerProvider(b.resource)).value!.items,
        [changed],
      );
      expect(f.controller.pendingSaveNeedsInspection, false);
      f.privateDrafts.result = reply();
      expect(await f.saveReply(target: changed), reply());
      expect(f.privateDrafts.replies.length, 2);
    },
  );
  test(
    'missing original target stays missing without adopting another discussion',
    () async {
      final f = Fixture();
      await f.init();
      f.privateDrafts.result = const GitLabConnectionException('Uncertain');
      await expectLater(f.saveReply(), throwsA(isA<GitLabException>()));
      f.privateDrafts.pages[1] = b.page([reply()]);
      f.publicComments.fresh = const GitLabNotFoundException('Missing');
      final inspection = await f.inspectReply();
      expect(inspection!.target, isNull);
      expect(inspection.notes, [reply()]);
      expect(
        f.c.read(mrDiscussionsControllerProvider(b.resource)).value!.items,
        isEmpty,
      );
      expect(await f.saveReply(), isNull);
      expect(f.privateDrafts.replies.length, 1);
    },
  );
  test(
    'failed second private page cannot adopt fresh target or clear uncertainty',
    () async {
      final f = Fixture();
      await f.init();
      f.privateDrafts.result = const GitLabConnectionException('Uncertain');
      await expectLater(f.saveReply(), throwsA(isA<GitLabException>()));
      f.privateDrafts.pages[1] = b.page([reply()], next: 2);
      f.privateDrafts.pages[2] = const GitLabServerException('Failed page');
      await expectLater(f.inspectReply(), throwsA(isA<GitLabException>()));
      expect(f.controller.pendingSaveNeedsInspection, true);
      expect(f.publicComments.targets.length, 1);
      expect(
        f.c.read(mrDiscussionsControllerProvider(b.resource)).value!.items,
        [thread],
      );
    },
  );
  test('scoped reply recovery cannot clear uncertain publication', () async {
    final f = Fixture();
    await f.init();
    final preview = await f.controller.preparePendingReviewPublication();
    await expectLater(
      f.controller.publishPendingReview(
        preview!,
        summaryNote: 'Public summary',
      ),
      throwsA(isA<GitLabException>()),
    );
    expect(f.controller.pendingPublicationNeedsInspection, true);
    expect(await f.inspectReply(), isNotNull);
    expect(f.controller.pendingPublicationNeedsInspection, true);
    expect(f.controller.pendingSaveNeedsInspection, true);
    expect(await f.saveReply(), isNull);
  });
  for (final phase in ['preflight', 'write', 'inspection']) {
    for (final change in [
      'account',
      'client',
      'drafts',
      'comments',
      'details',
      'controller',
      'view',
    ]) {
      test('$phase $change replacement discards late results', () async {
        final f = Fixture();
        await f.init();
        var active = true;
        final read = Completer<Discussion>();
        final write = Completer<MergeRequestDraftNote>();
        if (phase == 'write') {
          f.privateDrafts.result = write.future;
        } else {
          f.publicComments.fresh = read.future;
        }
        final Future<Object?> result = phase == 'inspection'
            ? f.inspectReply(current: () => active)
            : f.saveReply(current: () => active);
        await f.c.pump();
        switch (change) {
          case 'account':
            f.c.read(b.accountState.notifier).state = b.account.copyWith(
              instanceUrl: 'https://other.example.com',
            );
          case 'client':
            f.c.read(b.clientState.notifier).state = Future.value(null);
          case 'drafts':
            f.c.read(b.draftState.notifier).state = Future.value(Drafts(f.api));
          case 'comments':
            f.c.read(b.commentsState.notifier).state = Future.value(
              Comments(f.api),
            );
          case 'details':
            f.c.read(b.sourceState.notifier).state = Future.value(
              b.Details(f.api),
            );
          case 'controller':
            f.c.invalidate(mrDiscussionsControllerProvider(b.resource));
          case 'view':
            active = false;
        }
        await f.c.pump();
        if (phase == 'write') {
          write.complete(reply());
        } else {
          read.complete(thread);
        }
        expect(await result, isNull);
        expect(f.publicComments.posts, isEmpty);
        expect(f.events.names, isEmpty);
        expect(f.privateDrafts.replies.length, phase == 'write' ? 1 : 0);
      });
    }
  }
}
