import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  for (final payload in <Map<String, dynamic>>[
    {},
    {'container_expiration_policy': null},
    {
      'container_expiration_policy': {'enabled': false},
    },
    {'container_expiration_policy': {}},
  ]) {
    test('policy snapshot preserves response presence $payload', () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          body: {
            'id': 7,
            'name': 'app',
            'path_with_namespace': 'team/app',
            ...payload,
          },
        );
      });
      final snapshot = await client.projects.cleanupPolicySnapshot('team/app');
      expect(request.method, 'GET');
      expect(request.path, '/projects/team%2Fapp');
      expect(
        snapshot.reported,
        payload.containsKey('container_expiration_policy'),
      );
      expect(
        snapshot.policy == null,
        payload['container_expiration_policy'] == null,
      );
    });
  }
  for (final enabled in [false, true]) {
    test(
      'creates policy with explicit activation $enabled and exact criteria',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (
            status: 200,
            body: {'id': 7, 'name': 'app', 'path_with_namespace': 'team/app'},
          );
        });
        await client.projects.createCleanupPolicy(
          'team/app',
          enabled: enabled,
          cadence: '1month',
          keepN: 100,
          olderThan: '365d',
          nameRegexDelete: r' release\..+ ',
          nameRegexKeep: '',
        );
        expect(request.method, 'PUT');
        expect(request.path, '/projects/team%2Fapp');
        expect(request.contentType, Headers.jsonContentType);
        expect(request.data, {
          'container_expiration_policy_attributes': {
            'enabled': enabled,
            'cadence': '1month',
            'keep_n': 100,
            'older_than': '365d',
            'name_regex_delete': r' release\..+ ',
            'name_regex_keep': '',
          },
        });
      },
    );
  }
  for (final status in [202, 204, 400, 401, 403, 404, 422, 429, 500]) {
    for (final read in [false, true]) {
      test(
        'rejects policy ${read ? "read" : "creation"} HTTP $status',
        () async {
          final client = _client((_) => (status: status, body: {}));
          final request = read
              ? client.projects.cleanupPolicySnapshot(7)
              : client.projects.createCleanupPolicy(
                  7,
                  enabled: true,
                  cadence: '7d',
                  keepN: 10,
                  olderThan: '14d',
                  nameRegexDelete: 'v.+',
                  nameRegexKeep: '.*',
                );
          await expectLater(
            request,
            throwsA(
              isA<GitLabException>().having(
                (e) => e.statusCode,
                'status',
                status,
              ),
            ),
          );
        },
      );
    }
  }
  for (final body in <Object>[
    [],
    'private malformed response',
    {'id': 'private'},
    {
      'id': 7,
      'name': 'app',
      'path_with_namespace': 'team/app',
      'container_expiration_policy': [],
    },
  ]) {
    test(
      'malformed creation response is a sanitized domain error $body',
      () async {
        final client = _client((_) => (status: 200, body: body));
        await expectLater(
          client.projects.createCleanupPolicy(
            7,
            enabled: true,
            cadence: '7d',
            keepN: 10,
            olderThan: '14d',
            nameRegexDelete: 'v.+',
            nameRegexKeep: '',
          ),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.toString().contains('private'),
              'sanitized',
              isFalse,
            ),
          ),
        );
      },
    );
  }
  for (final read in [false, true]) {
    test('empty policy response is not accepted read=$read', () async {
      final client = _client((_) => (status: 200, body: null));
      final request = read
          ? client.projects.cleanupPolicySnapshot(7)
          : client.projects.createCleanupPolicy(
              7,
              cadence: '7d',
              keepN: 10,
              olderThan: '14d',
              nameRegexDelete: 'v.+',
              nameRegexKeep: '.*',
            );
      await expectLater(request, throwsA(isA<GitLabServerException>()));
    });
    test('transport failure is mapped read=$read', () async {
      final client = _client(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
      final request = read
          ? client.projects.cleanupPolicySnapshot(7)
          : client.projects.createCleanupPolicy(
              7,
              cadence: '7d',
              keepN: 10,
              olderThan: '14d',
              nameRegexDelete: 'v.+',
              nameRegexKeep: '.*',
            );
      await expectLater(request, throwsA(isA<GitLabConnectionException>()));
    });
  }
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final ({int status, Object? body}) Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final result = handler(options);
    return ResponseBody.fromString(
      result.body == null ? '' : jsonEncode(result.body),
      result.status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
