import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  test(
    'unprotects the exact encoded rule without tag deletion or payload',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (status: 204, headers: const {}, body: null);
      });
      await client.protectedTags.unprotect('team/app', 'release/a+# %*');
      expect(request.method, 'DELETE');
      expect(
        request.path,
        '/projects/team%2Fapp/protected_tags/release%2Fa%2B%23%20%25*',
      );
      expect(request.data, isNull);
      expect(request.followRedirects, isFalse);
    },
  );
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
    test('unprotect accepts only 204, maps HTTP $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedTags.unprotect(7, 'v*'),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('unprotect never refreshes or replays an OAuth request', () async {
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
      client.protectedTags.unprotect(7, 'v*'),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });
  for (final body in <Object>[
    {},
    [],
    'private',
    {'name': 'v*'},
    {'name': 'v*', 'create_access_levels': null},
    {
      'name': 'v*',
      'create_access_levels': [{}],
    },
    {
      'name': 'v*',
      'create_access_levels': [
        {'access_level': 'private'},
      ],
    },
    {'name': 'wrong', 'create_access_levels': []},
  ]) {
    test(
      'incomplete or mismatched preflight rule fails safely $body',
      () async {
        final client = _client(
          (_) => (status: 200, headers: const {}, body: body),
        );
        await expectLater(
          client.protectedTags.get(7, 'v*'),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.toString().contains('private'),
              'sanitized',
              isFalse,
            ),
          ),
        );
      },
    );
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
