import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/commits/data/history_repository.dart';
import '../../../packages/gitlab_api/test/commit_diff_pages_api_test.dart' as b;

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
          [b.file(path: page == 1 ? 'a.dart' : 'b.dart')],
          headers: {
            'x-next-page': [page == 1 ? '3' : ''],
          },
        );
      });
      addTearDown(c.close);
      final result = await HistoryRepository(c).originalCommitDiff(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => true,
      );
      expect(pages, [1, 3]);
      expect(result!.map((f) => f.newPath), ['a.dart', 'b.dart']);
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
          page == 1 ? [b.file()] : [],
          headers: page == 1
              ? {
                  'link': [b.link(4, perPage: 100)],
                }
              : {},
        );
      });
      addTearDown(c.close);
      final result = await HistoryRepository(c).originalCommitDiff(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => true,
      );
      expect(pages, [1, 4]);
      expect(result!.single.newPath, 'lib/a.dart');
    },
  );
  test(
    'GitLab route echoes are confirmed but never forwarded as query overrides',
    () async {
      final pages = <int>[];
      final c = b.client((o) {
        final page = o.queryParameters['page'] as int;
        pages.add(page);
        expect(o.path, '/projects/8/repository/commits/${b.head}/diff');
        expect(
          o.queryParameters.keys,
          unorderedEquals(['page', 'per_page', 'unidiff']),
        );
        return b.response(
          page == 1 ? [b.file()] : [],
          headers: page == 1
              ? {
                  'link': [
                    b
                        .link(4, perPage: 100)
                        .replaceFirst('page=4', 'id=8&sha=${b.head}&page=4'),
                  ],
                }
              : {},
        );
      });
      addTearDown(c.close);
      final result = await HistoryRepository(c).originalCommitDiff(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => true,
      );
      expect(pages, [1, 4]);
      expect(result!.single.newPath, 'lib/a.dart');
    },
  );
  test(
    'omitted literal text and unknown omission flags remain distinguishable',
    () async {
      final c = b.client(
        (o) => b.response([
          {...b.file(path: 'a.dart'), 'diff': ''},
          b.file(path: 'b.dart')..remove('diff'),
        ]),
      );
      addTearDown(c.close);
      final result = await HistoryRepository(c).originalCommitDiff(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => true,
      );
      expect(result![0].diff, isEmpty);
      expect(result[1].diff, isNull);
    },
  );
  test(
    'duplicate original path pairs across pages never expose a partial membership list',
    () async {
      final c = b.client(
        (o) => b.response(
          [b.file()],
          headers: {
            'x-next-page': [o.queryParameters['page'] == 1 ? '2' : ''],
          },
        ),
      );
      addTearDown(c.close);
      await expectLater(
        HistoryRepository(c).originalCommitDiff(
          projectId: 8,
          commitId: b.head,
          isCurrent: () => true,
        ),
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
                [b.file()],
                headers: {
                  'x-next-page': ['2'],
                },
              )
            : b.response('{private-marker', status: 403, raw: true),
      );
      addTearDown(c.close);
      await expectLater(
        HistoryRepository(c).originalCommitDiff(
          projectId: 8,
          commitId: b.head,
          isCurrent: () => true,
        ),
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
      await HistoryRepository(c).originalCommitDiff(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => false,
      ),
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
          [b.file()],
          headers: {
            'x-next-page': ['2'],
          },
        );
      });
      addTearDown(c.close);
      expect(
        await HistoryRepository(c).originalCommitDiff(
          projectId: 8,
          commitId: b.head,
          isCurrent: () => current,
        ),
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
        [b.file()],
        headers: {
          'x-next-page': ['2'],
        },
      );
    });
    addTearDown(c.close);
    expect(
      await HistoryRepository(c).originalCommitDiff(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => ++guards < 3,
      ),
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
      return b.response([b.file()]);
    });
    addTearDown(c.close);
    final result = HistoryRepository(c).originalCommitDiff(
      projectId: 8,
      commitId: b.head,
      isCurrent: () => current,
    );
    await Future.any<Object?>([started.future, result]);
    expect(started.isCompleted, true);
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
    final result = HistoryRepository(c).originalCommitDiff(
      projectId: 8,
      commitId: b.head,
      isCurrent: () => current,
    );
    await Future.any<Object?>([started.future, result]);
    expect(started.isCompleted, true);
    current = false;
    answer.complete();
    expect(await result, isNull);
  });
  test(
    'currency is checked once more before exposing a complete list',
    () async {
      var guards = 0;
      final c = b.client((o) => b.response([b.file()]));
      addTearDown(c.close);
      expect(
        await HistoryRepository(c).originalCommitDiff(
          projectId: 8,
          commitId: b.head,
          isCurrent: () => ++guards < 3,
        ),
        isNull,
      );
    },
  );
  test(
    'a current empty diff returns an empty immutable list, separately from cancellation',
    () async {
      final c = b.client((o) => b.response([]));
      addTearDown(c.close);
      final result = await HistoryRepository(c).originalCommitDiff(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => true,
      );
      expect(result, isEmpty);
      expect(
        () => result!.add(
          const CommitDiffFile(
            oldPath: 'a',
            newPath: 'a',
            isNew: false,
            isDeleted: false,
            isRenamed: false,
          ),
        ),
        throwsUnsupportedError,
      );
    },
  );
  for (final route in [(0, b.head), (-1, b.head), (8, ''), (8, 'main')]) {
    test('invalid captured diff identity prevents dispatch $route', () async {
      var calls = 0;
      final c = b.client((o) {
        calls++;
        return b.response([]);
      });
      addTearDown(c.close);
      await expectLater(
        HistoryRepository(c).originalCommitDiff(
          projectId: route.$1,
          commitId: route.$2,
          isCurrent: () => true,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
}
