import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'lists effective group members with encoded path and pagination',
    () async {
      late RequestOptions request;
      final dio = Dio(
        BaseOptions(validateStatus: (status) => status != null && status < 500),
      );
      dio.httpClientAdapter = _Adapter((options) {
        request = options;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {
              'id': 11,
              'username': 'alex',
              'name': 'Alex Smith',
              'access_level': 30,
            },
          ],
        );
      });
      final client = GitLabClient(
        baseUrl: 'https://gitlab.example.com',
        token: 'glpat-xxxxxxxxxxxx',
        dio: dio,
      );

      final page = await client.groupMembers.list('team/core', query: 'alex');
      expect(request.path, '/groups/team%2Fcore/members/all');
      expect(request.queryParameters['query'], 'alex');
      expect(request.queryParameters['page'], 1);
      expect(page.nextPage, 2);
      expect(page.items.single.accessLevel, 30);
    },
  );

  test('maps forbidden group member response', () async {
    final dio = Dio(
      BaseOptions(validateStatus: (status) => status != null && status < 500),
    );
    dio.httpClientAdapter = _Adapter(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    final client = GitLabClient(
      baseUrl: 'https://gitlab.example.com',
      token: 'glpat-xxxxxxxxxxxx',
      dio: dio,
    );
    await expectLater(
      client.groupMembers.list(7),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final ({int status, Map<String, List<String>> headers, Object? body})
  Function(RequestOptions)
  handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    return ResponseBody.fromString(
      jsonEncode(result.body),
      result.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...result.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
