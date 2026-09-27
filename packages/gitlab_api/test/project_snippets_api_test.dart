import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'adds one file to a project snippet without replacing other files',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: const {},
          body: {'id': 73, 'title': 'Deploy helper'},
        );
      });

      final snippet = await client.snippets.addFile(
        'team/project',
        73,
        filePath: 'scripts/release.sh',
        content: 'echo release',
      );

      expect(request.method, 'PUT');
      expect(request.path, '/projects/team%2Fproject/snippets/73');
      expect(request.data, {
        'files': [
          {
            'action': 'create',
            'file_path': 'scripts/release.sh',
            'content': 'echo release',
          },
        ],
      });
      expect(snippet.id, 73);
    },
  );

  test('maps forbidden file creation to a domain exception', () async {
    final client = _client((_) => (status: 403, headers: const {}, body: {}));

    await expectLater(
      client.snippets.addFile(42, 73, filePath: 'new.txt', content: 'hello'),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('updates one snippet file using the files action payload', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {'id': 73, 'title': 'Deploy helper'},
      );
    });

    final snippet = await client.snippets.updateFileContent(
      'team/project',
      73,
      filePath: 'scripts/deploy.sh',
      content: 'echo ready',
    );

    expect(request.method, 'PUT');
    expect(request.path, '/projects/team%2Fproject/snippets/73');
    expect(request.data, {
      'files': [
        {
          'action': 'update',
          'file_path': 'scripts/deploy.sh',
          'content': 'echo ready',
        },
      ],
    });
    expect(snippet.id, 73);
  });

  test('maps forbidden snippet file updates', () async {
    final client = _client((_) => (status: 403, headers: const {}, body: {}));

    await expectLater(
      client.snippets.updateFileContent(
        42,
        73,
        filePath: 'deploy.sh',
        content: 'echo ready',
      ),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('updates snippet metadata without a files payload', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {'id': 73, 'title': 'Revised', 'description': 'New notes'},
      );
    });

    final snippet = await client.snippets.updateMetadata(
      'team/project',
      73,
      title: 'Revised',
      description: 'New notes',
    );

    expect(request.method, 'PUT');
    expect(request.path, '/projects/team%2Fproject/snippets/73');
    expect(request.data, {'title': 'Revised', 'description': 'New notes'});
    expect(snippet.title, 'Revised');
  });

  test('maps forbidden snippet metadata updates', () async {
    final client = _client((_) => (status: 403, headers: const {}, body: {}));

    await expectLater(
      client.snippets.updateMetadata(42, 73, title: 'Revised', description: ''),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('updates project snippet visibility with metadata', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {'id': 73, 'title': 'Deploy helper', 'visibility': 'public'},
      );
    });

    final snippet = await client.snippets.updateMetadata(
      'team/project',
      73,
      title: 'Deploy helper',
      description: 'Notes',
      visibility: 'public',
    );

    expect(request.method, 'PUT');
    expect(request.path, '/projects/team%2Fproject/snippets/73');
    expect(request.data, {
      'title': 'Deploy helper',
      'description': 'Notes',
      'visibility': 'public',
    });
    expect(snippet.visibility, 'public');
  });

  test(
    'creates a project snippet with one file and explicit visibility',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 201,
          headers: const {},
          body: {'id': 73, 'title': 'Deploy helper', 'visibility': 'private'},
        );
      });

      final snippet = await client.snippets.create(
        'team/project',
        title: 'Deploy helper',
        description: 'Release command',
        visibility: 'private',
        filePath: 'scripts/deploy.sh',
        content: '#!/bin/sh\necho ok',
      );

      expect(request.method, 'POST');
      expect(request.path, '/projects/team%2Fproject/snippets');
      expect(request.data, {
        'title': 'Deploy helper',
        'description': 'Release command',
        'visibility': 'private',
        'files': [
          {'file_path': 'scripts/deploy.sh', 'content': '#!/bin/sh\necho ok'},
        ],
      });
      expect(snippet.id, 73);
    },
  );

  test('maps permission denial while creating a project snippet', () async {
    final client = _client((_) => (status: 403, headers: const {}, body: {}));

    await expectLater(
      client.snippets.create(
        42,
        title: 'Example',
        visibility: 'public',
        filePath: 'example.txt',
        content: 'hello',
      ),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('deletes a project snippet using the encoded project path', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 204, headers: const {}, body: {});
    });

    await client.snippets.delete('team/project', 73);

    expect(request.method, 'DELETE');
    expect(request.path, '/projects/team%2Fproject/snippets/73');
  });

  test('maps a forbidden project snippet deletion', () async {
    final client = _client((_) => (status: 403, headers: const {}, body: {}));

    await expectLater(
      client.snippets.delete(42, 73),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('lists project snippets using the next-page header', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: {
          'x-next-page': ['3'],
        },
        body: [
          {'id': 7, 'title': 'Example', 'file_name': 'sample.rb'},
        ],
      );
    });

    final page = await client.snippets.list(42, page: 2);

    expect(request.path, '/projects/42/snippets');
    expect(request.queryParameters['page'], 2);
    expect(page.nextPage, 3);
    expect(page.items.single.title, 'Example');
  });

  test('retrieves project snippet details and files', () async {
    final client = _client(
      (_) => (
        status: 200,
        headers: const {},
        body: {
          'id': 7,
          'title': 'Example',
          'files': [
            {'path': 'sample.rb', 'raw_url': 'https://example.test/raw'},
          ],
        },
      ),
    );

    final snippet = await client.snippets.get(42, 7);
    expect(snippet.files.single.path, 'sample.rb');
  });

  test('maps unauthorized snippet requests to an auth exception', () async {
    final client = _client((_) => (status: 401, headers: const {}, body: {}));
    await expectLater(
      client.snippets.list(42),
      throwsA(isA<GitLabAuthException>()),
    );
  });

  test('loads raw snippet text without JSON decoding', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 200, headers: const {}, body: 'print("hello");');
    });

    expect(await client.snippets.raw(42, 7), 'print("hello");');
    expect(request.path, '/projects/42/snippets/7/raw');
  });

  test(
    'encodes a multi-file snippet path and surfaces a forbidden response',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (status: 403, headers: const {}, body: {});
      });

      await expectLater(
        client.snippets.file(42, 7, ref: 'main', path: 'src/a b.rb'),
        throwsA(isA<GitLabException>()),
      );
      expect(request.path, contains('/files/main/src%2Fa%20b.rb/raw'));
    },
  );
}

GitLabClient _client(
  ({int status, Map<String, List<String>> headers, Object body}) Function(
    RequestOptions,
  )
  handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _FakeAdapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example',
    token: 'glpat-x',
    dio: dio,
  );
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ({int status, Map<String, List<String>> headers, Object body}) Function(
    RequestOptions,
  )
  handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    return ResponseBody.fromString(
      options.responseType == ResponseType.plain
          ? result.body.toString()
          : json.encode(result.body),
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
