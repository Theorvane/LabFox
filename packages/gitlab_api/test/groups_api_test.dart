import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('GroupsApi.list', () {
    test('lists the groups visible to the user with pagination', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': 42, 'name': 'YouthPick', 'full_path': 'youthpick'},
          ],
        );
      });

      final page = await client.groups.list();

      expect(captured.path, '/groups');
      // Membership only — all_available would list every public group on the
      // instance.
      expect(captured.queryParameters['all_available'], false);
      expect(captured.queryParameters['order_by'], 'name');
      expect(page.items.single.fullPath, 'youthpick');
      expect(page.nextPage, 2);
    });

    test('maps a 401 to unauthorized', () async {
      final client = _client(
        (_) => (status: 401, headers: const {}, body: const {}),
      );
      await expectLater(
        client.groups.list(),
        throwsA(isA<GitLabAuthException>()),
      );
    });
  });

  group('GroupsApi browsing', () {
    test('loads a group without deprecated embedded projects', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          headers: const {},
          body: {'id': 42, 'name': 'Team', 'full_path': 'parent/team'},
        );
      });
      final group = await client.groups.get('parent/team');
      expect(captured.path, '/groups/parent%2Fteam');
      expect(captured.queryParameters['with_projects'], false);
      expect(group.fullPath, 'parent/team');
    });

    test('lists direct projects and carries the next page', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          headers: const {
            'x-next-page': ['3'],
          },
          body: [
            {'id': 10, 'name': 'App', 'path_with_namespace': 'parent/team/app'},
          ],
        );
      });

      final page = await client.groups.listProjects(groupId: 42, page: 2);

      expect(captured.path, '/groups/42/projects');
      expect(captured.queryParameters['page'], 2);
      expect(captured.queryParameters['include_subgroups'], false);
      expect(page.items.single.name, 'App');
      expect(page.nextPage, 3);
    });

    test('lists direct subgroups and maps permission failures', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          headers: const {},
          body: [
            {'id': 9, 'name': 'Infra', 'full_path': 'parent/team/infra'},
          ],
        );
      });

      final page = await client.groups.listSubgroups(groupId: 42);

      expect(captured.path, '/groups/42/subgroups');
      expect(page.items.single.fullPath, 'parent/team/infra');
      expect(page.hasMore, isFalse);

      final denied = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        denied.groups.listSubgroups(groupId: 42),
        throwsA(isA<GitLabForbiddenException>()),
      );
    });
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
    baseUrl: 'https://gitlab.com',
    token: 'glpat-x',
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
