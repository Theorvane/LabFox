import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> _updated(int membership) => {
  'name': 'review/production',
  'required_approval_count': 0,
  'deploy_access_levels': [
    {
      'id': 12,
      'group_id': 989,
      'access_level': 40,
      'group_inheritance_type': membership,
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
  for (final membership in [0, 1]) {
    test(
      'edits only deploy group membership=$membership without replay',
      () async {
        late RequestOptions request;
        final client = _client((options) {
          request = options;
          return (status: 200, body: _updated(membership));
        });
        final updated = await client.protectedEnvironments
            .editDeployGroupInheritance(
              'team/app',
              'review/production',
              grantId: 12,
              groupInheritanceType: membership,
            );
        expect(
          request.path,
          '/projects/team%2Fapp/protected_environments/review%2Fproduction',
        );
        expect(request.method, 'PUT');
        expect(request.data, {
          'deploy_access_levels': [
            {'id': 12, 'group_inheritance_type': membership},
          ],
        });
        expect(request.followRedirects, isFalse);
        expect(request.extra['labfox_no_auth_retry'], isTrue);
        expect(updated.deployAccessLevels.first.groupId, 989);
        expect(updated.deployAccessLevels.first.accessLevel, 40);
        expect(
          updated.deployAccessLevels.first.groupInheritanceType,
          membership,
        );
        expect(updated.approvalRules.single.requiredApprovals, 2);
      },
    );
  }
  test(
    'strict deploy inspection retains explicit direct membership and role metadata',
    () async {
      late RequestOptions request;
      final client = _client((options) {
        request = options;
        return (status: 200, body: _updated(0));
      });
      final detail = await client.protectedEnvironments.getForDeployGroupEdit(
        'team/app',
        'review/production',
      );
      expect(request.method, 'GET');
      expect(request.followRedirects, isFalse);
      expect(detail.deployAccessLevels.first.groupInheritanceType, 0);
      expect(detail.deployAccessLevels.first.accessLevel, 40);
    },
  );
  for (final malformed in [
    _updated(0),
    _updated(1)..remove('approval_rules'),
    _updated(1)..remove('required_approval_count'),
    _updated(1)..['name'] = 'other',
    _updated(1)
      ..['deploy_access_levels'] = [
        {'id': 12, 'group_id': 989},
      ],
    _updated(1)
      ..['deploy_access_levels'] = [
        {'id': 12.5, 'group_id': 989, 'group_inheritance_type': 1},
      ],
    _updated(1)
      ..['deploy_access_levels'] = [
        {'id': 12, 'group_id': 989.5, 'group_inheritance_type': 1},
      ],
    _updated(1)
      ..['deploy_access_levels'] = [
        {'id': 12, 'group_id': 989, 'user_id': 5, 'group_inheritance_type': 1},
      ],
    _updated(1)
      ..['deploy_access_levels'] = [
        {'id': 12, 'user_id': 5, 'group_inheritance_type': 1},
      ],
    _updated(1)
      ..['deploy_access_levels'] = [
        {'id': 14, 'group_id': 989, 'group_inheritance_type': 1},
      ],
    _updated(1)
      ..['deploy_access_levels'] = [
        {'id': 12, 'group_id': 0, 'group_inheritance_type': 1},
      ],
  ]) {
    test('deploy membership rejects unconfirmed response $malformed', () async {
      final client = _client((_) => (status: 200, body: malformed));
      await expectLater(
        client.protectedEnvironments.editDeployGroupInheritance(
          7,
          'review/production',
          grantId: 12,
          groupInheritanceType: 1,
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
    test('deploy membership maps HTTP $status before parsing', () async {
      final client = _client((_) => (status: status, body: 'private response'));
      await expectLater(
        client.protectedEnvironments.editDeployGroupInheritance(
          7,
          'review/production',
          grantId: 12,
          groupInheritanceType: 1,
        ),
        throwsA(
          isA<GitLabException>().having(
            (error) => error.statusCode,
            'status',
            status,
          ),
        ),
      );
      await expectLater(
        client.protectedEnvironments.getForDeployGroupEdit(
          7,
          'review/production',
        ),
        throwsA(
          isA<GitLabException>().having(
            (error) => error.statusCode,
            'status',
            status,
          ),
        ),
      );
    });
  }
  test('invalid deploy membership drafts never dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, body: {});
    });
    for (final (name, id, membership) in [
      (' ', 12, 1),
      (' production', 12, 1),
      ('production', 0, 1),
      ('production', 12, -1),
      ('production', 12, 2),
    ]) {
      await expectLater(
        client.protectedEnvironments.editDeployGroupInheritance(
          7,
          name,
          grantId: id,
          groupInheritanceType: membership,
        ),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });
  test('deploy membership OAuth writes never refresh or replay 401', () async {
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
      client.protectedEnvironments.editDeployGroupInheritance(
        7,
        'production',
        grantId: 12,
        groupInheritanceType: 1,
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
