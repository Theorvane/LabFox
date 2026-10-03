import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  for (final projectId in [7, 'team/app']) {
    test('clears only keep pattern for encoded project $projectId', () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          body: {
            'id': 7,
            'name': 'app',
            'path_with_namespace': 'team/app',
            'container_expiration_policy': {
              'enabled': false,
              'name_regex_keep': '',
              'name_regex_delete': 'release.+',
            },
          },
        );
      });
      final project = await client.projects.clearCleanupPolicyKeepPattern(
        projectId,
      );
      expect(request.method, 'PUT');
      expect(
        request.path,
        '/projects/${Uri.encodeComponent(projectId.toString())}',
      );
      expect(request.contentType, Headers.jsonContentType);
      expect(request.data, {
        'container_expiration_policy_attributes': {'name_regex_keep': ''},
      });
      expect(project.containerExpirationPolicy!.nameRegexKeep, '');
      expect(project.containerExpirationPolicy!.enabled, isFalse);
      expect(project.containerExpirationPolicy!.nameRegexDelete, 'release.+');
    });
  }
  test('missing response is not an accepted update', () async {
    final client = _client((_) => (status: 200, body: null));
    await expectLater(
      client.projects.clearCleanupPolicyKeepPattern(7),
      throwsA(isA<GitLabServerException>()),
    );
  });
  for (final status in [202, 204, 400, 401, 403, 404, 422, 429, 500]) {
    test('rejects clear HTTP $status', () async {
      final client = _client((_) => (status: status, body: {}));
      await expectLater(
        client.projects.clearCleanupPolicyKeepPattern(7),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('transport errors do not leak Dio', () async {
    final client = _client(
      (options) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      client.projects.clearCleanupPolicyKeepPattern(7),
      throwsA(isA<GitLabConnectionException>()),
    );
  });
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
