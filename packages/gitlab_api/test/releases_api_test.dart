import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists releases with pagination and parses assets', () async {
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
            'name': 'Version 1',
            'tag_name': 'v1',
            'description': 'Changes',
            'released_at': '2026-01-02T00:00:00Z',
            'assets': {
              'links': [
                {'id': 4, 'name': 'Binary', 'url': 'https://example.com/bin'},
              ],
              'sources': [],
            },
          },
        ],
      );
    });
    final page = await client.releases.list('team/app');
    expect(request.path, '/projects/team%2Fapp/releases');
    expect(request.queryParameters['page'], 1);
    expect(page.nextPage, 2);
    expect(page.items.single.assets?.links.single.name, 'Binary');
  });

  test('gets a release by URL-encoded tag and maps 404', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: <String, List<String>>{},
        body: {'name': 'Version 1', 'tag_name': 'release/1'},
      );
    });
    final release = await client.releases.get(7, 'release/1');
    expect(request.path, '/projects/7/releases/release%2F1');
    expect(release.tagName, 'release/1');

    final missing = _client(
      (_) => (status: 404, headers: const {}, body: const {}),
    );
    await expectLater(
      missing.releases.get(7, 'missing'),
      throwsA(isA<GitLabNotFoundException>()),
    );
  });

  test('creates a release with optional ref and Markdown notes', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 201,
        headers: const <String, List<String>>{},
        body: {
          'name': 'Version 2',
          'tag_name': 'release/2',
          'description': '## Changes',
        },
      );
    });
    final created = await client.releases.create(
      'team/app',
      tagName: 'release/2',
      ref: 'main',
      name: 'Version 2',
      description: '## Changes',
    );
    expect(request.method, 'POST');
    expect(request.path, '/projects/team%2Fapp/releases');
    expect(request.data, {
      'tag_name': 'release/2',
      'ref': 'main',
      'name': 'Version 2',
      'description': '## Changes',
    });
    expect(created.tagName, 'release/2');

    await client.releases.create(7, tagName: 'v1');
    expect(request.data, {'tag_name': 'v1'});
  });

  test('maps forbidden release creation', () async {
    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.releases.create(7, tagName: 'v2'),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('deletes only the release at an encoded tag', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 204, headers: const <String, List<String>>{}, body: null);
    });
    await client.releases.delete('team/app', 'release/2');
    expect(request.method, 'DELETE');
    expect(request.path, '/projects/team%2Fapp/releases/release%2F2');
  });

  test('maps forbidden release deletion', () async {
    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.releases.delete(7, 'v2'),
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
