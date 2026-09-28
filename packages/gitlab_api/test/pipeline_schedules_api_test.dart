import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('updates only supplied schedule fields on encoded project', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: <String, List<String>>{},
        body: {
          'id': 13,
          'description': 'Weekly',
          'ref': 'main',
          'cron': '0 1 * * *',
          'active': true,
        },
      );
    });
    final result = await client.pipelineSchedules.update(
      'team/app',
      13,
      description: 'Weekly',
    );
    expect(request.method, 'PUT');
    expect(request.path, '/projects/team%2Fapp/pipeline_schedules/13');
    expect(request.data, {'description': 'Weekly'});
    expect(result.description, 'Weekly');
    await client.pipelineSchedules.update(
      7,
      13,
      cron: '0 2 * * *',
      cronTimezone: 'America/New_York',
    );
    expect(request.data, {
      'cron': '0 2 * * *',
      'cron_timezone': 'America/New_York',
    });
  });

  for (final status in [400, 403, 422]) {
    test('maps rejected schedule update $status to a domain error', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: const {}),
      );
      await expectLater(
        client.pipelineSchedules.update(7, 13, cron: 'invalid'),
        throwsA(isA<GitLabException>()),
      );
    });
  }

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
