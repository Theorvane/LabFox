import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

// Synthetic fixture following the documented created-note response shape.
const _note = <String, Object?>{
  'id': 301,
  'body': 'A threaded reply',
  'type': 'DiscussionNote',
  'author': {'id': 7, 'username': 'reviewer', 'name': 'Reviewer'},
  'created_at': '2026-09-28T12:30:00Z',
  'updated_at': '2026-09-28T12:31:00Z',
  'system': false,
  'resolvable': true,
  'resolved': false,
  'resolved_by': null,
  'resolved_at': null,
};

void main() {
  for (final project in [8, 'group/project']) {
    test('posts one reply with project $project and encoded thread ID', () async {
      late RequestOptions request;
      var writes = 0;
      final client = _client((o) {
        request = o;
        writes++;
        return (status: 201, body: _note);
      });
      addTearDown(client.close);
      const body = '  **Review**\n\nKeep this formatting.  ';
      final result = await client.mergeRequests.replyToDiscussion(
        project,
        iid: 142,
        discussionId: 'thread/with ?#%',
        body: body,
      );
      final encoded = project is int ? '$project' : 'group%2Fproject';
      expect(
        request.path,
        '/projects/$encoded/merge_requests/142/discussions/thread%2Fwith%20%3F%23%25/notes',
      );
      expect(request.method, 'POST');
      expect(request.baseUrl, 'https://gitlab.example.com/api/v4');
      expect(request.data, {'body': body});
      expect(request.queryParameters, isEmpty);
      expect(request.extra['labfox_no_auth_retry'], true);
      expect(writes, 1);
      expect(result.id, 301);
      expect(result.body, 'A threaded reply');
      expect(result.type, 'DiscussionNote');
      expect(result.author?.id, 7);
      expect(result.updatedAt, DateTime.utc(2026, 9, 28, 12, 31));
      expect(result.resolved, false);
      expect(result.resolvedBy, isNull);
      expect(result.resolvedAt, isNull);
    });
  }

  test(
    'accepts a minimal created note without inventing resolution metadata',
    () async {
      final client = _client(
        (_) => (status: 201, body: {'id': 301, 'body': ''}),
      );
      addTearDown(client.close);
      final result = await client.mergeRequests.replyToDiscussion(
        8,
        iid: 142,
        discussionId: 'thread-1',
        body: 'Reply',
      );
      expect(result.id, 301);
      expect(result.body, '');
      expect(result.author, isNull);
      expect(result.resolvable, isNull);
      expect(result.resolved, isNull);
    },
  );

  test('preserves generated resolver and unknown response fields', () async {
    final client = _client(
      (_) => (
        status: 201,
        body: {
          ..._note,
          'resolved': true,
          'resolved_by': {
            'id': 9,
            'username': 'maintainer',
            'name': 'Maintainer',
          },
          'resolved_at': '2026-09-28T12:32:00Z',
          'future_field': {'ignored': true},
        },
      ),
    );
    addTearDown(client.close);
    final result = await client.mergeRequests.replyToDiscussion(
      8,
      iid: 142,
      discussionId: 'thread-1',
      body: 'Reply',
    );
    expect(result.resolved, true);
    expect(result.resolvedBy?.id, 9);
    expect(result.resolvedAt, DateTime.utc(2026, 9, 28, 12, 32));
  });

  for (final input in [
    (iid: 0, thread: 'thread-1', body: 'Reply'),
    (iid: -1, thread: 'thread-1', body: 'Reply'),
    (iid: 142, thread: '', body: 'Reply'),
    (iid: 142, thread: ' \n\t', body: 'Reply'),
    (iid: 142, thread: 'thread-1', body: ''),
    (iid: 142, thread: 'thread-1', body: ' \n\t'),
  ]) {
    test(
      'rejects empty input or invalid IID before dispatch: $input',
      () async {
        var writes = 0;
        final client = _client((_) {
          writes++;
          return (status: 201, body: _note);
        });
        addTearDown(client.close);
        await expectLater(
          client.mergeRequests.replyToDiscussion(
            8,
            iid: input.iid,
            discussionId: input.thread,
            body: input.body,
          ),
          throwsArgumentError,
        );
        expect(writes, 0);
      },
    );
  }

  final malformed = <String, Object?>{
    'null': null,
    'list': [_note],
    'scalar': 'private-content-marker',
    'empty map': {},
    'missing ID': {'body': 'private-content-marker'},
    'missing body': {'id': 301},
    for (final id in [null, 0, -1, 301.5, '301'])
      'invalid ID $id': {..._note, 'id': id},
    'invalid body': {..._note, 'body': 7},
    'invalid system': {..._note, 'system': 'false'},
    'invalid type': {..._note, 'type': []},
    'invalid resolution': {..._note, 'resolved': 'false'},
    'invalid resolvability': {..._note, 'resolvable': 1},
    'invalid created timestamp': {
      ..._note,
      'created_at': 'private-content-marker',
    },
    'invalid updated timestamp': {
      ..._note,
      'updated_at': 'private-content-marker',
    },
    'invalid resolved timestamp': {
      ..._note,
      'resolved_at': 'private-content-marker',
    },
    for (final key in ['author', 'resolved_by']) ...{
      'invalid $key shape': {..._note, key: []},
      'incomplete $key': {
        ..._note,
        key: {'id': 7},
      },
      for (final id in [null, 0, -1, 7.5, '7'])
        'invalid $key ID $id': {
          ..._note,
          key: {'id': id, 'username': 'reviewer', 'name': 'Reviewer'},
        },
    },
  };
  for (final entry in malformed.entries) {
    test('rejects malformed created reply: ${entry.key}', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 201, body: entry.value);
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.replyToDiscussion(
          8,
          iid: 142,
          discussionId: 'thread-1',
          body: 'Reply',
        ),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized message',
            'Invalid discussion reply response.',
          ),
        ),
      );
      expect(writes, 1);
    });
  }

  for (final status in [200, 204, 400, 401, 403, 404, 422, 429, 500, 503]) {
    test(
      'maps status $status before parsing and does not repeat writes',
      () async {
        var writes = 0;
        final client = _client(
          (_) {
            writes++;
            return (status: status, body: 'private-content-marker');
          },
          headers: {
            'retry-after': ['17'],
          },
        );
        addTearDown(client.close);
        final matcher = switch (status) {
          401 => isA<GitLabAuthException>(),
          403 => isA<GitLabForbiddenException>(),
          404 => isA<GitLabNotFoundException>(),
          429 => isA<GitLabRateLimitException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 17),
          ),
          _ => isA<GitLabServerException>(),
        };
        await expectLater(
          client.mergeRequests.replyToDiscussion(
            8,
            iid: 142,
            discussionId: 'thread-1',
            body: 'Reply',
          ),
          throwsA(
            allOf(
              matcher,
              isA<GitLabException>()
                  .having((e) => e.statusCode, 'statusCode', status)
                  .having(
                    (e) => e.message,
                    'no server content',
                    isNot(contains('private-content-marker')),
                  ),
            ),
          ),
        );
        expect(writes, 1);
      },
    );
  }

  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('sanitizes transport $type without replaying the write', () async {
      var writes = 0;
      final client = _client((request) {
        writes++;
        throw DioException(
          requestOptions: request,
          type: type,
          error: 'private-content-marker',
        );
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.replyToDiscussion(
          8,
          iid: 142,
          discussionId: 'thread-1',
          body: 'Reply',
        ),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.message,
            'sanitized',
            isNot(contains('private-content-marker')),
          ),
        ),
      );
      expect(writes, 1);
    });
  }

  test(
    'OAuth rejection does not refresh or replay a reply under a new token',
    () async {
      var writes = 0;
      var refreshes = 0;
      final client = _client(
        (_) {
          writes++;
          return (status: 401, body: {});
        },
        onUnauthorized: () async {
          refreshes++;
          return 'dummy-refreshed-token';
        },
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.replyToDiscussion(
          8,
          iid: 142,
          discussionId: 'thread-1',
          body: 'Reply',
        ),
        throwsA(isA<GitLabAuthException>()),
      );
      expect(writes, 1);
      expect(refreshes, 0);
    },
  );
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  Map<String, List<String>> headers = const {},
  Future<String?> Function()? onUnauthorized,
}) {
  final dio = Dio()..httpClientAdapter = _Adapter(handler, headers);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    bearer: onUnauthorized != null,
    onUnauthorized: onUnauthorized,
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler, this.headers);
  final ({int status, Object? body}) Function(RequestOptions) handler;
  final Map<String, List<String>> headers;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    return ResponseBody.fromString(
      r.body == null ? '' : json.encode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
