import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';

import 'mr_pending_review_maintenance_test.dart' show ComparedDraft;
import 'mr_pending_review_save_test.dart' as b;

class Drafts extends b.Drafts {
  Drafts(super.client);
  final publications = <(int, int, int)>[];
  Object? publication;
  @override
  Future<void> publishNote({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
  }) async {
    expect(draft.id, 7);
    publications.add((projectId, iid, mergeRequestId));
    if (publication is Future<void>) return publication as Future<void>;
    if (publication != null) throw publication!;
  }
}

class ObservedDiscussion implements Discussion {
  ObservedDiscussion(this.onRead);
  final void Function() onRead;
  @override
  String get id {
    scheduleMicrotask(onRead);
    return 'public-thread';
  }

  @override
  List<Note> get notes => const [Note(id: 9, body: 'Public')];
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class PublicComments extends b.Comments {
  PublicComments(super.client);
  final results = <int, Object>{1: const Paginated<Discussion>(items: [])};
  @override
  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    pages.add(page);
    final result = results[page]!;
    if (result is Future<Paginated<Discussion>>) return result;
    if (result is Paginated<Discussion>) return result;
    throw result;
  }
}

class Fixture extends b.Fixture {
  late final private = Drafts(api);
  Future<void> initialize() async {
    c.read(b.draftState.notifier).state = Future.value(private);
    private.pages[1] = b.page([b.draft(7)]);
    comments.pageResult = const Paginated<Discussion>(items: []);
    await ready();
  }

  Future<MrPendingReviewPublication?> prepare({bool Function()? current}) =>
      controller.preparePendingNotePublication(b.draft(7), isCurrent: current);
  Future<bool> publish(
    MrPendingReviewPublication snapshot, {
    bool Function()? current,
  }) => controller.publishPendingNote(snapshot, isCurrent: current);
}

