import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('does not invent a status from the requested value', () async {
    final client = _client(
      (_) => (
        status: 200,
        raw: false,
        body: {
          'id': 7,
          'name': 'app',
          'path_with_namespace': 'team/app',
          'container_expiration_policy': {'enabled': false},
        },
      ),
    );
    expect(
      (await client.projects.setCleanupPolicyDeletePattern(
        7,
        nameRegexDelete: 'v.+',
      )).containerExpirationPolicy!.enabled,
      isFalse,
    );
  });
  test('empty successful response is not a confirmed update', () async {
    final client = _client((_) => (status: 200, raw: false, body: null));
    await expectLater(
      client.projects.setCleanupPolicyDeletePattern(7, nameRegexDelete: '.*'),
      throwsA(isA<GitLabServerException>()),
    );
  });
  for (final nameRegexDelete in ['v.+', '.*', r'release\..+', ' release .+ ']) {
    test(
      'updates only name_regex_delete=$nameRegexDelete through encoded project PUT',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (
            status: 200,
            raw: false,
            body: {
              'id': 7,
              'name': 'app',
              'path_with_namespace': 'team/app',
              'container_expiration_policy': {
                'name_regex_delete': nameRegexDelete,
                'enabled': false,
                'cadence': '7d',
                'keep_n': 10,
              },
            },
          );
        });
        final project = await client.projects.setCleanupPolicyDeletePattern(
          'team/app',
          nameRegexDelete: nameRegexDelete,
        );
        expect(request.method, 'PUT');
        expect(request.path, '/projects/team%2Fapp');
        expect(request.contentType, Headers.jsonContentType);
        expect(request.data, {
          'container_expiration_policy_attributes': {
            'name_regex_delete': nameRegexDelete,
          },
        });
        expect(
          project.containerExpirationPolicy!.nameRegexDelete,
          nameRegexDelete,
        );
        expect(project.containerExpirationPolicy!.enabled, isFalse);
        expect(project.containerExpirationPolicy!.cadence, '7d');
        expect(project.containerExpirationPolicy!.keepN, 10);
      },
    );
  }
  for (final status in [202, 204, 400, 401, 403, 404, 422, 429, 500]) {
    test(
      'rejects delete pattern HTTP $status as a successful update',
      () async {
        final client = _client((_) => (status: status, raw: false, body: {}));
        await expectLater(
          client.projects.setCleanupPolicyDeletePattern(
            7,
            nameRegexDelete: '.*',
          ),
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
  test('maps transport failures without leaking Dio', () async {
    final client = _client(
      (options) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      client.projects.setCleanupPolicyDeletePattern(7, nameRegexDelete: 'v.+'),
      throwsA(isA<GitLabConnectionException>()),
    );
  });
}

GitLabClient _client(
  ({int status, Object? body, bool raw}) Function(RequestOptions) handler,
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
  final ({int status, Object? body, bool raw}) Function(RequestOptions) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    final payload = r.body == null
        ? ''
        : (r.raw ? r.body as String : json.encode(r.body));
    return ResponseBody.fromString(
      payload,
      r.status,
      headers: {
        Headers.contentTypeHeader: [
          r.raw ? 'text/plain' : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
