import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

Map<String, Object?> _thread({
  Object? notes = const [
    {
      'id': 301,
      'body': 'Review',
      'type': 'DiscussionNote',
      'resolvable': true,
      'resolved': false,
    },
  ],
}) => {'id': 'thread-1', 'individual_note': false, 'notes': notes};
void main() {
  test('reads one MR discussion page using project path and IID', () async {
    late RequestOptions request;
    final client = _client((o) {
      request = o;
      return (
        status: 200,
        body: [
          _thread(),
          {
            'id': 'single-2',
            'individual_note': true,
            'notes': [
              {'id': 302, 'body': 'System event', 'system': true},
            ],
          },
        ],
      );
    });
    addTearDown(client.close);
    final page = await client.mergeRequests.discussions(
      'group/project',
      iid: 142,
      page: 3,
      perPage: 10,
    );
    expect(
      request.path,
      '/projects/group%2Fproject/merge_requests/142/discussions',
    );
    expect(request.method, 'GET');
    expect(request.queryParameters, {'page': 3, 'per_page': 10});
    expect(request.baseUrl, 'https://gitlab.example.com/api/v4');
    expect(page.items.map((d) => d.id), ['thread-1', 'single-2']);
    expect(page.items.first.notes.single.resolved, false);
    expect(page.items.last.notes.single.isSystem, true);
    expect(page.total, isNull);
    expect(page.nextPage, isNull);
    expect(() => page.items.clear(), throwsUnsupportedError);
  });
  test(
    'preserves next cursor on an empty page without fetching ahead',
    () async {
      var requests = 0;
      final client = _client(
        (o) {
          requests++;
          return (status: 200, body: []);
        },
        headers: {
          'x-next-page': ['5'],
        },
      );
      addTearDown(client.close);
      final page = await client.mergeRequests.discussions(8, iid: 142, page: 3);
      expect(page.items, isEmpty);
      expect(page.nextPage, 5);
      expect(page.hasMore, true);
      expect(page.total, isNull);
      expect(requests, 1);
    },
  );
  test('preserves totals when present and ends on an empty cursor', () async {
    final client = _client(
      (o) => (status: 200, body: [_thread()]),
      headers: {
        'x-next-page': [''],
        'x-total': ['42'],
        'x-total-pages': ['3'],
      },
    );
    addTearDown(client.close);
    final page = await client.mergeRequests.discussions(8, iid: 142);
    expect(page.total, 42);
    expect(page.totalPages, 3);
    expect(page.hasMore, false);
  });
  for (final cursor in ['private-content-marker', '0', '-1', '2', '3.5']) {
    test('rejects invalid or nonadvancing cursor $cursor', () async {
      final client = _client(
        (o) => (status: 200, body: [_thread()]),
        headers: {
          'x-next-page': [cursor],
        },
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.discussions(8, iid: 142, page: 2),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized message',
            'Invalid discussions pagination.',
          ),
        ),
      );
    });
  }
  for (final options in [(0, 20), (1, 0), (1, 101)]) {
    test('rejects invalid paging parameters $options before sending', () async {
      var requests = 0;
      final client = _client((o) {
        requests++;
        return (status: 200, body: []);
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.discussions(
          8,
          iid: 142,
          page: options.$1,
          perPage: options.$2,
        ),
        throwsArgumentError,
      );
      expect(requests, 0);
    });
  }
  final malformed = <String, Object?>{
    'null': null,
    'object': {},
    'scalar': 'private-content-marker',
    'null thread': [null],
    'missing fields': [{}],
    'empty thread ID': [
      {..._thread(), 'id': ''},
    ],
    'invalid individual flag': [
      {..._thread(), 'individual_note': 'false'},
    ],
    'missing notes': [
      {'id': 'thread-1', 'individual_note': false},
    ],
    'null notes': [_thread(notes: null)],
    'object notes': [_thread(notes: {})],
    'null note': [
      _thread(notes: [null]),
    ],
    'missing body': [
      _thread(
        notes: [
          {'id': 301},
        ],
      ),
    ],
    'fractional note ID': [
      _thread(
        notes: [
          {'id': 301.5, 'body': 'Review'},
        ],
      ),
    ],
    'zero note ID': [
      _thread(
        notes: [
          {'id': 0, 'body': 'Review'},
        ],
      ),
    ],
    'invalid resolution': [
      _thread(
        notes: [
          {'id': 301, 'body': 'Review', 'resolved': 'false'},
        ],
      ),
    ],
    'invalid timestamp': [
      _thread(
        notes: [
          {'id': 301, 'body': 'Review', 'updated_at': 'private-content-marker'},
        ],
      ),
    ],
    'invalid author': [
      _thread(
        notes: [
          {
            'id': 301,
            'body': 'Review',
            'author': {'id': 7},
          },
        ],
      ),
    ],
    'fractional author ID': [
      _thread(
        notes: [
          {
            'id': 301,
            'body': 'Review',
            'author': {'id': 7.5, 'username': 'reviewer', 'name': 'Reviewer'},
          },
        ],
      ),
    ],
    'negative resolver ID': [
      _thread(
        notes: [
          {
            'id': 301,
            'body': 'Review',
            'resolved_by': {
              'id': -7,
              'username': 'reviewer',
              'name': 'Reviewer',
            },
          },
        ],
      ),
    ],
    'mixed valid and invalid': [_thread(), {}],
  };
  for (final entry in malformed.entries) {
    test('rejects incomplete discussion page: ${entry.key}', () async {
      final client = _client((_) => (status: 200, body: entry.value));
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.discussions(8, iid: 142),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized message',
            'Invalid discussions response.',
          ),
        ),
      );
    });
  }
  for (final status in [401, 403, 404, 429, 500]) {
    test('maps HTTP $status before decoding discussion payload', () async {
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
        client.mergeRequests.discussions(8, iid: 142),
        throwsA(matcher),
      );
    });
  }
  test('accepts explicit empty discussion pages', () async {
    final client = _client((_) => (status: 200, body: []));
    addTearDown(client.close);
    expect(
      (await client.mergeRequests.discussions(8, iid: 142)).items,
      isEmpty,
    );
  });
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  Map<String, List<String>> headers = const {},
}) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler, headers);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler, this.headers);
  final Map<String, List<String>> headers;
  final ({int status, Object? body}) Function(RequestOptions) handler;

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
