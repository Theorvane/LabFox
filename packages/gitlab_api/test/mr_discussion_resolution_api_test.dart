import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

Map<String, Object?> _thread(bool resolved) => {
  'id': 'thread/1',
  'individual_note': false,
  'notes': [
    {'id': 301, 'body': 'Review', 'resolvable': true, 'resolved': resolved},
    {'id': 302, 'body': 'Reply', 'resolvable': false},
  ],
};
void main() {
  for (final resolved in [true, false]) {
    for (final project in [8, 'group/project']) {
      test('sets explicit resolution $resolved for project $project', () async {
        late RequestOptions request;
        var writes = 0;
        final client = _client((o) {
          request = o;
          writes++;
          return (status: 200, body: _thread(resolved));
        });
        addTearDown(client.close);
        final result = await client.mergeRequests.setDiscussionResolved(
          project,
          iid: 142,
          discussionId: 'thread/1',
          resolved: resolved,
        );
        final encoded = project is int ? '$project' : 'group%2Fproject';
        expect(
          request.path,
          '/projects/$encoded/merge_requests/142/discussions/thread%2F1',
        );
        expect(request.method, 'PUT');
        expect(request.baseUrl, 'https://gitlab.example.com/api/v4');
        expect(request.data, {'resolved': resolved});
        expect(request.queryParameters, isEmpty);
        expect(request.extra['labfox_no_auth_retry'], true);
        expect(request.followRedirects, false);
        expect(writes, 1);
        expect(result.id, 'thread/1');
        expect(result.notes.first.resolved, resolved);
        expect(result.notes.last.resolved, isNull);
      });
    }
  }
  for (final input in [
    (iid: 0, id: 'thread/1'),
    (iid: -1, id: 'thread/1'),
    (iid: 142, id: ''),
    (iid: 142, id: ' \n\t'),
  ]) {
    test('rejects invalid input before dispatch $input', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        return (status: 200, body: _thread(true));
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.setDiscussionResolved(
          8,
          iid: input.iid,
          discussionId: input.id,
          resolved: true,
        ),
        throwsArgumentError,
      );
      expect(writes, 0);
    });
  }
  final malformed = <String, Object?>{
    'null': null,
    'scalar': 'private-content-marker',
    'list': [_thread(true)],
    'empty': {},
    'wrong thread': {..._thread(true), 'id': 'other'},
    'missing individual flag': {
      'id': 'thread/1',
      'notes': _thread(true)['notes'],
    },
    'bad individual flag': {..._thread(true), 'individual_note': 'false'},
    'missing notes': {'id': 'thread/1', 'individual_note': false},
    'empty notes': {..._thread(true), 'notes': []},
    'missing note body': {
      ..._thread(true),
      'notes': [
        {'id': 301, 'resolvable': true, 'resolved': true},
      ],
    },
    'missing resolution': {
      ..._thread(true),
      'notes': [
        {'id': 301, 'body': 'Review', 'resolvable': true},
      ],
    },
    'wrong resolution': _thread(false),
    'no resolvable notes': {
      ..._thread(true),
      'notes': [
        {'id': 301, 'body': 'Review', 'resolved': true},
      ],
    },
    'mixed incomplete resolution': {
      ..._thread(true),
      'notes': [
        {'id': 301, 'body': 'Review', 'resolvable': true, 'resolved': true},
        {'id': 302, 'body': 'Reply', 'resolvable': true, 'resolved': false},
      ],
    },
    'invalid resolver timestamp': {
      ..._thread(true),
      'notes': [
        {
          'id': 301,
          'body': 'Review',
          'resolvable': true,
          'resolved': true,
          'resolved_at': 'private-content-marker',
        },
      ],
    },
    for (final id in [null, 0, -1, 301.5, '301'])
      'invalid note ID $id': {
        ..._thread(true),
        'notes': [
          {'id': id, 'body': 'Review', 'resolvable': true, 'resolved': true},
        ],
      },
    for (final key in ['author', 'resolved_by']) ...{
      'incomplete $key': {
        ..._thread(true),
        'notes': [
          {
            'id': 301,
            'body': 'Review',
            'resolvable': true,
            'resolved': true,
            key: {'id': 7},
          },
        ],
      },
      'fractional $key': {
        ..._thread(true),
        'notes': [
          {
            'id': 301,
            'body': 'Review',
            'resolvable': true,
            'resolved': true,
            key: {'id': 7.5, 'username': 'reviewer', 'name': 'Reviewer'},
          },
        ],
      },
    },
  };
  for (final entry in malformed.entries) {
    test('rejects unconfirmed updated thread: ${entry.key}', () async {
      final client = _client((_) => (status: 200, body: entry.value));
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.setDiscussionResolved(
          8,
          iid: 142,
          discussionId: 'thread/1',
          resolved: true,
        ),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid discussion resolution response.',
          ),
        ),
      );
    });
  }
  for (final status in [
    201,
    204,
    302,
    400,
    401,
    403,
    404,
    422,
    429,
    500,
    503,
  ]) {
    test('maps resolution HTTP $status before parsing', () async {
      var writes = 0;
      final client = _client(
        (_) {
          writes++;
          return (status: status, body: 'private-content-marker');
        },
        headers: {
          'retry-after': ['17'],
          'location': ['https://other.example.com/'],
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
        client.mergeRequests.setDiscussionResolved(
          8,
          iid: 142,
          discussionId: 'thread/1',
          resolved: true,
        ),
        throwsA(
          allOf(
            matcher,
            isA<GitLabException>()
                .having((e) => e.statusCode, 'status', status)
                .having(
                  (e) => e.message,
                  'sanitized',
                  isNot(contains('private-content-marker')),
                ),
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('maps transport $type without replay', () async {
      var writes = 0;
      final client = _client((r) {
        writes++;
        throw DioException(
          requestOptions: r,
          type: type,
          error: 'private-content-marker',
        );
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.setDiscussionResolved(
          8,
          iid: 142,
          discussionId: 'thread/1',
          resolved: true,
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
  test('OAuth rejection does not refresh or replay resolution', () async {
    var writes = 0;
    var refreshes = 0;
    final client = _client(
      (r) {
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
      client.mergeRequests.setDiscussionResolved(
        8,
        iid: 142,
        discussionId: 'thread/1',
        resolved: true,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(writes, 1);
    expect(refreshes, 0);
  });
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
