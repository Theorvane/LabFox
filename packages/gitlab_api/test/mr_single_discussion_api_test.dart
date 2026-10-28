import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const _thread = <String, Object?>{
  'id': 'thread /#%',
  'individual_note': false,
  'notes': [
    {
      'id': 301,
      'body': 'Review',
      'type': 'DiffNote',
      'system': false,
      'suggestions': [
        {
          'id': 7,
          'applied': false,
          'appliable': true,
          'from_line': 10,
          'to_line': 12,
          'from_content': 'old\n',
          'to_content': 'new\n',
        },
      ],
    },
  ],
};
void main() {
  for (final project in [8, 'group/project']) {
    test('reads exact discussion $project with encoded identity', () async {
      late RequestOptions request;
      final client = _client((o) {
        request = o;
        return (status: 200, body: _thread);
      });
      addTearDown(client.close);
      final result = await client.mergeRequests.discussion(
        project,
        iid: 142,
        discussionId: 'thread /#%',
      );
      expect(request.method, 'GET');
      expect(
        request.path,
        '/projects/${project is int ? project : 'group%2Fproject'}/merge_requests/142/discussions/thread%20%2F%23%25',
      );
      expect(request.queryParameters, isEmpty);
      expect(request.followRedirects, false);
      expect(result.id, 'thread /#%');
      expect(result.notes.single.suggestions!.single.toContent, 'new\n');
    });
  }
  for (final input in [
    (iid: 0, id: 'thread'),
    (iid: -1, id: 'thread'),
    (iid: 142, id: ''),
    (iid: 142, id: ' \n\t'),
  ]) {
    test('rejects invalid request $input before dispatch', () async {
      var reads = 0;
      final client = _client((o) {
        reads++;
        return (status: 200, body: _thread);
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.discussion(
          8,
          iid: input.iid,
          discussionId: input.id,
        ),
        throwsArgumentError,
      );
      expect(reads, 0);
    });
  }
  final note = (_thread['notes'] as List).single as Map<String, Object?>;
  final malformed = <String, Object?>{
    'null': null,
    'list': [_thread],
    'scalar': 'private-content-marker',
    'empty': {},
    'wrong identity': {..._thread, 'id': 'other'},
    'numeric identity': {..._thread, 'id': 7},
    'missing group kind': {..._thread, 'individual_note': null},
    'invalid note list': {..._thread, 'notes': 'private-content-marker'},
    for (final id in [null, 0, -1, 301.5, '301'])
      'note ID $id': {
        ..._thread,
        'notes': [
          {...note, 'id': id},
        ],
      },
    'invalid note body': {
      ..._thread,
      'notes': [
        {...note, 'body': 7},
      ],
    },
    'invalid suggestion': {
      ..._thread,
      'notes': [
        {
          ...note,
          'suggestions': [
            {'id': 7.5},
          ],
        },
      ],
    },
    'duplicate suggestion': {
      ..._thread,
      'notes': [
        {
          ...note,
          'suggestions': [
            {'id': 7},
            {'id': 7},
          ],
        },
      ],
    },
    'bad date': {
      ..._thread,
      'notes': [
        {...note, 'created_at': 'private-content-marker'},
      ],
    },
  };
  for (final entry in malformed.entries) {
    test('rejects malformed single discussion ${entry.key}', () async {
      final client = _client((o) => (status: 200, body: entry.value));
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.discussion(
          8,
          iid: 142,
          discussionId: 'thread /#%',
        ),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid discussion response.',
          ),
        ),
      );
    });
  }
  for (final status in [
    201,
    204,
    301,
    302,
    307,
    308,
    401,
    403,
    404,
    429,
    500,
    503,
  ]) {
    test('maps discussion status $status before parsing', () async {
      var reads = 0;
      final client = _client(
        (o) {
          reads++;
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
        429 => isA<GitLabRateLimitException>(),
        _ => isA<GitLabServerException>(),
      };
      await expectLater(
        client.mergeRequests.discussion(
          8,
          iid: 142,
          discussionId: 'thread /#%',
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
      expect(reads, 1);
    });
  }
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('maps single discussion transport $type', () async {
      final client = _client(
        (o) => throw DioException(
          requestOptions: o,
          type: type,
          error: 'private-content-marker',
        ),
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.discussion(
          8,
          iid: 142,
          discussionId: 'thread /#%',
        ),
        throwsA(isA<GitLabConnectionException>()),
      );
    });
  }
  test('ordinary authenticated read can refresh OAuth once', () async {
    var reads = 0, refreshes = 0;
    final client = _client(
      (o) {
        reads++;
        return (
          status: reads == 1 ? 401 : 200,
          body: reads == 1 ? {} : _thread,
        );
      },
      onUnauthorized: () async {
        refreshes++;
        return 'dummy-refreshed-token';
      },
    );
    addTearDown(client.close);
    final result = await client.mergeRequests.discussion(
      8,
      iid: 142,
      discussionId: 'thread /#%',
    );
    expect(result.id, 'thread /#%');
    expect(reads, 2);
    expect(refreshes, 1);
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
