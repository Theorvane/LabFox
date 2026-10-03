import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test('schedules cleanup with encoded IDs and exact JSON criteria', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 202, headers: const {}, body: const {});
    });
    await client.containerRegistry.deleteTags(
      'team/app',
      3,
      nameRegexDelete: '^release.+',
      nameRegexKeep: r'^stable$',
      keepN: 10,
      olderThan: '7d',
    );
    expect(request.method, 'DELETE');
    expect(request.contentType, Headers.jsonContentType);
    expect(request.path, '/projects/team%2Fapp/registry/repositories/3/tags');
    expect(request.data, {
      'name_regex_delete': '^release.+',
      'name_regex_keep': r'^stable$',
      'keep_n': 10,
      'older_than': '7d',
    });
  });

  test('omits optional criteria and preserves zero retention', () async {
    final bodies = <Object?>[];
    final client = _client((options) {
      bodies.add(options.data);
      return (status: 202, headers: const {}, body: const {});
    });
    await client.containerRegistry.deleteTags(7, 3, nameRegexDelete: '.*');
    await client.containerRegistry.deleteTags(
      7,
      3,
      nameRegexDelete: '.*',
      keepN: 0,
    );
    expect(bodies, [
      {'name_regex_delete': '.*'},
      {'name_regex_delete': '.*', 'keep_n': 0},
    ]);
  });

  for (final status in [200, 204, 400, 401, 403, 404, 422, 429, 500]) {
    test(
      'does not accept cleanup HTTP $status as scheduling success',
      () async {
        final client = _client(
          (_) => (status: status, headers: const {}, body: const {}),
        );
        await expectLater(
          client.containerRegistry.deleteTags(7, 3, nameRegexDelete: '.*'),
          throwsA(
            isA<GitLabException>().having(
              (e) => e.statusCode,
              'status',
              status,
            ),
          ),
        );
      },
    );
  }

  test(
    'maps cleanup permission, authentication and rate errors distinctly',
    () async {
      for (final (status, matcher) in [
        (401, isA<GitLabAuthException>()),
        (403, isA<GitLabForbiddenException>()),
        (404, isA<GitLabNotFoundException>()),
        (429, isA<GitLabRateLimitException>()),
      ]) {
        final client = _client(
          (_) => (status: status, headers: const {}, body: const {}),
        );
        await expectLater(
          client.containerRegistry.deleteTags(7, 3, nameRegexDelete: 'release'),
          throwsA(matcher),
        );
      }
    },
  );

  test(
    'maps cleanup transport failure without leaking Dio exceptions',
    () async {
      final client = _client(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        client.containerRegistry.deleteTags(7, 3, nameRegexDelete: 'release'),
        throwsA(isA<GitLabConnectionException>()),
      );
    },
  );

  test(
    'lists repository protection rules using an encoded project path',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: const {},
          body: [
            {
              'id': 2,
              'project_id': 7,
              'repository_path_pattern': 'team/app/*',
              'minimum_access_level_for_push': null,
              'minimum_access_level_for_delete': 'owner',
            },
          ],
        );
      });
      final rules = await client.containerRegistry
          .listRepositoryProtectionRules('team/project');
      expect(request.method, 'GET');
      expect(
        request.path,
        '/projects/team%2Fproject/registry/protection/repository/rules',
      );
      expect(request.queryParameters, isEmpty);
      expect(rules.single.repositoryPathPattern, 'team/app/*');
      expect(rules.single.minimumAccessLevelForPush, isNull);
      expect(rules.single.minimumAccessLevelForDelete, 'owner');
    },
  );
  test('empty protection rules remain an empty list', () async {
    final client = _client((_) => (status: 200, headers: const {}, body: []));
    expect(
      await client.containerRegistry.listRepositoryProtectionRules(7),
      isEmpty,
    );
  });
  for (final status in [401, 403, 404, 429, 500]) {
    test('maps rejected protection rule reads $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.containerRegistry.listRepositoryProtectionRules(7),
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
  test('schedules deletion of the exact encoded project repository', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 202, headers: const {}, body: null);
    });
    await client.containerRegistry.deleteRepository('team/project', 3);
    expect(request.method, 'DELETE');
    expect(request.path, '/projects/team%2Fproject/registry/repositories/3');
    expect(request.data, isNull);
    expect(request.queryParameters, isEmpty);
  });
  for (final status in [200, 204, 401, 403, 404, 429, 500]) {
    test('maps rejected or unconfirmed repository deletion $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.containerRegistry.deleteRepository(7, 3),
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
  test('deletes one encoded tag without deleting its repository', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (status: 204, headers: const {}, body: null);
    });
    await client.containerRegistry.deleteTag(
      'team/project',
      3,
      'release/1+test',
    );
    expect(request.method, 'DELETE');
    expect(
      request.path,
      '/projects/team%2Fproject/registry/repositories/3/tags/release%2F1%2Btest',
    );
    expect(request.data, isNull);
    expect(request.queryParameters, isEmpty);
  });
  for (final status in [200, 202, 401, 403, 404, 429, 500]) {
    test('maps rejected or unconfirmed tag deletion $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.containerRegistry.deleteTag(7, 3, 'v1'),
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
  for (final body in [
    null,
    <String, dynamic>{},
    [null],
    [{}],
    [
      {'id': 2, 'project_id': 7, 'tag_name_pattern': false},
    ],
  ]) {
    test('malformed tag rule list becomes a safe domain error $body', () async {
      final client = _client(
        (_) => (status: 200, headers: const {}, body: body),
      );
      await expectLater(
        client.containerRegistry.listTagProtectionRules(7),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  test('only HTTP 200 is a successful tag rule read', () async {
    final client = _client((_) => (status: 204, headers: const {}, body: []));
    await expectLater(
      client.containerRegistry.listTagProtectionRules(7),
      throwsA(
        isA<GitLabServerException>().having((e) => e.statusCode, 'status', 204),
      ),
    );
  });
  test('maps tag rule transport errors without leaking Dio', () async {
    final client = _client(
      (options) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      client.containerRegistry.listTagProtectionRules(7),
      throwsA(isA<GitLabConnectionException>()),
    );
  });
  test('lists tag protection rules using an encoded project path', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: [
          {
            'id': 2,
            'project_id': 7,
            'tag_name_pattern': 'v*-release',
            'minimum_access_level_for_push': null,
            'minimum_access_level_for_delete': 'owner',
          },
        ],
      );
    });
    final rules = await client.containerRegistry.listTagProtectionRules(
      'team/project',
    );
    expect(request.method, 'GET');
    expect(
      request.path,
      '/projects/team%2Fproject/registry/protection/tag/rules',
    );
    expect(request.queryParameters, isEmpty);
    expect(rules.single.tagNamePattern, 'v*-release');
    expect(rules.single.minimumAccessLevelForPush, isNull);
    expect(rules.single.minimumAccessLevelForDelete, 'owner');
  });
  test('empty protection rules remain an empty list', () async {
    final client = _client((_) => (status: 200, headers: const {}, body: []));
    expect(await client.containerRegistry.listTagProtectionRules(7), isEmpty);
  });
  for (final status in [401, 403, 404, 429, 500]) {
    test('maps rejected protection rule reads $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.containerRegistry.listTagProtectionRules(7),
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
  test('lists image repositories with pagination', () async {
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
            'id': 3,
            'name': 'service',
            'path': 'team/app/service',
            'project_id': 7,
            'location': 'registry.example.com/team/app/service',
          },
        ],
      );
    });

    final page = await client.containerRegistry.listRepositories(7);
    expect(request.path, '/projects/7/registry/repositories');
    expect(request.queryParameters['page'], 1);
    expect(page.items.single.name, 'service');
    expect(page.nextPage, 2);
  });

  test('lists tags and URL-encodes tag names in detail paths', () async {
    final paths = <String>[];
    final client = _client((options) {
      paths.add(options.path);
      if (paths.length == 1) {
        return (
          status: 200,
          headers: {
            'x-next-page': ['2'],
          },
          body: [
            {'name': 'release/1', 'path': 'team/app:release/1'},
          ],
        );
      }
      return (
        status: 200,
        headers: <String, List<String>>{},
        body: {
          'name': 'release/1',
          'path': 'team/app:release/1',
          'digest': 'sha256:abc',
          'total_size': 42,
        },
      );
    });

    final tags = await client.containerRegistry.listTags(7, 3);
    final detail = await client.containerRegistry.getTag(7, 3, 'release/1');
    expect(paths, [
      '/projects/7/registry/repositories/3/tags',
      '/projects/7/registry/repositories/3/tags/release%2F1',
    ]);
    expect(tags.nextPage, 2);
    expect(detail.digest, 'sha256:abc');
    expect(detail.totalSize, 42);
  });

  test('maps forbidden registry access', () async {
    final client = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      client.containerRegistry.listRepositories(7),
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
