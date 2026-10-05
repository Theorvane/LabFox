import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/gitlab_client_provider.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_pending_review_controller.dart';

const resource = MergeRequestRef(projectId: 8, iid: 142);
const account = Account(
  instanceUrl: 'https://gitlab.example.com',
  user: User(id: 23, username: 'reviewer', name: 'Reviewer'),
);
const markdown = '  **Private**\n\nKeep this exact text.  ';
MergeRequest mr({int id = 1100, int iid = 142, int? project = 8}) =>
    MergeRequest(
      id: id,
      iid: iid,
      projectId: project,
      title: 'Review',
      state: 'opened',
      sourceBranch: 'feature',
      targetBranch: 'dev',
    );
MergeRequestDraftNote draft(
  int id, {
  int global = 1100,
  int author = 23,
  String body = markdown,
}) => MergeRequestDraftNote(
  id: id,
  authorId: author,
  mergeRequestId: global,
  note: body,
);
Paginated<MergeRequestDraftNote> page(
  List<MergeRequestDraftNote> items, {
  int? next,
}) => Paginated(items: items, nextPage: next);
final accountState = StateProvider<Account?>((ref) => account);
final draftState = StateProvider<Future<MrDraftNotesRepository?>>(
  (ref) async => null,
);
final sourceState = StateProvider<Future<MergeRequestsRepository?>>(
  (ref) async => null,
);
final clientState = StateProvider<Future<GitLabClient?>>((ref) async => null);
final commentsState = StateProvider<Future<CommentsRepository?>>(
  (ref) async => null,
);
GitLabClient client() => GitLabClient(
  baseUrl: 'https://gitlab.example.com',
  token: 'glpat-xxxxxxxxxxxx',
);

class Drafts extends MrDraftNotesRepository {
  Drafts(this.client, {int author = 23}) : super(client, authorId: author);
  final GitLabClient client;
  Object result = draft(7);
  final writes = <(int, int, int, String, DiffNotePosition?)>[];
  final reads = <(int, int, int, int)>[];
  final pages = <int, Object>{1: page([])};
  @override
  Future<MergeRequestDraftNote> create({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String note,
    DiffNotePosition? position,
  }) async {
    writes.add((projectId, iid, mergeRequestId, note, position));
    final value = result;
    if (value is Future<MergeRequestDraftNote>) return value;
    if (value is MergeRequestDraftNote) return value;
    throw value;
  }

  @override
  Future<Paginated<MergeRequestDraftNote>> list({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    reads.add((projectId, iid, page, perPage));
    final value = pages[page]!;
    if (value is Future<Paginated<MergeRequestDraftNote>>) return value;
    if (value is Paginated<MergeRequestDraftNote>) return value;
    throw value;
  }
}

class Details extends MergeRequestsRepository {
  Details(super.client);
  Object result = mr();
  final reads = <(int, int)>[];
  @override
  Future<MergeRequest> get({required int projectId, required int iid}) async {
    reads.add((projectId, iid));
    final value = result;
    if (value is Future<MergeRequest>) return value;
    if (value is MergeRequest) return value;
    throw value;
  }
}

class Comments extends CommentsRepository {
  Comments(super.client);
  Object pageResult = const Paginated<Discussion>(items: [], nextPage: 2);
  Future<Note>? pendingPost;
  final posts = <String>[];
  final pages = <int>[];
  @override
  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    pages.add(page);
    if (pageResult is Future<Paginated<Discussion>>) {
      return pageResult as Future<Paginated<Discussion>>;
    }
    if (pageResult is Paginated<Discussion>) {
      return pageResult as Paginated<Discussion>;
    }
    throw pageResult;
  }

  @override
  Future<Note> post({
    required NoteableType type,
    required int projectId,
    required int iid,
    required String body,
  }) async {
    posts.add(body);
    return pendingPost ?? const Note(id: 9, body: 'Public');
  }
}

class Events implements Analytics {
  final names = <String>[];
  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    names.add(name);
  }
}

