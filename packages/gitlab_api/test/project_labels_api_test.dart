import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists labels with inherited groups and usage counts', () async {
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
            'id': 7,
            'name': 'bug',
            'color': '#D9534F',
            'open_issues_count': 3,
            'is_project_label': true,
          },
        ],
      );
    });

    final page = await client.projectLabels.list(42);
    expect(request.path, '/projects/42/labels');
    expect(request.queryParameters['with_counts'], true);
    expect(request.queryParameters['include_ancestor_groups'], true);
    expect(page.nextPage, 2);
    expect(page.items.single.openIssuesCount, 3);
  });

  test('gets a project label by id', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {'id': 7, 'name': 'bug', 'color': '#D9534F'},
      );
    });

    expect((await client.projectLabels.get(42, 7)).name, 'bug');
    expect(request.path, '/projects/42/labels/7');
  });

  test('encodes self-hosted project paths as one segment', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 200, headers: const {}, body: const []);
    });

    await client.projectLabels.list('team/project');
    expect(request.path, '/projects/team%2Fproject/labels');
  });

  test('creates a project label with name, color, and description', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 201,
        headers: const {},
        body: {'id': 8, 'name': 'feature', 'color': '#5843AD'},
      );
    });

    await client.projectLabels.create(
      42,
      name: 'feature',
      color: '#5843AD',
      description: 'New work',
    );
    expect(request.method, 'POST');
    expect(request.data, containsPair('name', 'feature'));
    expect(request.data, containsPair('color', '#5843AD'));
    expect(request.data, containsPair('description', 'New work'));
  });

  test('maps forbidden list access to a domain exception', () async {
    final client = _client((_) => (status: 403, headers: const {}, body: {}));
    await expectLater(
      client.projectLabels.list(42),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
}

GitLabClient _client(
  ({int status, Map<String, List<String>> headers, Object body}) Function(
    RequestOptions,
  )
  handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example',
    token: 'glpat-x',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
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
      json.encode(result.body),
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
