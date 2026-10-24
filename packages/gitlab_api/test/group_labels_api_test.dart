import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists group and ancestor labels with counts and pagination', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: {
          'x-next-page': ['2'],
        },
        body: [
          {'id': 7, 'name': 'bug', 'color': '#D9534F', 'open_issues_count': 3},
        ],
      );
    });

    final page = await client.groupLabels.list('team/core');
    expect(request.path, '/groups/team%2Fcore/labels');
    expect(request.queryParameters['with_counts'], true);
    expect(request.queryParameters['include_ancestor_groups'], true);
    expect(page.nextPage, 2);
    expect(page.items.single.openIssuesCount, 3);
  });

  test('loads and creates a group label', () async {
    final requests = <RequestOptions>[];
    final client = _client((options) {
      requests.add(options);
      return (
        status: options.method == 'POST' ? 201 : 200,
        headers: <String, List<String>>{},
        body: {'id': 7, 'name': 'bug', 'color': '#D9534F'},
      );
    });

    expect((await client.groupLabels.get(42, 7)).name, 'bug');
    await client.groupLabels.create(
      42,
      name: 'bug',
      color: '#D9534F',
      description: 'A defect',
    );
    expect(requests.first.path, '/groups/42/labels/7');
    expect(requests.last.path, '/groups/42/labels');
    expect(requests.last.data, containsPair('description', 'A defect'));
  });

  test('maps forbidden group-label response', () async {
    final client = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      client.groupLabels.list(42),
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
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
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
