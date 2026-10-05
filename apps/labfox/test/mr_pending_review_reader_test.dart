import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_pending_review_controller.dart';

const account = Account(
  instanceUrl: 'https://gitlab.example.com',
  user: User(id: 23, username: 'reviewer', name: 'Reviewer'),
);
const query = MrPendingReviewQuery(
  mergeRequest: MergeRequestRef(projectId: 8, iid: 142),
  mergeRequestId: 1100,
  perPage: 10,
);
final repoState = StateProvider<Future<MrDraftNotesRepository?>>(
  (ref) async => null,
);
final accountState = StateProvider<Account?>((ref) => account);
MergeRequestDraftNote draft(int id, {int mr = 1100, int author = 23}) =>
    MergeRequestDraftNote(
      id: id,
      authorId: author,
      mergeRequestId: mr,
      note: '  **Private $id**\n\n  ',
    );
Paginated<MergeRequestDraftNote> page(
  List<MergeRequestDraftNote> items, {
  int? next,
  int? total,
  int? totalPages,
}) => Paginated(
  items: items,
  nextPage: next,
  total: total,
  totalPages: totalPages,
);

class Repository extends MrDraftNotesRepository {
  Repository(this.readPage, {int author = 23})
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
        authorId: author,
      );
  final Future<Paginated<MergeRequestDraftNote>> Function(int) readPage;
  final calls = <(int, int, int, int)>[];
  @override
  Future<Paginated<MergeRequestDraftNote>> list({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) {
    calls.add((projectId, iid, page, perPage));
    return readPage(page);
  }

  @override
  Future<MergeRequestDraftNote> create({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String note,
    DiffNotePosition? position,
  }) => throw StateError('Reads must never mutate drafts.');
}

