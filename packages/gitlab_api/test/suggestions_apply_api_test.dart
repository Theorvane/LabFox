import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const _payload = <String, Object?>{
  'id': 5,
  'from_line': 10,
  'to_line': 12,
  'from_content': '  original();\n',
  'to_content': '  reviewed();\n',
  'applicable': false,
  'applied': true,
};
void main() {
  for (final base in [
    'https://gitlab.example.com',
    'https://git.example.com/gitlab/',
  ]) {
    for (final bearer in [false, true]) {
      for (final message in <String?>[
        null,
        '',
        '  custom\n\nKeep whitespace.  ',
      ]) {
        test(
          'preserves routing authentication and commit message $base $bearer $message',
          () async {
            late RequestOptions request;
            var writes = 0;
            final client = _client(
              (o) {
                request = o;
                writes++;
                return (status: 200, body: _payload);
              },
              baseUrl: base,
              bearer: bearer,
            );
            addTearDown(client.close);
            final result = await client.suggestions.apply(
              5,
              commitMessage: message,
            );
            expect(request.path, '/suggestions/5/apply');
            expect(request.method, 'PUT');
            expect(
              request.uri.toString(),
              Uri.parse(base).path.startsWith('/gitlab')
                  ? 'https://git.example.com/gitlab/api/v4/suggestions/5/apply'
                  : 'https://gitlab.example.com/api/v4/suggestions/5/apply',
            );
            expect(request.queryParameters, isEmpty);
            expect(
              request.data,
              message == null
                  ? <String, Object?>{}
                  : {'commit_message': message},
            );
            expect(
              request.headers[bearer ? 'Authorization' : 'PRIVATE-TOKEN'],
              bearer ? 'Bearer glpat-xxxxxxxxxxxx' : 'glpat-xxxxxxxxxxxx',
            );
            expect(request.followRedirects, false);
            expect(request.extra['labfox_no_auth_retry'], true);
            expect(writes, 1);
            expect(result.id, 5);
            expect(result.applied, true);
            expect(result.patchApplicable, false);
            expect(result.fromContent, '  original();\n');
            expect(result.toContent, '  reviewed();\n');
          },
        );
      }
    }
  }
  for (final id in [0, -1]) {
    test('rejects global suggestion ID $id before dispatch', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 200, body: _payload);
      });
      addTearDown(client.close);
      await expectLater(client.suggestions.apply(id), throwsArgumentError);
      expect(writes, 0);
    });
  }
  final valid = <String, Map<String, Object?>>{
    'minimal applied confirmation': {'id': 5, 'applied': true},
    'null metadata': {
      'id': 5,
      'applied': true,
      'from_line': null,
      'to_line': null,
      'from_content': null,
      'to_content': null,
      'applicable': null,
      'appliable': null,
    },
    'legacy state': {..._payload, 'applicable': null, 'appliable': false},
    'matching aliases': {..._payload, 'appliable': false},
    'empty content': {..._payload, 'from_content': '', 'to_content': ''},
    'future fields': {
      ..._payload,
      'future': {'value': true},
    },
    'applied independent of applicability': {..._payload, 'applicable': true},
    'partial range': {..._payload, 'to_line': null},
  };
  for (final entry in valid.entries) {
    test('preserves confirmed ${entry.key}', () async {
      final client = _client((_) => (status: 200, body: entry.value));
      addTearDown(client.close);
      final s = await client.suggestions.apply(5);
      expect(s.id, 5);
      expect(s.applied, true);
      expect(s.fromLine, entry.value['from_line']);
      expect(s.toLine, entry.value['to_line']);
      expect(s.fromContent, entry.value['from_content']);
      expect(s.toContent, entry.value['to_content']);
      expect(s.applicable, entry.value['applicable']);
      expect(s.appliable, entry.value['appliable']);
    });
  }
  final malformed = <String, Object?>{
    'null': null,
    'scalar': 'private-content-marker',
    'list': [_payload],
    'empty': {},
    for (final value in [null, 0, -1, 5.5, '5', true, 6])
      'ID $value': {..._payload, 'id': value},
    for (final value in [null, false, 'true', 1])
      'applied $value': {..._payload, 'applied': value},
    for (final key in ['from_line', 'to_line'])
      for (final value in [0, -1, 10.5, '10', true])
        '$key $value': {..._payload, key: value},
    'reversed range': {..._payload, 'from_line': 13},
    for (final key in ['from_content', 'to_content'])
      for (final value in [
        1,
        true,
        ['code'],
        {'content': 'code'},
      ])
        '$key $value': {..._payload, key: value},
    for (final key in ['applicable', 'appliable'])
      for (final value in [1, 'false', [], {}])
        '$key $value': {..._payload, key: value},
    'conflicting aliases': {..._payload, 'appliable': true},
  };
  for (final entry in malformed.entries) {
    test(
      'rejects unconfirmed application ${entry.key} without replay',
      () async {
        var writes = 0;
        final client = _client((_) {
          writes++;
          return (status: 200, body: entry.value);
        });
        addTearDown(client.close);
        await expectLater(
          client.suggestions.apply(5),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message,
              'sanitized',
              'Invalid suggestion application response.',
            ),
          ),
        );
        expect(writes, 1);
      },
    );
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
    test('maps status $status before decoding and never replays', () async {
      var writes = 0;
      final client = _client(
        (_) {
          writes++;
          return (status: status, body: {'message': 'private-content-marker'});
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
        client.suggestions.apply(5),
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
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
    DioExceptionType.cancel,
  ]) {
    test('maps transport $type without replay', () async {
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
        client.suggestions.apply(5),
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
  test('OAuth failure never invokes refresh or replays application', () async {
    var writes = 0, refreshes = 0;
    final client = _client(
      (_) {
        writes++;
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
      client.suggestions.apply(5),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(writes, 1);
    expect(refreshes, 0);
  });
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
