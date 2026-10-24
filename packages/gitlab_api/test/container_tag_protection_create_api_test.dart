import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const body = {
  'id': 2,
  'project_id': 7,
  'tag_name_pattern': 'v*-release',
  'minimum_access_level_for_push': 'owner',
  'minimum_access_level_for_delete': 'admin',
};
void main() {
  for (final project in [7, 'team/app']) {
    for (final push in ['maintainer', 'owner', 'admin']) {
      for (final delete in ['maintainer', 'owner', 'admin']) {
        test(
          'POST encoded project $project with both roles $push/$delete',
          () async {
            final client = clientFor((r) {
              expect(r.method, 'POST');
              expect(
                r.path,
                '/projects/${Uri.encodeComponent(project.toString())}/registry/protection/tag/rules',
              );
              expect(r.queryParameters, isEmpty);
              expect(r.data, {
                'tag_name_pattern': ' v*-release ',
                'minimum_access_level_for_push': push,
                'minimum_access_level_for_delete': delete,
              });
              return (
                201,
                {
                  ...body,
                  'tag_name_pattern': ' v*-release ',
                  'minimum_access_level_for_push': push,
                  'minimum_access_level_for_delete': delete,
                },
              );
            });
            final result = await client.containerRegistry
                .createTagProtectionRule(
                  project,
                  tagNamePattern: ' v*-release ',
                  minimumAccessLevelForPush: push,
                  minimumAccessLevelForDelete: delete,
                );
            expect(result.tagNamePattern, ' v*-release ');
            expect(result.minimumAccessLevelForPush, push);
            expect(result.minimumAccessLevelForDelete, delete);
          },
        );
      }
    }
  }
  for (final response in [
    null,
    [],
    <String, dynamic>{},
    {...body, 'id': 'bad'},
    {...body, 'minimum_access_level_for_push': 40},
    {...body, 'minimum_access_level_for_delete': 40},
  ]) {
    test('malformed response becomes safe domain error $response', () async {
      final client = clientFor((_) => (201, response));
      await expectLater(
        client.containerRegistry.createTagProtectionRule(
          7,
          tagNamePattern: 'v*-release',
          minimumAccessLevelForPush: 'owner',
          minimumAccessLevelForDelete: 'admin',
        ),
        throwsA(isA<GitLabServerException>()),
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
    test('rejects create HTTP $status', () async {
      final client = clientFor((_) => (status, body));
      await expectLater(
        client.containerRegistry.createTagProtectionRule(
          7,
          tagNamePattern: 'v*-release',
          minimumAccessLevelForPush: 'owner',
          minimumAccessLevelForDelete: 'admin',
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
      client.containerRegistry.createTagProtectionRule(
        7,
        tagNamePattern: 'v*-release',
        minimumAccessLevelForPush: 'owner',
        minimumAccessLevelForDelete: 'admin',
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
