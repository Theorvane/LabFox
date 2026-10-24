import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';
import 'mr_commits_api_test.dart' as b;

void main() {
  for (final project in [8, 'group/project +']) {
    test(
      'fixed detail preserves exact identity, content and route $project',
      () async {
        late RequestOptions request;
        final c = b.client((o) {
          request = o;
          return b.response(b.commit());
        });
        addTearDown(c.close);
        final result = await c.repository.fixedCommit(
          project,
          commitId: b.head,
        );
        expect(
          request.path,
          '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/repository/commits/${b.head}',
        );
        expect(request.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
        expect(request.method, 'GET');
        expect(request.queryParameters, {'stats': false});
        expect(request.followRedirects, isFalse);
        expect(request.responseType, ResponseType.plain);
        expect(result.id, b.head);
        expect(result.title, '  Exact commit title  ');
        expect(result.message, 'Exact message\n\nBody.');
        expect(result.parentIds, [b.parent, b.second]);
        expect(() => result.parentIds!.clear(), throwsUnsupportedError);
      },
    );
  }
  for (final parents in [
    null,
    <String>[],
    [b.parent],
    [b.second, b.parent],
  ]) {
    test('retains unknown root and ordered parent metadata $parents', () async {
      final c = b.client(
        (o) => b.response({...b.commit(), 'parent_ids': parents}),
      );
      addTearDown(c.close);
      expect(
        (await c.repository.fixedCommit(8, commitId: b.head)).parentIds,
        parents,
      );
    });
  }
  test('omitted parents remain unknown', () async {
    final payload = b.commit()..remove('parent_ids');
    final c = b.client((o) => b.response(payload));
    addTearDown(c.close);
    expect(
      (await c.repository.fixedCommit(8, commitId: b.head)).parentIds,
      isNull,
    );
  });
  for (final project in [0, -1, '', '  ', 8.5, false]) {
    test('invalid project never dispatches $project', () async {
      var calls = 0;
      final c = b.client((o) {
        calls++;
        return b.response(b.commit());
      });
      addTearDown(c.close);
      await expectLater(
        c.repository.fixedCommit(project, commitId: b.head),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final sha in [
    '',
    'main',
    'v1.0',
    '12345678',
    b.head.toUpperCase(),
    '${b.head} ',
    '${b.head}\n',
    'z${b.head.substring(1)}',
    '${b.head}${b.head}',
  ]) {
    test('noncanonical commit reference never dispatches $sha', () async {
      var calls = 0;
      final c = b.client((o) {
        calls++;
        return b.response(b.commit());
      });
      addTearDown(c.close);
      await expectLater(
        c.repository.fixedCommit(8, commitId: sha),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final id in [
    null,
    8,
    '',
    'main',
    b.parent,
    b.head.toUpperCase(),
    '${b.head}\n',
  ]) {
    test('rejects mismatched or malformed response head $id', () async {
      final c = b.client((o) => b.response({...b.commit(), 'id': id}));
      addTearDown(c.close);
      await expectLater(
        c.repository.fixedCommit(8, commitId: b.head),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final parents in [
    false,
    '',
    {},
    [null],
    [8],
    ['main'],
    [b.head],
    [b.parent, b.parent],
    [b.parent.toUpperCase()],
    ['${b.parent}\n'],
  ]) {
    test('rejects malformed self or duplicate parents $parents', () async {
      final c = b.client(
        (o) => b.response({...b.commit(), 'parent_ids': parents}),
      );
      addTearDown(c.close);
      await expectLater(
        c.repository.fixedCommit(8, commitId: b.head),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final payload in [
    null,
    [],
    8,
    'private malformed JSON',
    {'id': b.head},
    {...b.commit(), 'title': false},
    {...b.commit(), 'authored_date': 'private invalid date'},
  ]) {
    test('malformed payload stays sanitized $payload', () async {
      final c = b.client((o) => b.response(payload));
      addTearDown(c.close);
      await expectLater(
        c.repository.fixedCommit(8, commitId: b.head),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'message',
            'Invalid fixed commit response.',
          ),
        ),
      );
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
    test('status $status precedes malformed JSON decoding', () async {
      final c = b.client(
        (o) => b.response('private invalid', status: status, raw: true),
      );
      addTearDown(c.close);
      await expectLater(
        c.repository.fixedCommit(8, commitId: b.head),
        throwsA(
          predicate(
            (e) =>
                e.runtimeType == type &&
                !e.toString().contains('private invalid'),
          ),
        ),
      );
    });
  }
  test('captured read-only OAuth retries only the same fixed route', () async {
    var requests = 0, refreshes = 0;
    final c = b.client(
      (o) {
        expect(o.path, '/projects/8/repository/commits/${b.head}');
        expect(o.queryParameters, {'stats': false});
        expect(o.followRedirects, isFalse);
        return ++requests == 1
            ? b.response('invalid', status: 401, raw: true)
            : b.response(b.commit());
      },
      onUnauthorized: () async {
        refreshes++;
        return 'dummy-refreshed-token';
      },
    );
    addTearDown(c.close);
    expect((await c.repository.fixedCommit(8, commitId: b.head)).id, b.head);
    expect(requests, 2);
    expect(refreshes, 1);
  });
  test('general detail still accepts a branch reference', () async {
    final c = b.client((o) {
      expect(o.path, '/projects/8/repository/commits/feature%2Fwork');
      return b.response(b.commit());
    });
    addTearDown(c.close);
    expect((await c.repository.commit(8, sha: 'feature/work')).id, b.head);
  });
}
