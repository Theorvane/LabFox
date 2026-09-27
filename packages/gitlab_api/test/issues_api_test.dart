import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('IssuesApi.list', () {
    test('lists open issues by default with pagination', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': 1, 'iid': 5, 'title': 'first', 'state': 'opened'},
          ],
        );
      });

      final page = await client.issues.list(42);

      expect(captured.path, '/projects/42/issues');
      expect(captured.queryParameters['state'], 'opened');
      // Label colours must be requested, or the chips have nothing to render.
      expect(captured.queryParameters['with_labels_details'], true);
      expect(page.items.single.iid, 5);
      expect(page.nextPage, 2);
    });

    test('passes a closed state filter through', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const []);
      });

      await client.issues.list(42, state: IssueState.closed);

      expect(captured.queryParameters['state'], 'closed');
    });

    test('passes a search term through and omits it when absent', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const []);
      });

      await client.issues.list(42, search: 'crash');
      expect(captured.queryParameters['search'], 'crash');

      await client.issues.list(42);
      expect(captured.queryParameters.containsKey('search'), isFalse);
    });
  });

  group('IssuesApi.get', () {
    test('fetches one issue by iid, not id', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {
            'id': 99401,
            'iid': 282,
            'title': 'Android login error',
            'state': 'opened',
          },
        );
      });

      final issue = await client.issues.get(42, iid: 282);

      // The path uses the iid; using the global id here would 404 or hit the
      // wrong project.
      expect(captured.path, '/projects/42/issues/282');
      expect(captured.queryParameters['with_labels_details'], true);
      expect(issue.iid, 282);
    });

    test('maps a 404 to not found', () async {
      final client = _client(
        (_) => (status: 404, headers: const {}, body: const {}),
      );
      await expectLater(
        client.issues.get(1, iid: 999),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });

  group('IssuesApi.create', () {
    test('POSTs the title and description and returns the new issue', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 201,
          headers: const {},
          body: {'id': 9, 'iid': 42, 'title': 'Bug', 'state': 'opened'},
        );
      });

      final issue = await client.issues.create(
        7,
        title: 'Bug',
        description: 'It broke',
      );

      expect(captured.method, 'POST');
      expect(captured.path, '/projects/7/issues');
      expect(captured.data, {'title': 'Bug', 'description': 'It broke'});
      expect(issue.iid, 42);
    });

    test('omits an empty description', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 201,
          headers: const {},
          body: {'id': 1, 'iid': 5, 'title': 'x', 'state': 'opened'},
        );
      });

      await client.issues.create(7, title: 'x');

      expect((captured.data as Map).containsKey('description'), isFalse);
    });
  });

  group('IssuesApi.setOpen', () {
    test('PUTs state_event=close and returns the updated issue', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {'id': 1, 'iid': 5, 'title': 'x', 'state': 'closed'},
        );
      });

      final issue = await client.issues.setOpen(7, iid: 5, open: false);

      expect(captured.method, 'PUT');
      expect(captured.path, '/projects/7/issues/5');
      expect(captured.data, {'state_event': 'close'});
      expect(issue.isOpen, isFalse);
    });

    test('PUTs state_event=reopen when opening', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {'id': 1, 'iid': 5, 'title': 'x', 'state': 'opened'},
        );
      });

      await client.issues.setOpen(7, iid: 5, open: true);

      expect(captured.data, {'state_event': 'reopen'});
    });
  });

  group('IssuesApi.update', () {
    test('PUTs title and empty description by project issue iid', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {'id': 123, 'iid': 5, 'title': 'Updated', 'state': 'opened'},
        );
      });

      final issue = await client.issues.update(
        7,
        iid: 5,
        title: 'Updated',
        description: '',
      );

      expect(captured.method, 'PUT');
      expect(captured.path, '/projects/7/issues/5');
      expect(captured.data, {'title': 'Updated', 'description': ''});
      expect(issue.title, 'Updated');
    });

    test('maps a permission denial', () async {
      final client = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        client.issues.update(7, iid: 5, title: 'New', description: ''),
        throwsA(isA<GitLabForbiddenException>()),
      );
    });
  });

  group('IssuesApi.listAssignedToMe', () {
    test('lists open issues assigned to the current user', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: [
            {
              'id': 1,
              'iid': 5,
              'title': 'assigned one',
              'state': 'opened',
              'project_id': 42,
            },
          ],
        );
      });

      final page = await client.issues.listAssignedToMe();

      // The account-scoped global endpoint, not a project path.
      expect(captured.path, '/issues');
      expect(captured.queryParameters['scope'], 'assigned_to_me');
      expect(captured.queryParameters['state'], 'opened');
      expect(captured.queryParameters['with_labels_details'], true);
      // The project id is kept so the row can route to the right project.
      expect(page.items.single.projectId, 42);
    });
    test('listMine passes the created_by_me scope', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const []);
      });

      await client.issues.listMine(scope: IssueScope.createdByMe);

      expect(captured.queryParameters['scope'], 'created_by_me');
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
    final r = handler(options);
    return ResponseBody.fromString(
      r.body == null ? '' : json.encode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...r.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
