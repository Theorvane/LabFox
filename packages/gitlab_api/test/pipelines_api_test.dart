import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('PipelinesApi.triggerJobs', () {
    test(
      'uses the modern endpoint, encoded project path and header cursor',
      () async {
        RequestOptions? captured;
        final client = _client((options) {
          captured = options;
          return (
            status: 200,
            headers: {
              'x-next-page': ['9'],
            },
            body: [
              {
                'id': 10,
                'name': 'deploy',
                'status': 'success',
                'downstream_pipeline': {
                  'id': 33,
                  'project_id': 8,
                  'status': 'running',
                },
              },
            ],
          );
        });
        final page = await client.pipelines.triggerJobs(
          'team/app',
          pipelineId: 944,
          page: 4,
          perPage: 10,
        );
        expect(
          captured?.path,
          '/projects/team%2Fapp/pipelines/944/trigger_jobs',
        );
        expect(captured?.queryParameters, {'page': 4, 'per_page': 10});
        expect(page.nextPage, 9);
        expect(page.items.single.downstreamPipeline?.projectId, 8);
      },
    );
    for (final strict in [false, true]) {
      test('only a 404 selects the legacy route with strict=$strict', () async {
        final paths = <String>[];
        final client = _client((options) {
          paths.add(options.path);
          if (options.path.endsWith('/trigger_jobs')) {
            return (
              status: 404,
              headers: const {},
              body: {'message': 'Not found'},
            );
          }
          expect(options.queryParameters, {'page': 4, 'per_page': 20});
          return (
            status: 200,
            headers: {
              'x-next-page': ['9'],
            },
            body: [
              {'id': 10, 'name': 'deploy', 'status': 'pending'},
            ],
          );
        }, strict404: strict);
        final result = await client.pipelines.triggerJobs(
          7,
          pipelineId: 944,
          page: 4,
        );
        expect(paths, [
          '/projects/7/pipelines/944/trigger_jobs',
          '/projects/7/pipelines/944/bridges',
        ]);
        expect(result.nextPage, 9);
        expect(result.items.single.downstreamPipeline, isNull);
      });
    }
    for (final code in [401, 403, 404, 429, 500]) {
      test(
        'HTTP $code is a domain error and does not retry other failures',
        () async {
          final paths = <String>[];
          final client = _client((options) {
            paths.add(options.path);
            return (
              status: code,
              headers: const {},
              body: {'message': 'private server response'},
            );
          });
          await expectLater(
            client.pipelines.triggerJobs(7, pipelineId: 944),
            throwsA(isA<GitLabException>()),
          );
          expect(paths.length, code == 404 ? 2 : 1);
        },
      );
    }
  });

  test(
    'trigger jobs map transport failures without leaking Dio exceptions',
    () async {
      final client = _client((options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'private payload',
        );
      });
      await expectLater(
        client.pipelines.triggerJobs(7, pipelineId: 944),
        throwsA(isA<GitLabConnectionException>()),
      );
    },
  );

  group('PipelinesApi.list', () {
    for (final entry in <PipelineSourceFilter, String>{
      PipelineSourceFilter.push: 'push',
      PipelineSourceFilter.web: 'web',
      PipelineSourceFilter.api: 'api',
      PipelineSourceFilter.schedule: 'schedule',
      PipelineSourceFilter.trigger: 'trigger',
      PipelineSourceFilter.pipeline: 'pipeline',
      PipelineSourceFilter.mergeRequestEvent: 'merge_request_event',
      PipelineSourceFilter.parentPipeline: 'parent_pipeline',
    }.entries) {
      test(
        'sends documented source ${entry.value} with status, ref and cursor',
        () async {
          late RequestOptions captured;
          final client = _client((options) {
            captured = options;
            return (
              status: 200,
              headers: {
                'x-next-page': ['9'],
              },
              body: [
                {'id': 33, 'status': 'failed', 'source': entry.value},
              ],
            );
          });
          final result = await client.pipelines.list(
            'team/app',
            page: 4,
            source: entry.key,
            status: PipelineStatusFilter.failed,
            ref: 'release/v1+fix',
          );
          expect(captured.path, '/projects/team%2Fapp/pipelines');
          expect(captured.queryParameters, {
            'page': 4,
            'per_page': 20,
            'order_by': 'id',
            'sort': 'desc',
            'source': entry.value,
            'status': 'failed',
            'ref': 'release/v1+fix',
          });
          expect(result.nextPage, 9);
          expect(result.items.single.source, entry.value);
        },
      );
    }
    test(
      'denied child listing stays a domain error rather than falling back to unfiltered results',
      () async {
        final client = _client(
          (_) => (
            status: 403,
            headers: const {},
            body: {'message': 'private server response'},
          ),
        );
        await expectLater(
          client.pipelines.list(7, source: PipelineSourceFilter.parentPipeline),
          throwsA(isA<GitLabForbiddenException>()),
        );
      },
    );

    test(
      'sends the exact branch or tag together with status and pagination',
      () async {
        late RequestOptions captured;
        final client = _client((options) {
          captured = options;
          return (status: 200, headers: const {}, body: []);
        });
        await client.pipelines.list(
          'team/app',
          page: 4,
          ref: 'release/\u65e5\u672c\u8a9e+v1',
          status: PipelineStatusFilter.failed,
        );
        expect(
          captured.queryParameters['ref'],
          'release/\u65e5\u672c\u8a9e+v1',
        );
        expect(captured.queryParameters['status'], 'failed');
        expect(captured.queryParameters['page'], 4);
        expect(
          Uri.splitQueryString(captured.uri.query)['ref'],
          'release/\u65e5\u672c\u8a9e+v1',
        );
      },
    );

    test(
      'uses the requested page and explicit newest-first ordering',
      () async {
        late RequestOptions captured;
        final client = _client((options) {
          captured = options;
          return (status: 200, headers: const {}, body: []);
        });
        final result = await client.pipelines.list(
          'team/app',
          page: 4,
          perPage: 10,
        );
        expect(captured.path, '/projects/team%2Fapp/pipelines');
        expect(captured.queryParameters, {
          'page': 4,
          'per_page': 10,
          'order_by': 'id',
          'sort': 'desc',
        });
        expect(result.nextPage, isNull);
      },
    );
    for (final status in PipelineStatusFilter.values) {
      test('sends exact $status on header-based continuation pages', () async {
        late RequestOptions captured;
        final client = _client((options) {
          captured = options;
          return (
            status: 200,
            headers: {
              'x-next-page': ['9'],
            },
            body: [
              {'id': 1, 'status': status.name},
            ],
          );
        });
        final result = await client.pipelines.list(
          'team/app',
          page: 4,
          status: status,
        );
        expect(captured.path, '/projects/team%2Fapp/pipelines');
        expect(captured.queryParameters, {
          'page': 4,
          'per_page': 20,
          'order_by': 'id',
          'sort': 'desc',
          'status': status.name,
        });
        expect(result.nextPage, 9);
        expect(result.items.single.status, status.name);
      });
    }
    test('maps denied filtered reads to a sanitized domain error', () async {
      final client = _client(
        (_) => (
          status: 403,
          headers: const {},
          body: {'message': 'private server response'},
        ),
      );
      await expectLater(
        client.pipelines.list(7, status: PipelineStatusFilter.failed),
        throwsA(isA<GitLabForbiddenException>()),
      );
    });
    test('lists pipelines with pagination', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': 944, 'status': 'failed', 'ref': 'main'},
          ],
        );
      });

      final page = await client.pipelines.list(42);

      expect(captured.path, '/projects/42/pipelines');
      expect(page.items.single.ciStatus, CiStatus.failed);
      expect(page.nextPage, 2);
    });
  });

  group('PipelinesApi.get', () {
    test('fetches one pipeline', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: {'id': 944, 'status': 'success', 'ref': 'main'},
        );
      });

      final p = await client.pipelines.get(42, pipelineId: 944);

      expect(captured.path, '/projects/42/pipelines/944');
      expect(p.ciStatus, CiStatus.success);
    });

    test('maps a 404 to not found', () async {
      final client = _client(
        (_) => (status: 404, headers: const {}, body: const {}),
      );
      await expectLater(
        client.pipelines.get(1, pipelineId: 9),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  });

  group('PipelinesApi.jobs', () {
    for (final filter in PipelineJobStatusFilter.values) {
      test(
        'maps job filter ${filter.name} to scalar scope across every header page',
        () async {
          final pages = <int>[];
          final c = _client((o) {
            final page = o.queryParameters['page'] as int;
            pages.add(page);
            expect(o.path, '/projects/team%2Fapp/pipelines/944/jobs');
            expect(o.queryParameters, {
              'page': page,
              'per_page': 10,
              'scope': filter.name,
            });
            return (
              status: 200,
              headers: {
                'x-next-page': [
                  page == 1
                      ? '4'
                      : page == 4
                      ? '9'
                      : '',
                ],
              },
              body: page == 4
                  ? []
                  : [
                      {'id': page, 'name': 'job-$page', 'status': filter.name},
                    ],
            );
          });
          final jobs = await c.pipelines.jobs(
            'team/app',
            pipelineId: 944,
            perPage: 10,
            status: filter,
          );
          expect(pages, [1, 4, 9]);
          expect(jobs.map((j) => j.id), [1, 9]);
        },
      );
    }
    test(
      'no filter omits scope and preserves newer response statuses and retry defaults',
      () async {
        final c = _client((o) {
          expect(o.queryParameters, {'page': 1, 'per_page': 100});
          return (
            status: 200,
            headers: const {},
            body: [
              {'id': 1, 'name': 'callback', 'status': 'waiting_for_callback'},
            ],
          );
        });
        expect(
          (await c.pipelines.jobs(7, pipelineId: 944)).single.status,
          'waiting_for_callback',
        );
      },
    );
    for (final code in [401, 403, 404, 429, 500]) {
      test(
        'filtered page HTTP $code discards incomplete results without unfiltered fallback',
        () async {
          var count = 0;
          final c = _client((o) {
            count++;
            expect(o.queryParameters['scope'], 'failed');
            return count == 1
                ? (
                    status: 200,
                    headers: {
                      'x-next-page': ['4'],
                    },
                    body: [
                      {'id': 1, 'name': 'first', 'status': 'failed'},
                    ],
                  )
                : (
                    status: code,
                    headers: const {},
                    body: {'message': 'private payload'},
                  );
          });
          await expectLater(
            c.pipelines.jobs(
              7,
              pipelineId: 944,
              status: PipelineJobStatusFilter.failed,
            ),
            throwsA(isA<GitLabException>()),
          );
          expect(count, 2);
        },
      );
    }

    test('lists a pipeline\'s jobs', () async {
      late RequestOptions captured;
      final client = _client((o) {
        captured = o;
        return (
          status: 200,
          headers: const {},
          body: [
            {'id': 1, 'name': 'compile', 'stage': 'build', 'status': 'success'},
            {'id': 2, 'name': 'unit-test', 'stage': 'test', 'status': 'failed'},
          ],
        );
      });

      final jobs = await client.pipelines.jobs(42, pipelineId: 944);

      expect(captured.path, '/projects/42/pipelines/944/jobs');
      expect(jobs.map((j) => j.name), ['compile', 'unit-test']);
    });

    test('follows pagination so no jobs are silently dropped', () async {
      // A pipeline with more jobs than one page: the first page reports a next
      // page, the second is the last. All jobs must come back, or stage groups
      // are incomplete while the UI presents them as the whole pipeline.
      final pages = <int, List<Map<String, dynamic>>>{
        1: [
          {'id': 1, 'name': 'a', 'stage': 'build', 'status': 'success'},
        ],
        2: [
          {'id': 2, 'name': 'b', 'stage': 'test', 'status': 'success'},
        ],
      };
      final client = _client((o) {
        final page = int.parse('${o.queryParameters['page'] ?? 1}');
        return (
          status: 200,
          headers: {
            'x-next-page': [page < 2 ? '${page + 1}' : ''],
          },
          body: pages[page] ?? const [],
        );
      });

      final jobs = await client.pipelines.jobs(42, pipelineId: 944);

      expect(jobs.map((j) => j.name), ['a', 'b']);
    });
  });
}

GitLabClient _client(
  ({int status, Map<String, List<String>> headers, Object? body}) Function(
    RequestOptions,
  )
  handler, {
  bool strict404 = false,
}) {
  final dio = Dio(
    BaseOptions(
      validateStatus: (s) => s != null && s < (strict404 ? 400 : 500),
    ),
  );
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
