import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  for (final status in PipelineJobStatusFilter.values) {
    for (final attempts in [false, true]) {
      test(
        'one jobs page preserves ${status.name} attempts=$attempts and header cursor',
        () async {
          var calls = 0;
          final c = _client((o) {
            calls++;
            expect(o.path, '/projects/team%2Fapp/pipelines/944/jobs');
            expect(o.queryParameters, {
              'page': 4,
              'per_page': 10,
              'scope': status.name,
              if (attempts) 'include_retried': true,
            });
            return (
              status: 200,
              headers: {
                'x-next-page': ['9'],
              },
              body: [
                {'id': 9, 'name': 'same', 'status': status.name},
                {'id': 8, 'name': 'same', 'status': status.name},
              ],
            );
          });
          addTearDown(c.close);
          final p = await c.pipelines.jobsPage(
            'team/app',
            pipelineId: 944,
            page: 4,
            perPage: 10,
            status: status,
            includeRetried: attempts,
          );
          expect(calls, 1);
          expect(p.nextPage, 9);
          expect(p.total, isNull);
          expect(p.items.map((j) => j.id), [9, 8]);
        },
      );
    }
  }
  test(
    'default page omits filters and keeps unknown response statuses',
    () async {
      final c = _client((o) {
        expect(o.queryParameters, {'page': 1, 'per_page': 20});
        expect(o.path, '/projects/7/pipelines/944/jobs');
        return (
          status: 200,
          headers: const {},
          body: [
            {'id': 1, 'name': 'callback', 'status': 'waiting_for_callback'},
          ],
        );
      });
      addTearDown(c.close);
      final p = await c.pipelines.jobsPage(7, pipelineId: 944);
      expect(p.items.single.status, 'waiting_for_callback');
      expect(p.nextPage, isNull);
    },
  );
  test(
    'an empty continuation page retains its server cursor and optional totals',
    () async {
      final c = _client(
        (o) => (
          status: 200,
          headers: {
            'x-next-page': ['9'],
            'x-total': ['40'],
            'x-total-pages': ['2'],
          },
          body: [],
        ),
      );
      addTearDown(c.close);
      final p = await c.pipelines.jobsPage(7, pipelineId: 944, page: 4);
      expect(p.items, isEmpty);
      expect(p.nextPage, 9);
      expect(p.total, 40);
    },
  );
  for (final body in <Object?>[
    null,
    {'message': 'private'},
    [null],
    [{}],
    [
      {'id': 'private', 'name': 'test', 'status': 'failed'},
    ],
    [
      {'id': 1, 'name': 'valid', 'status': 'failed'},
      {'id': 2},
    ],
  ]) {
    test(
      'malformed successful jobs payload ${body.runtimeType} is a sanitized domain error: $body',
      () async {
        final c = _client((o) => (status: 200, headers: const {}, body: body));
        addTearDown(c.close);
        await expectLater(
          c.pipelines.jobsPage(7, pipelineId: 944),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message,
              'sanitized message',
              isNot(contains('private')),
            ),
          ),
        );
      },
    );
  }
  for (final cursor in ['x', '0', '1', '-2']) {
    test(
      'invalid or nonadvancing jobs cursor $cursor does not silently truncate',
      () async {
        final c = _client(
          (o) => (
            status: 200,
            headers: {
              'x-next-page': [cursor],
            },
            body: [],
          ),
        );
        addTearDown(c.close);
        await expectLater(
          c.pipelines.jobsPage(7, pipelineId: 944),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  for (final strict in [false, true]) {
    for (final code in [401, 403, 404, 429, 500]) {
      test(
        'jobs page HTTP $code strict=$strict remains a typed single request',
        () async {
          var calls = 0;
          final c = _client((o) {
            calls++;
            expect(o.queryParameters['scope'], 'failed');
            expect(o.queryParameters['include_retried'], true);
            return (
              status: code,
              headers: const {},
              body: {'message': 'private'},
            );
          }, strict404: strict);
          addTearDown(c.close);
          await expectLater(
            c.pipelines.jobsPage(
              7,
              pipelineId: 944,
              page: 4,
              status: PipelineJobStatusFilter.failed,
              includeRetried: true,
            ),
            throwsA(isA<GitLabException>()),
          );
          expect(calls, 1);
        },
      );
    }
  }
  test(
    'all-pages helper rejects a repeated cursor before requesting it again',
    () async {
      var calls = 0;
      final c = _client((o) {
        calls++;
        if (calls > 2) throw StateError('Repeated cursor dispatched');
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'id': calls, 'name': 'test', 'status': 'failed'},
          ],
        );
      });
      addTearDown(c.close);
      await expectLater(
        c.pipelines.jobs(7, pipelineId: 944),
        throwsA(isA<GitLabServerException>()),
      );
      expect(calls, 2);
    },
  );
  test('transport failure is translated to a safe connection error', () async {
    final c = _client(
      (o) => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
        error: 'private',
      ),
    );
    addTearDown(c.close);
    await expectLater(
      c.pipelines.jobsPage(7, pipelineId: 944),
      throwsA(isA<GitLabConnectionException>()),
    );
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
    baseUrl: 'https://gitlab.example.com/subpath',
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