ProviderContainer container(Future<MrDraftNotesRepository?> repo) {
  final c = ProviderContainer(
    overrides: [
      repoState.overrideWith((ref) => repo),
      currentAccountProvider.overrideWith((ref) => ref.watch(accountState)),
      mrDraftNotesRepositoryProvider.overrideWith(
        (ref) => ref.watch(repoState),
      ),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void listen(ProviderContainer c, [MrPendingReviewQuery q = query]) {
  final sub = c.listen(mrPendingReviewProvider(q), (_, _) {});
  addTearDown(sub.close);
}

Future<MrPendingReviewDrafts> loaded(ProviderContainer c) =>
    c.read(mrPendingReviewControllerProvider(query).future);
MrPendingReviewController notifier(ProviderContainer c) =>
    c.read(mrPendingReviewControllerProvider(query).notifier);
MrPendingReviewDrafts visible(ProviderContainer c) =>
    c.read(mrPendingReviewProvider(query)).requireValue;
void hidden(ProviderContainer c) =>
    expect(c.read(mrPendingReviewProvider(query)).valueOrNull, isNull);

void main() {
  test(
    'query equality distinguishes project, IID, global MR ID and page size',
    () {
      const same = MrPendingReviewQuery(
        mergeRequest: MergeRequestRef(projectId: 8, iid: 142),
        mergeRequestId: 1100,
        perPage: 10,
      );
      expect(query, same);
      expect(query.hashCode, same.hashCode);
      for (final q in [
        const MrPendingReviewQuery(
          mergeRequest: MergeRequestRef(projectId: 9, iid: 142),
          mergeRequestId: 1100,
          perPage: 10,
        ),
        const MrPendingReviewQuery(
          mergeRequest: MergeRequestRef(projectId: 8, iid: 143),
          mergeRequestId: 1100,
          perPage: 10,
        ),
        const MrPendingReviewQuery(
          mergeRequest: MergeRequestRef(projectId: 8, iid: 142),
          mergeRequestId: 1101,
          perPage: 10,
        ),
        const MrPendingReviewQuery(
          mergeRequest: MergeRequestRef(projectId: 8, iid: 142),
          mergeRequestId: 1100,
        ),
      ]) {
        expect(q, isNot(query));
      }
    },
  );
  test(
    'initial immutable page retains exact bodies, order, totals and cursor without eager reads',
    () async {
      final items = [draft(5), draft(3)];
      final repo = Repository(
        (p) async => page(items, next: 4, total: 8, totalPages: 5),
      );
      final c = container(Future.value(repo));
      listen(c);
      final result = await loaded(c);
      expect(repo.calls, [(8, 142, 1, 10)]);
      expect(result.items.map((d) => d.id), [5, 3]);
      expect(result.items.first.note, items.first.note);
      expect(result.nextPage, 4);
      expect(result.total, 8);
      expect(result.totalPages, 5);
      expect(result.isComplete, false);
      expect(result.isLoadingMore, false);
      expect(() => result.items.clear(), throwsUnsupportedError);
      items.clear();
      expect(result.items.length, 2);
      await c.pump();
      expect(repo.calls.length, 1);
    },
  );
  test(
    'explicit loads follow cursors through empty pages in server order',
    () async {
      final repo = Repository(
        (p) async => switch (p) {
          1 => page([draft(7)], next: 3),
          3 => page([], next: 8),
          8 => page([draft(2), draft(9)], total: 3),
          _ => throw StateError('Unexpected page'),
        },
      );
      final c = container(Future.value(repo));
      listen(c);
      await loaded(c);
      expect(await notifier(c).loadMore(), true);
      expect(visible(c).nextPage, 8);
      expect(visible(c).items.map((d) => d.id), [7]);
      expect(repo.calls.length, 2);
      expect(await notifier(c).loadMore(), true);
      expect(visible(c).items.map((d) => d.id), [7, 2, 9]);
      expect(visible(c).isComplete, true);
      expect(visible(c).total, 3);
      expect(await notifier(c).loadMore(), false);
      expect(repo.calls.map((v) => v.$3), [1, 3, 8]);
    },
  );
  test('totals carry forward and do not infer completeness', () async {
    final repo = Repository(
      (p) async => p == 1
          ? page([draft(1)], next: 2, total: 90, totalPages: 9)
          : page([draft(2)], next: 7),
    );
    final c = container(Future.value(repo));
    listen(c);
    await loaded(c);
    await notifier(c).loadMore();
    expect(visible(c).total, 90);
    expect(visible(c).totalPages, 9);
    expect(visible(c).isComplete, false);
  });
  test(
    'empty list without a cursor is complete without inventing totals',
    () async {
      final repo = Repository((p) async => page([]));
      final c = container(Future.value(repo));
      listen(c);
      final result = await loaded(c);
      expect(result.items, isEmpty);
      expect(result.isComplete, true);
      expect(result.total, isNull);
      expect(await notifier(c).loadMore(), false);
    },
  );
  test(
    'duplicate continuation is blocked while one request is pending',
    () async {
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      final repo = Repository(
        (p) async => p == 1 ? page([draft(1)], next: 2) : pending.future,
      );
      final c = container(Future.value(repo));
      listen(c);
      await loaded(c);
      final first = notifier(c).loadMore();
      expect(visible(c).isLoadingMore, true);
      expect(await notifier(c).loadMore(), false);
      await c.pump();
      expect(repo.calls.length, 2);
      pending.complete(page([draft(2)]));
      expect(await first, true);
      expect(visible(c).isLoadingMore, false);
    },
  );
  for (final fault in ['global MR', 'author', 'duplicate', 'backward cursor']) {
    for (final first in [true, false]) {
      test('$fault on initial=$first fails with no partial rows', () async {
        final invalid = switch (fault) {
          'global MR' => page([draft(2, mr: 1101)]),
          'author' => page([draft(2, author: 24)]),
          'duplicate' => page(
            first ? [draft(1), draft(1)] : [draft(1), draft(2)],
          ),
          _ => page([draft(2)], next: first ? 1 : 2),
        };
        final repo = Repository(
          (p) async => first || p == 2 ? invalid : page([draft(1)], next: 2),
        );
        final c = container(Future.value(repo));
        listen(c);
        final error = throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'static',
            'Invalid pending review draft page.',
          ),
        );
        if (first) {
          await expectLater(loaded(c), error);
        } else {
          await loaded(c);
          await expectLater(notifier(c).loadMore(), error);
        }
        hidden(c);
        expect(c.read(mrPendingReviewProvider(query)).hasError, true);
        expect(await notifier(c).loadMore(), false);
      });
    }
  }
  test(
    'failed continuation hides all rows; explicit refresh restarts page one',
    () async {
      var fail = true;
      final repo = Repository((p) async {
        if (p == 2 && fail) throw const GitLabForbiddenException('Forbidden');
        return page([draft(p)], next: p == 1 ? 2 : null);
      });
      final c = container(Future.value(repo));
      listen(c);
      await loaded(c);
      await expectLater(
        notifier(c).loadMore(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      hidden(c);
      fail = false;
      notifier(c).refresh();
      hidden(c);
      expect((await loaded(c)).items.single.id, 1);
      await notifier(c).loadMore();
      expect(visible(c).items.map((d) => d.id), [1, 2]);
      expect(repo.calls.map((v) => v.$3), [1, 2, 1, 2]);
    },
  );
  for (final fail in [false, true]) {
    test('refresh supersedes pending pagination fail=$fail', () async {
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      var reads = 0;
      final repo = Repository(
        (p) async => p == 1 ? page([draft(++reads)], next: 2) : pending.future,
      );
      final c = container(Future.value(repo));
      listen(c);
      await loaded(c);
      final old = notifier(c).loadMore();
      await c.pump();
      notifier(c).refresh();
      hidden(c);
      expect((await loaded(c)).items.single.id, 2);
      if (fail) {
        pending.completeError(const GitLabForbiddenException('Obsolete'));
      } else {
        pending.complete(page([draft(9)]));
      }
      expect(await old, false);
      expect(visible(c).items.single.id, 2);
      expect(visible(c).isLoadingMore, false);
    });
  }
  for (final change in ['account', 'instance', 'client', 'sign-out']) {
    test('loaded private rows disappear immediately on $change', () async {
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      final repo = Repository((p) async => page([draft(1)]));
      final author = change == 'account' ? 24 : 23;
      final next = Repository((p) => pending.future, author: author);
      final c = container(Future.value(repo));
      listen(c);
      await loaded(c);
      if (change == 'account') {
        c.read(accountState.notifier).state = account.copyWith(
          user: const User(id: 24, username: 'other', name: 'Other'),
        );
      }
      if (change == 'instance') {
        c.read(accountState.notifier).state = account.copyWith(
          instanceUrl: 'https://other.example.com',
        );
      }
      if (change == 'sign-out') {
        c.read(accountState.notifier).state = null;
      }
      c.read(repoState.notifier).state = Future.value(
        change == 'sign-out' ? null : next,
      );
      hidden(c);
      await c.pump();
      if (change == 'sign-out') {
        await expectLater(loaded(c), throwsA(isA<GitLabAuthException>()));
        expect(next.calls, isEmpty);
      } else {
        pending.complete(page([draft(2, author: author)]));
        expect((await loaded(c)).items.single.id, 2);
      }
    });
  }
  for (final fail in [false, true]) {
    test(
      'old pagination cannot reach a replacement account fail=$fail',
      () async {
        final pending = Completer<Paginated<MergeRequestDraftNote>>();
        final repo = Repository(
          (p) async => p == 1 ? page([draft(1)], next: 2) : pending.future,
        );
        final c = container(Future.value(repo));
        listen(c);
        await loaded(c);
        final old = notifier(c).loadMore();
        await c.pump();
        final next = Repository(
          (p) async => page([draft(3, author: 24)]),
          author: 24,
        );
        c.read(accountState.notifier).state = account.copyWith(
          user: const User(id: 24, username: 'other', name: 'Other'),
        );
        c.read(repoState.notifier).state = Future.value(next);
        hidden(c);
        expect((await loaded(c)).items.single.id, 3);
        if (fail) {
          pending.completeError(
            const GitLabForbiddenException('Old private error'),
          );
        } else {
          pending.complete(page([draft(2)]));
        }
        expect(await old, false);
        expect(visible(c).items.single.authorId, 24);
        expect(visible(c).isLoadingMore, false);
      },
    );
  }
  test(
    'obsolete repository resolution never dispatches initial read',
    () async {
      final pending = Completer<MrDraftNotesRepository?>();
      final repo = Repository((p) async => page([draft(1)]));
      final next = Repository((p) async => page([draft(2)]));
      final c = container(pending.future);
      listen(c);
      await c.pump();
      c.read(repoState.notifier).state = Future.value(next);
      expect((await loaded(c)).items.single.id, 2);
      pending.complete(repo);
      await c.pump();
      expect(repo.calls, isEmpty);
    },
  );
  for (final fail in [false, true]) {
    test(
      'disposed resource suppresses pagination outcome fail=$fail',
      () async {
        final pending = Completer<Paginated<MergeRequestDraftNote>>();
        final repo = Repository(
          (p) async => p == 1 ? page([draft(1)], next: 2) : pending.future,
        );
        final c = container(Future.value(repo));
        final sub = c.listen(mrPendingReviewProvider(query), (_, _) {});
        await loaded(c);
        final old = notifier(c).loadMore();
        await c.pump();
        sub.close();
        await c.pump();
        if (fail) {
          pending.completeError(const GitLabForbiddenException('Obsolete'));
        } else {
          pending.complete(page([draft(2)]));
        }
        expect(await old, false);
      },
    );
  }
  test('disposal before repository resolution prevents dispatch', () async {
    final pending = Completer<MrDraftNotesRepository?>();
    final repo = Repository((p) async => page([draft(1)]));
    final c = container(pending.future);
    final sub = c.listen(mrPendingReviewProvider(query), (_, _) {});
    await c.pump();
    sub.close();
    await c.pump();
    pending.complete(repo);
    await c.pump();
    expect(repo.calls, isEmpty);
  });
  for (final q in [
    const MrPendingReviewQuery(
      mergeRequest: MergeRequestRef(projectId: 0, iid: 142),
      mergeRequestId: 1100,
    ),
    const MrPendingReviewQuery(
      mergeRequest: MergeRequestRef(projectId: 8, iid: 0),
      mergeRequestId: 1100,
    ),
    const MrPendingReviewQuery(
      mergeRequest: MergeRequestRef(projectId: 8, iid: 142),
      mergeRequestId: 0,
    ),
    const MrPendingReviewQuery(
      mergeRequest: MergeRequestRef(projectId: 8, iid: 142),
      mergeRequestId: 1100,
      perPage: 0,
    ),
    const MrPendingReviewQuery(
      mergeRequest: MergeRequestRef(projectId: 8, iid: 142),
      mergeRequestId: 1100,
      perPage: 101,
    ),
  ]) {
    test(
      'invalid query fails before dispatch ${q.mergeRequest.projectId}/${q.mergeRequest.iid}/${q.mergeRequestId}/${q.perPage}',
      () async {
        final repo = Repository((p) async => page([]));
        final c = container(Future.value(repo));
        listen(c, q);
        await expectLater(
          c.read(mrPendingReviewControllerProvider(q).future),
          throwsArgumentError,
        );
        expect(repo.calls, isEmpty);
      },
    );
  }
  for (final fail in [false, true]) {
    test('old initial read cannot replace current rows fail=$fail', () async {
      final pending = Completer<Paginated<MergeRequestDraftNote>>();
      final repo = Repository((p) => pending.future);
      final c = container(Future.value(repo));
      listen(c);
      await c.pump();
      await c.read(mrDraftNotesRepositoryProvider.future);
      await Future<void>.delayed(Duration.zero);
      expect(
        repo.calls.length,
        1,
        reason: 'The old initial request must actually have dispatched.',
      );
      final next = Repository((p) async => page([draft(9)]));
      c.read(repoState.notifier).state = Future.value(next);
      expect((await loaded(c)).items.single.id, 9);
      if (fail) {
        pending.completeError(const GitLabForbiddenException('Obsolete'));
      } else {
        pending.complete(page([draft(1)]));
      }
      await c.pump();
      expect(visible(c).items.single.id, 9);
      expect(c.read(mrPendingReviewProvider(query)).hasError, false);
    });
    test(
      'container disposal suppresses a pagination outcome fail=$fail',
      () async {
        final pending = Completer<Paginated<MergeRequestDraftNote>>();
        final repo = Repository(
          (p) async => p == 1 ? page([draft(1)], next: 2) : pending.future,
        );
        final c = container(Future.value(repo));
        listen(c);
        await loaded(c);
        final old = notifier(c).loadMore();
        await c.pump();
        c.dispose();
        if (fail) {
          pending.completeError(const GitLabForbiddenException('Obsolete'));
        } else {
          pending.complete(page([draft(2)]));
        }
        expect(await old, false);
      },
    );
  }
  test(
    'repository replacement blocks pagination even before the rebuild pump',
    () async {
      final repo = Repository((p) async => page([draft(1)], next: 2));
      final c = container(Future.value(repo));
      listen(c);
      await loaded(c);
      final old = notifier(c);
      final next = Repository((p) async => page([draft(2)]));
      c.read(repoState.notifier).state = Future.value(next);
      expect(await old.loadMore(), false);
      expect(repo.calls.map((v) => v.$3), [1]);
      expect((await loaded(c)).items.single.id, 2);
    },
  );
  test(
    'initial failure remains typed and explicit refresh retries page one',
    () async {
      var reads = 0;
      final repo = Repository((p) async {
        if (++reads == 1) throw const GitLabConnectionException('Unavailable');
        return page([draft(2)]);
      });
      final c = container(Future.value(repo));
      listen(c);
      await expectLater(loaded(c), throwsA(isA<GitLabConnectionException>()));
      hidden(c);
      expect(await notifier(c).loadMore(), false);
      notifier(c).refresh();
      hidden(c);
      expect((await loaded(c)).items.single.id, 2);
      expect(repo.calls.map((v) => v.$3), [1, 1]);
    },
  );
  test(
    'failed refresh never restores previously loaded private rows',
    () async {
      var reads = 0;
      final repo = Repository((p) async {
        if (++reads > 1) throw const GitLabForbiddenException('Forbidden');
        return page([draft(1)]);
      });
      final c = container(Future.value(repo));
      listen(c);
      await loaded(c);
      notifier(c).refresh();
      hidden(c);
      await expectLater(loaded(c), throwsA(isA<GitLabForbiddenException>()));
      hidden(c);
    },
  );
  test('obsolete repository resolution error is suppressed', () async {
    final pending = Completer<MrDraftNotesRepository?>();
    final c = container(pending.future);
    listen(c);
    await c.pump();
    final next = Repository((p) async => page([draft(9)]));
    c.read(repoState.notifier).state = Future.value(next);
    expect((await loaded(c)).items.single.id, 9);
    pending.completeError(const GitLabConnectionException('Obsolete'));
    await c.pump();
    expect(visible(c).items.single.id, 9);
  });
  for (final signedOut in [false, true]) {
    test('missing authenticated session fails signedOut=$signedOut', () async {
      final c = container(Future.value(null));
      if (signedOut) c.read(accountState.notifier).state = null;
      listen(c);
      await expectLater(loaded(c), throwsA(isA<GitLabAuthException>()));
      hidden(c);
    });
  }
}
