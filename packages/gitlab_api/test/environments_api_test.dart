import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'lists filtered environments with encoded paths and pagination',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: {
            'x-next-page': ['3'],
          },
          body: [
            {
              'id': 9,
              'name': 'production',
              'state': 'available',
              'external_url': 'https://example.com',
            },
          ],
        );
      });

      final page = await client.environments.list(
        'team/app',
        state: 'available',
        search: 'prod',
        page: 2,
      );

      expect(request.path, '/projects/team%2Fapp/environments');
      expect(request.queryParameters['states'], 'available');
      expect(request.queryParameters['search'], 'prod');
      expect(request.queryParameters['page'], 2);
      expect(page.nextPage, 3);
      expect(page.items.single.name, 'production');
    },
  );

  test('gets environment detail and maps forbidden access', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: <String, List<String>>{},
        body: {
          'id': 9,
          'name': 'production',
          'state': 'available',
          'last_deployment': {'id': 42, 'status': 'success'},
        },
      );
    });

    final environment = await client.environments.get(7, 9);
    expect(request.path, '/projects/7/environments/9');
    expect(environment.lastDeployment?.id, 42);

    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.environments.list(7),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
}

GitLabClient _client(
  ({int status, Map<String, List<String>> headers, Object? body}) Function(
    RequestOptions,
  )
  handler,
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
