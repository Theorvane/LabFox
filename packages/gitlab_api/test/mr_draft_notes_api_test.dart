import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

Map<String, Object?> _draft({int id = 5}) => {
  'id': id,
  'author_id': 23,
  'merge_request_id': 1100,
  'note': '  **Review**\n\n```suggestion\nupdated\n```  ',
  'resolve_discussion': false,
  'discussion_id': null,
  'commit_id': null,
  'line_code': null,
  'position': {'position_type': 'text', 'old_line': null, 'new_line': null},
};

void main() {
  test(
    'reads exactly one draft page using encoded project and MR IID',
    () async {
      late RequestOptions request;
      var calls = 0;
      final client = _client(
        (o) {
          calls++;
          request = o;
          return (status: 200, body: [_draft()]);
        },
        headers: {
          'x-next-page': ['4'],
        },
      );
      addTearDown(client.close);
      final page = await client.mergeRequests.draftNotes(
        'group/project +',
        iid: 142,
        page: 3,
        perPage: 10,
      );
      expect(
        request.path,
        '/projects/group%2Fproject%20%2B/merge_requests/142/draft_notes',
      );
      expect(request.method, 'GET');
      expect(request.queryParameters, {'page': 3, 'per_page': 10});
      expect(request.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
      expect(request.followRedirects, false);
      expect(request.headers['PRIVATE-TOKEN'], 'glpat-xxxxxxxxxxxx');
      expect(page.items.single.id, 5);
      expect(page.items.single.mergeRequestId, 1100);
      expect(page.items.single.note, _draft()['note']);
      expect(page.nextPage, 4);
      expect(page.total, isNull);
      expect(calls, 1);
      expect(() => page.items.clear(), throwsUnsupportedError);
    },
  );
  test(
    'retains nullable metadata and full original multiline position',
    () async {
      final client = _client(
        (_) => (
          status: 200,
          body: [
            {
              ..._draft(),
              'discussion_id': 'thread/a',
              'resolve_discussion': true,
              'commit_id': 'original',
              'line_code': 'file_1_2',
              'position': {
                'position_type': 'text',
                'base_sha': 'base',
                'start_sha': 'start',
                'head_sha': 'head',
                'old_path': 'old.dart',
                'new_path': 'new.dart',
                'old_line': 1,
                'new_line': 2,
                'line_range': {
                  'start': {
                    'line_code': 'file_1_2',
                    'type': 'old',
                    'old_line': 1,
                  },
                  'end': {
                    'line_code': 'file_2_3',
                    'type': 'new',
                    'new_line': 3,
                  },
                },
              },
            },
          ],
        ),
      );
      addTearDown(client.close);
      final draft = (await client.mergeRequests.draftNotes(
        8,
        iid: 142,
      )).items.single;
      expect(draft.discussionId, 'thread/a');
      expect(draft.resolveDiscussion, true);
      expect(draft.commitId, 'original');
      expect(draft.position!.oldPath, 'old.dart');
      expect(draft.position!.lineRange!.end!.newLine, 3);
    },
  );
  test('empty intermediate page retains cursor and optional totals', () async {
    final client = _client(
      (_) => (status: 200, body: []),
      headers: {
        'x-next-page': ['5'],
        'x-total': ['42'],
        'x-total-pages': ['3'],
      },
    );
    addTearDown(client.close);
    final page = await client.mergeRequests.draftNotes(8, iid: 142, page: 3);
    expect(page.items, isEmpty);
    expect(page.nextPage, 5);
    expect(page.total, 42);
    expect(page.totalPages, 3);
  });
  for (final cursor in [null, '']) {
    test('absent or empty cursor ends the page: $cursor', () async {
      final client = _client(
        (_) => (status: 200, body: []),
        headers: {
          if (cursor != null) 'x-next-page': [cursor],
        },
      );
      addTearDown(client.close);
      expect(
        (await client.mergeRequests.draftNotes(8, iid: 142)).hasMore,
        false,
      );
    });
  }
  for (final cursor in ['private-content-marker', '0', '-1', '2', '3.5']) {
    test('rejects malformed or nonadvancing cursor: $cursor', () async {
      final client = _client(
        (_) => (status: 200, body: []),
        headers: {
          'x-next-page': [cursor],
        },
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.draftNotes(8, iid: 142, page: 2),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid draft notes pagination.',
          ),
        ),
      );
    });
  }
  for (final args in [(0, 1, 20), (142, 0, 20), (142, 1, 0), (142, 1, 101)]) {
    test('invalid identity/paging fails before dispatch: $args', () async {
      var calls = 0;
      final client = _client((_) {
        calls++;
        return (status: 200, body: []);
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.draftNotes(
          8,
          iid: args.$1,
          page: args.$2,
          perPage: args.$3,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  final malformed = <String, Object?>{
    'null': null,
    'object': {},
    'scalar': 'private-content-marker',
    'null draft': [null],
    'missing draft': [{}],
    'duplicate ID': [_draft(), _draft()],
    'mixed MR identities': [
      _draft(),
      {..._draft(id: 6), 'merge_request_id': 2000},
    ],
    'missing note': [
      {..._draft()}..remove('note'),
    ],
    'invalid note': [
      {..._draft(), 'note': 8},
    ],
    'invalid resolution': [
      {..._draft(), 'resolve_discussion': 'false'},
    ],
    'invalid discussion ID': [
      {..._draft(), 'discussion_id': 7},
    ],
    'invalid commit ID': [
      {..._draft(), 'commit_id': {}},
    ],
    'invalid line code': [
      {..._draft(), 'line_code': []},
    ],
    'invalid position': [
      {..._draft(), 'position': []},
    ],
    'fractional position': [
      {
        ..._draft(),
        'position': {'old_line': 1.5},
      },
    ],
    'zero position': [
      {
        ..._draft(),
        'position': {'new_line': 0},
      },
    ],
    'invalid SHA': [
      {
        ..._draft(),
        'position': {'base_sha': 5},
      },
    ],
    'invalid range': [
      {
        ..._draft(),
        'position': {'line_range': []},
      },
    ],
    'invalid endpoint': [
      {
        ..._draft(),
        'position': {
          'line_range': {'start': []},
        },
      },
    ],
    'invalid range side': [
      {
        ..._draft(),
        'position': {
          'line_range': {
            'end': {'type': 2},
          },
        },
      },
    ],
    'fractional range line': [
      {
        ..._draft(),
        'position': {
          'line_range': {
            'end': {'new_line': 3.5},
          },
        },
      },
    ],
    'negative image coordinate': [
      {
        ..._draft(),
        'position': {'x': -1},
      },
    ],
    'invalid image coordinate': [
      {
        ..._draft(),
        'position': {'y': 'private-content-marker'},
      },
    ],
    'mixed valid and invalid': [_draft(), {}],
  };
  for (final field in ['id', 'author_id', 'merge_request_id']) {
    for (final invalid in [null, 0, -1, 1.5, 1.0, '23']) {
      malformed['$field=$invalid (${invalid.runtimeType})'] = [
        {..._draft(), field: invalid},
      ];
    }
  }
  for (final entry in malformed.entries) {
    test('rejects malformed draft page: ${entry.key}', () async {
      final client = _client((_) => (status: 200, body: entry.value));
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.draftNotes(8, iid: 142),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid draft notes response.',
          ),
        ),
      );
    });
  }
  for (final status in [201, 204, 302, 401, 403, 404, 429, 500]) {
    test('maps HTTP $status before parsing private payload', () async {
      final client = _client(
        (_) => (status: status, body: 'private-content-marker'),
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
        client.mergeRequests.draftNotes(8, iid: 142),
        throwsA(matcher),
      );
    });
  }
  test(
    'multiple next-page headers are a sanitized pagination failure',
    () async {
      final client = _client(
        (_) => (status: 200, body: []),
        headers: {
          'x-next-page': ['2', 'private-content-marker'],
        },
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.draftNotes(8, iid: 142),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid draft notes pagination.',
          ),
        ),
      );
    },
  );
  test(
    'read-only OAuth refresh retries once with the replacement token',
    () async {
      var reads = 0, refreshes = 0;
      final tokens = <Object?>[];
      final client = _client(
        (o) {
          tokens.add(o.headers['Authorization']);
          reads++;
          return (
            status: reads == 1 ? 401 : 200,
            body: reads == 1 ? {} : [_draft()],
          );
        },
        onUnauthorized: () async {
          refreshes++;
          return 'dummy-refreshed-token';
        },
      );
      addTearDown(client.close);
      expect(
        (await client.mergeRequests.draftNotes(8, iid: 142)).items.single.id,
        5,
      );
      expect(reads, 2);
      expect(refreshes, 1);
      expect(tokens, [
        'Bearer glpat-xxxxxxxxxxxx',
        'Bearer dummy-refreshed-token',
      ]);
    },
  );
  test(
    'optional fields may be absent and future position types remain opaque',
    () async {
      final client = _client(
        (_) => (
          status: 200,
          body: [
            {
              'id': 5,
              'author_id': 23,
              'merge_request_id': 1100,
              'note': '',
              'position': {'position_type': 'future', 'x': 0.5, 'y': 0},
            },
          ],
        ),
      );
      addTearDown(client.close);
      final draft = (await client.mergeRequests.draftNotes(
        8,
        iid: 142,
      )).items.single;
      expect(draft.note, '');
      expect(draft.resolveDiscussion, isNull);
      expect(draft.position!.positionType, 'future');
    },
  );
  test(
    'server draft order is retained without sorting or fetching ahead',
    () async {
      final client = _client(
        (_) => (status: 200, body: [_draft(id: 6), _draft()]),
      );
      addTearDown(client.close);
      expect(
        (await client.mergeRequests.draftNotes(
          8,
          iid: 142,
        )).items.map((d) => d.id),
        [6, 5],
      );
    },
  );
  test('transport errors are typed and sanitized', () async {
    final client = _client(
      (o) => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
        message: 'private-content-marker',
        error: 'private-content-marker',
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.mergeRequests.draftNotes(8, iid: 142),
      throwsA(
        isA<GitLabConnectionException>().having(
          (e) => e.toString(),
          'sanitized',
          isNot(contains('private-content-marker')),
        ),
      ),
    );
  });
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  Map<String, List<String>> headers = const {},
  Future<String?> Function()? onUnauthorized,
}) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler, headers);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com/subpath',
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
