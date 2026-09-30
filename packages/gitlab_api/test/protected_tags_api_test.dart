import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  for (final role in [0, 30, 40]) {
    test(
      'creates encoded project rule with only explicit role $role',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (
            status: 201,
            headers: const {},
            body: {
              'name': 'release/*',
              'create_access_levels': [
                {'access_level': role},
              ],
            },
          );
        });
        final rule = await client.protectedTags.protect(
          'team/app',
          name: 'release/*',
          createAccessLevel: role,
        );
        expect(request.method, 'POST');
        expect(request.path, '/projects/team%2Fapp/protected_tags');
        expect(request.data, {
          'name': 'release/*',
          'create_access_level': role,
        });
        expect(request.followRedirects, isFalse);
        expect(rule.name, 'release/*');
        expect(rule.createAccessLevels.single.accessLevel, role);
      },
    );
  }
  for (final role in [-1, 10, 20, 50]) {
    test('unsupported role $role never dispatches', () async {
      var calls = 0;
      final client = _client((options) {
        calls++;
        return (status: 201, headers: const {}, body: {});
      });
      await expectLater(
        client.protectedTags.protect(7, name: 'v*', createAccessLevel: role),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final body in <Object?>[
    null,
    {},
    [],
    {
      'name': 'other',
      'create_access_levels': [
        {'access_level': 40},
      ],
    },
    {'name': 'v*', 'create_access_levels': []},
    {
      'name': 'v*',
      'create_access_levels': [
        {'access_level': 30},
      ],
    },
    {
      'name': 'v*',
      'create_access_levels': [
        {'access_level': 40},
        {'user_id': 9},
      ],
    },
  ]) {
    test('malformed or mismatched 201 is not confirmed $body', () async {
      final client = _client(
        (_) => (status: 201, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedTags.protect(7, name: 'v*', createAccessLevel: 40),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final status in [
    200,
    202,
    301,
    400,
    401,
    403,
    404,
    409,
    422,
    429,
    500,
  ]) {
    test('creation rejects HTTP $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedTags.protect(7, name: 'v*', createAccessLevel: 40),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('creation does not retry OAuth on 401', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (s) => true));
    dio.httpClientAdapter = _Adapter((options) {
      calls++;
      return (status: 401, headers: const {}, body: {});
    });
    final client = GitLabClient(
      baseUrl: 'https://gitlab.example.com/subpath',
      token: 'dummy-oauth',
      bearer: true,
      dio: dio,
      onUnauthorized: () async {
        refreshes++;
        return 'dummy-refreshed';
      },
    );
    await expectLater(
      client.protectedTags.protect(7, name: 'v*', createAccessLevel: 40),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });
  for (final body in <Object?>[
    null,
    {},
    'private',
    [
      {'create_access_levels': []},
    ],
    [
      {'name': 'v*'},
    ],
    [
      {'name': 7, 'create_access_levels': []},
    ],
    [
      {'name': 'v*', 'create_access_levels': null},
    ],
  ]) {
    test('incomplete rule list is a safe error $body', () async {
      final client = _client(
        (_) => (status: 200, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedTags.list(7),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.toString().contains('private'),
            'sanitized',
            isFalse,
          ),
        ),
      );
    });
  }

  test('lists protected tag rules with paginated create permissions', () async {
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
            'name': 'release/*',
            'create_access_levels': [
              {
                'id': 1,
                'access_level': 40,
                'access_level_description': 'Maintainers',
              },
              {
                'id': 2,
                'group_id': 20,
                'access_level_description': 'Release team',
              },
            ],
          },
        ],
      );
    });

    final page = await client.protectedTags.list('team/app');
    expect(request.path, '/projects/team%2Fapp/protected_tags');
    expect(request.queryParameters['page'], 1);
    expect(page.nextPage, 2);
    expect(page.items.single.name, 'release/*');
    expect(page.items.single.createAccessLevels.first.accessLevel, 40);
    expect(page.items.single.createAccessLevels.last.groupId, 20);
  });

  test(
    'gets wildcard rule by encoded name and maps forbidden access',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (
          status: 200,
          headers: <String, List<String>>{},
          body: {'name': 'release/*', 'create_access_levels': []},
        );
      });
      final rule = await client.protectedTags.get(7, 'release/*');
      expect(request.path, '/projects/7/protected_tags/release%2F*');
      expect(rule.name, 'release/*');

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.protectedTags.list(7),
        throwsA(isA<GitLabForbiddenException>()),
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
