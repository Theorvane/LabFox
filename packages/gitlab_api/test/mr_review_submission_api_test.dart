import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

import 'mr_draft_note_maintenance_api_test.dart' show makeClient, Adapter;

class ReviewerAdapter extends Adapter {
  ReviewerAdapter(this.cursor) : super((o) => (status: 200, body: []));
  final List<String> cursor;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    final body = await super.fetch(o, stream, cancel);
    body.headers['x-next-page'] = cursor;
    return body;
  }
}

void main() {
  for (final cursor in [
    <String>[],
    ['1'],
    ['0'],
    ['x'],
    ['2', '3'],
    ['3'],
  ]) {
    test('reviewer page cursor $cursor validates advancement', () async {
      final dio = Dio()..httpClientAdapter = ReviewerAdapter(cursor);
      final c = GitLabClient(
        baseUrl: 'https://gitlab.example.com',
        token: 'glpat-xxxxxxxxxxxx',
        dio: dio,
      );
      addTearDown(c.close);
      if (cursor.length == 1 && cursor.single == '3') {
        final result = await c.mergeRequests.reviewers(8, iid: 142);
        expect(result.nextPage, 3);
        expect(result.items, isEmpty);
        expect(
          () => result.items.add(
            const MergeRequestReviewer(
              user: User(id: 23, username: 'r', name: 'R'),
              state: 'reviewed',
            ),
          ),
          throwsUnsupportedError,
        );
      } else {
        await expectLater(
          c.mergeRequests.reviewers(8, iid: 142),
          throwsA(isA<GitLabServerException>()),
        );
      }
    });
  }

  for (final state in [null, ...ReviewerSubmissionState.values]) {
    for (final summary in [null, '  **Public summary**\n\nExact Markdown  ']) {
      test('one public bulk request with $state and $summary', () async {
        final requests = <RequestOptions>[];
        final c = makeClient((o) {
          requests.add(o);
          return (status: 204, body: '{private');
        }, raw: true);
        addTearDown(c.close);
        await c.mergeRequests.publishDraftNotes(
          8,
          iid: 142,
          summaryNote: summary,
          reviewerState: state,
        );
        final o = requests.single;
        expect(
          o.path,
          '/projects/8/merge_requests/142/draft_notes/bulk_publish',
        );
        expect(o.method, 'POST');
        expect(o.followRedirects, false);
        expect(o.extra['labfox_no_auth_retry'], true);
        expect(o.queryParameters, isEmpty);
        expect(
          o.data,
          summary == null && state == null
              ? null
              : {
                  'note': ?summary,
                  if (summary != null) 'internal': false,
                  if (state != null) 'reviewer_state': state.value,
                },
        );
      });
    }
  }
  for (final text in ['', '  \n ']) {
    test('blank explicit summary prevents dispatch', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.publishDraftNotes(8, iid: 142, summaryNote: text),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  test(
    'reviewer GET uses encoded project and preserves future review state',
    () async {
      late RequestOptions request;
      final c = makeClient((o) {
        request = o;
        return (
          status: 200,
          body: [
            {
              'user': {
                'id': 23,
                'username': 'reviewer',
                'name': 'Reviewer',
                'state': 'active',
              },
              'state': 'future_review',
              'created_at': '2026-10-06T00:00:00Z',
            },
          ],
        );
      });
      addTearDown(c.close);
      final result = await c.mergeRequests.reviewers(
        'group/project +',
        iid: 142,
        page: 2,
        perPage: 10,
      );
      expect(
        request.path,
        '/projects/group%2Fproject%20%2B/merge_requests/142/reviewers',
      );
      expect(request.method, 'GET');
      expect(request.followRedirects, false);
      expect(request.queryParameters, {'page': 2, 'per_page': 10});
      expect(result.items.single.state, 'future_review');
      expect(result.items.single.user.state, 'active');
      expect(result.items.single.createdAt, DateTime.utc(2026, 10, 6));
    },
  );
  for (final id in [23.5, 23.0, '23', true, null]) {
    test('reviewer wire identity must be a positive integer $id', () async {
      final c = makeClient(
        (o) => (
          status: 200,
          body: [
            {
              'user': {'id': id, 'username': 'r', 'name': 'R'},
              'state': 'reviewed',
            },
          ],
        ),
      );
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.reviewers(8, iid: 142),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final body in [
    null,
    {},
    '{private-marker',
    [
      {
        'user': {'id': 23, 'username': 'r', 'name': 'R'},
        'state': '',
      },
    ],
    [
      {
        'user': {'id': 0, 'username': 'r', 'name': 'R'},
        'state': 'reviewed',
      },
    ],
  ]) {
    test('malformed reviewer response is sanitized $body', () async {
      final c = makeClient((o) => (status: 200, body: body));
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.reviewers(8, iid: 142),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.toString(),
            'safe message',
            isNot(contains('private-marker')),
          ),
        ),
      );
    });
  }
  for (final status in [201, 302, 401, 403, 404, 429, 500]) {
    test('reviewer status $status precedes body decode', () async {
      final c = makeClient(
        (o) => (status: status, body: '{private-marker'),
        raw: true,
      );
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.reviewers(8, iid: 142),
        throwsA(switch (status) {
          401 => isA<GitLabAuthException>(),
          403 => isA<GitLabForbiddenException>(),
          404 => isA<GitLabNotFoundException>(),
          429 => isA<GitLabRateLimitException>(),
          _ => isA<GitLabServerException>(),
        }),
      );
    });
  }
  for (final args in [
    (0, 142, 1, 20),
    (8, 0, 1, 20),
    (8, 142, 0, 20),
    (8, 142, 1, 0),
    (8, 142, 1, 101),
  ]) {
    test('invalid reviewer route or pagination $args', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 200, body: []);
      });
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.reviewers(
          args.$1,
          iid: args.$2,
          page: args.$3,
          perPage: args.$4,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
}
