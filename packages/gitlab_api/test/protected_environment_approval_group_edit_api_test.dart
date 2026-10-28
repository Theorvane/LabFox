import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

Map<String, dynamic> _updated() => {
  'name': 'review/production',
  'required_approval_count': 0,
  'deploy_access_levels': [
    {'id': 12, 'access_level': 40},
  ],
  'approval_rules': [
    {
      'id': 38,
      'group_id': 136,
      'group_inheritance_type': 1,
      'required_approvals': 2,
      'access_level_description': 'New release team',
    },
    {'id': 39, 'user_id': 5, 'required_approvals': 1},
  ],
};
void main() {
  test(
    'replaces only one group ID using an encoded non-retrying PUT',
    () async {
      late RequestOptions request;
      var calls = 0;
      final client = _client((options) {
        calls++;
        request = options;
        return (status: 200, body: _updated());
      });
      final updated = await client.protectedEnvironments.editApprovalGroup(
        'team/app',
        'review/production',
        ruleId: 38,
        groupId: 136,
      );
      expect(calls, 1);
      expect(request.method, 'PUT');
      expect(
        request.path,
        '/projects/team%2Fapp/protected_environments/review%2Fproduction',
      );
      expect(request.data, {
        'approval_rules': [
          {'id': 38, 'group_id': 136},
        ],
      });
      expect(request.followRedirects, isFalse);
      expect(request.extra['labfox_no_auth_retry'], isTrue);
      expect(updated.approvalRules.first.description, 'New release team');
      expect(updated.approvalRules.first.requiredApprovals, 2);
      expect(updated.approvalRules.first.groupInheritanceType, 1);
      expect(updated.deployAccessLevels.single.id, 12);
    },
  );
  for (final malformed in [
    _updated()..remove('deploy_access_levels'),
    _updated()..remove('required_approval_count'),
    _updated()..['name'] = 'other',
    _updated()
      ..['approval_rules'] = [
        {
          'id': 38,
          'group_id': 135,
          'group_inheritance_type': 1,
          'required_approvals': 2,
        },
      ],
    _updated()
      ..['approval_rules'] = [
        {
          'id': 38.5,
          'group_id': 136,
          'group_inheritance_type': 1,
          'required_approvals': 2,
        },
      ],
    _updated()
      ..['approval_rules'] = [
        {
          'id': 38,
          'group_id': 136.5,
          'group_inheritance_type': 1,
          'required_approvals': 2,
        },
      ],
    _updated()
      ..['approval_rules'] = [
        {'id': 38, 'group_id': 136, 'required_approvals': 2},
      ],
    _updated()
      ..['approval_rules'] = [
        {
          'id': 38,
          'group_id': 136,
          'group_inheritance_type': 7,
          'required_approvals': 2,
        },
      ],
    _updated()
      ..['approval_rules'] = [
        {
          'id': 38,
          'group_id': 136,
          'user_id': 5,
          'group_inheritance_type': 1,
          'required_approvals': 2,
        },
      ],
    _updated()
      ..['approval_rules'] = [
        {
          'id': 38,
          'group_id': 136,
          'access_level': 40,
          'group_inheritance_type': 1,
          'required_approvals': 2,
        },
      ],
    _updated()
      ..['approval_rules'] = [
        {
          'id': 40,
          'group_id': 136,
          'group_inheritance_type': 1,
          'required_approvals': 2,
        },
      ],
  ]) {
    test(
      'replacement rejects malformed or unconfirmed state $malformed',
      () async {
        final client = _client((_) => (status: 200, body: malformed));
        await expectLater(
          client.protectedEnvironments.editApprovalGroup(
            7,
            'review/production',
            ruleId: 38,
            groupId: 136,
          ),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
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
    test('replacement maps HTTP $status before parsing', () async {
      final client = _client((_) => (status: status, body: 'private response'));
      await expectLater(
        client.protectedEnvironments.editApprovalGroup(
          7,
          'review/production',
          ruleId: 38,
          groupId: 136,
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
  test('invalid replacement arguments do not dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, body: _updated());
    });
    for (final (name, id, group) in [
      (' ', 38, 136),
      (' production', 38, 136),
      ('production', 0, 136),
      ('production', 38, 0),
      ('production', 38, -1),
    ]) {
      await expectLater(
        client.protectedEnvironments.editApprovalGroup(
          7,
          name,
          ruleId: id,
          groupId: group,
        ),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });
  test('OAuth replacement never refreshes or replays a 401', () async {
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
      client.protectedEnvironments.editApprovalGroup(
        7,
        'production',
        ruleId: 38,
        groupId: 136,
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
