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
import 'package:labfox/features/diff/data/diff_repository.dart';
import 'package:labfox/features/diff/presentation/controllers/diff_controllers.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_review_snapshot_controller.dart';

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

const raw = '@@ -27,2 +29,2 @@\n context\n-old\n+new\n';
MergeRequestDiffVersion version({String head = 'head', String diff = raw}) =>
    MergeRequestDiffVersion(
      id: 110,
      baseCommitSha: 'base',
      startCommitSha: 'start',
      headCommitSha: head,
      state: 'collected',
      files: [
        MergeRequestVersionFile(
          oldPath: 'old.dart',
          newPath: 'new.dart',
          diff: diff,
          isRenamed: true,
        ),
      ],
    );

class Diffs extends DiffRepository {
  Diffs(super.client);
  Object listing = Paginated<MergeRequestDiffVersion>(items: [version()]);
  Object detail = version();
  int reads = 0, details = 0;
  @override
  Future<Paginated<MergeRequestDiffVersion>> mergeRequestDiffVersions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    expect((projectId, iid, page), (8, 142, 1));
    reads++;
    final v = listing;
    if (v is Paginated<MergeRequestDiffVersion>) return v;
    if (v is Future<Paginated<MergeRequestDiffVersion>>) return v;
    throw v;
  }

  @override
  Future<MergeRequestDiffVersion> mergeRequestDiffVersion({
    required int projectId,
    required int iid,
    required int versionId,
  }) async {
    expect((projectId, iid, versionId), (8, 142, 110));
    details++;
    final v = detail;
    if (v is MergeRequestDiffVersion) return v;
    if (v is Future<MergeRequestDiffVersion>) return v;
    throw v;
  }
}

final diffState = StateProvider<Future<DiffRepository?>>((ref) async => null);

