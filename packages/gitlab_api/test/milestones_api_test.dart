import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('lists project milestones and preserves id versus iid', () async {
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
            'project_id': 7,
            'title': '10.0',
            'state': 'active',
            'due_date': '2026-10-01',
          },
        ],
      );
    });

    final page = await client.milestones.list('team/app');
    expect(request.path, '/projects/team%2Fapp/milestones');
    expect(request.queryParameters['page'], 1);
    expect(page.nextPage, 2);
    expect(page.items.single.id, 12);
    expect(page.items.single.iid, 3);
    expect(page.items.single.dueDate, DateTime(2026, 10, 1));
  });

  test('includes ancestor-group milestones for issue selection', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 200, headers: const {}, body: const []);
    });

    await client.milestones.list(
      7,
      state: 'active',
      includeAncestors: true,
      page: 2,
    );

    expect(request.queryParameters['include_ancestors'], true);
    expect(request.queryParameters['state'], 'active');
    expect(request.queryParameters['page'], 2);
  });

  test(
    'gets a milestone using its global id and maps forbidden access',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: <String, List<String>>{},
          body: {'id': 12, 'iid': 3, 'title': '10.0', 'state': 'active'},
        );
      });
      final milestone = await client.milestones.get(7, 12);
      expect(request.path, '/projects/7/milestones/12');
      expect(milestone.iid, 3);

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.milestones.list(7),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );

  test(
    'creates a project milestone with optional fields and encoded path',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 201,
          headers: <String, List<String>>{},
          body: {
            'id': 42,
            'iid': 4,
            'title': 'Release 1',
            'state': 'active',
            'description': 'Shipping scope',
            'start_date': '2026-10-01',
            'due_date': '2026-10-31',
          },
        );
      });

      final created = await client.milestones.create(
        'team/app',
        title: 'Release 1',
        description: 'Shipping scope',
        startDate: '2026-10-01',
        dueDate: '2026-10-31',
      );
      expect(request.method, 'POST');
      expect(request.path, '/projects/team%2Fapp/milestones');
      expect(request.data, {
        'title': 'Release 1',
        'description': 'Shipping scope',
        'start_date': '2026-10-01',
        'due_date': '2026-10-31',
      });
      expect(created.id, 42);
      expect(created.iid, 4);
    },
  );

  test('omits blank optional fields and maps a forbidden create', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 201,
        headers: <String, List<String>>{},
        body: {'id': 42, 'iid': 4, 'title': 'Release 1', 'state': 'active'},
      );
    });
    await client.milestones.create(7, title: 'Release 1', description: '');
    expect(request.data, {'title': 'Release 1'});

    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.milestones.create(7, title: 'Release 1'),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test(
    'updates a project milestone using its global id and encoded path',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: const <String, List<String>>{},
          body: {
            'id': 12,
            'iid': 3,
            'title': '11.0',
            'description': 'Updated scope',
            'start_date': '2026-10-01',
            'due_date': '2026-10-31',
            'state': 'active',
          },
        );
      });

      final milestone = await client.milestones.update(
        'team/app',
        12,
        title: '11.0',
        description: 'Updated scope',
        startDate: '2026-10-01',
        dueDate: '2026-10-31',
      );

      expect(request.method, 'PUT');
      expect(request.path, '/projects/team%2Fapp/milestones/12');
      expect(request.data, {
        'title': '11.0',
        'description': 'Updated scope',
        'start_date': '2026-10-01',
        'due_date': '2026-10-31',
      });
      expect(milestone.id, 12);
      expect(milestone.iid, 3);
      expect(milestone.dueDate, DateTime(2026, 10, 31));
    },
  );

  test('omits unchanged optional dates and maps forbidden update', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const <String, List<String>>{},
        body: {'id': 12, 'iid': 3, 'title': '11.0', 'state': 'active'},
      );
    });
    await client.milestones.update(7, 12, title: '11.0');
    expect(request.data, {'title': '11.0'});

    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.milestones.update(7, 12, title: '11.0'),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('explicitly clears only selected milestone dates', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const <String, List<String>>{},
        body: {
          'id': 12,
          'iid': 3,
          'title': '11.0',
          'state': 'active',
          'start_date': null,
          'due_date': '2026-10-31',
        },
      );
    });

    final milestone = await client.milestones.update(
      7,
      12,
      title: '11.0',
      clearStartDate: true,
      dueDate: '2026-10-31',
    );
    expect(request.data, {
      'title': '11.0',
      'start_date': '',
      'due_date': '2026-10-31',
    });
    expect(milestone.startDate, isNull);
    expect(milestone.dueDate, DateTime(2026, 10, 31));

    await client.milestones.update(7, 12, title: '11.0', clearDueDate: true);
    expect(request.data, {'title': '11.0', 'due_date': ''});
  });
  for (final event in ['close', 'activate']) {
    test('changes project milestone state with $event', () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: const <String, List<String>>{},
          body: {
            'id': 42,
            'iid': 4,
            'title': 'Release 1',
            'state': event == 'close' ? 'closed' : 'active',
          },
        );
      });
      final result = await client.milestones.setStateEvent(
        'team/app',
        42,
        stateEvent: event,
      );
      expect(request.method, 'PUT');
      expect(request.path, '/projects/team%2Fapp/milestones/42');
      expect(request.data, {'state_event': event});
      expect(result.id, 42);
      expect(result.iid, 4);
      expect(result.state, event == 'close' ? 'closed' : 'active');
    });
  }

  test(
    'rejects invalid milestone state events and maps forbidden writes',
    () async {
      final client = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        client.milestones.setStateEvent(7, 42, stateEvent: 'close'),
        throwsA(isA<GitLabForbiddenException>()),
      );
      await expectLater(
        client.milestones.setStateEvent(7, 42, stateEvent: 'reopen'),
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
