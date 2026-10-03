import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  for (final projectId in [7, 'team/app']) {
    test(
      'deletes only the repository protection rule for encoded project $projectId',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (status: 204, body: null);
        });
        await client.containerRegistry.deleteRepositoryProtectionRule(
          projectId,
          2,
        );
        expect(request.method, 'DELETE');
        expect(
          request.path,
          '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/repository/rules/2',
        );
        expect(request.data, isNull);
        expect(request.queryParameters, isEmpty);
      },
    );
  }
  for (final status in [200, 202, 400, 401, 403, 404, 422, 429, 500]) {
    test('rejects rule deletion HTTP $status', () async {
      final client = _client((_) => (status: status, body: {}));
      await expectLater(
        client.containerRegistry.deleteRepositoryProtectionRule(7, 2),
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
      client.containerRegistry.deleteRepositoryProtectionRule(7, 2),
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
