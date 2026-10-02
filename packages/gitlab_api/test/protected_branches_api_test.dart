import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  for (final field in ['push_access_levels', 'merge_access_levels']) {
    test('role-only creation rejects custom member role in $field', () async {
      final response = <String, dynamic>{
        'id': 12,
        'name': 'release/*',
        'allow_force_push': false,
        'push_access_levels': [
          <String, dynamic>{'id': 1, 'access_level': 40},
        ],
        'merge_access_levels': [
          <String, dynamic>{'id': 2, 'access_level': 40},
        ],
      };
      (response[field] as List<Map<String, dynamic>>).single['member_role_id'] =
          99;
      final client = _client(
        (_) => (status: 201, headers: const {}, body: response),
      );
      await expectLater(
        client.protectedBranches.protect(
          7,
          name: 'release/*',
          pushAccessLevel: 40,
          mergeAccessLevel: 40,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }

  test('updates only the existing push role record once', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {
          'id': 101,
          'name': 'release/*',
          'allow_force_push': false,
          'merge_access_levels': [
            {'id': 1, 'access_level': 40},
          ],
          'push_access_levels': [
            {'id': 2, 'access_level': 30},
          ],
          'unprotect_access_levels': [
            {'id': 3, 'access_level': 40},
          ],
        },
      );
    });
    final changed = await client.protectedBranches.updatePushRole(
      'team/app',
      'release/*',
      accessRecordId: 2,
      accessLevel: 30,
    );
    expect(request.method, 'PATCH');
    expect(request.path, '/projects/team%2Fapp/protected_branches/release%2F*');
    expect(request.data, {
      'allowed_to_push': [
        {'id': 2, 'access_level': 30},
      ],
    });
    expect(request.followRedirects, isFalse);
    expect(changed.pushAccessLevels.single.accessLevel, 30);
    expect(changed.unprotectAccessLevels.single.accessLevel, 40);
  });

  for (final status in [201, 204, 302, 401, 403, 404, 429, 500]) {
    test('push role update requires 200, maps $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedBranches.updatePushRole(
          7,
          'main',
          accessRecordId: 2,
          accessLevel: 30,
        ),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }

  test('push role update rejects an unconfirmed response', () async {
    final client = _client(
      (_) => (
        status: 200,
        headers: const {},
        body: {
          'name': 'main',
          'allow_force_push': false,
          'merge_access_levels': [],
          'push_access_levels': [
            {'id': 2, 'access_level': 40},
          ],
        },
      ),
    );
    await expectLater(
      client.protectedBranches.updatePushRole(
        7,
        'main',
        accessRecordId: 2,
        accessLevel: 30,
      ),
      throwsA(isA<GitLabServerException>()),
    );
  });

  test('OAuth 401 does not replay push role PATCH', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (s) => true));
    dio.httpClientAdapter = _Adapter((_) {
      calls++;
      return (status: 401, headers: const {}, body: {});
    });
    final client = GitLabClient(
      baseUrl: 'https://gitlab.example.com',
      token: 'dummy-oauth',
      bearer: true,
      dio: dio,
      onUnauthorized: () async {
        refreshes++;
        return 'dummy-refreshed';
      },
    );
    await expectLater(
      client.protectedBranches.updatePushRole(
        7,
        'main',
        accessRecordId: 2,
        accessLevel: 30,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test('updates only the existing merge role record once', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {
          'id': 101,
          'name': 'release/*',
          'allow_force_push': false,
          'push_access_levels': [
            {'id': 1, 'access_level': 40},
          ],
          'merge_access_levels': [
            {'id': 2, 'access_level': 30},
          ],
          'unprotect_access_levels': [
            {'id': 3, 'access_level': 40},
          ],
        },
      );
    });
    final changed = await client.protectedBranches.updateMergeRole(
      'team/app',
      'release/*',
      accessRecordId: 2,
      accessLevel: 30,
    );
    expect(request.method, 'PATCH');
    expect(request.path, '/projects/team%2Fapp/protected_branches/release%2F*');
    expect(request.data, {
      'allowed_to_merge': [
        {'id': 2, 'access_level': 30},
      ],
    });
    expect(request.followRedirects, isFalse);
    expect(changed.mergeAccessLevels.single.accessLevel, 30);
    expect(changed.unprotectAccessLevels.single.accessLevel, 40);
  });

  for (final status in [201, 204, 302, 401, 403, 404, 429, 500]) {
    test('merge role update requires 200, maps $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedBranches.updateMergeRole(
          7,
          'main',
          accessRecordId: 2,
          accessLevel: 30,
        ),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }

  test('merge role update rejects an unconfirmed response', () async {
    final client = _client(
      (_) => (
        status: 200,
        headers: const {},
        body: {
          'name': 'main',
          'allow_force_push': false,
          'push_access_levels': [],
          'merge_access_levels': [
            {'id': 2, 'access_level': 40},
          ],
        },
      ),
    );
    await expectLater(
      client.protectedBranches.updateMergeRole(
        7,
        'main',
        accessRecordId: 2,
        accessLevel: 30,
      ),
      throwsA(isA<GitLabServerException>()),
    );
  });

  test('OAuth 401 does not replay merge role PATCH', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (s) => true));
    dio.httpClientAdapter = _Adapter((_) {
      calls++;
      return (status: 401, headers: const {}, body: {});
    });
    final client = GitLabClient(
      baseUrl: 'https://gitlab.example.com',
      token: 'dummy-oauth',
      bearer: true,
      dio: dio,
      onUnauthorized: () async {
        refreshes++;
        return 'dummy-refreshed';
      },
    );
    await expectLater(
      client.protectedBranches.updateMergeRole(
        7,
        'main',
        accessRecordId: 2,
        accessLevel: 30,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  for (final roles in [
    (push: 0, merge: 40),
    (push: 30, merge: 30),
    (push: 40, merge: 40),
  ]) {
    test(
      'protects an encoded project with push ${roles.push} and merge ${roles.merge}',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (
            status: 201,
            headers: const {},
            body: {
              'name': 'release/*',
              'push_access_levels': [
                {'access_level': roles.push},
              ],
              'merge_access_levels': [
                {'access_level': roles.merge},
              ],
              'allow_force_push': false,
            },
          );
        });
        final rule = await client.protectedBranches.protect(
          'team/app',
          name: 'release/*',
          pushAccessLevel: roles.push,
          mergeAccessLevel: roles.merge,
        );
        expect(request.method, 'POST');
        expect(request.path, '/projects/team%2Fapp/protected_branches');
        expect(request.data, {
          'name': 'release/*',
          'push_access_level': roles.push,
          'merge_access_level': roles.merge,
          'allow_force_push': false,
        });
        expect(request.followRedirects, isFalse);
        expect(rule.name, 'release/*');
      },
    );
  }
  for (final roles in [
    (push: -1, merge: 40),
    (push: 10, merge: 40),
    (push: 40, merge: 60),
  ]) {
    test('invalid push or merge role cannot dispatch $roles', () async {
      var calls = 0;
      final client = _client((options) {
        calls++;
        return (status: 201, headers: const {}, body: {});
      });
      await expectLater(
        client.protectedBranches.protect(
          7,
          name: 'v*',
          pushAccessLevel: roles.push,
          mergeAccessLevel: roles.merge,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final body in <Object?>[
    null,
    {},
    {
      'name': 'other',
      'push_access_levels': [
        {'access_level': 0},
      ],
      'merge_access_levels': [
        {'access_level': 40},
      ],
      'allow_force_push': false,
    },
    {
      'name': 'v*',
      'push_access_levels': [],
      'merge_access_levels': [
        {'access_level': 40},
      ],
      'allow_force_push': false,
    },
    {
      'name': 'v*',
      'push_access_levels': [
        {'access_level': 30},
      ],
      'merge_access_levels': [
        {'access_level': 40},
      ],
      'allow_force_push': false,
    },
    {
      'name': 'v*',
      'push_access_levels': [
        {'access_level': 0},
      ],
      'merge_access_levels': [
        {'access_level': 40},
      ],
      'allow_force_push': true,
    },
  ]) {
    test('unconfirmed 201 is rejected $body', () async {
      final client = _client(
        (_) => (status: 201, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedBranches.protect(
          7,
          name: 'v*',
          pushAccessLevel: 0,
          mergeAccessLevel: 40,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final status in [200, 301, 401, 403, 404, 409, 422, 429, 500]) {
    test('creation maps HTTP $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedBranches.protect(
          7,
          name: 'v*',
          pushAccessLevel: 0,
          mergeAccessLevel: 40,
        ),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('creation is not automatically replayed after OAuth 401', () async {
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
      client.protectedBranches.protect(
        7,
        name: 'v*',
        pushAccessLevel: 0,
        mergeAccessLevel: 40,
      ),
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
      {'name': 'main'},
    ],
    [
      {'name': 7, 'push_access_levels': [], 'merge_access_levels': []},
    ],
    [
      {'name': 'main', 'push_access_levels': null, 'merge_access_levels': []},
    ],
  ]) {
    test('incomplete list is a sanitized domain error $body', () async {
      final client = _client(
        (_) => (status: 200, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedBranches.list(7),
        throwsA(
          isA<GitLabServerException>().having(
            (error) => error.toString().contains('private'),
            'sanitized',
            isFalse,
          ),
        ),
      );
    });
  }
  for (final allowed in [true, false]) {
    test(
      'updates only force-push=$allowed on an encoded project rule',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (
            status: 200,
            headers: const {},
            body: {
              'id': 101,
              'name': 'release/*',
              'allow_force_push': allowed,
              'push_access_levels': [
                {'id': 1, 'access_level': 40},
              ],
              'merge_access_levels': [
                {'id': 2, 'access_level': 40},
              ],
            },
          );
        });
        final changed = await client.protectedBranches.updateForcePush(
          'team/app',
          'release/*',
          allowForcePush: allowed,
        );
        expect(request.method, 'PATCH');
        expect(
          request.path,
          '/projects/team%2Fapp/protected_branches/release%2F*',
        );
        expect(request.data, {'allow_force_push': allowed});
        expect(request.followRedirects, isFalse);
        expect(changed.allowForcePush, allowed);
      },
    );
  }

  for (final body in <Object?>[
    null,
    {},
    [
      {'name': 'main', 'push_access_levels': [], 'merge_access_levels': []},
    ],
    [
      {
        'name': 'main',
        'allow_force_push': false,
        'push_access_levels': [{}],
        'merge_access_levels': [],
      },
    ],
  ]) {
    test('malformed force-push inventory fails safely $body', () async {
      final client = _client(
        (_) => (status: 200, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedBranches.list(7),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }

  for (final body in <Object?>[
    null,
    {},
    {'name': 'main', 'push_access_levels': [], 'merge_access_levels': []},
    {
      'name': 'wrong',
      'allow_force_push': false,
      'push_access_levels': [],
      'merge_access_levels': [],
    },
  ]) {
    test('malformed force-push detail fails safely $body', () async {
      final client = _client(
        (_) => (status: 200, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedBranches.get(7, 'main'),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }

  for (final status in [
    201,
    202,
    204,
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
    test('force-push update accepts only 200, maps HTTP $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedBranches.updateForcePush(
          7,
          'main',
          allowForcePush: true,
        ),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }

  for (final body in <Object?>[
    null,
    {},
    [],
    {'name': 'main', 'allow_force_push': true},
    {
      'name': 'other',
      'allow_force_push': true,
      'push_access_levels': [],
      'merge_access_levels': [],
    },
    {
      'name': 'main',
      'allow_force_push': false,
      'push_access_levels': [],
      'merge_access_levels': [],
    },
    {
      'name': 'main',
      'allow_force_push': true,
      'push_access_levels': [{}],
      'merge_access_levels': [],
    },
  ]) {
    test('unconfirmed force-push response fails safely $body', () async {
      final client = _client(
        (_) => (status: 200, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedBranches.updateForcePush(
          7,
          'main',
          allowForcePush: true,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }

  test('blank force-push rule name never dispatches PATCH', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, headers: const {}, body: {});
    });
    await expectLater(
      client.protectedBranches.updateForcePush(7, ' ', allowForcePush: true),
      throwsArgumentError,
    );
    expect(calls, 0);
  });

  test('OAuth 401 does not refresh or replay force-push PATCH', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (s) => true));
    dio.httpClientAdapter = _Adapter((options) {
      calls++;
      return (status: 401, headers: const {}, body: {});
    });
    final client = GitLabClient(
      baseUrl: 'https://gitlab.example.com',
      token: 'dummy-oauth',
      bearer: true,
      dio: dio,
      onUnauthorized: () async {
        refreshes++;
        return 'dummy-refreshed';
      },
    );
    await expectLater(
      client.protectedBranches.updateForcePush(7, 'main', allowForcePush: true),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test('lists protected branch rules and preserves access levels', () async {
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
            'id': 100,
            'name': 'main',
            'allow_force_push': false,
            'code_owner_approval_required': true,
            'inherited': true,
            'push_access_levels': [
              {
                'id': 1001,
                'access_level': 40,
                'access_level_description': 'Maintainers',
              },
            ],
            'merge_access_levels': [
              {
                'id': 2001,
                'access_level': null,
                'group_id': 1234,
                'access_level_description': 'Release team',
              },
            ],
          },
        ],
      );
    });

    final page = await client.protectedBranches.list('team/app');
    expect(request.path, '/projects/team%2Fapp/protected_branches');
    expect(request.queryParameters['page'], 1);
    expect(page.nextPage, 2);
    final branch = page.items.single;
    expect(branch.name, 'main');
    expect(branch.inherited, isTrue);
    expect(branch.codeOwnerApprovalRequired, isTrue);
    expect(branch.pushAccessLevels.single.accessLevel, 40);
    expect(branch.mergeAccessLevels.single.groupId, 1234);
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
          body: {
            'id': 101,
            'name': 'release/*',
            'allow_force_push': false,
            'push_access_levels': [],
            'merge_access_levels': [],
          },
        );
      });
      final rule = await client.protectedBranches.get(7, 'release/*');
      expect(request.path, '/projects/7/protected_branches/release%2F*');
      expect(rule.name, 'release/*');

      final forbidden = _client(
        (_) => (status: 403, headers: const {}, body: const {}),
      );
      await expectLater(
        forbidden.protectedBranches.list(7),
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
