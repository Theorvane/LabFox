import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'lists linked issues with iid, project id, relation, and pagination',
    () async {
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
              'id': 84,
              'iid': 14,
              'project_id': 4,
              'issue_link_id': 1,
              'title': 'Fix authentication',
              'state': 'opened',
              'link_type': 'blocks',
            },
          ],
        );
      });

      final page = await client.issueLinks.list('team/app', issueIid: 7);
      expect(request.path, '/projects/team%2Fapp/issues/7/links');
      expect(request.queryParameters['page'], 1);
      expect(page.nextPage, 2);
      final link = page.items.single;
      expect(link.id, 84);
      expect(link.iid, 14);
      expect(link.projectId, 4);
      expect(link.issueLinkId, 1);
      expect(link.linkType, 'blocks');
    },
  );

  test('maps forbidden issue links without leaking Dio errors', () async {
    final client = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      client.issueLinks.list(7, issueIid: 14),
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
