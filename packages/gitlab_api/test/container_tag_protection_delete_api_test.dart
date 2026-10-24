import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  for (final project in [7, 'team/app']) {
    test('deletes exact tag rule for encoded project $project', () async {
      final client = clientFor((request) {
        expect(request.method, 'DELETE');
        expect(
          request.path,
          '/projects/${Uri.encodeComponent(project.toString())}/registry/protection/tag/rules/2',
        );
        expect(request.queryParameters, isEmpty);
        expect(request.data, isNull);
        return (204, null);
      });
      await client.containerRegistry.deleteTagProtectionRule(project, 2);
    });
  }
  for (final status in [
    200,
    201,
    202,
    400,
    401,
    403,
    404,
    409,
    422,
    429,
    500,
  ]) {
    test('rejects deletion HTTP $status', () async {
      final client = clientFor((_) => (status, {'message': 'private'}));
      await expectLater(
        client.containerRegistry.deleteTagProtectionRule(7, 2),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('transport failure becomes domain error', () async {
    final client = clientFor(
      (r) => throw DioException(
        requestOptions: r,
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      client.containerRegistry.deleteTagProtectionRule(7, 2),
      throwsA(isA<GitLabConnectionException>()),
    );
  });
}

GitLabClient clientFor((int, Object?) Function(RequestOptions) handler) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final (int, Object?) Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
