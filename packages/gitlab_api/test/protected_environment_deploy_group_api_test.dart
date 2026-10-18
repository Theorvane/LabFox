import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> _updated() => {
  'name': 'review/production',
  'required_approval_count': 0,
  'deploy_access_levels': [
    {
      'id': 12,
      'group_id': 134,
      'access_level': 40,
      'group_inheritance_type': 1,
    },
    {
      'id': 15,
      'group_id': 135,
      'access_level': 40,
      'group_inheritance_type': 0,
    },
  ],
  'approval_rules': [
    {
      'id': 38,
      'group_id': 135,
      'required_approvals': 2,
      'group_inheritance_type': 1,
    },
  ],
};
void main() {
  test(
    'adds exactly one direct deploy group without role selector or record ID',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (status: 200, body: _updated());
      });
      final updated = await client.protectedEnvironments.addDeployGroup(
        'team/app',
        'review/production',
        groupId: 135,
      );
      expect(
        request.path,
        '/projects/team%2Fapp/protected_environments/review%2Fproduction',
      );
      expect(request.method, 'PUT');
      expect(request.data, {
        'deploy_access_levels': [
          {'group_id': 135, 'group_inheritance_type': 0},
        ],
      });
      expect(request.followRedirects, isFalse);
      expect(request.extra['labfox_no_auth_retry'], isTrue);
      expect(updated.deployAccessLevels.last.accessLevel, 40);
      expect(updated.deployAccessLevels.last.groupId, 135);
      expect(updated.approvalRules.single.requiredApprovals, 2);
    },
  );
  for (final malformed in [
    {},
    _updated()..remove('approval_rules'),
    _updated()..remove('required_approval_count'),
    _updated()..['name'] = 'other',
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 15, 'group_id': 135},
      ],
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 15.5, 'group_id': 135, 'group_inheritance_type': 0},
      ],
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 15, 'group_id': 135.5, 'group_inheritance_type': 0},
      ],
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 15, 'group_id': 136, 'group_inheritance_type': 0},
      ],
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 15, 'group_id': 135, 'group_inheritance_type': 1},
      ],
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 15, 'group_id': 135, 'user_id': 5, 'group_inheritance_type': 0},
      ],
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 15, 'group_id': 135, 'group_inheritance_type': 0},
        {'id': 16, 'group_id': 135, 'group_inheritance_type': 0},
      ],
    _updated()
      ..['deploy_access_levels'] = [
        {'id': 0, 'group_id': 135, 'group_inheritance_type': 0},
      ],
  ]) {
    test('rejects unconfirmed deploy group response $malformed', () async {
      final client = _client((_) => (status: 200, body: malformed));
      await expectLater(
        client.protectedEnvironments.addDeployGroup(
          7,
          'review/production',
          groupId: 135,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final status in [
    201,
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
    test('maps HTTP $status before parsing', () async {
      final client = _client((_) => (status: status, body: 'private response'));
      await expectLater(
        client.protectedEnvironments.addDeployGroup(
          7,
          'review/production',
          groupId: 135,
        ),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('invalid drafts never dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, body: {});
    });
    for (final (name, id) in [
      (' ', 135),
      (' production', 135),
      ('production ', 135),
      ('production', 0),
      ('production', -1),
    ]) {
      await expectLater(
        client.protectedEnvironments.addDeployGroup(7, name, groupId: id),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });
  test('OAuth 401 never refreshes or replays deploy group creation', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (_) => true));
    dio.httpClientAdapter = _Adapter((_) {
      calls++;
      return (status: 401, body: {});
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
      client.protectedEnvironments.addDeployGroup(
        7,
        'review/production',
        groupId: 135,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.httpClientAdapter = _Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final ({int status, Object? body}) Function(RequestOptions) handler;
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
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
