import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> _removed() => {
  'name': 'review/production',
  'required_approval_count': 0,
  'deploy_access_levels': [
    {
      'id': 15,
      'group_id': 990,
      'access_level': 40,
      'group_inheritance_type': 1,
    },
    {'id': 13, 'user_id': 5},
  ],
  'approval_rules': [
    {
      'id': 38,
      'group_id': 134,
      'group_inheritance_type': 1,
      'required_approvals': 2,
    },
  ],
};
void main() {
  for (final last in [false, true]) {
    test('removes only exact grant without unprotecting last=$last', () async {
      late RequestOptions request;
      final body = _removed();
      if (last) body['deploy_access_levels'] = [];
      final client = _client((options) {
        request = options;
        return (status: 200, body: body);
      });
      final updated = await client.protectedEnvironments.removeDeployGroup(
        'team/app',
        'review/production',
        grantId: 12,
      );
      expect(
        request.path,
        '/projects/team%2Fapp/protected_environments/review%2Fproduction',
      );
      expect(request.method, 'PUT');
      expect(request.data, {
        'deploy_access_levels': [
          {'id': 12, '_destroy': true},
        ],
      });
      expect(request.followRedirects, isFalse);
      expect(request.extra['labfox_no_auth_retry'], isTrue);
      expect(updated.name, 'review/production');
      expect(updated.approvalRules.single.requiredApprovals, 2);
      expect(updated.deployAccessLevels.length, last ? 0 : 2);
    });
  }
  for (final malformed in [
    {},
    _removed()..remove('approval_rules'),
    _removed()..remove('required_approval_count'),
    _removed()..['name'] = 'other',
    _removed()
      ..['deploy_access_levels'] = [
        {'id': 12, 'group_id': 989, 'group_inheritance_type': 0},
      ],
    _removed()
      ..['deploy_access_levels'] = [
        {'id': 15.5, 'group_id': 990},
      ],
    _removed()
      ..['deploy_access_levels'] = [
        {'id': 15, 'group_id': 990.5},
      ],
    _removed()
      ..['deploy_access_levels'] = [
        {'id': 15, 'access_level': 40},
        {'id': 15, 'user_id': 5},
      ],
    _removed()
      ..['deploy_access_levels'] = [
        {'id': 0, 'access_level': 40},
      ],
    _removed()
      ..['approval_rules'] = [
        {'id': 38, 'group_id': 134},
      ],
  ]) {
    test('rejects incomplete or unconfirmed removal $malformed', () async {
      final client = _client((_) => (status: 200, body: malformed));
      await expectLater(
        client.protectedEnvironments.removeDeployGroup(
          7,
          'review/production',
          grantId: 12,
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
    test('maps removal HTTP $status before parsing', () async {
      final client = _client((_) => (status: status, body: 'private response'));
      await expectLater(
        client.protectedEnvironments.removeDeployGroup(
          7,
          'review/production',
          grantId: 12,
        ),
        throwsA(
          isA<GitLabException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    });
  }
  test('invalid removal drafts do not dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, body: {});
    });
    for (final (name, id) in [
      (' ', 12),
      (' production', 12),
      ('production ', 12),
      ('production', 0),
      ('production', -1),
    ]) {
      await expectLater(
        client.protectedEnvironments.removeDeployGroup(7, name, grantId: id),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });
  test('OAuth removal never refreshes or replays 401', () async {
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
      client.protectedEnvironments.removeDeployGroup(
        7,
        'review/production',
        grantId: 12,
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
