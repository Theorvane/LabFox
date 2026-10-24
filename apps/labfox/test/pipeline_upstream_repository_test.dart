import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final Object? Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<dynamic>? cancel,
  ) async => ResponseBody.fromString(
    jsonEncode(handler(options)),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'resolves current REST identity before the named relationship query',
    () async {
      final paths = <String>[];
      final dio = Dio()
        ..httpClientAdapter = Adapter((r) {
          paths.add(r.path);
          if (r.method == 'GET') {
            return {'id': 7, 'name': 'app', 'path_with_namespace': 'team/app'};
          }
          expect(r.data['variables'], {
            'fullPath': 'team/app',
            'pipelineId': 'gid://gitlab/Ci::Pipeline/944',
          });
          return {
            'data': {
              'project': {
                'id': 'gid://gitlab/Project/7',
                'pipeline': {
                  'id': 'gid://gitlab/Ci::Pipeline/944',
                  'upstream': {
                    'id': 'gid://gitlab/Ci::Pipeline/33',
                    'status': 'RUNNING',
                    'ref': null,
                    'project': {'id': 'gid://gitlab/Project/8'},
                  },
                },
              },
            },
          };
        });
      final client = GitLabClient(
        baseUrl: 'https://gitlab.example.com/subpath',
        token: 'glpat-xxxxxxxxxxxx',
        dio: dio,
      );
      addTearDown(client.close);
      final v = await PipelinesRepository(
        client,
      ).upstream(projectId: 7, pipelineId: 944);
      expect(v?.pipelineId, 33);
      expect(paths.length, 2);
      expect(paths.first, '/projects/7');
      expect(paths.last, 'https://gitlab.example.com/subpath/api/graphql');
    },
  );
  for (final project in [
    {'id': 8, 'name': 'app', 'path_with_namespace': 'team/app'},
    {'id': 7, 'name': 'app', 'path_with_namespace': ' '},
    {'id': 7, 'name': 'app'},
  ]) {
    test(
      'does not dispatch GraphQL for invalid REST project identity $project',
      () async {
        var count = 0;
        final dio = Dio()
          ..httpClientAdapter = Adapter((r) {
            count++;
            expect(r.method, 'GET');
            return project;
          });
        final client = GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
          dio: dio,
        );
        addTearDown(client.close);
        await expectLater(
          PipelinesRepository(client).upstream(projectId: 7, pipelineId: 944),
          throwsA(isA<GitLabServerException>()),
        );
        expect(count, 1);
      },
    );
  }
}
