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
  final pages = <int, Object>{
    1: page([draft(7)]),
  };
  final updates = <(int, int, int, MergeRequestDraftNote, String)>[];
  final deletes = <(int, int, int, MergeRequestDraftNote)>[];
  Object updated = draft(7, body: '  Updated **private**\n  ');
  Object? deleted;
  @override
  Future<MergeRequestDraftNote> update({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
    required String note,
  }) async {
    updates.add((projectId, iid, mergeRequestId, draft, note));
    final value = updated;
    if (value is Future<MergeRequestDraftNote>) return value;
    if (value is MergeRequestDraftNote) return value;
    throw value;
  }

  @override
  Future<void> delete({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
  }) async {
    deletes.add((projectId, iid, mergeRequestId, draft));
    final value = deleted;
    if (value is Future<void>) return value;
    if (value != null) throw value;
  }

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

const edited = '  Updated **private**\n  ';
Future<Object?> mutate(
  Fixture f,
  bool deleting, {
  MergeRequestDraftNote? target,
  bool Function()? current,
}) => deleting
    ? f.controller.deletePendingNote(target ?? draft(7), isCurrent: current)
    : f.controller.updatePendingNote(
        target ?? draft(7),
        edited,
        isCurrent: current,
      );

// Simulates an external account event queued at the target-comparison boundary.
class ComparedDraft implements MergeRequestDraftNote {
  ComparedDraft(this.original, this.onCompared);
  final MergeRequestDraftNote original;
  final void Function() onCompared;
  @override
  int get id => original.id;
  @override
  int get authorId => original.authorId;
  @override
  int get mergeRequestId => original.mergeRequestId;
  @override
  bool operator ==(Object other) {
    scheduleMicrotask(onCompared);
    return original == other;
  }

