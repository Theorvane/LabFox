import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('updates only publication time as UTC by encoded tag', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const <String, List<String>>{},
        body: {
          'tag_name': 'release/1',
          'name': 'Original',
          'released_at': '2027-01-02T03:04:05.000Z',
        },
      );
    });
    final release = await client.releases.updateReleasedAt(
      'team/app',
      'release/1',
      DateTime.parse('2027-01-02T12:04:05+09:00'),
    );
    expect(request.method, 'PUT');
    expect(request.path, '/projects/team%2Fapp/releases/release%2F1');
    expect(request.data, {'released_at': '2027-01-02T03:04:05.000Z'});
    expect(release.name, 'Original');
    expect(release.releasedAt, DateTime.utc(2027, 1, 2, 3, 4, 5));
  });

  test('maps rejected publication time updates to domain errors', () async {
    final client = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      client.releases.updateReleasedAt(7, 'v1', DateTime.utc(2027)),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
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

  test(
    'updates release name and Markdown description by encoded tag',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: const <String, List<String>>{},
          body: {
            'name': 'Version 2',
            'tag_name': 'release/2',
            'description': '',
          },
        );
      });
      final updated = await client.releases.update(
        'team/app',
        'release/2',
        name: 'Version 2',
        description: '',
      );
      expect(request.method, 'PUT');
      expect(request.path, '/projects/team%2Fapp/releases/release%2F2');
      expect(request.data, {'name': 'Version 2', 'description': ''});
      expect(updated.tagName, 'release/2');
      expect(updated.name, 'Version 2');

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.releases.update(7, 'v2', name: 'Version 2', description: ''),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );
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

  test('creates an asset link for an encoded release tag', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 201,
        headers: const <String, List<String>>{},
        body: {
          'id': 12,
          'name': 'Desktop package',
          'url': 'https://example.com/app.zip',
          'link_type': 'package',
        },
      );
    });
    final link = await client.releases.createAssetLink(
      'team/app',
      'release/2',
      name: 'Desktop package',
      url: 'https://example.com/app.zip',
      linkType: 'package',
    );
    expect(request.method, 'POST');
    expect(
      request.path,
      '/projects/team%2Fapp/releases/release%2F2/assets/links',
    );
    expect(request.data, {
      'name': 'Desktop package',
      'url': 'https://example.com/app.zip',
      'link_type': 'package',
    });
    expect(link.id, 12);
  });

  test('maps forbidden asset link creation', () async {
    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.releases.createAssetLink(
        7,
        'v2',
        name: 'Package',
        url: 'https://example.com/app.zip',
      ),
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

  test('updates an asset link using its global id and encoded tag', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const <String, List<String>>{},
        body: {
          'id': 12,
          'name': 'New package',
          'url': 'https://example.com/new.zip',
        },
      );
    });
    final link = await client.releases.updateAssetLink(
      'team/app',
      'release/2',
      12,
      name: 'New package',
      url: 'https://example.com/new.zip',
    );
    expect(request.method, 'PUT');
    expect(
      request.path,
      '/projects/team%2Fapp/releases/release%2F2/assets/links/12',
    );
    expect(request.data, {
      'name': 'New package',
      'url': 'https://example.com/new.zip',
    });
    expect(link.id, 12);
    expect(link.name, 'New package');
  });

  for (final type in ['other', 'runbook', 'image', 'package']) {
    test('updates an asset link with type $type', () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: const <String, List<String>>{},
          body: {
            'id': 12,
            'name': 'Asset',
            'url': 'https://example.com/asset',
            'link_type': type,
          },
        );
      });
      final link = await client.releases.updateAssetLink(
        'team/app',
        'release/2',
        12,
        name: 'Asset',
        url: 'https://example.com/asset',
        linkType: type,
      );
      expect(request.method, 'PUT');
      expect(
        request.path,
        '/projects/team%2Fapp/releases/release%2F2/assets/links/12',
      );
      expect(request.data, {
        'name': 'Asset',
        'url': 'https://example.com/asset',
        'link_type': type,
      });
      expect(link.linkType, type);
    });
  }

  test('maps forbidden asset link editing', () async {
    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.releases.updateAssetLink(
        7,
        'v2',
        12,
        name: 'Package',
        url: 'https://example.com/app.zip',
      ),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
  test('deletes a release asset link by global link id', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const <String, List<String>>{},
        body: {
          'id': 12,
          'name': 'Package',
          'url': 'https://example.com/app.zip',
        },
      );
    });
    await client.releases.deleteAssetLink('team/app', 'release/2', 12);
    expect(request.method, 'DELETE');
    expect(
      request.path,
      '/projects/team%2Fapp/releases/release%2F2/assets/links/12',
    );
  });

  test('maps forbidden asset link deletion', () async {
    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.releases.deleteAssetLink(7, 'v2', 12),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('accepts no-content success for asset link deletion', () async {
    final client = _client((_) => (status: 204, headers: const {}, body: null));
    await client.releases.deleteAssetLink(7, 'v2', 12);
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
