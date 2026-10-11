import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';

import '../../../packages/gitlab_api/test/commit_diff_pages_api_test.dart' as f;
import '../../../packages/gitlab_api/test/mr_commits_api_test.dart' as b;
import '../../../packages/gitlab_api/test/mr_detail_identity_api_test.dart'
    as d;

const detail = '/projects/8/merge_requests/142';
const membership = '$detail/commits';
const commit = '/projects/8/repository/commits/${b.head}';
const diff = '$commit/diff';
const routes = [detail, membership, commit, diff, detail, membership];

Future<MrOriginalCommitContext?> read(
  GitLabClient c, {
  bool Function()? current,
  int project = 8,
  int iid = 142,
  int id = 55123,
  String sha = b.head,
}) => MergeRequestsRepository(c).originalCommitContext(
  projectId: project,
  iid: iid,
  mergeRequestId: id,
  commitId: sha,
  isCurrent: current ?? () => true,
);

void main() {
  for (final source in [8, 19, null]) {
    test(
      'one captured target confirms fork source $source without writes or fallbacks',
      () async {
        final requests = <String>[];
        final c = b.client((o) {
          requests.add(o.path);
          expect(o.method, 'GET');
          expect(o.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
          if (o.path == detail) {
            return b.response({...d.mr(), 'source_project_id': source});
          }
          if (o.path == membership) return b.response([b.commit()]);
          if (o.path == commit) return b.response(b.commit());
          if (o.path == diff) return b.response([f.file()]);
          throw StateError('Unexpected route');
        });
        addTearDown(c.close);
        final result = await read(c);
        expect(requests, routes);
        expect(result!.mergeRequest.sourceProjectId, source);
        expect(result.mergeRequest.targetProjectId, 8);
        expect(result.commit.id, b.head);
        expect(result.files.single.diff, f.file()['diff']);
        expect(() => result.files.clear(), throwsUnsupportedError);
      },
    );
  }
  for (final parents in [
    null,
    <String>[],
    [b.parent],
    [b.second, b.parent],
  ]) {
    test(
      'preserves unknown root and ordered target parent context $parents',
      () async {
        final c = b.client((o) {
          if (o.path == detail) return b.response(d.mr());
          if (o.path == membership) {
            return b.response([
              {...b.commit(), 'parent_ids': parents},
            ]);
          }
          if (o.path == commit) {
            return b.response({...b.commit(), 'parent_ids': parents});
          }
          return b.response([]);
        });
        addTearDown(c.close);
        expect((await read(c))!.commit.parentIds, parents);
      },
    );
  }
  test(
    'unknown membership parents never replace reported target parents',
    () async {
      final c = b.client((o) {
        if (o.path == detail) return b.response(d.mr());
        if (o.path == membership) {
          return b.response([
            {...b.commit(), 'parent_ids': null},
          ]);
        }
        if (o.path == commit) return b.response(b.commit());
        return b.response([
          {...f.file(), 'diff': null, 'collapsed': true},
        ]);
      });
      addTearDown(c.close);
      final result = (await read(c))!;
      expect(result.commit.parentIds, [b.parent, b.second]);
      expect(result.files.single.diff, isNull);
      expect(result.files.single.isCollapsed, isTrue);
    },
  );
  test('known membership parents never fill unknown target parents', () async {
    final c = b.client((o) {
      if (o.path == detail) return b.response(d.mr());
      if (o.path == membership) return b.response([b.commit()]);
      if (o.path == commit) {
        return b.response({...b.commit(), 'parent_ids': null});
      }
      return b.response([]);
    });
    addTearDown(c.close);
    expect((await read(c))!.commit.parentIds, isNull);
  });
  for (final finalRead in [false, true]) {
    test(
      'missing selected membership fails before exposure $finalRead',
      () async {
        var memberships = 0;
        final requests = <String>[];
        final c = b.client((o) {
          requests.add(o.path);
          if (o.path == detail) return b.response(d.mr());
          if (o.path == membership) {
            return b.response(
              ++memberships == (finalRead ? 2 : 1) ? [] : [b.commit()],
            );
          }
          if (o.path == commit) return b.response(b.commit());
          return b.response([]);
        });
        addTearDown(c.close);
        await expectLater(read(c), throwsA(isA<GitLabConflictException>()));
        expect(requests, finalRead ? routes : routes.take(2).toList());
      },
    );
  }
  for (final finalRead in [false, true]) {
    test('contradictory reported parent order fails $finalRead', () async {
      var memberships = 0;
      final c = b.client((o) {
        if (o.path == detail) return b.response(d.mr());
        if (o.path == membership) {
          return b.response([
            {
              ...b.commit(),
              if (++memberships == (finalRead ? 2 : 1))
                'parent_ids': [b.second, b.parent],
            },
          ]);
        }
        if (o.path == commit) return b.response(b.commit());
        return b.response([]);
      });
      addTearDown(c.close);
      await expectLater(read(c), throwsA(isA<GitLabServerException>()));
    });
  }
  for (final change in [
    {'source_project_id': 20},
    {'source_project_id': null},
    {'source_branch': 'replacement'},
    {'target_branch': 'replacement'},
  ]) {
    test('reconfirmation rejects changed MR origin $change', () async {
      var details = 0;
      final c = b.client((o) {
        if (o.path == detail) {
          return b.response({...d.mr(), if (++details == 2) ...change});
        }
        if (o.path == membership) return b.response([b.commit()]);
        if (o.path == commit) return b.response(b.commit());
        return b.response([]);
      });
      addTearDown(c.close);
      await expectLater(read(c), throwsA(isA<GitLabConflictException>()));
    });
  }
  for (final change in [
    {'id': 55124},
    {'iid': 143},
    {'target_project_id': 9},
    {'target_project_id': null},
  ]) {
    test(
      'fresh detail identity mismatch cannot expose context $change',
      () async {
        var details = 0;
        final c = b.client((o) {
          if (o.path == detail) {
            return b.response({...d.mr(), if (++details == 2) ...change});
          }
          if (o.path == membership) return b.response([b.commit()]);
          if (o.path == commit) return b.response(b.commit());
          return b.response([]);
        });
        addTearDown(c.close);
        await expectLater(read(c), throwsA(isA<GitLabServerException>()));
      },
    );
  }
  test(
    'complete advertised traversal is reconfirmed and file order remains immutable',
    () async {
      final requests = <(String, int?)>[];
      final c = b.client((o) {
        final page = o.queryParameters['page'] as int?;
        requests.add((o.path, page));
        if (o.path == detail) return b.response(d.mr());
        if (o.path == membership) {
          expect(o.queryParameters['per_page'], 100);
          return b.response(
            page == 1 ? [b.commit(id: b.parent)] : [b.commit()],
            headers: {
              'x-next-page': [page == 1 ? '3' : ''],
            },
          );
        }
        if (o.path == commit) return b.response(b.commit());
        expect(o.queryParameters['unidiff'], true);
        expect(o.queryParameters['per_page'], 100);
        return b.response(
          [f.file(path: page == 1 ? 'first' : 'second')],
          headers: {
            'x-next-page': [page == 1 ? '4' : ''],
          },
        );
      });
      addTearDown(c.close);
      final result = (await read(c))!;
      expect(result.files.map((v) => v.newPath), ['first', 'second']);
      expect(requests, [
        (detail, null),
        (membership, 1),
        (membership, 3),
        (commit, null),
        (diff, 1),
        (diff, 4),
        (detail, null),
        (membership, 1),
        (membership, 3),
      ]);
    },
  );
  for (final (project, iid, id, sha) in [
    (0, 142, 55123, b.head),
    (8, 0, 55123, b.head),
    (8, 142, 0, b.head),
    (8, 142, 55123, 'main'),
  ]) {
    test(
      'invalid captured identity dispatches nothing $project $iid $id $sha',
      () async {
        var requests = 0;
        final c = b.client((o) {
          requests++;
          return b.response(d.mr());
        });
        addTearDown(c.close);
        await expectLater(
          read(c, project: project, iid: iid, id: id, sha: sha),
          throwsArgumentError,
        );
        expect(requests, 0);
      },
    );
  }
  test('already obsolete context dispatches nothing', () async {
    var requests = 0;
    final c = b.client((o) {
      requests++;
      return b.response(d.mr());
    });
    addTearDown(c.close);
    expect(await read(c, current: () => false), isNull);
    expect(requests, 0);
  });
  for (var stop = 0; stop < routes.length; stop++) {
    for (final status in [200, 404, 500]) {
      test(
        'origin replacement discards phase $stop status $status without subsequent requests',
        () async {
          var index = 0, current = true;
          final started = Completer<void>(), answer = Completer<void>();
          final c = b.client((o) async {
            final phase = index++;
            expect(o.path, routes[phase]);
            if (phase == stop) {
              started.complete();
              await answer.future;
            }
            final body = o.path == detail
                ? d.mr()
                : o.path == membership
                ? [b.commit()]
                : o.path == commit
                ? b.commit()
                : [f.file()];
            return b.response(body, status: phase == stop ? status : 200);
          });
          addTearDown(c.close);
          final result = read(c, current: () => current);
          await Future.any<Object?>([started.future, result]);
          expect(started.isCompleted, isTrue);
          current = false;
          answer.complete();
          expect(await result, isNull);
          expect(index, stop + 1);
        },
      );
    }
  }
  for (var stop = 0; stop < routes.length; stop++) {
    test('current phase $stop not-found failure stays typed', () async {
      var index = 0;
      final c = b.client((o) {
        final phase = index++;
        final body = o.path == detail
            ? d.mr()
            : o.path == membership
            ? [b.commit()]
            : o.path == commit
            ? b.commit()
            : [];
        return b.response(body, status: phase == stop ? 404 : 200);
      });
      addTearDown(c.close);
      await expectLater(read(c), throwsA(isA<GitLabNotFoundException>()));
      expect(index, stop + 1);
    });
  }
}
