import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

Map<String, Object?> _version() => {
  'id': 110,
  'base_commit_sha': 'base',
  'start_commit_sha': 'start',
  'head_commit_sha': 'head',
  'merge_request_id': 93958054,
  'state': 'collected',
  'real_size': '2',
};
Map<String, Object?> _file() => {
  'old_path': 'old.dart',
  'new_path': 'new.dart',
  'diff': '@@ -27,1 +29,1 @@\n-context\n+changed\n',
  'new_file': false,
  'deleted_file': false,
  'renamed_file': true,
  'collapsed': false,
  'too_large': false,
  'generated_file': false,
};
Future<MergeRequestDiffVersion> _read(GitLabClient c, String operation) async {
  if (operation == 'detail') {
    return c.mergeRequests.diffVersion(
      'group/project',
      iid: 142,
      versionId: 110,
    );
  }
  return (await c.mergeRequests.diffVersions(
    'group/project',
    iid: 142,
  )).items.single;
}

Object? _body(String operation, Object? value) =>
    operation == 'detail' ? value : [value];
void main() {
  for (final projectId in [8, 'group/project']) {
    for (final operation in ['list', 'detail']) {
      test(
        '$operation uses encoded project $projectId, IID and version identity',
        () async {
          late RequestOptions request;
          var calls = 0;
          final c = _client((o) {
            request = o;
            calls++;
            return (
              status: 200,
              body: _body(operation, {
                ..._version(),
                'diffs': [_file()],
              }),
            );
          });
          addTearDown(c.close);
          final v = operation == 'detail'
              ? await c.mergeRequests.diffVersion(
                  projectId,
                  iid: 142,
                  versionId: 110,
                )
              : (await c.mergeRequests.diffVersions(
                  projectId,
                  iid: 142,
                  page: 3,
                  perPage: 10,
                )).items.single;
          expect(
            request.path,
            '/projects/${Uri.encodeComponent('$projectId')}/merge_requests/142/versions${operation == 'detail' ? '/110' : ''}',
          );
          expect(request.method, 'GET');
          expect(request.baseUrl, 'https://gitlab.example.com/api/v4');
          expect(
            request.queryParameters,
            operation == 'detail'
                ? {'unidiff': true}
                : {'page': 3, 'per_page': 10},
          );
          expect(request.data, isNull);
          expect(calls, 1);
          expect(v.id, 110);
          expect(v.mergeRequestId, 93958054);
          expect(v.baseCommitSha, 'base');
          expect(v.startCommitSha, 'start');
          expect(v.headCommitSha, 'head');
          expect(v.files!.single.oldPath, 'old.dart');
          expect(v.files!.single.newPath, 'new.dart');
          expect(v.files!.single.diff, _file()['diff']);
          expect(v.files!.single.isRenamed, true);
        },
      );
    }
  }
  test(
    'list retains server order and headers without fetching ahead',
    () async {
      var calls = 0;
      final c = _client(
        (_) {
          calls++;
          return (
            status: 200,
            body: [
              _version(),
              {..._version(), 'id': 108, 'head_commit_sha': 'older'},
            ],
          );
        },
        headers: {
          'x-next-page': ['4'],
          'x-total': ['42'],
          'x-total-pages': ['5'],
        },
      );
      addTearDown(c.close);
      final page = await c.mergeRequests.diffVersions(8, iid: 142, page: 3);
      expect(page.items.map((v) => v.id), [110, 108]);
      expect(page.nextPage, 4);
      expect(page.total, 42);
      expect(page.totalPages, 5);
      expect(calls, 1);
      expect(() => page.items.clear(), throwsUnsupportedError);
    },
  );
  test('empty page can carry a next cursor with unknown totals', () async {
    var calls = 0;
    final c = _client(
      (_) {
        calls++;
        return (status: 200, body: []);
      },
      headers: {
        'x-next-page': ['5'],
      },
    );
    addTearDown(c.close);
    final page = await c.mergeRequests.diffVersions(8, iid: 142, page: 3);
    expect(page.items, isEmpty);
    expect(page.nextPage, 5);
    expect(page.total, isNull);
    expect(calls, 1);
  });
  for (final cursor in [null, '']) {
    test('missing or empty next cursor ends a page: $cursor', () async {
      final c = _client(
        (_) => (status: 200, body: []),
        headers: {
          if (cursor != null) 'x-next-page': [cursor],
        },
      );
      addTearDown(c.close);
      final page = await c.mergeRequests.diffVersions(8, iid: 142);
      expect(page.hasMore, false);
      expect(page.total, isNull);
    });
  }
  for (final cursor in ['private-content-marker', '0', '-1', '2', '2.5']) {
    test('rejects nonadvancing cursor $cursor', () async {
      final c = _client(
        (_) => (status: 200, body: []),
        headers: {
          'x-next-page': [cursor],
        },
      );
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.diffVersions(8, iid: 142, page: 2),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid diff versions pagination.',
          ),
        ),
      );
    });
  }
  for (final input in [
    ('list', 0, 1, 20, 110),
    ('detail', 0, 1, 20, 110),
    ('list', 142, 0, 20, 110),
    ('list', 142, 1, 0, 110),
    ('list', 142, 1, 101, 110),
    ('detail', 142, 1, 20, 0),
    ('detail', 142, 1, 20, -1),
  ]) {
    test('invalid request $input sends nothing', () async {
      var calls = 0;
      final c = _client((_) {
        calls++;
        return (status: 200, body: []);
      });
      addTearDown(c.close);
      await expectLater(
        input.$1 == 'detail'
            ? c.mergeRequests.diffVersion(8, iid: input.$2, versionId: input.$5)
            : c.mergeRequests.diffVersions(
                8,
                iid: input.$2,
                page: input.$3,
                perPage: input.$4,
              ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  final malformed = <String, Object?>{
    'null': null,
    'scalar': 'private-content-marker',
    'list': [],
    'missing ID': {},
    'zero ID': {'id': 0},
    'fractional ID': {'id': 110.5},
    'fractional global MR ID': {..._version(), 'merge_request_id': 93958054.5},
    'negative global MR ID': {..._version(), 'merge_request_id': -1},
    'invalid SHA': {..._version(), 'head_commit_sha': true},
    'invalid timestamp': {
      ..._version(),
      'created_at': 'private-content-marker',
    },
    'invalid state': {..._version(), 'state': 12},
    'numeric size': {..._version(), 'real_size': 2},
    'scalar files': {..._version(), 'diffs': 'private-content-marker'},
    'null file': {
      ..._version(),
      'diffs': [null],
    },
    'missing path': {
      ..._version(),
      'diffs': [
        {'new_path': 'new.dart'},
      ],
    },
    'wrong path': {
      ..._version(),
      'diffs': [
        {..._file(), 'old_path': true},
      ],
    },
    'invalid raw diff': {
      ..._version(),
      'diffs': [
        {..._file(), 'diff': 12},
      ],
    },
    'invalid mode': {
      ..._version(),
      'diffs': [
        {..._file(), 'a_mode': 100644},
      ],
    },
    'invalid file flag': {
      ..._version(),
      'diffs': [
        {..._file(), 'renamed_file': 'false'},
      ],
    },
    'invalid omission flag': {
      ..._version(),
      'diffs': [
        {..._file(), 'too_large': 'true'},
      ],
    },
  };
  for (final operation in ['list', 'detail']) {
    for (final entry in malformed.entries) {
      test('$operation rejects malformed ${entry.key}', () async {
        final c = _client(
          (_) => (status: 200, body: _body(operation, entry.value)),
        );
        addTearDown(c.close);
        await expectLater(
          _read(c, operation),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message,
              'sanitized',
              operation == 'detail'
                  ? 'Invalid merge request diff version response.'
                  : 'Invalid merge request diff versions response.',
            ),
          ),
        );
      });
    }
    for (final value in [
      null,
      <Map<String, Object?>>[],
      [
        {'old_path': 'image.png', 'new_path': 'image.png', 'diff': ''},
      ],
      [
        {'old_path': 'large.dart', 'new_path': 'large.dart', 'too_large': true},
      ],
      [
        {
          'old_path': 'collapsed.dart',
          'new_path': 'collapsed.dart',
          'collapsed': true,
        },
      ],
    ]) {
      test(
        '$operation preserves missing/empty/binary/omitted files $value',
        () async {
          final c = _client(
            (_) => (
              status: 200,
              body: _body(operation, {..._version(), 'diffs': value}),
            ),
          );
          addTearDown(c.close);
          final v = await _read(c, operation);
          expect(
            v.files?.map((f) => f.toJson()).toList(),
            value == null
                ? isNull
                : (value as List)
                      .map(
                        (f) => MergeRequestVersionFile.fromJson(
                          f as Map<String, dynamic>,
                        ).toJson(),
                      )
                      .toList(),
          );
        },
      );
    }
    test('$operation keeps sparse metadata unknown', () async {
      final c = _client(
        (_) => (status: 200, body: _body(operation, {'id': 110})),
      );
      addTearDown(c.close);
      final v = await _read(c, operation);
      expect(v.headCommitSha, isNull);
      expect(v.baseCommitSha, isNull);
      expect(v.startCommitSha, isNull);
      expect(v.files, isNull);
    });
    for (final status in [201, 401, 403, 404, 429, 500]) {
      test('$operation maps $status before malformed payload', () async {
        final c = _client(
          (_) => (status: status, body: 'private-content-marker'),
          headers: {
            'retry-after': ['17'],
          },
        );
        addTearDown(c.close);
        await expectLater(
          _read(c, operation),
          throwsA(switch (status) {
            401 => isA<GitLabAuthException>(),
            403 => isA<GitLabForbiddenException>(),
            404 => isA<GitLabNotFoundException>(),
            429 => isA<GitLabRateLimitException>().having(
              (e) => e.retryAfter,
              'retry after',
              const Duration(seconds: 17),
            ),
            _ => isA<GitLabServerException>().having(
              (e) => e.message,
              'HTTP context',
              isNot(contains('private-content-marker')),
            ),
          }),
        );
      });
    }
    test('$operation sanitizes transport failure', () async {
      final c = _client((o) {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
          error: 'private-content-marker',
        );
      });
      addTearDown(c.close);
      await expectLater(
        _read(c, operation),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.message,
            'sanitized',
            isNot(contains('private-content-marker')),
          ),
        ),
      );
    });
  }
  for (final payload in [null, <String, dynamic>{}, 'private-content-marker']) {
    test('list rejects a non-array top-level payload $payload', () async {
      final client = _client((_) => (status: 200, body: payload));
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.diffVersions(8, iid: 142),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid merge request diff versions response.',
          ),
        ),
      );
    });
  }
  test(
    'detail rejects a different returned version instead of falling back',
    () async {
      final c = _client((_) => (status: 200, body: {..._version(), 'id': 108}));
      addTearDown(c.close);
      await expectLater(
        _read(c, 'detail'),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid merge request diff version response.',
          ),
        ),
      );
    },
  );
  test('list rejects duplicate version IDs in a page', () async {
    final c = _client((_) => (status: 200, body: [_version(), _version()]));
    addTearDown(c.close);
    await expectLater(
      c.mergeRequests.diffVersions(8, iid: 142),
      throwsA(
        isA<GitLabServerException>().having(
          (e) => e.message,
          'sanitized',
          'Invalid merge request diff versions response.',
        ),
      ),
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
