import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const query =
    r'query RegistryRules($path: ID!) { project(fullPath: $path) { id } }';
const payload = {
  'data': {'project': null},
};
typedef Reply = ({int status, Object? body});

GitLabClient client(
  Reply Function(RequestOptions) handler, {
  String baseUrl = 'https://gitlab.example.com',
  bool bearer = false,
  Future<String?> Function()? refresh,
}) {
  final dio = Dio()..httpClientAdapter = Adapter(handler);
  return GitLabClient(
    baseUrl: baseUrl,
    token: 'glpat-xxxxxxxxxxxx',
    bearer: bearer,
    onUnauthorized: refresh,
    dio: dio,
  );
}

Future<Map<String, dynamic>> read(GitLabClient c) => c.graphql.query(
  document: query,
  operationName: 'RegistryRules',
  variables: {'path': 'team/app'},
);

void main() {
  for (final entry in {
    'https://gitlab.example.com': 'https://gitlab.example.com/api/graphql',
    'https://gitlab.example.com///': 'https://gitlab.example.com/api/graphql',
    'https://gitlab.example.com/gitlab':
        'https://gitlab.example.com/gitlab/api/graphql',
    'https://gitlab.example.com/gitlab/api/v4/':
        'https://gitlab.example.com/gitlab/api/graphql',
  }.entries) {
    for (final bearer in [false, true]) {
      test(
        'query routing and header isolation ${entry.key} bearer=$bearer',
        () async {
          final requests = <RequestOptions>[];
          final c = client(
            (r) {
              requests.add(r);
              return (
                status: 200,
                body: r.uri.path.endsWith('/graphql')
                    ? payload
                    : {'id': 1, 'username': 'user', 'name': 'User'},
              );
            },
            baseUrl: entry.key,
            bearer: bearer,
          );
          addTearDown(c.close);
          expect(await read(c), {'project': null});
          final request = requests.single;
          expect(request.uri.toString(), entry.value);
          expect(request.method, 'POST');
          expect(request.queryParameters, isEmpty);
          expect(request.data, {
            'query': query,
            'operationName': 'RegistryRules',
            'variables': {'path': 'team/app'},
          });
          expect(request.headers['Authorization'], 'Bearer glpat-xxxxxxxxxxxx');
          expect(request.headers.containsKey('PRIVATE-TOKEN'), isFalse);
          expect(request.contentType, Headers.jsonContentType);
          await c.users.current();
          final rest = requests.last;
          expect(
            rest.uri.path,
            entry.value
                .replaceFirst('/api/graphql', '/api/v4/user')
                .substring('https://gitlab.example.com'.length),
          );
          expect(
            rest.headers[bearer ? 'Authorization' : 'PRIVATE-TOKEN'],
            bearer ? 'Bearer glpat-xxxxxxxxxxxx' : 'glpat-xxxxxxxxxxxx',
          );
          expect(
            rest.headers.containsKey(
              bearer ? 'PRIVATE-TOKEN' : 'Authorization',
            ),
            isFalse,
          );
        },
      );
    }
  }
  for (final document in [
    '',
    'mutation RegistryRules { remove { id } }',
    'subscription RegistryRules { project { id } }',
    '{ currentUser { id } }',
    'query Other { currentUser { id } }',
    'query RegistryRulesSuffix { currentUser { id } }',
  ]) {
    test('unsupported operation cannot reach network: $document', () async {
      var requests = 0;
      final c = client((_) {
        requests++;
        return (status: 200, body: payload);
      });
      addTearDown(c.close);
      await expectLater(
        c.graphql.query(document: document, operationName: 'RegistryRules'),
        throwsArgumentError,
      );
      expect(requests, 0);
    });
  }
  test(
    'selects named query explicitly even with another operation present',
    () async {
      const document = '$query mutation Other { remove { id } }';
      final c = client((r) {
        expect(r.data['operationName'], 'RegistryRules');
        expect(r.data['query'], document);
        return (status: 200, body: payload);
      });
      addTearDown(c.close);
      expect(
        await c.graphql.query(
          document: document,
          operationName: 'RegistryRules',
        ),
        {'project': null},
      );
    },
  );
  for (final body in [
    null,
    [],
    'private detail',
    {},
    {'data': null},
    {'data': []},
    {'data': {}, 'errors': null},
    {'data': {}, 'errors': 'private detail'},
    {
      'data': {},
      'errors': [
        {'message': 'private schema detail'},
      ],
    },
    {
      'errors': [
        {'message': 'private schema detail'},
      ],
    },
    {
      'data': {
        'project': {'id': 'partial'},
      },
      'errors': [
        {'message': 'private detail'},
      ],
    },
  ]) {
    test(
      'malformed or partial success is a sanitized domain error $body',
      () async {
        final c = client((_) => (status: 200, body: body));
        addTearDown(c.close);
        await expectLater(
          read(c),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message.contains('private'),
              'private text',
              isFalse,
            ),
          ),
        );
      },
    );
  }
  test(
    'empty error list and null resource stay distinct from failure',
    () async {
      final c = client((_) => (status: 200, body: {...payload, 'errors': []}));
      addTearDown(c.close);
      expect(await read(c), {'project': null});
    },
  );
  for (final status in [201, 202, 204, 400, 401, 403, 404, 422, 429, 500]) {
    test('HTTP $status remains a typed failure', () async {
      final c = client((_) => (status: status, body: {'private': 'detail'}));
      addTearDown(c.close);
      await expectLater(
        read(c),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('$type does not leak raw transport details', () async {
      final c = client(
        (r) => throw DioException(
          requestOptions: r,
          type: type,
          message: 'private detail',
        ),
      );
      addTearDown(c.close);
      await expectLater(
        read(c),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.message.contains('private'),
            'private text',
            isFalse,
          ),
        ),
      );
    });
  }
  test('OAuth refresh applies to query and subsequent REST calls', () async {
    var refreshes = 0;
    final requests = <RequestOptions>[];
    final c = client(
      (r) {
        requests.add(r);
        if (r.headers['Authorization'] == 'Bearer glpat-xxxxxxxxxxxx') {
          return (
            status: 401,
            body: {
              'errors': [
                {'message': 'private invalid token'},
              ],
            },
          );
        }
        expect(r.headers['Authorization'], 'Bearer refreshed-dummy');
        return (
          status: 200,
          body: r.uri.path.endsWith('/graphql')
              ? payload
              : {'id': 1, 'username': 'user', 'name': 'User'},
        );
      },
      bearer: true,
      refresh: () async {
        refreshes++;
        return 'refreshed-dummy';
      },
    );
    addTearDown(c.close);
    expect(await read(c), {'project': null});
    await c.users.current();
    expect(refreshes, 1);
    expect(requests, hasLength(3));
    expect(
      requests.every((r) => !r.headers.containsKey('PRIVATE-TOKEN')),
      isTrue,
    );
  });
  test('rejected refreshed token retries only once', () async {
    var requests = 0;
    var refreshes = 0;
    final c = client(
      (_) {
        requests++;
        return (status: 401, body: payload);
      },
      bearer: true,
      refresh: () async {
        refreshes++;
        return 'refreshed-dummy';
      },
    );
    addTearDown(c.close);
    await expectLater(read(c), throwsA(isA<GitLabAuthException>()));
    expect(requests, 2);
    expect(refreshes, 1);
  });
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final Reply Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final reply = handler(options);
    return ResponseBody.fromString(
      reply.body == null ? '' : jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