class Fixture {
  Fixture() {
    c = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(events),
        currentAccountProvider.overrideWith((ref) => ref.watch(accountState)),
        draftState.overrideWith((ref) async => drafts),
        sourceState.overrideWith((ref) async => details),
        commentsState.overrideWith((ref) async => comments),
        clientState.overrideWith((ref) async => api),
        mrDraftNotesRepositoryProvider.overrideWith(
          (ref) => ref.watch(draftState),
        ),
        mergeRequestsRepositoryProvider.overrideWith(
          (ref) => ref.watch(sourceState),
        ),
        commentsRepositoryProvider.overrideWith(
          (ref) => ref.watch(commentsState),
        ),
        gitLabClientProvider.overrideWith((ref) => ref.watch(clientState)),
      ],
    );
    addTearDown(c.dispose);
    addTearDown(api.close);
  }
  final events = Events();
  final api = client();
  late final drafts = Drafts(api);
  late final details = Details(api);
  late final comments = Comments(api);
  late final ProviderContainer c;
  MrDiscussionsController get controller =>
      c.read(mrDiscussionsControllerProvider(resource).notifier);
  Future<void> ready() async =>
      c.read(mrDiscussionsControllerProvider(resource).future);
  Future<MergeRequestDraftNote?> save({bool Function()? current}) =>
      controller.savePendingNote(markdown, isCurrent: current);
  Future<List<MergeRequestDraftNote>?> inspect({bool Function()? current}) =>
      controller.inspectPendingNotes(isCurrent: current);
  Future<void> fail() async {
    drafts.result = const GitLabServerException('Uncertain save.');
    await expectLater(save(), throwsA(isA<GitLabServerException>()));
    expect(controller.pendingSaveNeedsInspection, true);
  }
}

