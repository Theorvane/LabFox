import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/wiki/data/wiki_repository.dart';

const _original = WikiPage(
  title: 'Install',
  slug: 'docs/install',
  content: '# Install',
  format: 'markdown',
);

void main() {
  test(
    'refuses to overwrite a wiki page changed since the draft began',
    () async {
      var writes = 0;
      final repository = _repository((request) {
        if (request.method == 'PUT') writes++;
        return (
          status: 200,
          body: {
            'title': 'Install',
            'slug': 'docs/install',
            'content': '# Another editor changed this',
            'format': 'markdown',
          },
        );
      });

      await expectLater(
        repository.update(
          projectId: 7,
          original: _original,
          title: 'Install',
          content: '# My change',
        ),
        throwsA(isA<WikiEditConflictException>()),
      );
      expect(writes, 0);
    },
  );

  test('updates an unchanged wiki page and returns the new slug', () async {
    var reads = 0;
    var writes = 0;
    final repository = _repository((request) {
      if (request.method == 'GET') {
        reads++;
        return (status: 200, body: _original.toJson());
      }
      writes++;
      return (
        status: 200,
        body: {
          'title': 'Updated',
          'slug': 'docs/Updated',
          'content': '# My change',
          'format': 'markdown',
        },
      );
    });

    final page = await repository.update(
      projectId: 7,
      original: _original,
      title: 'Updated',
      content: '# My change',
    );

    expect(reads, 1);
    expect(writes, 1);
    expect(page.slug, 'docs/Updated');
  });
}

WikiRepository _repository(
  ({int status, Object? body}) Function(RequestOptions) handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler);
  return WikiRepository(
    GitLabClient(
      baseUrl: 'https://example.com',
      token: 'glpat-xxxxxxxxxxxx',
      dio: dio,
    ),
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
