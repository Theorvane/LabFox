import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('updates only supplied execution fields including false', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {
          'id': 13,
          'description': 'Nightly',
          'ref': 'refs/tags/main',
          'cron': '0 1 * * *',
          'active': false,
        },
      );
    });
    final result = await client.pipelineSchedules.updateExecution(
      'team/app',
      13,
      active: false,
    );
    expect(request.method, 'PUT');
    expect(request.path, '/projects/team%2Fapp/pipeline_schedules/13');
    expect(request.data, {'active': false});
    expect(result.active, false);
    await client.pipelineSchedules.updateExecution(
      7,
      13,
      ref: 'refs/tags/main',
    );
    expect(request.data, {'ref': 'refs/tags/main'});
    await client.pipelineSchedules.updateExecution(
      7,
      13,
      ref: 'main',
      active: true,
    );
    expect(request.data, {'ref': 'main', 'active': true});
  });
  test('rejects an empty execution update response', () async {
    final client = _client((_) => (status: 200, headers: const {}, body: null));
    await expectLater(
      client.pipelineSchedules.updateExecution(7, 13, active: false),
      throwsA(isA<GitLabException>()),
    );
  });
  for (final status in [401, 403, 404, 422, 429, 500]) {
    test('maps rejected execution update $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: const {}),
      );
      await expectLater(
        client.pipelineSchedules.updateExecution(7, 13, active: false),
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

  for (final status in [200, 201]) {
    test('takes schedule ownership on encoded project $status', () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: status,
          headers: const {},
          body: {
            'id': 13,
            'description': 'Nightly',
            'ref': 'main',
            'cron': '0 1 * * *',
            'active': true,
            'owner': {'id': 50, 'name': 'New owner'},
          },
        );
      });
      final schedule = await client.pipelineSchedules.takeOwnership(
        'team/app',
        13,
      );
      expect(request.method, 'POST');
      expect(
        request.path,
        '/projects/team%2Fapp/pipeline_schedules/13/take_ownership',
      );
      expect(request.data, isNull);
      expect(request.queryParameters, isEmpty);
      expect(schedule.owner?.name, 'New owner');
    });
  }
  for (final status in [401, 403, 404, 429, 500, 202, 204]) {
    test('maps rejected ownership response $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: const {}),
      );
      await expectLater(
        client.pipelineSchedules.takeOwnership(7, 13),
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
  test(
    'supports omitted owner metadata and rejects empty successful response',
    () async {
      final client = _client(
        (_) => (
          status: 201,
          headers: const {},
          body: {
            'id': 13,
            'description': 'Nightly',
            'ref': 'main',
            'cron': '* * * * *',
            'active': true,
          },
        ),
      );
      expect(
        (await client.pipelineSchedules.takeOwnership(7, 13)).owner,
        isNull,
      );
      final empty = _client(
        (_) => (status: 201, headers: const {}, body: null),
      );
      await expectLater(
        empty.pipelineSchedules.takeOwnership(7, 13),
        throwsA(isA<GitLabException>()),
      );
    },
  );

  test('lists schedules with encoded project path and active scope', () async {
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
            'id': 13,
            'description': 'Nightly',
            'ref': 'main',
            'cron': '0 1 * * *',
            'active': true,
          },
        ],
      );
    });

    final page = await client.pipelineSchedules.list('team/app', active: true);
    expect(request.path, '/projects/team%2Fapp/pipeline_schedules');
    expect(request.queryParameters['scope'], 'active');
    expect(page.nextPage, 2);
    expect(page.items.single.id, 13);
  });

  test('loads schedule by id and runs it immediately', () async {
    final requests = <RequestOptions>[];
    final client = _client((options) {
      requests.add(options);
      return options.method == 'POST'
          ? (
              status: 201,
              headers: <String, List<String>>{},
              body: {'message': '201 Created'},
            )
          : (
              status: 200,
              headers: <String, List<String>>{},
              body: {
                'id': 13,
                'description': 'Nightly',
                'ref': 'main',
                'cron': '0 1 * * *',
                'active': true,
                'variables': [
                  {'key': 'SECRET', 'value': 'hidden'},
                ],
              },
            );
    });

    final schedule = await client.pipelineSchedules.get(7, 13);
    await client.pipelineSchedules.play(7, 13);
    expect(requests.map((request) => request.path), [
      '/projects/7/pipeline_schedules/13',
      '/projects/7/pipeline_schedules/13/play',
    ]);
    expect(requests.last.method, 'POST');
    expect(schedule.toJson().toString(), isNot(contains('hidden')));
  });

  test('maps forbidden play response', () async {
    final client = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      client.pipelineSchedules.play(7, 13),
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
