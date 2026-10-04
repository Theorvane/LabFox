import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const target = {
  'id': 'gid://gitlab/Ci::Pipeline/33',
  'iid': '2',
  'status': 'RUNNING',
  'ref': 'release/v1',
  'project': {'id': 'gid://gitlab/Project/8'},
};
Map<String, dynamic> response(Object? upstream) => {
  'data': {
    'project': {
      'id': 'gid://gitlab/Project/7',
      'pipeline': {'id': 'gid://gitlab/Ci::Pipeline/944', 'upstream': upstream},
    },
  },
};
GitLabClient client(
  ({int status, Object? body}) Function(RequestOptions) handler,
) {
  final dio = Dio()..httpClientAdapter = Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com/subpath',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

void main() {
  test(
    'selects named upstream query with exact source global identity and JSON variables',
    () async {
      final c = client((r) {
        expect(
          r.uri.toString(),
          'https://gitlab.example.com/subpath/api/graphql',
        );
        expect(r.method, 'POST');
        expect(r.data['operationName'], 'PipelineUpstream');
        expect(r.data['variables'], {
          'fullPath': 'team/app',
          'pipelineId': 'gid://gitlab/Ci::Pipeline/944',
        });
        expect(r.data['query'], contains(r'pipeline(id: $pipelineId)'));
        expect(r.data['query'], contains('upstream'));
        expect(r.data['query'], isNot(contains('iid')));
        return (status: 200, body: response(target));
      });
      addTearDown(c.close);
      final upstream = await c.pipelineRelations.upstream(
        'team/app',
        projectId: 7,
        pipelineId: 944,
      );
      expect(upstream?.pipelineId, 33);
      expect(upstream?.projectId, 8);
    },
  );
  test(
    'explicit null upstream is unavailable without inferring a parent',
    () async {
      final c = client((_) => (status: 200, body: response(null)));
      addTearDown(c.close);
      expect(
        await c.pipelineRelations.upstream(
          'team/app',
          projectId: 7,
          pipelineId: 944,
        ),
        isNull,
      );
    },
  );
  test(
    'explicit null target project retains noninteractive target metadata',
    () async {
      final c = client(
        (_) => (status: 200, body: response({...target, 'project': null})),
      );
      addTearDown(c.close);
      final v = await c.pipelineRelations.upstream(
        'team/app',
        projectId: 7,
        pipelineId: 944,
      );
      expect(v?.pipelineId, 33);
      expect(v?.projectId, isNull);
    },
  );
  final missingRef = {...target}..remove('ref');
  final missingProject = {...target}..remove('project');
  final malformed = <Object?>[
    {},
    {'project': {}},
    {
      'project': {
        'id': 'gid://gitlab/Project/8',
        'pipeline': {'id': 'gid://gitlab/Ci::Pipeline/944', 'upstream': target},
      },
    },
    {
      'project': {
        'id': 'gid://gitlab/Project/7',
        'pipeline': {'id': 'gid://gitlab/Ci::Pipeline/2', 'upstream': target},
      },
    },
    {
      'project': {
        'id': 'gid://gitlab/Project/7',
        'pipeline': {'id': 'gid://gitlab/Ci::Pipeline/944'},
      },
    },
    for (final v in [
      1,
      {},
      missingRef,
      missingProject,
      {...target, 'id': 'gid://gitlab/Project/33'},
      {...target, 'project': {}},
      {
        ...target,
        'project': {'id': 'gid://gitlab/Group/8'},
      },
      {...target, 'status': null},
      {...target, 'status': ''},
    ])
      response(v)['data'],
  ];
  for (var i = 0; i < malformed.length; i++) {
    test('rejects malformed or mismatched relationship $i', () async {
      final c = client((_) => (status: 200, body: {'data': malformed[i]}));
      addTearDown(c.close);
      await expectLater(
        c.pipelineRelations.upstream('team/app', projectId: 7, pipelineId: 944),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final v in [
    {'project': null},
    {
      'project': {'id': 'gid://gitlab/Project/7', 'pipeline': null},
    },
  ]) {
    test(
      'unavailable source is an error rather than a null upstream: $v',
      () async {
        final c = client((_) => (status: 200, body: {'data': v}));
        addTearDown(c.close);
        await expectLater(
          c.pipelineRelations.upstream(
            'team/app',
            projectId: 7,
            pipelineId: 944,
          ),
          throwsA(isA<GitLabNotFoundException>()),
        );
      },
    );
  }
  test(
    'GraphQL partial data and unsupported schema errors are sanitized',
    () async {
      final c = client(
        (_) => (
          status: 200,
          body: {
            ...response(target),
            'errors': [
              {'message': 'private unknown field upstream'},
            ],
          },
        ),
      );
      addTearDown(c.close);
      await expectLater(
        c.pipelineRelations.upstream('team/app', projectId: 7, pipelineId: 944),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'message',
            isNot(contains('private')),
          ),
        ),
      );
    },
  );
  for (final code in [401, 403, 404, 429, 500]) {
    test('HTTP $code maps to a domain error in a single request', () async {
      var count = 0;
      final c = client((_) {
        count++;
        return (status: code, body: {'message': 'private'});
      });
      addTearDown(c.close);
      await expectLater(
        c.pipelineRelations.upstream('team/app', projectId: 7, pipelineId: 944),
        throwsA(isA<GitLabException>()),
      );
      expect(count, 1);
    });
  }
  test('transport failures do not leak Dio', () async {
    final c = client((r) {
      throw DioException(
        requestOptions: r,
        type: DioExceptionType.connectionError,
        error: 'private',
      );
    });
    addTearDown(c.close);
    await expectLater(
      c.pipelineRelations.upstream('team/app', projectId: 7, pipelineId: 944),
      throwsA(isA<GitLabConnectionException>()),
    );
  });
  test('invalid source identity is rejected before dispatch', () async {
    var count = 0;
    final c = client((_) {
      count++;
      return (status: 200, body: response(target));
    });
    addTearDown(c.close);
    for (final a in [
      (path: ' ', project: 7, pipeline: 944),
      (path: 'team/app', project: 0, pipeline: 944),
      (path: 'team/app', project: 7, pipeline: 0),
    ]) {
      await expectLater(
        c.pipelineRelations.upstream(
          a.path,
          projectId: a.project,
          pipelineId: a.pipeline,
        ),
        throwsArgumentError,
      );
    }
    expect(count, 0);
  });
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final ({int status, Object? body}) Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final r = handler(options);
    return ResponseBody.fromString(
      jsonEncode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