void main() {
  for (final field in [
    'resolution',
    'discussion',
    'commit',
    'line code',
    'position',
  ]) {
    test('changed selected metadata refuses dispatch: $field', () async {
      final f = Fixture();
      await f.initialize();
      final s = (await f.prepare())!;
      final original = b.draft(7);
      f.private.pages[1] = b.page([
        switch (field) {
          'resolution' => original.copyWith(resolveDiscussion: true),
          'discussion' => original.copyWith(discussionId: 'other-thread'),
          'commit' => original.copyWith(commitId: 'other-commit'),
          'line code' => original.copyWith(lineCode: 'other-line'),
          _ => original.copyWith(
            position: const DiffNotePosition(positionType: 'future'),
          ),
        },
      ]);
      await expectLater(f.publish(s), throwsA(isA<GitLabConflictException>()));
      expect(f.private.publications, isEmpty);
      expect(f.controller.pendingPublicationNeedsInspection, false);
    });
  }
  for (final kind in ['text', 'image', 'file', 'future', 'reply', 'commit']) {
    test(
      'owned saved metadata is published by identity unchanged: $kind',
      () async {
        final f = Fixture();
        await f.initialize();
        final selected = b
            .draft(7)
            .copyWith(
              position: ['reply', 'commit'].contains(kind)
                  ? null
                  : DiffNotePosition(positionType: kind),
              discussionId: kind == 'reply' ? 'original-thread' : null,
              commitId: kind == 'commit' ? 'original-commit' : null,
              resolveDiscussion: kind == 'reply' ? true : null,
            );
        f.private.pages[1] = b.page([selected]);
        final s = (await f.controller.preparePendingNotePublication(selected))!;
        expect(s.items.single, selected);
        expect(await f.publish(s), true);
        expect(f.private.publications.length, 1);
      },
    );
  }

  test(
    'unrelated private changes keep the selected authorization valid',
    () async {
      final f = Fixture();
      await f.initialize();
      f.private.pages[1] = b.page([b.draft(7), b.draft(8)]);
      final s = (await f.prepare())!;
      f.private.pages[1] = b.page([b.draft(9, body: 'Unrelated'), b.draft(7)]);
      expect(await f.publish(s), true);
      expect(s.items, [b.draft(7)]);
    },
  );
  test('whole and selected confirmation cannot cross dispatch', () async {
    final f = Fixture();
    await f.initialize();
    final whole = (await f.controller.preparePendingReviewPublication())!;
    expect(await f.publish(whole), false);
    final selected = (await f.prepare())!;
    expect(await f.controller.publishPendingReview(selected), false);
    expect(whole.forNote(0), isNull);
    expect(whole.forNote(8), isNull);
    expect(await f.publish(whole.forNote(7)!), true);
  });

  test(
    'queued client replacement at last recovery page preserves gate',
    () async {
      final f = Fixture();
      final comments = PublicComments(f.api);
      f.c.read(b.commentsState.notifier).state = Future.value(comments);
      await f.initialize();
      final s = (await f.prepare())!;
      f.private.publication = const GitLabServerException('Uncertain');
      await expectLater(f.publish(s), throwsA(isA<GitLabServerException>()));
      comments.results[1] = Paginated(
        items: [
          ObservedDiscussion(() {
            f.c.read(b.clientState.notifier).state = Future.value(b.client());
          }),
        ],
      );
      expect(await f.controller.inspectPendingReviewPublication(), isNull);
      expect(f.controller.pendingPublicationNeedsInspection, true);
      expect(
        f.c.read(mrDiscussionsControllerProvider(b.resource)).value!.items,
        isEmpty,
      );
    },
  );

  test('account change queued by full comparison prevents dispatch', () async {
    final f = Fixture();
    await f.initialize();
    final s = (await f.prepare())!;
    f.private.pages[1] = b.page([
      ComparedDraft(b.draft(7), () {
        f.c.read(b.accountState.notifier).state = b.account.copyWith(
          instanceUrl: 'https://other.example.com',
        );
      }),
    ]);
    expect(await f.publish(s), false);
    expect(f.private.publications, isEmpty);
  });
  test(
    'account change queued at confirmed refresh suppresses old completion',
    () async {
      final f = Fixture();
      await f.initialize();
      final s = (await f.prepare())!;
      final subscription = f.c.listen(
        mrDraftNotesRevisionProvider(b.resource),
        (_, next) {
          if (next > 0) {
            scheduleMicrotask(() {
              f.c.read(b.accountState.notifier).state = b.account.copyWith(
                instanceUrl: 'https://other.example.com',
              );
            });
          }
        },
      );
      addTearDown(subscription.close);
      expect(await f.publish(s), false);
      expect(f.private.publications.length, 1);
      expect(f.details.reads.length, 2);
    },
  );

  test(
    'selected snapshot is immutable and unrelated order is accepted',
    () async {
      final f = Fixture();
      await f.initialize();
      f.private.pages[1] = b.page([b.draft(7), b.draft(8)]);
      final s = (await f.prepare())!;
      expect(() => s.items.add(b.draft(9)), throwsUnsupportedError);
      f.private.pages[1] = b.page([b.draft(8), b.draft(7)]);
      expect(await f.publish(s), true);
    },
  );
  test(
    'recovery stages every public page including empty intermediate pages',
    () async {
      final f = Fixture();
      final comments = PublicComments(f.api);
      f.c.read(b.commentsState.notifier).state = Future.value(comments);
      await f.initialize();
      comments.results[1] = const Paginated<Discussion>(items: [], nextPage: 3);
      comments.results[3] = const Paginated<Discussion>(items: [], nextPage: 4);
      comments.results[4] = const Paginated<Discussion>(
        items: [
          Discussion(
            id: 'last',
            individualNote: true,
            notes: [Note(id: 99, body: 'Last public page')],
          ),
        ],
      );
      final result = (await f.controller.inspectPendingReviewPublication())!;
      expect(result.publicDiscussions.single.id, 'last');
      expect(comments.pages, [1, 1, 3, 4]);
      expect(() => result.publicDiscussions.clear(), throwsUnsupportedError);
    },
  );
  for (final mode in [
    'cursor',
    'duplicate thread',
    'duplicate note',
    'invalid note',
    'blank thread',
    'later failure',
  ]) {
    test(
      'incomplete or invalid public recovery preserves uncertainty: $mode',
      () async {
        final f = Fixture();
        final comments = PublicComments(f.api);
        f.c.read(b.commentsState.notifier).state = Future.value(comments);
        await f.initialize();
        final s = (await f.prepare())!;
        f.private.publication = const GitLabServerException('Uncertain');
        await expectLater(f.publish(s), throwsA(isA<GitLabServerException>()));
        const first = Discussion(
          id: 'first',
          individualNote: true,
          notes: [Note(id: 9, body: 'Public')],
        );
        comments.results[1] = const Paginated(items: [first], nextPage: 3);
        comments.results[3] = switch (mode) {
          'cursor' => const Paginated<Discussion>(items: [], nextPage: 1),
          'duplicate thread' => const Paginated(items: [first]),
          'duplicate note' => Paginated(items: [first.copyWith(id: 'second')]),
          'invalid note' => Paginated(
            items: [
              first.copyWith(
                id: 'second',
                notes: [const Note(id: 0, body: 'Invalid')],
              ),
            ],
          ),
          'blank thread' => Paginated(items: [first.copyWith(id: ' ')]),
          _ => const GitLabServerException('Later page failed'),
        };
        await expectLater(
          f.controller.inspectPendingReviewPublication(),
          throwsA(isA<GitLabServerException>()),
        );
        expect(f.controller.pendingPublicationNeedsInspection, true);
        expect(
          f.c.read(mrDiscussionsControllerProvider(b.resource)).value!.items,
          isEmpty,
        );
        expect(f.private.publications.length, 1);
      },
    );
  }
  test(
    'same-account wrapper refresh cannot clear publication uncertainty',
    () async {
      final f = Fixture();
      await f.initialize();
      final s = (await f.prepare())!;
      f.private.publication = const GitLabServerException('Uncertain');
      await expectLater(f.publish(s), throwsA(isA<GitLabServerException>()));
      f.c.read(b.commentsState.notifier).state = Future.value(
        b.Comments(f.api)..pageResult = const Paginated<Discussion>(items: []),
      );
      await f.ready();
      expect(f.controller.pendingPublicationNeedsInspection, true);
      await f.inspect();
      expect(f.controller.pendingPublicationNeedsInspection, true);
      expect(await f.controller.inspectPendingReviewPublication(), isNotNull);
      expect(f.controller.pendingPublicationNeedsInspection, false);
    },
  );

  test(
    'selected snapshot publishes once after every page and refreshes confirmed state',
    () async {
      final f = Fixture();
      await f.initialize();
      f.private.pages[1] = b.page([b.draft(7)], next: 3);
      f.private.pages[3] = b.page([b.draft(8, body: 'Second')]);
      final snapshot = (await f.prepare())!;
      expect(snapshot.items, [b.draft(7)]);
      expect(f.private.publications, isEmpty);
      expect(await f.publish(snapshot), true);
      expect(f.private.publications, [(8, 142, 1100)]);
      expect(f.private.reads.map((e) => e.$3), [1, 3, 1, 3]);
      expect(f.c.read(mrDraftNotesRevisionProvider(b.resource)), 1);
      expect(f.controller.pendingSaveNeedsInspection, false);
      expect(f.events.names, isEmpty);
      expect(f.comments.posts, isEmpty);
    },
  );
  for (final notes in [
    <MergeRequestDraftNote>[],
    [b.draft(7, body: 'changed')],
    [b.draft(8)],
  ]) {
    test('changed selected target prevents publication $notes', () async {
      final f = Fixture();
      await f.initialize();
      final s = (await f.prepare())!;
      f.private.pages[1] = b.page(notes);
      await expectLater(f.publish(s), throwsA(isA<GitLabConflictException>()));
      expect(f.private.publications, isEmpty);
      expect(f.controller.pendingSaveNeedsInspection, false);
    });
  }
  test('empty and obsolete snapshots never publish', () async {
    final f = Fixture();
    await f.initialize();
    f.private.pages[1] = b.page([]);
    await expectLater(f.prepare(), throwsA(isA<GitLabConflictException>()));
    f.private.pages[1] = b.page([b.draft(7)]);
    final s = (await f.prepare())!;
    f.c.read(b.clientState.notifier).state = Future.value(b.client());
    await Future<void>.delayed(Duration.zero);
    expect(await f.publish(s), false);
    expect(f.private.publications, isEmpty);
  });
  test(
    'uncertain publication blocks all private mutations until both sides inspected',
    () async {
      final f = Fixture();
      await f.initialize();
      final s = (await f.prepare())!;
      f.private.publication = const GitLabServerException('Uncertain.');
      await expectLater(f.publish(s), throwsA(isA<GitLabServerException>()));
      expect(f.controller.pendingPublicationNeedsInspection, true);
      expect(await f.publish(s), false);
      expect(await f.save(), isNull);
      await f.inspect();
      expect(f.controller.pendingSaveNeedsInspection, true);
      expect(await f.prepare(), isNull);
      f.comments.pageResult = const GitLabServerException('Inspection failed.');
      await expectLater(
        f.controller.inspectPendingReviewPublication(),
        throwsA(isA<GitLabServerException>()),
      );
      expect(f.controller.pendingSaveNeedsInspection, true);
      f.comments.pageResult = const Paginated<Discussion>(
        items: [
          Discussion(
            id: 'thread',
            individualNote: true,
            notes: [Note(id: 9, body: 'Public text')],
          ),
        ],
      );
      final inspected = (await f.controller.inspectPendingReviewPublication())!;
      expect(
        inspected.publicDiscussions.single.notes.single.body,
        'Public text',
      );
      expect(inspected.pending.items, [b.draft(7)]);
      expect(f.controller.pendingSaveNeedsInspection, false);
      expect(f.private.publications.length, 1);
    },
  );
  for (final phase in ['prepare', 'preflight', 'write', 'inspection']) {
    for (final change in [
      'account',
      'client',
      'drafts',
      'detail',
      'comments',
      'view',
      'refresh',
    ]) {
      test('$phase cancels obsolete $change session', () async {
        final f = Fixture();
        await f.initialize();
        final s = (await f.prepare())!;
        final read = Completer<Paginated<MergeRequestDraftNote>>();
        final write = Completer<void>();
        var active = true;
        if (phase == 'write') {
          f.private.publication = write.future;
        } else {
          f.private.pages[1] = read.future;
        }
        final Future<Object?> result = switch (phase) {
          'prepare' => f.prepare(current: () => active),
          'inspection' => f.controller.inspectPendingReviewPublication(
            isCurrent: () => active,
          ),
          _ => f.publish(s, current: () => active),
        };
        await Future<void>.delayed(Duration.zero);
        switch (change) {
          case 'account':
            f.c.read(b.accountState.notifier).state = b.account.copyWith(
              instanceUrl: 'https://other.example.com',
            );
          case 'client':
            f.c.read(b.clientState.notifier).state = Future.value(b.client());
          case 'drafts':
            f.c.read(b.draftState.notifier).state = Future.value(Drafts(f.api));
          case 'detail':
            f.c.read(b.sourceState.notifier).state = Future.value(
              b.Details(f.api),
            );
          case 'comments':
            f.c.read(b.commentsState.notifier).state = Future.value(
              b.Comments(f.api),
            );
          case 'view':
            active = false;
          case 'refresh':
            f.c.invalidate(mrDiscussionsControllerProvider(b.resource));
        }
        await Future<void>.delayed(Duration.zero);
        read.complete(b.page([b.draft(7)]));
        write.complete();
        expect(
          await result,
          phase == 'preflight' || phase == 'write' ? false : null,
        );
        expect(f.private.publications.length, phase == 'write' ? 1 : 0);
        expect(f.c.read(mrDraftNotesRevisionProvider(b.resource)), 0);
      });
    }
  }
  test(
    'recovery waits for a cancelled publication to actually settle',
    () async {
      final f = Fixture();
      await f.initialize();
      final s = (await f.prepare())!;
      final write = Completer<void>();
      f.private.publication = write.future;
      var active = true;
      final result = f.publish(s, current: () => active);
      await Future<void>.delayed(Duration.zero);
      active = false;
      f.c.invalidate(mrDiscussionsControllerProvider(b.resource));
      await f.ready();
      expect(await result, false);
      final count = f.private.reads.length;
      final inspect = f.controller.inspectPendingReviewPublication();
      await Future<void>.delayed(Duration.zero);
      expect(f.private.reads.length, count);
      write.complete();
      expect(await inspect, isNotNull);
      expect(f.private.publications.length, 1);
    },
  );
  for (final bad in [
    [b.draft(7), b.draft(7)],
    [b.draft(0)],
    [b.draft(7, author: 99)],
    [b.draft(7, global: 142)],
  ]) {
    test('invalid full private snapshot rejected $bad', () async {
      final f = Fixture();
      await f.initialize();
      f.private.pages[1] = b.page(bad);
      await expectLater(f.prepare(), throwsA(isA<GitLabServerException>()));
      expect(f.private.publications, isEmpty);
    });
  }
  test(
    'shared reservation prevents public posts and concurrent publication',
    () async {
      final f = Fixture();
      await f.initialize();
      final s = (await f.prepare())!;
      final read = Completer<Paginated<MergeRequestDraftNote>>();
      f.private.pages[1] = read.future;
      final first = f.publish(s);
      await Future<void>.delayed(Duration.zero);
      expect(await f.controller.post('Public'), false);
      expect(await f.publish(s), false);
      expect(await f.save(), isNull);
      await f.controller.loadMore();
      read.complete(b.page([b.draft(7)]));
      expect(await first, true);
      expect(f.private.publications.length, 1);
      expect(f.comments.posts, isEmpty);
    },
  );
}
