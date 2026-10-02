import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const document =
    r'mutation CreateImmutable($input: createContainerProtectionTagRuleInput!) { createContainerProtectionTagRule(input: $input) { errors } }';
const variables = {
  'input': {
    'projectPath': 'team/app',
    'tagNamePattern': r'^v\d+.*$',
    'minimumAccessLevelForPush': null,
    'minimumAccessLevelForDelete': null,
  },
};
const body = {
  'data': {
    'createContainerProtectionTagRule': {'errors': []},
  },
};
typedef Reply = ({int status, Object? body});
GitLabClient client(
  Reply Function(RequestOptions) handler, {
  bool bearer = false,
  Future<String?> Function()? refresh,
}) {
  final dio = Dio()..httpClientAdapter = Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com/subpath/api/v4/',
    token: 'glpat-xxxxxxxxxxxx',
    bearer: bearer,
    onUnauthorized: refresh,
    dio: dio,
  );
}

Future<Map<String, dynamic>> mutate(GitLabClient c) => c.graphql.mutate(
  document: document,
  operationName: 'CreateImmutable',
  variables: variables,
);
void main() {
  for (final bearer in [false, true]) {
    test(
      'mutation uses account-bound routing/headers bearer=$bearer',
      () async {
        final c = client((r) {
          expect(r.method, 'POST');
          expect(r.followRedirects, isFalse);
          expect(
            r.uri.toString(),
            'https://gitlab.example.com/subpath/api/graphql',
          );
          expect(r.headers['Authorization'], 'Bearer glpat-xxxxxxxxxxxx');
          expect(r.headers.containsKey('PRIVATE-TOKEN'), isFalse);
          expect(r.queryParameters, isEmpty);
          expect(r.data, {
            'query': document,
            'operationName': 'CreateImmutable',
            'variables': variables,
          });
          return (status: 200, body: body);
        }, bearer: bearer);
        addTearDown(c.close);
        expect(await mutate(c), body['data']);
      },
    );
    test('mutation 401 never refreshes or replays bearer=$bearer', () async {
      var requests = 0;
      var refreshes = 0;
      final c = client(
        (_) {
          requests++;
          return (
            status: 401,
            body: {
              'errors': [
                {'message': 'private rejected token'},
              ],
            },
          );
        },
        bearer: bearer,
        refresh: () async {
          refreshes++;
          return 'refreshed-dummy';
        },
      );
      addTearDown(c.close);
      await expectLater(mutate(c), throwsA(isA<GitLabAuthException>()));
      expect(requests, 1);
      expect(refreshes, 0);
    });
  }
  for (final input in [
    '',
    'query CreateImmutable { currentUser { id } }',
    'subscription CreateImmutable { currentUser { id } }',
    '{ currentUser { id } }',
    'mutation Other { remove { id } }',
    'mutation CreateImmutableSuffix { remove { id } }',
  ]) {
    test('invalid selected mutation cannot reach network: $input', () async {
      var requests = 0;
      final c = client((_) {
        requests++;
        return (status: 200, body: body);
      });
      addTearDown(c.close);
      await expectLater(
        c.graphql.mutate(document: input, operationName: 'CreateImmutable'),
        throwsArgumentError,
      );
      expect(requests, 0);
    });
  }
  for (final status in [
    201,
    202,
    204,
    301,
    302,
    307,
    308,
    400,
    403,
    404,
    409,
    422,
    429,
    500,
  ]) {
    test('HTTP $status does not replay a mutation', () async {
      var requests = 0;
      final c = client((_) {
        requests++;
        return (status: status, body: {'private': 'details'});
      });
      addTearDown(c.close);
      await expectLater(
        mutate(c),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
      expect(requests, 1);
    });
  }
  for (final response in [
    null,
    [],
    {},
    {'data': null},
    {'data': []},
    {'data': {}, 'errors': null},
    {'data': {}, 'errors': 'private detail'},
    {
      ...body,
      'errors': [
        {'message': 'private detail'},
      ],
    },
  ]) {
    test(
      'malformed/partial response fails safely without retry: $response',
      () async {
        var requests = 0;
        final c = client((_) {
          requests++;
          return (status: 200, body: response);
        });
        addTearDown(c.close);
        await expectLater(
          mutate(c),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message.contains('private'),
              'private text',
              isFalse,
            ),
          ),
        );
        expect(requests, 1);
      },
    );
  }
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('$type cannot replay or leak mutation transport errors', () async {
      var requests = 0;
      final c = client((r) {
        requests++;
        throw DioException(
          requestOptions: r,
          type: type,
          message: 'private detail',
        );
      });
      addTearDown(c.close);
      await expectLater(
        mutate(c),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.message.contains('private'),
            'private text',
            isFalse,
          ),
        ),
      );
      expect(requests, 1);
    });
  }
  test(
    'rejected mutation does not disable later query/REST token refresh',
    () async {
      var requests = 0;
      var refreshes = 0;
      final c = client(
        (r) {
          requests++;
          if (r.headers['Authorization'] == 'Bearer glpat-xxxxxxxxxxxx') {
            return (status: 401, body: {});
          }
          return (
            status: 200,
            body: r.uri.path.endsWith('/graphql')
                ? {
                    'data': {
                      'currentUser': {'id': 'gid://gitlab/User/1'},
                    },
                  }
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
      await expectLater(mutate(c), throwsA(isA<GitLabAuthException>()));
      expect(refreshes, 0);
      await c.graphql.query(
        document: 'query CurrentUser { currentUser { id } }',
        operationName: 'CurrentUser',
      );
      await c.users.current();
      expect(refreshes, 1);
      expect(requests, 4);
    },
  );
  test(
    'domain mutation errors are returned for resource-specific validation',
    () async {
      final c = client(
        (_) => (
          status: 200,
          body: {
            'data': {
              'createContainerProtectionTagRule': {
                'errors': ['Rejected'],
              },
            },
          },
        ),
      );
      addTearDown(c.close);
      final result = await mutate(c);
      expect(result['createContainerProtectionTagRule']['errors'], [
        'Rejected',
      ]);
    },
  );
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final Reply Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions request,
    Stream<Uint8List>? stream,
    Future<dynamic>? cancel,
  ) async {
    final reply = handler(request);
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