void main() {
  test(
    'regular save preserves exact body and separates route IID from global ID',
    () async {
      final f = Fixture();
      await f.ready();
      final saved = await f.save();
      expect(saved, draft(7));
      expect(f.drafts.writes, [(8, 142, 1100, markdown, null)]);
      expect(f.details.reads, [(8, 142)]);
      expect(f.comments.posts, isEmpty);
      expect(f.events.names, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
    },
  );
  for (final body in ['', '  \n\t ']) {
    test('blank note $body does not read or dispatch', () async {
      final f = Fixture();
      await f.ready();
      expect(await f.controller.savePendingNote(body), isNull);
      expect(f.details.reads, isEmpty);
      expect(f.drafts.writes, isEmpty);
    });
  }
  test('repository wait reserves duplicate saves and public writes', () async {
    final f = Fixture();
    await f.ready();
    final pending = Completer<MrDraftNotesRepository?>();
    f.c.read(draftState.notifier).state = pending.future;
    final saving = f.save();
    await f.c.pump();
    expect(await f.save(), isNull);
    expect(await f.controller.post('Other'), false);
    await f.controller.loadMore();
    expect(f.comments.pages, [1]);
    pending.complete(f.drafts);
    expect(await saving, draft(7));
    expect(f.drafts.writes.length, 1);
  });
  test(
    'public write prevents private save and releases after completion',
    () async {
      final f = Fixture();
      await f.ready();
      final pending = Completer<Note>();
      f.comments.pendingPost = pending.future;
      final posting = f.controller.post('Other');
      await f.c.pump();
      expect(await f.save(), isNull);
      pending.complete(const Note(id: 9, body: 'Other'));
      expect(await posting, true);
      await f.c.pump();
      await f.ready();
      expect(await f.save(), draft(7));
    },
  );
  test('in-flight pagination prevents private save', () async {
    final f = Fixture();
    await f.ready();
    final pending = Completer<Paginated<Discussion>>();
    f.comments.pageResult = pending.future;
    final loading = f.controller.loadMore();
    await f.c.pump();
    expect(await f.save(), isNull);
    pending.complete(const Paginated(items: []));
    await loading;
    expect(await f.save(), draft(7));
  });
  for (final detail in [mr(id: 0), mr(iid: 143), mr(project: 9)]) {
    test(
      'invalid authoritative detail ${detail.id}/${detail.iid}/${detail.projectId} prevents save',
      () async {
        final f = Fixture();
        await f.ready();
        f.details.result = detail;
        await expectLater(f.save(), throwsA(isA<GitLabServerException>()));
        expect(f.drafts.writes, isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
  }
  test(
    'nullable project identity still uses authoritative global ID',
    () async {
      final f = Fixture();
      await f.ready();
      f.details.result = mr(project: null);
      expect(await f.save(), draft(7));
    },
  );
  test(
    'fresh detail is awaited and previous cached ID is never used',
    () async {
      final f = Fixture();
      await f.ready();
      await f.c.read(mergeRequestControllerProvider(resource).future);
      final pending = Completer<MergeRequest>();
      f.details.result = pending.future;
      final saving = f.save();
      await f.c.pump();
      expect(f.drafts.writes, isEmpty);
      f.drafts.result = draft(8, global: 1200);
      pending.complete(mr(id: 1200));
      expect((await saving)!.mergeRequestId, 1200);
      expect(f.drafts.writes.single.$3, 1200);
    },
  );
  for (final result in [
    draft(0),
    draft(7, global: 142),
    draft(7, author: 24),
    draft(7, body: 'Altered'),
  ]) {
    test('unconfirmed create response $result keeps inspection gate', () async {
      final f = Fixture();
      await f.ready();
      f.drafts.result = result;
      await expectLater(f.save(), throwsA(isA<GitLabServerException>()));
      expect(f.controller.pendingSaveNeedsInspection, true);
      expect(await f.save(), isNull);
      expect(f.drafts.writes.length, 1);
    });
  }
  for (final error in [
    const GitLabAuthException('Rejected'),
    const GitLabForbiddenException('Rejected'),
    const GitLabServerException('Unknown'),
    const GitLabConflictException('Rejected'),
  ]) {
    test(
      'failed dispatched save $error is never retried without inspection',
      () async {
        final f = Fixture();
        await f.ready();
        f.drafts.result = error;
        await expectLater(f.save(), throwsA(same(error)));
        expect(await f.save(), isNull);
        expect(f.drafts.writes.length, 1);
        expect(f.drafts.reads, isEmpty);
        f.c.invalidate(mrDiscussionsControllerProvider(resource));
        await f.ready();
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(await f.save(), isNull);
      },
    );
  }
  test(
    'complete explicit inspection follows empty cursors and permits manual save only',
    () async {
      final f = Fixture();
      await f.ready();
      await f.fail();
      f.drafts.pages.addAll({
        1: page([draft(9)], next: 3),
        3: page([], next: 8),
        8: page([draft(2), draft(7)]),
      });
      final result = await f.inspect();
      expect(result!.map((d) => d.id), [9, 2, 7]);
      expect(() => result.clear(), throwsUnsupportedError);
      expect(f.drafts.reads, [
        (8, 142, 1, 20),
        (8, 142, 3, 20),
        (8, 142, 8, 20),
      ]);
      expect(f.controller.pendingSaveNeedsInspection, false);
      expect(f.drafts.writes.length, 1);
      f.drafts.result = draft(10);
      expect(await f.save(), draft(10));
      expect(f.drafts.writes.length, 2);
    },
  );
  for (final bad in [
    page([draft(1), draft(1)]),
    page([draft(1, author: 24)]),
    page([draft(1, global: 142)]),
    page([draft(0)]),
    page([], next: 1),
    page([], next: 0),
  ]) {
    test(
      'malformed inspection $bad keeps gate and cannot return partial notes',
      () async {
        final f = Fixture();
        await f.ready();
        await f.fail();
        f.drafts.pages[1] = bad;
        await expectLater(f.inspect(), throwsA(isA<GitLabServerException>()));
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(await f.save(), isNull);
        expect(f.drafts.writes.length, 1);
      },
    );
  }
  test('late duplicate inspection page rejects complete result', () async {
    final f = Fixture();
    await f.ready();
    await f.fail();
    f.drafts.pages.addAll({
      1: page([draft(1)], next: 2),
      2: page([draft(1)]),
    });
    await expectLater(f.inspect(), throwsA(isA<GitLabServerException>()));
    expect(f.controller.pendingSaveNeedsInspection, true);
  });
  test('late inspection page failure retains uncertainty', () async {
    final f = Fixture();
    await f.ready();
    await f.fail();
    f.drafts.pages.addAll({
      1: page([draft(1)], next: 2),
      2: const GitLabForbiddenException('Rejected'),
    });
    await expectLater(f.inspect(), throwsA(isA<GitLabForbiddenException>()));
    expect(f.controller.pendingSaveNeedsInspection, true);
  });
  test(
    'inspection shares reservation with save and public operations',
    () async {
      final f = Fixture();
      await f.ready();
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      f.drafts.pages[1] = pending.future;
      final inspect = f.inspect();
      await f.c.pump();
      expect(await f.inspect(), isNull);
      expect(await f.save(), isNull);
      expect(await f.controller.post('Public'), false);
      pending.complete(page([]));
      expect(await inspect, isEmpty);
    },
  );
  test(
    'same-account repository replacement keeps uncertainty until inspection',
    () async {
      final f = Fixture();
      await f.ready();
      await f.fail();
      final replacement = Drafts(f.api);
      f.c.read(draftState.notifier).state = Future.value(replacement);
      await f.c.pump();
      expect(f.controller.pendingSaveNeedsInspection, true);
      expect(await f.save(), isNull);
      expect(await f.inspect(), isEmpty);
      expect(await f.save(), draft(7));
      expect(replacement.writes.length, 1);
    },
  );
  for (final change in [
    'account',
    'client',
    'draft repository',
    'detail repository',
    'comments repository',
    'dispose',
    'view',
  ]) {
    test('$change replacement cancels waiting save before dispatch', () async {
      final f = Fixture();
      await f.ready();
      final pending = Completer<MergeRequest>();
      f.details.result = pending.future;
      var active = true;
      final saving = f.save(current: () => active);
      await f.c.pump();
      switch (change) {
        case 'account':
          f.c.read(accountState.notifier).state = account.copyWith(
            user: const User(id: 24, username: 'other', name: 'Other'),
          );
        case 'client':
          final api = client();
          addTearDown(api.close);
          f.c.read(clientState.notifier).state = Future.value(api);
        case 'draft repository':
          f.c.read(draftState.notifier).state = Future.value(Drafts(f.api));
        case 'detail repository':
          f.c.read(sourceState.notifier).state = Future.value(Details(f.api));
        case 'comments repository':
          f.c.read(commentsState.notifier).state = Future.value(
            Comments(f.api),
          );
        case 'dispose':
          f.c.invalidate(mrDiscussionsControllerProvider(resource));
        case 'view':
          active = false;
          pending.complete(mr());
      }
      await f.c.pump();
      expect(await saving.timeout(const Duration(seconds: 1)), isNull);
      expect(f.drafts.writes, isEmpty);
      if (!pending.isCompleted) pending.complete(mr());
      await f.c.pump();
    });
  }
  for (final lateError in [false, true]) {
    test(
      'obsolete dispatched save late error=$lateError cannot refresh or clear uncertainty',
      () async {
        final f = Fixture();
        await f.ready();
        final pending = Completer<MergeRequestDraftNote>();
        f.drafts.result = pending.future;
        final saving = f.save();
        await f.c.pump();
        expect(f.drafts.writes.length, 1);
        f.c.invalidate(mrDiscussionsControllerProvider(resource));
        await f.ready();
        expect(await saving, isNull);
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(await f.save(), isNull);
        if (lateError) {
          pending.completeError(const GitLabServerException('Late'));
        } else {
          pending.complete(draft(7));
        }
        await f.c.pump();
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(f.c.read(mrDraftNotesRevisionProvider(resource)), 0);
        expect(await f.inspect(), isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
  }
  test(
    'inspection waits for cancelled in-flight write to settle before reading',
    () async {
      final f = Fixture();
      await f.ready();
      final pending = Completer<MergeRequestDraftNote>();
      f.drafts.result = pending.future;
      final saving = f.save();
      await f.c.pump();
      f.c.invalidate(mrDiscussionsControllerProvider(resource));
      await f.ready();
      expect(await saving, isNull);
      final inspecting = f.inspect();
      await f.c.pump();
      expect(f.drafts.reads, isEmpty);
      expect(await f.save(), isNull);
      pending.complete(draft(7));
      expect(await inspecting, isEmpty);
      expect(f.drafts.writes.length, 1);
    },
  );
  test(
    'view replacement during dispatch retains same-session inspection requirement',
    () async {
      final f = Fixture();
      await f.ready();
      final pending = Completer<MergeRequestDraftNote>();
      f.drafts.result = pending.future;
      var active = true;
      final saving = f.save(current: () => active);
      await f.c.pump();
      active = false;
      pending.complete(draft(7));
      expect(await saving, isNull);
      expect(f.controller.pendingSaveNeedsInspection, true);
      expect(f.c.read(mrDraftNotesRevisionProvider(resource)), 0);
    },
  );
  test(
    'successful save invalidates all matching private reader variants only',
    () async {
      final f = Fixture();
      await f.ready();
      const q = MrPendingReviewQuery(
        mergeRequest: resource,
        mergeRequestId: 1100,
        perPage: 10,
      );
      const other = MergeRequestRef(projectId: 8, iid: 143);
      final subs = [
        f.c.listen(mrPendingReviewProvider(q), (_, _) {}),
        f.c.listen(
          mrDraftNotesPageProvider(
            const MrDraftNotesQuery(mergeRequest: resource, page: 3),
          ),
          (_, _) {},
        ),
        f.c.listen(mrDraftNotesRevisionProvider(other), (_, _) {}),
      ];
      for (final s in subs) {
        addTearDown(s.close);
      }
      f.drafts.pages[3] = page([]);
      await f.c.read(mrPendingReviewControllerProvider(q).future);
      await f.c.read(
        mrDraftNotesReadProvider(
          const MrDraftNotesQuery(mergeRequest: resource, page: 3),
        ).future,
      );
      final before = f.drafts.reads.length;
      expect(await f.save(), draft(7));
      await f.c.pump();
      expect(f.c.read(mrDraftNotesRevisionProvider(resource)), 1);
      expect(f.c.read(mrDraftNotesRevisionProvider(other)), 0);
      await f.c.read(mrPendingReviewControllerProvider(q).future);
      await f.c.read(
        mrDraftNotesReadProvider(
          const MrDraftNotesQuery(mergeRequest: resource, page: 3),
        ).future,
      );
      expect(f.drafts.reads.length, before + 2);
      expect(f.comments.pages, [1]);
    },
  );
  for (final changed in ['account', 'instance', 'sign-out']) {
    test('actual $changed private session removes old uncertainty', () async {
      final f = Fixture();
      await f.ready();
      await f.fail();
      switch (changed) {
        case 'account':
          f.c.read(accountState.notifier).state = account.copyWith(
            user: const User(id: 24, username: 'other', name: 'Other'),
          );
        case 'instance':
          f.c.read(accountState.notifier).state = account.copyWith(
            instanceUrl: 'https://other.example.com',
          );
        case 'client':
          final api = client();
          addTearDown(api.close);
          f.c.read(clientState.notifier).state = Future.value(api);
          await f.c.pump();
        case 'sign-out':
          f.c.read(accountState.notifier).state = null;
      }
      expect(f.controller.pendingSaveNeedsInspection, false);
    });
  }
  test('same-account client replacement cannot clear uncertain save', () async {
    final f = Fixture();
    await f.ready();
    await f.fail();
    final replacement = client();
    addTearDown(replacement.close);
    f.c.read(clientState.notifier).state = Future.value(replacement);
    await f.c.read(gitLabClientProvider.future);
    expect(f.controller.pendingSaveNeedsInspection, true);
    expect(await f.save(), isNull);
    expect(f.drafts.writes.length, 1);
    expect(await f.inspect(), isEmpty);
    expect(f.controller.pendingSaveNeedsInspection, false);
  });
  for (final failure in [
    'detail',
    'draft repository',
    'detail repository',
    'client',
  ]) {
    test(
      'failed $failure preflight never writes or requires inspection',
      () async {
        final f = Fixture();
        await f.ready();
        const error = GitLabForbiddenException('Rejected');
        switch (failure) {
          case 'detail':
            f.details.result = error;
          case 'draft repository':
            f.c.read(draftState.notifier).state = Future.error(error);
          case 'detail repository':
            f.c.read(sourceState.notifier).state = Future.error(error);
          case 'client':
            f.c.read(clientState.notifier).state = Future.error(error);
        }
        await expectLater(f.save(), throwsA(same(error)));
        expect(f.drafts.writes, isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
        expect(f.events.names, isEmpty);
      },
    );
  }
  for (final unavailable in [
    'signed-out',
    'client',
    'draft repository',
    'detail repository',
    'wrong author',
  ]) {
    test('unavailable $unavailable session rejects before write', () async {
      final f = Fixture();
      await f.ready();
      switch (unavailable) {
        case 'signed-out':
          f.c.read(accountState.notifier).state = null;
        case 'client':
          f.c.read(clientState.notifier).state = Future.value(null);
        case 'draft repository':
          f.c.read(draftState.notifier).state = Future.value(null);
        case 'detail repository':
          f.c.read(sourceState.notifier).state = Future.value(null);
        case 'wrong author':
          f.c.read(draftState.notifier).state = Future.value(
            Drafts(f.api, author: 24),
          );
      }
      await expectLater(f.save(), throwsA(isA<GitLabAuthException>()));
      expect(f.drafts.writes, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
    });
  }
  for (final stale in ['account', 'repository', 'detail', 'view']) {
    for (final lateError in [false, true]) {
      test(
        'obsolete inspection $stale lateError=$lateError returns no private rows or next-page reads',
        () async {
          final f = Fixture();
          await f.ready();
          await f.fail();
          final pending = Completer<Paginated<MergeRequestDraftNote>>();
          f.drafts.pages[1] = pending.future;
          var active = true;
          final inspecting = f.inspect(current: () => active);
          await f.c.pump();
          expect(f.drafts.reads.length, 1);
          switch (stale) {
            case 'account':
              f.c.read(accountState.notifier).state = null;
            case 'repository':
              f.c.read(draftState.notifier).state = Future.value(Drafts(f.api));
            case 'detail':
              f.c.invalidate(mergeRequestControllerProvider(resource));
            case 'view':
              active = false;
          }
          await f.c.pump();
          if (lateError) {
            pending.completeError(const GitLabServerException('Late'));
          } else {
            pending.complete(page([draft(1)], next: 2));
          }
          expect(await inspecting, isNull);
          await f.c.pump();
          expect(f.drafts.reads.length, 1);
          expect(f.drafts.writes.length, 1);
          expect(f.events.names, isEmpty);
          if (stale != 'account') {
            expect(f.controller.pendingSaveNeedsInspection, true);
          }
        },
      );
    }
  }
  test(
    'known reply, resolve and suggestion targets cannot overlap private save',
    () async {
      final f = Fixture();
      const suggestion = Suggestion(
        id: 7,
        fromLine: 1,
        toLine: 1,
        applied: false,
        applicable: true,
        fromContent: 'Old',
        toContent: 'New',
      );
      const note = Note(
        id: 4,
        body: 'Review',
        resolvable: true,
        resolved: false,
        suggestions: [suggestion],
      );
      f.comments.pageResult = const Paginated<Discussion>(
        items: [
          Discussion(id: 'thread', individualNote: false, notes: [note]),
        ],
      );
      await f.ready();
      final pending = Completer<MergeRequestDraftNote>();
      f.drafts.result = pending.future;
      final saving = f.save();
      await f.c.pump();
      expect(f.drafts.writes.length, 1);
      expect(
        await f.controller.reply(discussionId: 'thread', body: 'Reply'),
        false,
      );
      expect(
        await f.controller.setResolved(discussionId: 'thread', resolved: true),
        false,
      );
      expect(
        await f.controller.applySuggestion(
          discussionId: 'thread',
          note: note,
          suggestion: suggestion,
        ),
        false,
      );
      expect(await f.controller.inspectDiscussion('thread'), isNull);
      pending.complete(draft(7));
      expect(await saving, draft(7));
    },
  );
  test(
    'same-account client replacement while write runs preserves settlement barrier',
    () async {
      final f = Fixture();
      await f.ready();
      final pending = Completer<MergeRequestDraftNote>();
      f.drafts.result = pending.future;
      final saving = f.save();
      await f.c.pump();
      expect(f.drafts.writes.length, 1);
      final replacement = client();
      addTearDown(replacement.close);
      f.c.read(clientState.notifier).state = Future.value(replacement);
      await f.c.pump();
      expect(await saving, isNull);
      expect(f.controller.pendingSaveNeedsInspection, true);
      final inspecting = f.inspect();
      await f.c.pump();
      expect(f.drafts.reads, isEmpty);
      pending.completeError(const GitLabServerException('Late'));
      expect(await inspecting, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
      expect(f.drafts.writes.length, 1);
    },
  );
}
