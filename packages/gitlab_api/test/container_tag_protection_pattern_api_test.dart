import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('preserves exact pattern text and does not send role fields', () async {
    final client = _client((options) {
      expect(options.data, {'tag_name_pattern': ' v*-stable '});
      return (
        status: 200,
        body: {
          'id': 2,
          'project_id': 7,
          'tag_name_pattern': ' v*-stable ',
          'minimum_access_level_for_push': null,
          'minimum_access_level_for_delete': 'future_role',
        },
      );
    });
    final rule = await client.containerRegistry.updateTagProtectionPattern(
      7,
      2,
      ' v*-stable ',
    );
    expect(rule.tagNamePattern, ' v*-stable ');
    expect(rule.minimumAccessLevelForPush, isNull);
    expect(rule.minimumAccessLevelForDelete, 'future_role');
  });
  for (final response in [
    null,
    [],
    <String, dynamic>{},
    {'id': 'invalid'},
  ]) {
    test(
      'malformed pattern update response maps to domain error $response',
      () async {
        final client = _client((_) => (status: 200, body: response));
        await expectLater(
          client.containerRegistry.updateTagProtectionPattern(
            7,
            2,
            'v*-stable',
          ),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  for (final projectId in [7, 'team/app']) {
    test(
      'updates only the tag protection pattern for encoded project $projectId',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (
            status: 200,
            body: {
              'id': 2,
              'project_id': 7,
              'tag_name_pattern': 'v*-stable',
              'minimum_access_level_for_push': 'maintainer',
              'minimum_access_level_for_delete': 'owner',
            },
          );
        });
        await client.containerRegistry.updateTagProtectionPattern(
          projectId,
          2,
          'v*-stable',
        );
        expect(request.method, 'PATCH');
        expect(
          request.path,
          '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/tag/rules/2',
        );
        expect(request.data, {'tag_name_pattern': 'v*-stable'});
        expect(request.queryParameters, isEmpty);
      },
    );
  }
  for (final status in [201, 202, 204, 400, 401, 403, 404, 422, 429, 500]) {
    test('rejects pattern update HTTP $status', () async {
      final client = _client((_) => (status: status, body: {}));
      await expectLater(
        client.containerRegistry.updateTagProtectionPattern(7, 2, 'v*-stable'),
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
      client.containerRegistry.updateTagProtectionPattern(7, 2, 'v*-stable'),
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
