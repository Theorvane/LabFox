import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists tags with pagination from GitLab headers', () async {
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
            'name': 'v1.0.0',
            'protected': true,
            'commit': {'id': 'abc', 'title': 'Ship'},
          },
        ],
      );
    });

    final page = await client.repository.tags(42);
    expect(request.path, '/projects/42/repository/tags');
    expect(page.nextPage, 2);
    expect(page.items.single.name, 'v1.0.0');
    expect(page.items.single.isProtected, isTrue);
  });

  test('gets a tag with an encoded slash in its name', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 200, headers: const {}, body: {'name': 'release/v1'});
    });

    final tag = await client.repository.tag(42, 'release/v1');
    expect(request.path, '/projects/42/repository/tags/release%2Fv1');
    expect(tag.name, 'release/v1');
  });

  test('creates a tag from a ref with an optional message', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 201, headers: const {}, body: {'name': 'v2.0.0'});
    });

    final tag = await client.repository.createTag(
      42,
      name: 'v2.0.0',
      ref: 'main',
      message: 'Ship',
    );
    expect(request.method, 'POST');
    expect(request.queryParameters, containsPair('tag_name', 'v2.0.0'));
    expect(request.queryParameters, containsPair('ref', 'main'));
    expect(request.queryParameters, containsPair('message', 'Ship'));
    expect(tag.name, 'v2.0.0');
  });

  test('maps a forbidden response to a domain exception', () async {
    final client = _client((_) => (status: 403, headers: const {}, body: {}));
    await expectLater(
      client.repository.tags(42),
      throwsA(isA<GitLabException>()),
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