class Fixture {
  Fixture() {
    c = ProviderContainer(
      overrides: [
        analyticsProvider.overrideWithValue(events),
        diffState.overrideWith((ref) async => diffs),
        diffRepositoryProvider.overrideWith((ref) => ref.watch(diffState)),
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
  late final diffs = Diffs(api);
  late MrReviewSnapshot snapshot;
  Future<void> displayed() async {
    await ready();
    c.listen(mrReviewSnapshotControllerProvider(resource), (_, _) {});
    snapshot = await c.read(
      mrReviewSnapshotControllerProvider(resource).future,
    );
  }

  DiffNotePosition selection(int index, {bool range = false}) {
    final file = snapshot.files.single;
    final lines = file.hunks.single.lines;
    return range
        ? snapshot.rangePositionFor(file, lines[0], lines[index])!
        : snapshot.positionFor(file, lines[index])!;
  }

  Future<MergeRequestDraftNote?> inline(
    DiffNotePosition p, {
    bool Function()? current,
  }) => controller.savePendingNote(markdown, position: p, isCurrent: current);
  void confirms(DiffNotePosition p) {
    drafts.result = draft(7).copyWith(position: p, resolveDiscussion: false);
  }

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

// Queues a replacement while the last private page is being validated.
class InspectedDraft implements MergeRequestDraftNote {
  InspectedDraft(this.onValidated);
  final void Function() onValidated;
  @override
  int get id => 7;
  @override
  int get authorId {
    scheduleMicrotask(onValidated);
    return 23;
  }

  @override
  int get mergeRequestId => 1100;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  for (final index in [0, 1, 2]) {
    test(
      'private create preserves selected side $index and exact body after fresh reads',
      () async {
        final f = Fixture();
        await f.displayed();
        final p = f.selection(index);
        f.confirms(p);
        expect(await f.inline(p), f.drafts.result);
        expect(f.drafts.writes, [(8, 142, 1100, markdown, p)]);
        expect(f.diffs.reads, 2);
        expect(f.diffs.details, 2);
        expect(f.comments.posts, isEmpty);
        expect(f.events.names, isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
  }
  test('multiline anchor preserves original range', () async {
    final f = Fixture();
    await f.displayed();
    final p = f.selection(2, range: true);
    f.confirms(p);
    expect(await f.inline(p), f.drafts.result);
    expect(f.drafts.writes.single.$5, p);
  });
  for (final changed in [
    'sha',
    'version',
    'file',
    'line',
    'opaque',
    'empty',
    'error',
  ]) {
    test(
      'fresh $changed rejects before dispatch without uncertainty',
      () async {
        final f = Fixture();
        await f.displayed();
        final p = f.selection(2);
        f.confirms(p);
        switch (changed) {
          case 'sha':
            f.diffs.listing = Paginated(items: [version(head: 'other')]);
            f.diffs.detail = version(head: 'other');
          case 'version':
            f.diffs.detail = version().copyWith(id: 111);
          case 'file':
            f.diffs.detail = version().copyWith(
              files: [
                const MergeRequestVersionFile(
                  oldPath: 'different',
                  newPath: 'new.dart',
                  diff: raw,
                ),
              ],
            );
          case 'line':
            f.diffs.detail = version(
              diff: raw.replaceFirst('+new', '+changed'),
            );
          case 'opaque':
            f.diffs.detail = version().copyWith(
              files: [
                const MergeRequestVersionFile(
                  oldPath: 'old.dart',
                  newPath: 'new.dart',
                  diff: raw,
                  isTooLarge: true,
                ),
              ],
            );
          case 'empty':
            f.diffs.listing = const Paginated<MergeRequestDiffVersion>(
              items: [],
            );
          case 'error':
            f.diffs.listing = const GitLabServerException('Failed diff');
        }
        await expectLater(f.inline(p), throwsA(isA<GitLabException>()));
        expect(f.drafts.writes, isEmpty);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
  }
  test('forged displayed coordinate is rejected without fresh reads', () async {
    final f = Fixture();
    await f.displayed();
    final p = f.selection(2).copyWith(newLine: 999);
    expect(await f.inline(p), isNull);
    expect(f.drafts.writes, isEmpty);
    expect(f.details.reads, isEmpty);
    expect(f.diffs.reads, 1);
  });
  test(
    'fresh diff wait reserves public and private commands and pagination',
    () async {
      final f = Fixture();
      await f.displayed();
      final p = f.selection(2);
      f.confirms(p);
      final pending = Completer<MergeRequestDiffVersion>();
      f.diffs.detail = pending.future;
      final saving = f.inline(p);
      await f.c.pump();
      expect(f.drafts.writes, isEmpty);
      expect(await f.save(), isNull);
      expect(await f.controller.post('Public'), false);
      await f.controller.loadMore();
      expect(f.comments.pages, [1]);
      pending.complete(version());
      expect(await saving, f.drafts.result);
    },
  );
  for (final phase in ['preflight', 'write']) {
    for (final change in [
      'account',
      'client',
      'drafts',
      'details',
      'comments',
      'diffs',
      'snapshot',
      'view',
      'controller',
    ]) {
      for (final lateError in [false, true]) {
        test(
          '$phase cancellation on $change ignores lateError=$lateError',
          () async {
            final f = Fixture();
            await f.displayed();
            final p = f.selection(2);
            f.confirms(p);
            var active = true;
            final read = Completer<MergeRequestDiffVersion>();
            final write = Completer<MergeRequestDraftNote>();
            if (phase == 'preflight') {
              f.diffs.detail = read.future;
            } else {
              f.drafts.result = write.future;
            }
            final saving = f.inline(p, current: () => active);
            await f.c.pump();
            expect(f.drafts.writes.length, phase == 'write' ? 1 : 0);
            switch (change) {
              case 'account':
                f.c.read(accountState.notifier).state = account.copyWith(
                  instanceUrl: 'https://another.example.com',
                );
              case 'client':
                f.c.read(clientState.notifier).state = Future.value(null);
              case 'drafts':
                f.c.read(draftState.notifier).state = Future.value(
                  Drafts(f.api),
                );
              case 'details':
                f.c.read(sourceState.notifier).state = Future.value(
                  Details(f.api),
                );
              case 'comments':
                f.c.read(commentsState.notifier).state = Future.value(
                  Comments(f.api),
                );
              case 'diffs':
                f.c.read(diffState.notifier).state = Future.value(Diffs(f.api));
              case 'snapshot':
                f.c.invalidate(mrReviewSnapshotControllerProvider(resource));
              case 'view':
                active = false;
              case 'controller':
                f.c.invalidate(mrDiscussionsControllerProvider(resource));
            }
            await f.c.pump();
            // Caller-only cancellation is observed at the completion boundary.
            if (phase == 'preflight') {
              if (lateError) {
                read.completeError(const GitLabServerException('Late'));
              } else {
                read.complete(version());
              }
            } else {
              if (lateError) {
                write.completeError(const GitLabServerException('Late'));
              } else {
                write.complete(draft(7).copyWith(position: p));
              }
            }
            expect(await saving, isNull);
            await f.c.pump();
            expect(f.drafts.writes.length, phase == 'write' ? 1 : 0);
            expect(f.comments.posts, isEmpty);
            expect(f.events.names, isEmpty);
            if (phase == 'write' && change != 'account') {
              expect(f.controller.pendingSaveNeedsInspection, true);
            }
          },
        );
      }
    }
  }
  for (final bad in [
    'missing',
    'wrongsha',
    'wrongpath',
    'wrongline',
    'resolve',
    'reply',
    'commit',
    'identity',
    'body',
  ]) {
    test(
      'unconfirmed positioned acknowledgement $bad retains inspection gate',
      () async {
        final f = Fixture();
        await f.displayed();
        final p = f.selection(2);
        f.confirms(p);
        var returned = f.drafts.result as MergeRequestDraftNote;
        returned = switch (bad) {
          'missing' => returned.copyWith(position: null),
          'wrongsha' => returned.copyWith(
            position: p.copyWith(headSha: 'other'),
          ),
          'wrongpath' => returned.copyWith(
            position: p.copyWith(newPath: 'other'),
          ),
          'wrongline' => returned.copyWith(position: p.copyWith(newLine: 31)),
          'resolve' => returned.copyWith(resolveDiscussion: true),
          'reply' => returned.copyWith(discussionId: 'thread'),
          'commit' => returned.copyWith(commitId: 'commit'),
          'identity' => returned.copyWith(mergeRequestId: 142),
          _ => returned.copyWith(note: 'different'),
        };
        f.drafts.result = returned;
        await expectLater(f.inline(p), throwsA(isA<GitLabServerException>()));
        expect(f.controller.pendingSaveNeedsInspection, true);
        expect(await f.inline(p), isNull);
        expect(await f.save(), isNull);
        expect(f.drafts.writes.length, 1);
        f.drafts.pages[1] = page([draft(7).copyWith(position: p)], next: 2);
        f.drafts.pages[2] = page([]);
        expect((await f.inspect())!.length, 1);
        expect(f.drafts.reads.map((r) => r.$3), [1, 2]);
        expect(f.controller.pendingSaveNeedsInspection, false);
      },
    );
  }
  test(
    'multiline acknowledgement accepts omitted optional counters only',
    () async {
      final f = Fixture();
      await f.displayed();
      final p = f.selection(2, range: true);
      f.drafts.result = draft(7).copyWith(
        position: p.copyWith(
          lineRange: p.lineRange!.copyWith(
            start: p.lineRange!.start!.copyWith(oldLine: null, newLine: null),
            end: p.lineRange!.end!.copyWith(oldLine: null, newLine: null),
          ),
        ),
      );
      expect(await f.inline(p), f.drafts.result);
      expect(f.controller.pendingSaveNeedsInspection, false);
    },
  );
  test('displayed loading snapshot prevents private dispatch', () async {
    final f = Fixture();
    await f.displayed();
    final p = f.selection(2);
    final pending = Completer<MergeRequestDiffVersion>();
    f.diffs.detail = pending.future;
    f.c.invalidate(mrReviewSnapshotControllerProvider(resource));
    await f.c.pump();
    expect(await f.inline(p), isNull);
    expect(f.drafts.writes, isEmpty);
    pending.complete(version());
    await f.c.pump();
  });
  test('regular note creation never reads the diff', () async {
    final f = Fixture();
    await f.ready();
    expect(await f.save(), draft(7));
    expect(f.diffs.reads, 0);
  });
  test(
    'selected line text fingerprint cannot be changed through old parsed lists',
    () async {
      final f = Fixture();
      await f.displayed();
      final p = f.selection(2);
      f.confirms(p);
      final pending = Completer<MergeRequest>();
      f.details.result = pending.future;
      final saving = f.inline(p);
      await f.c.pump();
      f.snapshot.files.single.hunks.single.lines[2] = const DiffLine(
        type: DiffLineType.added,
        newLine: 30,
        text: 'mutated',
      );
      f.diffs.detail = version(diff: raw.replaceFirst('+new', '+mutated'));
      pending.complete(mr());
      await expectLater(saving, throwsA(isA<GitLabConflictException>()));
      expect(f.drafts.writes, isEmpty);
    },
  );
  test(
    'queued client replacement after the last private page cannot clear inline uncertainty or return rows',
    () async {
      final f = Fixture();
      await f.displayed();
      final p = f.selection(2);
      f.drafts.result = const GitLabServerException('Uncertain');
      await expectLater(f.inline(p), throwsA(isA<GitLabServerException>()));
      f.drafts.pages[1] = page([
        InspectedDraft(() {
          f.c.read(clientState.notifier).state = Future.value(null);
        }),
      ]);
      expect(await f.inspect(), isNull);
      expect(f.controller.pendingSaveNeedsInspection, true);
    },
  );
}
