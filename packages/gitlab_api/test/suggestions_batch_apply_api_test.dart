import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const _patch = <String, Object?>{
  'id': 5,
  'from_line': 10,
  'to_line': 12,
  'from_content': '  original();\n',
  'to_content': '  reviewed();\n',
  'applicable': false,
  'applied': true,
};
List<Map<String, Object?>> _payload() => [
  _patch,
  {..._patch, 'id': 6},
];
void main() {
  for (final base in [
    'https://gitlab.example.com',
    'https://git.example.com/gitlab/',
  ]) {
    for (final bearer in [false, true]) {
      for (final message in <String?>[null, '', '  Exact\nMessage  ']) {
        test(
          'batch routing auth and exact message $base $bearer $message',
          () async {
            late RequestOptions request;
            var writes = 0;
            final client = _client(
              (o) {
                request = o;
                writes++;
                return (status: 200, body: _payload());
              },
              baseUrl: base,
              bearer: bearer,
            );
            addTearDown(client.close);
            final result = await client.suggestions.applyBatch([
              5,
              6,
            ], commitMessage: message);
            expect(request.method, 'PUT');
            expect(request.path, '/suggestions/batch_apply');
            expect(
              request.uri.toString(),
              Uri.parse(base).path.startsWith('/gitlab')
                  ? 'https://git.example.com/gitlab/api/v4/suggestions/batch_apply'
                  : 'https://gitlab.example.com/api/v4/suggestions/batch_apply',
            );
            expect(request.queryParameters, isEmpty);
            expect(
              request.data,
              message == null
                  ? {
                      'ids': [5, 6],
                    }
                  : {
                      'ids': [5, 6],
                      'commit_message': message,
                    },
            );
            expect(
              request.headers[bearer ? 'Authorization' : 'PRIVATE-TOKEN'],
              bearer ? 'Bearer glpat-xxxxxxxxxxxx' : 'glpat-xxxxxxxxxxxx',
            );
            expect(request.followRedirects, false);
            expect(request.extra['labfox_no_auth_retry'], true);
            expect(writes, 1);
            expect(result.map((s) => s.id), [5, 6]);
            expect(result.every((s) => s.applied == true), true);
            expect(result.first.fromContent, _patch['from_content']);
            expect(result.last.toContent, _patch['to_content']);
            expect(result.first.patchApplicable, false);
            expect(() => result.clear(), throwsUnsupportedError);
          },
        );
      }
    }
  }
  for (final ids in <List<int>>[
    [],
    [0],
    [-1],
    [5, 0],
    [5, -1],
    [5, 5],
    [6, 5, 6],
    [5, 6, 0],
  ]) {
    test('invalid batch IDs reject before dispatch $ids', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 200, body: _payload());
      });
      addTearDown(client.close);
      await expectLater(
        client.suggestions.applyBatch(ids),
        throwsArgumentError,
      );
      expect(writes, 0);
    });
  }
  for (final ids in [
    [5, 6],
    [6, 5],
  ]) {
    test(
      'accepts reordered complete response and preserves server order $ids',
      () async {
        final client = _client(
          (_) => (status: 200, body: _payload().reversed.toList()),
        );
        addTearDown(client.close);
        final result = await client.suggestions.applyBatch(ids);
        expect(result.map((s) => s.id), [6, 5]);
        expect(ids, ids.first == 5 ? [5, 6] : [6, 5]);
      },
    );
  }
  test(
    'one suggestion uses the batch endpoint without inventing minimum count',
    () async {
      late RequestOptions request;
      final client = _client((o) {
        request = o;
        return (status: 200, body: [_patch]);
      });
      addTearDown(client.close);
      final result = await client.suggestions.applyBatch([5]);
      expect(result.single.id, 5);
      expect(request.path, '/suggestions/batch_apply');
      expect(request.data, {
        'ids': [5],
      });
    },
  );
  for (final mutation in [0, 1, 2]) {
    test(
      'snapshots caller IDs before asynchronous dispatch mutation=$mutation',
      () async {
        final ids = [5, 6];
        late RequestOptions request;
        final client = _client((o) {
          request = o;
          return (status: 200, body: _payload());
        });
        addTearDown(client.close);
        final future = client.suggestions.applyBatch(ids);
        switch (mutation) {
          case 0:
            ids.clear();
          case 1:
            ids[0] = 99;
          case 2:
            ids.add(7);
        }
        final result = await future;
        expect(request.data, {
          'ids': [5, 6],
        });
        expect(result.map((s) => s.id), [5, 6]);
      },
    );
  }
  final valid = <String, Map<String, Object?>>{
    'sparse': {'id': 5, 'applied': true},
    'null metadata': {
      'id': 5,
      'applied': true,
      'from_line': null,
      'to_line': null,
      'from_content': null,
      'to_content': null,
      'appliable': null,
      'applicable': null,
    },
    'legacy alias': {..._patch, 'applicable': null, 'appliable': false},
    'matching aliases': {..._patch, 'appliable': false},
    'empty content': {..._patch, 'from_content': '', 'to_content': ''},
    'future fields': {
      ..._patch,
      'future': {'value': true},
    },
    'applied independent of applicability': {..._patch, 'applicable': true},
    'partial range': {..._patch, 'to_line': null},
  };
  for (final entry in valid.entries) {
    test('preserves confirmed batch nullable metadata ${entry.key}', () async {
      final client = _client(
        (_) => (
          status: 200,
          body: [
            entry.value,
            {'id': 6, 'applied': true},
          ],
        ),
      );
      addTearDown(client.close);
      final result = await client.suggestions.applyBatch([5, 6]);
      final s = result.first;
      expect(s.fromLine, entry.value['from_line']);
      expect(s.toLine, entry.value['to_line']);
      expect(s.fromContent, entry.value['from_content']);
      expect(s.toContent, entry.value['to_content']);
      expect(s.applied, true);
      expect(s.applicable, entry.value['applicable']);
      expect(s.appliable, entry.value['appliable']);
      expect(result.last.fromContent, isNull);
    });
  }
  final invalidShapes = <String, Object?>{
    'null': null,
    'scalar': 'private-content-marker',
    'object': _patch,
    'empty': [],
    'missing one': [_patch],
    'unrequested extra': [
      ..._payload(),
      {..._patch, 'id': 7},
    ],
    'duplicate': [_patch, _patch],
    'unexpected ID': [
      _patch,
      {..._patch, 'id': 7},
    ],
    'nested array': [
      _patch,
      [
        {..._patch, 'id': 6},
      ],
    ],
    'null member': [_patch, null],
    'scalar member': [_patch, 'private-content-marker'],
    'missing identity': [
      _patch,
      {'applied': true},
    ],
  };
  for (final entry in invalidShapes.entries) {
    test('rejects incomplete or ambiguous batch shape ${entry.key}', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 200, body: entry.value);
      });
      addTearDown(client.close);
      await expectLater(
        client.suggestions.applyBatch([5, 6]),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid suggestion batch application response.',
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  final mutations = <String, Map<String, Object?>>{
    for (final v in [null, 0, -1, 5.5, '5', true, 7]) 'id $v': {'id': v},
    for (final v in [null, false, 'true', 1]) 'applied $v': {'applied': v},
    for (final key in ['from_line', 'to_line'])
      for (final v in [0, -1, 10.5, '10', true]) '$key $v': {key: v},
    'reversed range': {'from_line': 13},
    for (final key in ['from_content', 'to_content'])
      for (final v in [
        1,
        true,
        ['code'],
        {'content': 'code'},
      ])
        '$key $v': {key: v},
    for (final key in ['applicable', 'appliable'])
      for (final v in [1, 'false', [], {}]) '$key $v': {key: v},
    'conflicting aliases': {'appliable': true},
  };
  for (final index in [0, 1]) {
    for (final entry in mutations.entries) {
      test(
        'validates every returned batch member $index ${entry.key}',
        () async {
          final payload = _payload();
          payload[index] = {...payload[index], ...entry.value};
          var writes = 0;
          final client = _client((_) {
            writes++;
            return (status: 200, body: payload);
          });
          addTearDown(client.close);
          await expectLater(
            client.suggestions.applyBatch([5, 6]),
            throwsA(
              isA<GitLabServerException>().having(
                (e) => e.message,
                'sanitized',
                'Invalid suggestion batch application response.',
              ),
            ),
          );
          expect(writes, 1);
        },
      );
    }
  }
  for (final status in [
    201,
    202,
    204,
    301,
    302,
    303,
    307,
    308,
    400,
    401,
    403,
    404,
    409,
    422,
    429,
    500,
    502,
    503,
  ]) {
    test(
      'maps batch status $status before payload decoding without replay',
      () async {
        var writes = 0;
        final client = _client(
          (_) {
            writes++;
            return (
              status: status,
              body: {'message': 'private-content-marker'},
            );
          },
          headers: {
            'retry-after': ['17'],
            'location': ['https://other.example.com/write'],
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
          client.suggestions.applyBatch([5, 6]),
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
      },
    );
  }
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
    DioExceptionType.cancel,
  ]) {
    test('batch transport $type is typed and never replayed', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        throw DioException(
          requestOptions: o,
          type: type,
          error: 'private-content-marker',
        );
      });
      addTearDown(client.close);
      await expectLater(
        client.suggestions.applyBatch([5, 6]),
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
    'OAuth batch failure never refreshes or falls back to single writes',
    () async {
      var writes = 0, refreshes = 0;
      final paths = <String>[];
      final client = _client(
        (o) {
          writes++;
          paths.add(o.path);
          return (status: 401, body: {});
        },
        bearer: true,
        onUnauthorized: () async {
          refreshes++;
          return 'dummy-refreshed-token';
        },
      );
      addTearDown(client.close);
      await expectLater(
        client.suggestions.applyBatch([5, 6]),
        throwsA(isA<GitLabAuthException>()),
      );
      expect(writes, 1);
      expect(refreshes, 0);
      expect(paths, ['/suggestions/batch_apply']);
    },
  );
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  String baseUrl = 'https://gitlab.example.com',
  bool bearer = false,
  Map<String, List<String>> headers = const {},
  Future<String?> Function()? onUnauthorized,
}) {
  final dio = Dio()..httpClientAdapter = _Adapter(handler, headers);
  return GitLabClient(
    baseUrl: baseUrl,
    token: 'glpat-xxxxxxxxxxxx',
    bearer: bearer,
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
