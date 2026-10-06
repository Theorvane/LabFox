import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import '../../../packages/gitlab_api/test/mr_commits_api_test.dart' as b;

void main() {
  test(
    'repository traverses advertised nonconsecutive pages and preserves immutable order',
    () async {
      final pages = <int>[];
      final c = b.client((o) {
        final page = o.queryParameters['page'] as int;
        pages.add(page);
        expect(o.queryParameters['per_page'], 100);
        return b.response(
          [b.commit(id: page == 1 ? b.head : b.parent)],
          headers: {
            'x-next-page': [page == 1 ? '3' : ''],
          },
        );
      });
      addTearDown(c.close);
      final result = await MergeRequestsRepository(
        c,
      ).commits(projectId: 8, iid: 142, isCurrent: () => true);
      expect(pages, [1, 3]);
      expect(result!.map((c) => c.id), [b.head, b.parent]);
      expect(() => result.clear(), throwsUnsupportedError);
    },
  );
  test(
    'Link-only continuation is followed with captured route and page size',
    () async {
      final pages = <int>[];
      final c = b.client((o) {
        final page = o.queryParameters['page'] as int;
        pages.add(page);
        return b.response(
          page == 1 ? [b.commit()] : [],
          headers: page == 1
              ? {
                  'link': [b.link(4, perPage: 100)],
                }
              : {},
        );
      });
      addTearDown(c.close);
      final result = await MergeRequestsRepository(
        c,
      ).commits(projectId: 8, iid: 142, isCurrent: () => true);
      expect(pages, [1, 4]);
      expect(result!.single.id, b.head);
    },
  );
  test(
    'GitLab route echoes are confirmed but never forwarded as query overrides',
    () async {
      final pages = <int>[];
      final c = b.client((o) {
        final page = o.queryParameters['page'] as int;
        pages.add(page);
        expect(o.path, '/projects/8/merge_requests/142/commits');
        expect(o.queryParameters.keys, unorderedEquals(['page', 'per_page']));
        return b.response(
          page == 1 ? [b.commit()] : [],
          headers: page == 1
              ? {
                  'link': [
                    b
                        .link(4, perPage: 100)
                        .replaceFirst(
                          'page=4',
                          'id=8&merge_request_iid=142&page=4',
                        ),
                  ],
                }
              : {},
        );
      });
      addTearDown(c.close);
      final result = await MergeRequestsRepository(
        c,
      ).commits(projectId: 8, iid: 142, isCurrent: () => true);
      expect(pages, [1, 4]);
      expect(result!.single.id, b.head);
    },
  );
  test(
    'a root commit and unknown parents stay distinguishable through the repository',
    () async {
      final c = b.client(
        (o) => b.response([
          {'id': b.head, 'title': '', 'parent_ids': []},
          {'id': b.parent, 'title': ''},
        ]),
      );
      addTearDown(c.close);
      final result = await MergeRequestsRepository(
        c,
      ).commits(projectId: 8, iid: 142, isCurrent: () => true);
      expect(result![0].parentIds, isEmpty);
      expect(result[1].parentIds, isNull);
    },
  );
  test(
    'duplicate commit IDs across pages never expose a partial membership list',
    () async {
      final c = b.client(
        (o) => b.response(
          [b.commit()],
          headers: {
            'x-next-page': [o.queryParameters['page'] == 1 ? '2' : ''],
          },
        ),
      );
      addTearDown(c.close);
      await expectLater(
        MergeRequestsRepository(
          c,
        ).commits(projectId: 8, iid: 142, isCurrent: () => true),
        throwsA(isA<GitLabServerException>()),
      );
    },
  );
  test(
    'later page failure never returns the previously loaded partial list',
    () async {
      final c = b.client(
        (o) => o.queryParameters['page'] == 1
            ? b.response(
                [b.commit()],
                headers: {
                  'x-next-page': ['2'],
                },
              )
            : b.response('{private-marker', status: 403, raw: true),
      );
      addTearDown(c.close);
      await expectLater(
        MergeRequestsRepository(
          c,
        ).commits(projectId: 8, iid: 142, isCurrent: () => true),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );
  test('obsolete origin prevents the first GET', () async {
    var calls = 0;
    final c = b.client((o) {
      calls++;
      return b.response([]);
    });
    addTearDown(c.close);
    expect(
      await MergeRequestsRepository(
        c,
      ).commits(projectId: 8, iid: 142, isCurrent: () => false),
      isNull,
    );
    expect(calls, 0);
  });
  test(
    'origin invalidation after a page discards it and prevents another GET',
    () async {
      var current = true, calls = 0;
      final c = b.client((o) {
        calls++;
        current = false;
        return b.response(
          [b.commit()],
          headers: {
            'x-next-page': ['2'],
          },
        );
      });
      addTearDown(c.close);
      expect(
        await MergeRequestsRepository(
          c,
        ).commits(projectId: 8, iid: 142, isCurrent: () => current),
        isNull,
      );
      expect(calls, 1);
    },
  );
  test('currency loss before continuation discards the partial list', () async {
    var guards = 0, calls = 0;
    final c = b.client((o) {
      calls++;
      return b.response(
        [b.commit()],
        headers: {
          'x-next-page': ['2'],
        },
      );
    });
    addTearDown(c.close);
    expect(
      await MergeRequestsRepository(
        c,
      ).commits(projectId: 8, iid: 142, isCurrent: () => ++guards < 3),
      isNull,
    );
    expect(calls, 1);
  });
  test('late final response is discarded after origin replacement', () async {
    var current = true;
    final started = Completer<void>();
    final answer = Completer<void>();
    final c = b.client((o) async {
      started.complete();
      await answer.future;
      return b.response([b.commit()]);
    });
    addTearDown(c.close);
    final result = MergeRequestsRepository(
      c,
    ).commits(projectId: 8, iid: 142, isCurrent: () => current);
    await started.future;
    current = false;
    answer.complete();
    expect(await result, isNull);
  });
  test('a late failed read is discarded when its origin is obsolete', () async {
    var current = true;
    final started = Completer<void>();
    final answer = Completer<void>();
    final c = b.client((o) async {
      started.complete();
      await answer.future;
      return b.response('{private-marker', status: 403, raw: true);
    });
    addTearDown(c.close);
    final result = MergeRequestsRepository(
      c,
    ).commits(projectId: 8, iid: 142, isCurrent: () => current);
    await started.future;
    current = false;
    answer.complete();
    expect(await result, isNull);
  });
  test(
    'currency is checked once more before exposing a complete list',
    () async {
      var guards = 0;
      final c = b.client((o) => b.response([b.commit()]));
      addTearDown(c.close);
      expect(
        await MergeRequestsRepository(
          c,
        ).commits(projectId: 8, iid: 142, isCurrent: () => ++guards < 3),
        isNull,
      );
    },
  );
  test(
    'a current empty MR returns an empty immutable list, separately from cancellation',
    () async {
      final c = b.client((o) => b.response([]));
      addTearDown(c.close);
      final result = await MergeRequestsRepository(
        c,
      ).commits(projectId: 8, iid: 142, isCurrent: () => true);
      expect(result, isEmpty);
      expect(
        () => result!.add(const Commit(id: b.head, title: '')),
        throwsUnsupportedError,
      );
    },
  );
  for (final route in [(0, 142), (8, 0), (-1, 142), (8, -1)]) {
    test(
      'invalid captured route prevents repository dispatch $route',
      () async {
        var calls = 0;
        final c = b.client((o) {
          calls++;
          return b.response([]);
        });
        addTearDown(c.close);
        await expectLater(
          MergeRequestsRepository(
            c,
          ).commits(projectId: route.$1, iid: route.$2, isCurrent: () => true),
          throwsArgumentError,
        );
        expect(calls, 0);
      },
    );
  }
}
