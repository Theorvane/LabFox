import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists deployments with encoded path, filters and pagination', () async {
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
            'id': 42,
            'iid': 2,
            'status': 'success',
            'environment': {'id': 9, 'name': 'production'},
          },
        ],
      );
    });

    final page = await client.deployments.list(
      'team/app',
      environment: 'production',
      status: 'success',
      page: 2,
    );

    expect(request.path, '/projects/team%2Fapp/deployments');
    expect(request.queryParameters['environment'], 'production');
    expect(request.queryParameters['status'], 'success');
    expect(request.queryParameters['order_by'], 'created_at');
    expect(request.queryParameters['sort'], 'desc');
    expect(request.queryParameters['page'], 2);
    expect(page.nextPage, 3);
    expect(page.items.single.iid, 2);
  });

  test(
    'gets deployment detail by global id and maps forbidden response',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: <String, List<String>>{},
          body: {'id': 42, 'status': 'success', 'deployable': null},
        );
      });

      final deployment = await client.deployments.get(7, 42);
      expect(request.path, '/projects/7/deployments/42');
      expect(deployment.id, 42);
      expect(deployment.deployable, isNull);

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.deployments.list(7),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );
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
