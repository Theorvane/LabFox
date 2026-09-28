import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('deletes only the exact file in an encoded project package', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 204, headers: const {}, body: null);
    });
    await client.packages.deleteFile('team/project', 4, 9);
    expect(request.method, 'DELETE');
    expect(request.path, '/projects/team%2Fproject/packages/4/package_files/9');
    expect(request.data, isNull);
    expect(request.queryParameters, isEmpty);
  });
  for (final status in [200, 202, 401, 403, 404, 429, 500]) {
    test('maps rejected or unconfirmed file deletion $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.packages.deleteFile(7, 4, 9),
        throwsA(switch (status) {
          401 => isA<GitLabAuthException>(),
          403 => isA<GitLabForbiddenException>(),
          404 => isA<GitLabNotFoundException>(),
          429 => isA<GitLabRateLimitException>(),
          _ => isA<GitLabServerException>(),
        }),
      );
    });
  }
  test('lists packages with the next-page header and newest first', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: {
          'x-next-page': ['2'],
        },
        body: [
          {
            'id': 4,
            'name': '@team/tool',
            'version': '1.2.0',
            'package_type': 'npm',
            'created_at': '2026-09-01T12:00:00Z',
          },
        ],
      );
    });

    final result = await client.packages.list('team/project');

    expect(request.path, '/projects/team%2Fproject/packages');
    expect(request.queryParameters['order_by'], 'created_at');
    expect(request.queryParameters['sort'], 'desc');
    expect(result.nextPage, 2);
    expect(result.items.single.name, '@team/tool');
    expect(result.items.single.packageType, 'npm');
  });

  test('reads one package and its files', () async {
    final requests = <String>[];
    final client = _client((options) {
      requests.add(options.path);
      if (options.path.endsWith('/package_files')) {
        return (
          status: 200,
          headers: const <String, List<String>>{},
          body: [
            {'id': 9, 'package_id': 4, 'file_name': 'tool.tgz', 'size': 512},
          ],
        );
      }
      return (
        status: 200,
        headers: const <String, List<String>>{},
        body: {
          'id': 4,
          'name': '@team/tool',
          'version': '1.2.0',
          'package_type': 'npm',
        },
      );
    });

    final package = await client.packages.get(7, 4);
    final files = await client.packages.listFiles(7, 4);

    expect(requests, [
      '/projects/7/packages/4',
      '/projects/7/packages/4/package_files',
    ]);
    expect(package.version, '1.2.0');
    expect(files.items.single.fileName, 'tool.tgz');
    expect(files.items.single.size, 512);
  });

  test('maps forbidden package access', () async {
    final client = _client(
      (_) => (
        status: 403,
        headers: const <String, List<String>>{},
        body: const {},
      ),
    );

    await expectLater(
      client.packages.get(7, 4),
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
    baseUrl: 'https://example.com',
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
