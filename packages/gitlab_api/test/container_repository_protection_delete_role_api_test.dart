import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  const original = {
    'id': 2,
    'project_id': 7,
    'repository_path_pattern': 'team/app/*',
    'minimum_access_level_for_push': 'admin',
  };
  for (final project in [7, 'team/app']) {
    for (final role in ['maintainer', 'owner', 'admin']) {
      test('PATCH only delete role for $project $role', () async {
        final client = _client((request) {
          expect(request.method, 'PATCH');
          expect(
            request.path,
            '/projects/${Uri.encodeComponent(project.toString())}/registry/protection/repository/rules/2',
          );
          expect(request.data, {'minimum_access_level_for_delete': role});
          expect(request.queryParameters, isEmpty);
          return (
            status: 200,
            body: {...original, 'minimum_access_level_for_delete': role},
          );
        });
        final rule = await client.containerRegistry
            .updateRepositoryProtectionDeleteRole(project, 2, role);
        expect(rule.minimumAccessLevelForDelete, role);
        expect(rule.repositoryPathPattern, 'team/app/*');
        expect(rule.minimumAccessLevelForPush, 'admin');
      });
    }
  }
  for (final body in [
    null,
    [],
    <String, dynamic>{},
    {...original, 'minimum_access_level_for_delete': 40},
  ]) {
    test('malformed 200 response maps to domain error $body', () async {
      final client = _client((_) => (status: 200, body: body));
      await expectLater(
        client.containerRegistry.updateRepositoryProtectionDeleteRole(
          7,
          2,
          'owner',
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final status in [201, 202, 204, 400, 401, 403, 404, 422, 429, 500]) {
    test('rejects role edit HTTP $status', () async {
      final client = _client((_) => (status: status, body: original));
      await expectLater(
        client.containerRegistry.updateRepositoryProtectionDeleteRole(
          7,
          2,
          'owner',
        ),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('transport errors become domain errors', () async {
    final client = _client(
      (r) => throw DioException(
        requestOptions: r,
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      client.containerRegistry.updateRepositoryProtectionDeleteRole(
        7,
        2,
        'owner',
      ),
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
