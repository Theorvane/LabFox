import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';

class Adapter implements HttpClientAdapter {
  final scopes = <Object?>[];
  final attempts = <Object?>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? stream,
    Future<dynamic>? cancel,
  ) async {
    scopes.add(o.queryParameters['scope']);
    attempts.add(o.queryParameters['include_retried']);
    final page = o.queryParameters['page'];
    return ResponseBody.fromString(
      jsonEncode([
        {'id': page, 'name': 'same-job', 'status': 'failed'},
      ]),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'x-next-page': [page == 1 ? '4' : ''],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'repository forwards attempts and status across all API pages',
    () async {
      final adapter = Adapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final client = GitLabClient(
        baseUrl: 'https://gitlab.example.com/subpath',
        token: 'glpat-xxxxxxxxxxxx',
        dio: dio,
      );
      addTearDown(client.close);
      final jobs = await PipelinesRepository(client).jobs(
        projectId: 7,
        pipelineId: 944,
        status: PipelineJobStatusFilter.failed,
        includeRetried: true,
      );
      expect(adapter.scopes, ['failed', 'failed']);
      expect(adapter.attempts, [true, true]);
      expect(jobs.map((j) => j.name), ['same-job', 'same-job']);
      expect(jobs.map((j) => j.id), [1, 4]);
    },
  );
}
