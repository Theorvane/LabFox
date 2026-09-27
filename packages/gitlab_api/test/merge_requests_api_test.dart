import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  group('MergeRequestsApi.list', () {
    test(
      'lists open MRs by default with label details and pagination',
      () async {
        late RequestOptions captured;
        final client = _client((o) {
          captured = o;
          return (
            status: 200,
            headers: {
              'x-next-page': ['2'],
            },
            body: [
              {
                'id': 1,
                'iid': 142,
                'title': 'Add OAuth',
                'state': 'opened',
                'source_branch': 'feature/oauth',
                'target_branch': 'develop',
              },
            ],
          );
        });

        final page = await client.mergeRequests.list(42);

        expect(captured.path, '/projects/42/merge_requests');
        expect(captured.queryParameters['state'], 'opened');
        expect(captured.queryParameters['with_labels_details'], true);
        expect(page.items.single.iid, 142);
        expect(page.nextPage, 2);
      },
    );

    test('passes the merged state filter through', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const []);
      });

      await client.mergeRequests.list(42, state: MergeRequestState.merged);

      expect(captured.queryParameters['state'], 'merged');
    });

    test('passes a search term through and omits it when absent', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const []);
      });

      await client.mergeRequests.list(42, search: 'diff viewer');
      expect(captured.queryParameters['search'], 'diff viewer');

      await client.mergeRequests.list(42);
      expect(captured.queryParameters.containsKey('search'), isFalse);
    });
  });

  group('MergeRequestsApi.get', () {
    test('fetches one MR by iid', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {
            'id': 55123,
            'iid': 142,
            'title': 'Add OAuth',
            'state': 'opened',
            'source_branch': 'feature/oauth',
            'target_branch': 'develop',
          },
        );
      });

      final mr = await client.mergeRequests.get(42, iid: 142);

      expect(captured.path, '/projects/42/merge_requests/142');
      expect(mr.iid, 142);
    });

    test('maps a 404 to not found', () async {
      final client = _client(
        (_) => (status: 404, headers: const {}, body: const {}),
      );
      await expectLater(
        client.mergeRequests.get(1, iid: 999),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });

  group('MergeRequestsApi.create', () {
    test('POSTs source, target, title and returns the new MR', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 201,
          headers: const {},
          body: {
            'id': 1,
            'iid': 9,
            'title': 'Add OAuth',
            'state': 'opened',
            'source_branch': 'feat/oauth',
            'target_branch': 'main',
          },
        );
      });

      final mr = await client.mergeRequests.create(
        7,
        sourceBranch: 'feat/oauth',
        targetBranch: 'main',
        title: 'Add OAuth',
        description: 'flow',
      );

      expect(captured.method, 'POST');
      expect(captured.path, '/projects/7/merge_requests');
      expect(captured.data, {
        'source_branch': 'feat/oauth',
        'target_branch': 'main',
        'title': 'Add OAuth',
        'description': 'flow',
      });
      expect(mr.iid, 9);
    });
  });

  group('MergeRequestsApi state edits', () {
    test('setOpen PUTs the close state_event', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {
            'id': 1,
            'iid': 5,
            'title': 'x',
            'state': 'closed',
            'source_branch': 'a',
            'target_branch': 'b',
          },
        );
      });

      await client.mergeRequests.setOpen(7, iid: 5, open: false);

      expect(captured.method, 'PUT');
      expect(captured.path, '/projects/7/merge_requests/5');
      expect(captured.data, {'state_event': 'close'});
    });

    test('setDraft adds a Draft: prefix to the title', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {
            'id': 1,
            'iid': 5,
            'title': 'Draft: Add OAuth',
            'state': 'opened',
            'source_branch': 'a',
            'target_branch': 'b',
          },
        );
      });

      await client.mergeRequests.setDraft(
        7,
        iid: 5,
        draft: true,
        title: 'Add OAuth',
      );

      expect(captured.data, {'title': 'Draft: Add OAuth'});
    });

    test(
      'setDraft strips an existing Draft: prefix when marking ready',
      () async {
        late RequestOptions captured;
        final client = _client((o) {
          captured = o;
          return (
            status: 200,
            headers: const {},
            body: {
              'id': 1,
              'iid': 5,
              'title': 'Add OAuth',
              'state': 'opened',
              'source_branch': 'a',
              'target_branch': 'b',
            },
          );
        });

        await client.mergeRequests.setDraft(
          7,
          iid: 5,
          draft: false,
          title: 'Draft: Add OAuth',
        );

        expect(captured.data, {'title': 'Add OAuth'});
      },
    );

    test('rebase PUTs to the rebase path', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 202,
          headers: const {},
          body: {'rebase_in_progress': true},
        );
      });

      await client.mergeRequests.rebase(7, iid: 5);

      expect(captured.method, 'PUT');
      expect(captured.path, '/projects/7/merge_requests/5/rebase');
    });
  });

  group('MergeRequestsApi.listAssignedToMe', () {
    test('lists open MRs assigned to the current user', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: [
            {
              'id': 1,
              'iid': 7,
              'title': 'mine',
              'state': 'opened',
              'source_branch': 'a',
              'target_branch': 'main',
              'project_id': 42,
            },
          ],
        );
      });

      final page = await client.mergeRequests.listAssignedToMe();

      expect(captured.path, '/merge_requests');
      expect(captured.queryParameters['scope'], 'assigned_to_me');
      expect(captured.queryParameters['state'], 'opened');
      expect(captured.queryParameters['with_labels_details'], true);
      expect(page.items.single.projectId, 42);
    });

    test('listMine passes the created_by_me scope', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (status: 200, headers: const {}, body: const []);
      });

      await client.mergeRequests.listMine(scope: MergeRequestScope.createdByMe);

      expect(captured.queryParameters['scope'], 'created_by_me');
    });
  });

  group('MergeRequestsApi.listForReview', () {
    test('lists open MRs where the given user is a reviewer', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: [
            {
              'id': 2,
              'iid': 9,
              'title': 'please review',
              'state': 'opened',
              'source_branch': 'b',
              'target_branch': 'main',
              'project_id': 7,
            },
          ],
        );
      });

      final page = await client.mergeRequests.listForReview('octocat');

      expect(captured.path, '/merge_requests');
      // Filter by reviewer username, not a scope: a scope cannot express it.
      expect(captured.queryParameters['reviewer_username'], 'octocat');
      expect(captured.queryParameters['state'], 'opened');
      expect(captured.queryParameters['with_labels_details'], true);
      expect(page.items.single.iid, 9);
    });
  });

  group('MergeRequestsApi.setSubscription', () {
    test('subscribes by merge request iid', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          headers: const {},
          body: {
            'id': 77,
            'iid': 5,
            'title': 'Review me',
            'state': 'opened',
            'source_branch': 'feature',
            'target_branch': 'main',
            'subscribed': true,
          },
        );
      });

      final mr = await client.mergeRequests.setSubscription(
        7,
        iid: 5,
        subscribed: true,
      );

      expect(captured.method, 'POST');
      expect(captured.path, '/projects/7/merge_requests/5/subscribe');
      expect(mr?.subscribed, isTrue);
    });

    test('unsubscribes and accepts an idempotent 304 response', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (status: 304, headers: const {}, body: null);
      });

      final mr = await client.mergeRequests.setSubscription(
        7,
        iid: 5,
        subscribed: false,
      );

      expect(captured.path, '/projects/7/merge_requests/5/unsubscribe');
      expect(mr, isNull);
    });

    test('maps permission denial', () async {
      final client = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );

      await expectLater(
        client.mergeRequests.setSubscription(7, iid: 5, subscribed: true),
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
