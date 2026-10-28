import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'lists project activity with encoded path, filter and pagination',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: {
            'x-next-page': ['3'],
          },
          body: [
            {
              'id': 8,
              'project_id': 7,
              'action_name': 'opened',
              'target_type': 'Issue',
              'target_iid': 53,
            },
          ],
        );
      });

      final page = await client.events.listProject(
        'team/app',
        targetType: 'issue',
        page: 2,
      );

      expect(request.path, '/projects/team%2Fapp/events');
      expect(request.queryParameters['target_type'], 'issue');
      expect(request.queryParameters['sort'], 'desc');
      expect(request.queryParameters['page'], 2);
      expect(page.nextPage, 3);
      expect(page.items.single.targetIid, 53);
    },
  );

  test('maps project activity forbidden response', () async {
    final client = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      client.events.listProject(7),
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