  @override
  int get hashCode => original.hashCode;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  for (final deleting in [false, true]) {
    final verb = deleting ? 'delete' : 'update';
    test(
      '$verb reloads all pages and confirms exact captured target before one write',
      () async {
        final f = Fixture();
        await f.ready();
        f.drafts.pages[1] = page([], next: 3);
        f.drafts.pages[3] = page([draft(7)]);
        final result = await mutate(f, deleting);
        expect(result, deleting ? true : draft(7, body: edited));
        expect(f.drafts.reads, [(8, 142, 1, 20), (8, 142, 3, 20)]);
        expect(f.details.reads, [(8, 142)]);
        expect(
          f.drafts.updates,
          deleting ? isEmpty : [(8, 142, 1100, draft(7), edited)],
        );
        expect(
          f.drafts.deletes,
          deleting ? [(8, 142, 1100, draft(7))] : isEmpty,
        );
        expect(f.drafts.writes, isEmpty);
        expect(f.comments.posts, isEmpty);
        expect(f.events.names, isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
    for (final replacement in [
      <MergeRequestDraftNote>[],
      [draft(7, body: 'Changed elsewhere')],
      [draft(7).copyWith(resolveDiscussion: true)],
      [draft(7).copyWith(discussionId: 'new-thread')],
      [draft(7).copyWith(commitId: 'different')],
      [draft(7).copyWith(lineCode: 'opaque')],
    ]) {
      test(
        '$verb refuses missing or stale target ${replacement.toString()}',
        () async {
          final f = Fixture();
          await f.ready();
          f.drafts.pages[1] = page(replacement);
          await expectLater(
            mutate(f, deleting),
            throwsA(isA<GitLabConflictException>()),
          );
          expect(f.drafts.updates, isEmpty);
          expect(f.drafts.deletes, isEmpty);
          expect(f.controller.pendingSaveNeedsInspection, false);
        },
      );
    }
    for (final invalid in [
      page([draft(7), draft(7)]),
      page([draft(7, author: 99)]),
      page([draft(7, global: 142)]),
      page([draft(0)]),
      page([draft(7)], next: 1),
    ]) {
      test('$verb rejects malformed private preflight $invalid', () async {
        final f = Fixture();
        await f.ready();
        f.drafts.pages[1] = invalid;
        await expectLater(
          mutate(f, deleting),
          throwsA(isA<GitLabServerException>()),
        );
        expect(f.drafts.updates, isEmpty);
        expect(f.drafts.deletes, isEmpty);
      });
    }
    for (final target in [
      draft(0),
      draft(7, author: 99),
      draft(7, global: 142),
    ]) {
      test('$verb cannot address wrong selected identity $target', () async {
        final f = Fixture();
        await f.ready();
        await expectLater(
          mutate(f, deleting, target: target),
          throwsA(isA<ArgumentError>()),
        );
        expect(f.drafts.updates, isEmpty);
        expect(f.drafts.deletes, isEmpty);
      });
    }
    for (final error in [
      const GitLabAuthException('Private'),
      const GitLabForbiddenException('Private'),
      const GitLabNotFoundException('Private'),
      const GitLabConflictException('Private'),
      const GitLabRateLimitException('Private'),
      const GitLabServerException('Private'),
      const GitLabConnectionException('Private'),
    ]) {
      test(
        '$verb failure gates all private writes until complete inspection ${error.runtimeType}',
        () async {
          final f = Fixture();
          await f.ready();
          if (deleting) {
            f.drafts.deleted = error;
          } else {
            f.drafts.updated = error;
          }
          await expectLater(mutate(f, deleting), throwsA(same(error)));
          expect(f.controller.pendingSaveNeedsInspection, true);
          expect(await f.save(), isNull);
          expect(await mutate(f, false), isNull);
          expect(await mutate(f, true), false);
          expect(f.drafts.updates.length + f.drafts.deletes.length, 1);
          expect(await f.inspect(), [draft(7)]);
          expect(f.controller.pendingSaveNeedsInspection, false);
          f.drafts.deleted = null;
          f.drafts.updated = draft(7, body: edited);
          expect(
            await mutate(f, deleting),
            deleting ? true : draft(7, body: edited),
          );
        },
      );
    }
    test(
      '$verb shares the public discussion reservation and waits before dispatch',
      () async {
        final f = Fixture();
        await f.ready();
        final p = Completer<Paginated<MergeRequestDraftNote>>();
        f.drafts.pages[1] = p.future;
        final operation = mutate(f, deleting);
        await f.c.pump();
        expect(await f.controller.post('Public'), false);
        expect(await f.save(), isNull);
        expect(await mutate(f, false), isNull);
        expect(await mutate(f, true), false);
        p.complete(page([draft(7)]));
        expect(await operation, deleting ? true : draft(7, body: edited));
      },
    );
    for (final phase in ['detail', 'private', 'write']) {
      for (final changed in [
        'account',
        'draft',
        'client',
        'comments',
        'view',
        'controller',
      ]) {
        test('$verb suppresses $changed replacement during $phase', () async {
          final f = Fixture();
          await f.ready();
          bool active = true;
          final detail = Completer<MergeRequest>(),
              notes = Completer<Paginated<MergeRequestDraftNote>>(),
              update = Completer<MergeRequestDraftNote>(),
              remove = Completer<void>();
          if (phase == 'detail') f.details.result = detail.future;
          if (phase == 'private') f.drafts.pages[1] = notes.future;
          if (phase == 'write') {
            if (deleting) {
              f.drafts.deleted = remove.future;
            } else {
              f.drafts.updated = update.future;
            }
          }
          final op = mutate(f, deleting, current: () => active);
          await f.c.pump();
          switch (changed) {
            case 'account':
              f.c.read(accountState.notifier).state = account.copyWith(
                user: const User(id: 99, username: 'other', name: 'Other'),
              );
            case 'draft':
              f.c.read(draftState.notifier).state = Future.value(Drafts(f.api));
            case 'client':
              f.c.read(clientState.notifier).state = Future.value(client());
            case 'comments':
              f.c.read(commentsState.notifier).state = Future.value(
                Comments(f.api),
              );
            case 'view':
              active = false;
            case 'controller':
              f.c.invalidate(mrDiscussionsControllerProvider(resource));
          }
          await f.c.pump();
          if (phase == 'detail') detail.complete(mr());
          if (phase == 'private') notes.complete(page([draft(7)]));
          if (phase == 'write') {
            if (deleting) {
              remove.complete();
            } else {
              update.complete(draft(7, body: edited));
            }
          }
          expect(await op, deleting ? false : isNull);
          expect(
            f.drafts.updates.length + f.drafts.deletes.length,
            phase == 'write' ? 1 : 0,
          );
          expect(f.comments.posts, isEmpty);
        });
      }
    }
    test(
      '$verb cancelled write settles before recovery reads and does not clear the gate',
      () async {
        final f = Fixture();
        await f.ready();
        bool active = true;
        final update = Completer<MergeRequestDraftNote>(),
            remove = Completer<void>();
        if (deleting) {
          f.drafts.deleted = remove.future;
        } else {
          f.drafts.updated = update.future;
        }
        final op = mutate(f, deleting, current: () => active);
        await f.c.pump();
        active = false;
        f.c.invalidate(mrDiscussionsControllerProvider(resource));
        await f.ready();
        expect(await op, deleting ? false : isNull);
        expect(f.controller.pendingSaveNeedsInspection, true);
        final readCount = f.drafts.reads.length;
        final inspection = f.inspect();
        await f.c.pump();
        expect(f.drafts.reads.length, readCount);
        expect(await f.save(), isNull);
        if (deleting) {
          remove.complete();
        } else {
          update.complete(draft(7, body: edited));
        }
        expect(await inspection, [draft(7)]);
      },
    );
  }
  for (final body in ['', ' \n ']) {
    test('blank edit cannot dispatch', () async {
      final f = Fixture();
      await f.ready();
      expect(await f.controller.updatePendingNote(draft(7), body), isNull);
      expect(f.drafts.reads, isEmpty);
    });
  }
  for (final p in [
    const DiffNotePosition(positionType: 'image'),
    const DiffNotePosition(positionType: 'file'),
    const DiffNotePosition(positionType: 'future'),
    const DiffNotePosition(positionType: 'text', newLine: 1),
  ]) {
    test('unsupported original position permits delete only $p', () async {
      final f = Fixture();
      await f.ready();
      final d = draft(7).copyWith(position: p);
      f.drafts.pages[1] = page([d]);
      expect(await f.controller.updatePendingNote(d, edited), isNull);
      expect(f.drafts.reads, isEmpty);
      expect(await f.controller.deletePendingNote(d), true);
      expect(f.drafts.deletes.single.$4, d);
    });
  }
  for (final bad in [
    draft(0, body: edited),
    draft(8, body: edited),
    draft(7, body: 'Wrong'),
    draft(7, author: 99, body: edited),
    draft(7, global: 142, body: edited),
  ]) {
    test('unconfirmed update keeps inspection gate $bad', () async {
      final f = Fixture();
      await f.ready();
      f.drafts.updated = bad;
      await expectLater(
        mutate(f, false),
        throwsA(isA<GitLabServerException>()),
      );
      expect(f.controller.pendingSaveNeedsInspection, true);
    });
  }
  for (final deleting in [false, true]) {
    test(
      'maintenance ${deleting ? 'delete' : 'update'} refreshes every private reader variant for only its MR',
      () async {
        final f = Fixture();
        await f.ready();
        const other = MergeRequestRef(projectId: 8, iid: 143);
        final keep = f.c.listen(
          mrDraftNotesRevisionProvider(resource),
          (_, _) {},
        );
        final otherKeep = f.c.listen(
          mrDraftNotesRevisionProvider(other),
          (_, _) {},
        );
        addTearDown(keep.close);
        addTearDown(otherKeep.close);
        expect(
          await mutate(f, deleting),
          deleting ? true : draft(7, body: edited),
        );
        expect(f.c.read(mrDraftNotesRevisionProvider(resource)), 1);
        expect(f.c.read(mrDraftNotesRevisionProvider(other)), 0);
        expect(f.comments.pages, [1]);
      },
    );
    test(
      'maintenance ${deleting ? 'delete' : 'update'} later preflight page failure cannot write',
      () async {
        final f = Fixture();
        await f.ready();
        f.drafts.pages[1] = page([draft(7)], next: 3);
        f.drafts.pages[3] = const GitLabServerException('Unread page');
        await expectLater(
          mutate(f, deleting),
          throwsA(isA<GitLabServerException>()),
        );
        expect(f.drafts.updates, isEmpty);
        expect(f.drafts.deletes, isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
  }
  for (final position in [
    null,
    const DiffNotePosition(),
    const DiffNotePosition(positionType: 'text'),
    const DiffNotePosition(
      positionType: 'text',
      baseSha: 'base',
      startSha: 'start',
      headSha: 'head',
      oldPath: 'old.dart',
      newPath: 'new.dart',
      newLine: 9,
    ),
  ]) {
    test('update retains supported original metadata $position', () async {
      final f = Fixture();
      await f.ready();
      final d = draft(7).copyWith(
        position: position,
        discussionId: 'thread',
        commitId: 'commit',
        resolveDiscussion: true,
      );
      f.drafts.pages[1] = page([d]);
      f.drafts.updated = d.copyWith(note: edited);
      expect(MrDraftNotesRepository.canUpdate(d), true);
      expect(
        await f.controller.updatePendingNote(d, edited),
        d.copyWith(note: edited),
      );
      expect(f.drafts.updates.single.$4, d);
    });
  }
  test(
    'opaque line-code-only draft cannot be edited but can be explicitly deleted',
    () async {
      final f = Fixture();
      await f.ready();
      final d = draft(7).copyWith(lineCode: 'opaque');
      f.drafts.pages[1] = page([d]);
      expect(MrDraftNotesRepository.canUpdate(d), false);
      expect(await f.controller.updatePendingNote(d, edited), isNull);
      expect(f.drafts.reads, isEmpty);
      expect(await f.controller.deletePendingNote(d), true);
    },
  );
  for (final deleting in [false, true]) {
    test(
      'account change queued after target comparison cannot dispatch ${deleting ? 'delete' : 'update'}',
      () async {
        final f = Fixture();
        await f.ready();
        f.drafts.pages[1] = page([
          ComparedDraft(draft(7), () {
            f.c.read(accountState.notifier).state = null;
          }),
        ]);
        expect(await mutate(f, deleting), deleting ? false : isNull);
        expect(f.drafts.updates, isEmpty);
        expect(f.drafts.deletes, isEmpty);
      },
    );
  }
}
