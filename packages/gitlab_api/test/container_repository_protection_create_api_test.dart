import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const body = {
  'id': 2,
  'project_id': 7,
  'repository_path_pattern': 'team/app-*',
  'minimum_access_level_for_push': 'owner',
  'minimum_access_level_for_delete': 'admin',
};
void main() {
  for (final response in [
    null,
    [],
    <String, dynamic>{},
    {...body, 'id': 'bad'},
  ]) {
    test(
      'malformed creation response becomes domain error: $response',
      () async {
        final client = clientFor((_) => (201, response));
        await expectLater(
          client.containerRegistry.createRepositoryProtectionRule(
            7,
            repositoryPathPattern: 'team/app-*',
            minimumAccessLevelForPush: 'owner',
          ),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  for (final project in [7, 'team/app']) {
    test('creates exact rule for encoded project $project', () async {
      late RequestOptions request;
      final client = clientFor((r) {
        request = r;
        return (201, body);
      });
      final result = await client.containerRegistry
          .createRepositoryProtectionRule(
            project,
            repositoryPathPattern: 'team/app-*',
            minimumAccessLevelForPush: 'owner',
            minimumAccessLevelForDelete: 'admin',
          );
      expect(request.method, 'POST');
      expect(
        request.path,
        '/projects/${Uri.encodeComponent(project.toString())}/registry/protection/repository/rules',
      );
      expect(request.queryParameters, isEmpty);
      expect(request.data, {
        'repository_path_pattern': 'team/app-*',
        'minimum_access_level_for_push': 'owner',
        'minimum_access_level_for_delete': 'admin',
      });
      expect(result.id, 2);
      expect(result.projectId, 7);
    });
  }
  for (final pushOnly in [true, false]) {
    test('omits the unselected role $pushOnly', () async {
      final client = clientFor((r) {
        expect(r.data, {
          'repository_path_pattern': ' x/* ',
          if (pushOnly)
            'minimum_access_level_for_push': 'maintainer'
          else
            'minimum_access_level_for_delete': 'maintainer',
        });
        return (
          201,
          {
            ...body,
            'repository_path_pattern': ' x/* ',
            'minimum_access_level_for_push': pushOnly ? 'maintainer' : null,
            'minimum_access_level_for_delete': pushOnly ? null : 'maintainer',
          },
        );
      });
      await client.containerRegistry.createRepositoryProtectionRule(
        7,
        repositoryPathPattern: ' x/* ',
        minimumAccessLevelForPush: pushOnly ? 'maintainer' : null,
        minimumAccessLevelForDelete: pushOnly ? null : 'maintainer',
      );
    });
  }
  for (final status in [
    200,
    202,
    204,
    400,
    401,
    403,
    404,
    409,
    422,
    429,
    500,
  ]) {
    test('rejects creation HTTP $status', () async {
      final client = clientFor((_) => (status, body));
      await expectLater(
        client.containerRegistry.createRepositoryProtectionRule(
          7,
          repositoryPathPattern: 'team/app-*',
          minimumAccessLevelForPush: 'owner',
        ),
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
      client.containerRegistry.createRepositoryProtectionRule(
        7,
        repositoryPathPattern: 'team/app-*',
        minimumAccessLevelForPush: 'owner',
      ),
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
