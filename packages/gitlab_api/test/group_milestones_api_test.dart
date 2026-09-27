import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists group milestones with pagination and group identity', () async {
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
            'id': 12,
            'iid': 3,
            'group_id': 7,
            'title': '10.0',
            'state': 'active',
          },
        ],
      );
    });

    final page = await client.groupMilestones.list(
      'team/subgroup',
      state: 'active',
    );
    expect(request.path, '/groups/team%2Fsubgroup/milestones');
    expect(request.queryParameters['state'], 'active');
    expect(request.queryParameters['page'], 1);
    expect(page.nextPage, 2);
    expect(page.items.single.id, 12);
    expect(page.items.single.iid, 3);
    expect(page.items.single.groupId, 7);
  });

  test(
    'gets a group milestone by global ID and maps forbidden access',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: <String, List<String>>{},
          body: {
            'id': 12,
            'iid': 3,
            'group_id': 7,
            'title': '10.0',
            'state': 'active',
          },
        );
      });
      final milestone = await client.groupMilestones.get(7, 12);
      expect(request.path, '/groups/7/milestones/12');
      expect(milestone.groupId, 7);

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.groupMilestones.list(7),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );

  test(
    'creates a group milestone with optional dates and encoded group path',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 201,
          headers: const <String, List<String>>{},
          body: {
            'id': 55,
            'iid': 9,
            'group_id': 7,
            'title': 'Release 1',
            'state': 'active',
            'start_date': '2026-10-01',
            'due_date': '2026-10-31',
          },
        );
      });
      final milestone = await client.groupMilestones.create(
        'team/subgroup',
        title: 'Release 1',
        description: 'Shipping scope',
        startDate: '2026-10-01',
        dueDate: '2026-10-31',
      );
      expect(request.method, 'POST');
      expect(request.path, '/groups/team%2Fsubgroup/milestones');
      expect(request.data, {
        'title': 'Release 1',
        'description': 'Shipping scope',
        'start_date': '2026-10-01',
        'due_date': '2026-10-31',
      });
      expect(milestone.id, 55);
      expect(milestone.iid, 9);
      expect(milestone.groupId, 7);
    },
  );

  test(
    'omits blank group milestone fields and maps forbidden create',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 201,
          headers: const <String, List<String>>{},
          body: {
            'id': 55,
            'iid': 9,
            'group_id': 7,
            'title': 'Release 1',
            'state': 'active',
          },
        );
      });
      await client.groupMilestones.create(
        7,
        title: 'Release 1',
        description: '',
      );
      expect(request.data, {'title': 'Release 1'});

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.groupMilestones.create(7, title: 'Release 1'),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );
  for (final event in ['close', 'activate']) {
    test('changes group milestone state with $event', () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: const <String, List<String>>{},
          body: {
            'id': 42,
            'iid': 4,
            'group_id': 7,
            'title': 'Release 1',
            'state': event == 'close' ? 'closed' : 'active',
          },
        );
      });
      final result = await client.groupMilestones.setStateEvent(
        'team/subgroup',
        42,
        stateEvent: event,
      );
      expect(request.method, 'PUT');
      expect(request.path, '/groups/team%2Fsubgroup/milestones/42');
      expect(request.data, {'state_event': event});
      expect(result.id, 42);
      expect(result.iid, 4);
      expect(result.state, event == 'close' ? 'closed' : 'active');
    });
  }

  test(
    'rejects invalid group state events and maps forbidden writes',
    () async {
      final client = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        client.groupMilestones.setStateEvent(7, 42, stateEvent: 'close'),
        throwsA(isA<GitLabForbiddenException>()),
      );
      await expectLater(
        client.groupMilestones.setStateEvent(7, 42, stateEvent: 'reopen'),
        throwsA(isA<ArgumentError>()),
      );
    },
  );
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
