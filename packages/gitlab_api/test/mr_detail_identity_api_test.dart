import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';
import 'mr_commits_api_test.dart' as b;

Map<String, dynamic> mr() => {
  'id': 55123,
  'iid': 142,
  'title': 'Review original commit',
  'state': 'opened',
  'source_branch': 'feature',
  'target_branch': 'main',
  'project_id': 8,
  'source_project_id': 19,
  'target_project_id': 8,
};

void main() {
  for (final project in [8, 'group/project +']) {
    test(
      'detail retains exact encoded route and read options $project',
      () async {
        late RequestOptions request;
        final c = b.client((o) {
          request = o;
          return b.response(mr());
        });
        addTearDown(c.close);
        final result = await c.mergeRequests.get(project, iid: 142);
        expect(
          request.path,
          '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/merge_requests/142',
        );
        expect(request.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
        expect(request.queryParameters, {'with_labels_details': true});
        expect(request.method, 'GET');
        expect(request.followRedirects, isFalse);
        expect(request.responseType, ResponseType.plain);
        expect(result.id, 55123);
        expect(result.iid, 142);
      },
    );
  }
  for (final project in [0, -1, '', '  ', 8.5, true, Object()]) {
    test('invalid project fails before dispatch $project', () async {
      var calls = 0;
      final c = b.client((o) {
        calls++;
        return b.response(mr());
      });
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.get(project, iid: 142),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final iid in [0, -1]) {
    test('invalid IID fails before dispatch $iid', () async {
      var calls = 0;
      final c = b.client((o) {
        calls++;
        return b.response(mr());
      });
      addTearDown(c.close);
      await expectLater(c.mergeRequests.get(8, iid: iid), throwsArgumentError);
      expect(calls, 0);
    });
  }
  for (final field in [
    'id',
    'iid',
    'project_id',
    'source_project_id',
    'target_project_id',
  ]) {
    for (final value in [0, -1, 8.0, 8.5, '8', false, [], {}]) {
      test(
        'rejects malformed identity $field=$value without truncation',
        () async {
          final c = b.client((o) => b.response({...mr(), field: value}));
          addTearDown(c.close);
          await expectLater(
            c.mergeRequests.get(8, iid: 142),
            throwsA(isA<GitLabServerException>()),
          );
        },
      );
    }
  }
  for (final field in ['id', 'iid']) {
    for (final missing in [false, true]) {
      test(
        'rejects required identity null or missing $field $missing',
        () async {
          final body = mr()..[field] = null;
          if (missing) body.remove(field);
          final c = b.client((o) => b.response(body));
          addTearDown(c.close);
          await expectLater(
            c.mergeRequests.get(8, iid: 142),
            throwsA(isA<GitLabServerException>()),
          );
        },
      );
    }
  }
  for (final change in [
    {'iid': 143},
    {'project_id': 9},
    {'target_project_id': 9},
    {'project_id': 9, 'target_project_id': 9},
  ]) {
    test('rejects identity mismatch $change', () async {
      final c = b.client((o) => b.response({...mr(), ...change}));
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.get(8, iid: 142),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  test(
    'slug route still rejects contradictory project and target IDs',
    () async {
      final c = b.client((o) => b.response({...mr(), 'target_project_id': 9}));
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.get('group/project', iid: 142),
        throwsA(isA<GitLabServerException>()),
      );
    },
  );
  for (final explicitNull in [false, true]) {
    test('optional identities can remain unknown $explicitNull', () async {
      final body = mr();
      for (final field in [
        'project_id',
        'source_project_id',
        'target_project_id',
      ]) {
        if (explicitNull) {
          body[field] = null;
        } else {
          body.remove(field);
        }
      }
      final c = b.client((o) => b.response(body));
      addTearDown(c.close);
      final result = await c.mergeRequests.get(8, iid: 142);
      expect(result.projectId, isNull);
    });
  }
  for (final body in [
    null,
    [],
    8,
    'private malformed response',
    {'id': 55123},
    {...mr(), 'title': false},
    {...mr(), 'created_at': 'private malformed date'},
  ]) {
    test('malformed detail stays a sanitized domain error $body', () async {
      final c = b.client((o) => b.response(body));
      addTearDown(c.close);
      try {
        await c.mergeRequests.get(8, iid: 142);
        fail('Expected invalid detail');
      } on GitLabServerException catch (e) {
        expect(e.message, 'Invalid merge request response.');
      }
    });
  }
  for (final (status, type) in [
    (401, GitLabAuthException),
    (403, GitLabForbiddenException),
    (404, GitLabNotFoundException),
    (429, GitLabRateLimitException),
    (500, GitLabServerException),
    (302, GitLabServerException),
  ]) {
    test('status $status is mapped before malformed JSON decoding', () async {
      final c = b.client(
        (o) => b.response('private malformed body', status: status, raw: true),
      );
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.get(8, iid: 142),
        throwsA(
          predicate(
            (e) =>
                e.runtimeType == type &&
                !e.toString().contains('private malformed'),
          ),
        ),
      );
    });
  }
  test(
    'read-only account OAuth refresh stays bound to the detail route',
    () async {
      var calls = 0, refreshes = 0;
      final c = b.client(
        (o) {
          calls++;
          expect(o.path, '/projects/8/merge_requests/142');
          expect(o.followRedirects, isFalse);
          return calls == 1
              ? b.response('invalid', status: 401, raw: true)
              : b.response(mr());
        },
        onUnauthorized: () async {
          refreshes++;
          return 'dummy-refreshed-token';
        },
      );
      addTearDown(c.close);
      expect((await c.mergeRequests.get(8, iid: 142)).id, 55123);
      expect(calls, 2);
      expect(refreshes, 1);
    },
  );
}
