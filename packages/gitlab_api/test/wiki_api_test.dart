import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists wiki pages without requesting full content', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        body: [
          {'title': 'Home', 'slug': 'home', 'format': 'markdown'},
        ],
      );
    });

    final pages = await client.wikis.list('team/project');

    expect(request.path, '/projects/team%2Fproject/wikis');
    expect(request.queryParameters['with_content'], false);
    expect(pages.single.title, 'Home');
    expect(pages.single.content, isNull);
  });

  test('reads a nested wiki slug as one encoded path segment', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        body: {
          'title': 'Install',
          'slug': 'docs/install',
          'content': '# Install',
          'format': 'markdown',
        },
      );
    });

    final page = await client.wikis.get(7, 'docs/install');

    expect(request.path, '/projects/7/wikis/docs%2Finstall');
    expect(page.content, '# Install');
  });

  test('maps permission errors while reading wiki pages', () async {
    final client = _client((_) => (status: 403, body: const {}));

    await expectLater(
      client.wikis.get(7, 'home'),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test(
    'creates a markdown page and returns the server-generated slug',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 201,
          body: {
            'title': 'Getting Started',
            'slug': 'Getting-Started',
            'content': '# Hello\n\nUse / and & safely.',
            'format': 'markdown',
          },
        );
      });

      final page = await client.wikis.create(
        'team/project',
        title: 'Getting Started',
        content: '# Hello\n\nUse / and & safely.',
      );

      expect(request.method, 'POST');
      expect(request.path, '/projects/team%2Fproject/wikis');
      expect(request.data, {
        'title': 'Getting Started',
        'content': '# Hello\n\nUse / and & safely.',
        'format': 'markdown',
      });
      expect(page.slug, 'Getting-Started');
    },
  );

  test('maps permission errors while creating a wiki page', () async {
    final client = _client((_) => (status: 403, body: const {}));

    await expectLater(
      client.wikis.create(7, title: 'Title', content: 'Body'),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('updates a nested wiki page and preserves its format', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        body: {
          'title': 'New title',
          'slug': 'docs/New-title',
          'content': 'Revised & tested',
          'format': 'asciidoc',
        },
      );
    });

    final page = await client.wikis.update(
      'team/project',
      slug: 'docs/old-title',
      title: 'New title',
      content: 'Revised & tested',
      format: 'asciidoc',
    );

    expect(request.method, 'PUT');
    expect(request.path, '/projects/team%2Fproject/wikis/docs%2Fold-title');
    expect(request.data, {
      'title': 'New title',
      'content': 'Revised & tested',
      'format': 'asciidoc',
    });
    expect(page.slug, 'docs/New-title');
  });

  test('maps permission errors while updating a wiki page', () async {
    final client = _client((_) => (status: 403, body: const {}));

    await expectLater(
      client.wikis.update(7, slug: 'home', title: 'Home', content: 'Text'),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler,
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

  final ({int status, Object? body}) Function(RequestOptions) handler;

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
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
