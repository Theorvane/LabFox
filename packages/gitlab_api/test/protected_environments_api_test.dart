import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> groupRule() => {
    'name': 'review/production',
    'required_approval_count': 0,
    'deploy_access_levels': [
      {'id': 12, 'access_level': 40},
    ],
    'approval_rules': [
      {
        'id': 38,
        'group_id': 134,
        'group_inheritance_type': 0,
        'required_approvals': 1,
      },
      {
        'id': 39,
        'group_id': 135,
        'group_inheritance_type': 0,
        'required_approvals': 2,
      },
    ],
  };

  test(
    'adds only one direct-membership approval group without retry',
    () async {
      late RequestOptions request;
      var calls = 0;
      final client = _client((options) {
        request = options;
        calls++;
        return (status: 200, headers: const {}, body: groupRule());
      });
      final updated = await client.protectedEnvironments.addApprovalGroup(
        'team/app',
        'review/production',
        groupId: 135,
        requiredApprovals: 2,
      );
      expect(calls, 1);
      expect(request.method, 'PUT');
      expect(
        request.path,
        '/projects/team%2Fapp/protected_environments/review%2Fproduction',
      );
      expect(request.data, {
        'approval_rules': [
          {
            'group_id': 135,
            'required_approvals': 2,
            'group_inheritance_type': 0,
          },
        ],
      });
      expect(request.followRedirects, isFalse);
      expect(request.extra['labfox_no_auth_retry'], isTrue);
      expect(updated.approvalRules.length, 2);
      expect(updated.deployAccessLevels.single.id, 12);
    },
  );

  test('approval-group inspection requires complete exact state', () async {
    final client = _client(
      (_) => (status: 200, headers: const {}, body: groupRule()),
    );
    final detail = await client.protectedEnvironments.getForApprovalGroupEdit(
      7,
      'review/production',
    );
    expect(detail.approvalRules.last.groupId, 135);
  });

  for (final malformed in [
    groupRule()..remove('approval_rules'),
    groupRule()..remove('required_approval_count'),
    groupRule()..['name'] = 'other',
    groupRule()..['required_approval_count'] = 0.5,
    groupRule()
      ..['deploy_access_levels'] = [
        {'id': 12.5, 'access_level': 40},
      ],
    groupRule()
      ..['approval_rules'] = [
        {'id': 39, 'group_id': 135.5, 'required_approvals': 2},
      ],
    groupRule()
      ..['approval_rules'] = [
        {'id': 39, 'group_id': 135, 'required_approvals': 2.5},
      ],
    groupRule()
      ..['approval_rules'] = [
        {
          'id': 39,
          'group_id': 135,
          'group_inheritance_type': 0.5,
          'required_approvals': 2,
        },
      ],
    groupRule()
      ..['approval_rules'] = [
        groupRule()['approval_rules'][1],
        groupRule()['approval_rules'][1],
      ],
  ]) {
    test(
      'approval-group reads reject incomplete or lossy rule $malformed',
      () async {
        final client = _client(
          (_) => (status: 200, headers: const {}, body: malformed),
        );
        await expectLater(
          client.protectedEnvironments.getForApprovalGroupEdit(
            7,
            'review/production',
          ),
          throwsA(isA<GitLabServerException>()),
        );
        await expectLater(
          client.protectedEnvironments.addApprovalGroup(
            7,
            'review/production',
            groupId: 135,
            requiredApprovals: 2,
          ),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  for (final malformed in [
    groupRule()
      ..['approval_rules'] = [
        {
          'id': 39,
          'group_id': 136,
          'group_inheritance_type': 0,
          'required_approvals': 2,
        },
      ],
    groupRule()
      ..['approval_rules'] = [
        {
          'id': 39,
          'group_id': 135,
          'group_inheritance_type': 1,
          'required_approvals': 2,
        },
      ],
    groupRule()
      ..['approval_rules'] = [
        {
          'id': 39,
          'group_id': 135,
          'group_inheritance_type': 0,
          'required_approvals': 1,
        },
      ],
    groupRule()
      ..['approval_rules'] = [
        {
          'id': 39,
          'group_id': 135,
          'access_level': 40,
          'group_inheritance_type': 0,
          'required_approvals': 2,
        },
      ],
  ]) {
    test(
      'approval-group write rejects an unconfirmed target $malformed',
      () async {
        final client = _client(
          (_) => (status: 200, headers: const {}, body: malformed),
        );
        await expectLater(
          client.protectedEnvironments.addApprovalGroup(
            7,
            'review/production',
            groupId: 135,
            requiredApprovals: 2,
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
    test('approval-group maps HTTP $status before parsing', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: 'private response'),
      );
      await expectLater(
        client.protectedEnvironments.addApprovalGroup(
          7,
          'review/production',
          groupId: 135,
          requiredApprovals: 2,
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
        client.protectedEnvironments.getForApprovalGroupEdit(
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
  test('invalid group approval drafts never dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, headers: const {}, body: groupRule());
    });
    for (final (name, group, count) in [
      (' ', 135, 2),
      (' production', 135, 2),
      ('production', 0, 2),
      ('production', -1, 2),
      ('production', 135, 0),
      ('production', 135, 6),
    ]) {
      await expectLater(
        client.protectedEnvironments.addApprovalGroup(
          7,
          name,
          groupId: group,
          requiredApprovals: count,
        ),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });
  test('approval-group OAuth 401 never refreshes or replays', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (_) => true));
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
      client.protectedEnvironments.addApprovalGroup(
        7,
        'production',
        groupId: 135,
        requiredApprovals: 2,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test('removes one approval rule with an encoded non-retrying PUT', () async {
    late RequestOptions request;
    var calls = 0;
    final client = _client((options) {
      calls++;
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {
          'name': 'review/production',
          'approval_rules': [
            {'id': 39, 'required_approvals': 1},
          ],
        },
      );
    });
    await client.protectedEnvironments.removeApprovalRule(
      'team/app',
      'review/production',
      ruleId: 38,
    );
    expect(calls, 1);
    expect(request.method, 'PUT');
    expect(
      request.path,
      '/projects/team%2Fapp/protected_environments/review%2Fproduction',
    );
    expect(request.data, {
      'approval_rules': [
        {'id': 38, '_destroy': true},
      ],
    });
    expect(request.followRedirects, isFalse);
    expect(request.extra['labfox_no_auth_retry'], isTrue);
  });

  test('confirms removal of the last approval rule', () async {
    final client = _client(
      (_) => (
        status: 200,
        headers: const {},
        body: {'name': 'production', 'approval_rules': []},
      ),
    );
    await client.protectedEnvironments.removeApprovalRule(
      7,
      'production',
      ruleId: 38,
    );
  });

  test('approval removal rejects invalid arguments without dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, headers: const {}, body: {});
    });
    for (final args in [
      (name: '', id: 38),
      (name: ' production', id: 38),
      (name: 'production', id: 0),
    ]) {
      await expectLater(
        client.protectedEnvironments.removeApprovalRule(
          7,
          args.name,
          ruleId: args.id,
        ),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });

  for (final status in [201, 301, 400, 401, 403, 404, 409, 422, 429, 500]) {
    test('approval removal maps HTTP $status before parsing', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: 'private response'),
      );
      await expectLater(
        client.protectedEnvironments.removeApprovalRule(
          7,
          'production',
          ruleId: 38,
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

  for (final body in [
    null,
    {'name': 'other', 'approval_rules': []},
    {'name': 'production'},
    {
      'name': 'production',
      'approval_rules': [
        {'id': 38, 'required_approvals': 1},
      ],
    },
    {
      'name': 'production',
      'approval_rules': [null],
    },
    {
      'name': 'production',
      'approval_rules': [{}],
    },
    {
      'name': 'production',
      'approval_rules': [
        {'id': 39.0},
      ],
    },
    {
      'name': 'production',
      'approval_rules': [
        {'id': 39},
        {'id': 39},
      ],
    },
  ]) {
    test('approval removal rejects unconfirmed response $body', () async {
      final client = _client(
        (_) => (status: 200, headers: const {}, body: body),
      );
      await expectLater(
        client.protectedEnvironments.removeApprovalRule(
          7,
          'production',
          ruleId: 38,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }

  test('approval removal never refreshes or replays OAuth writes', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (_) => true));
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
      client.protectedEnvironments.removeApprovalRule(
        7,
        'production',
        ruleId: 38,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test('updates one approval count with an encoded non-retrying PUT', () async {
    late RequestOptions request;
    var calls = 0;
    final client = _client((options) {
      calls++;
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {
          'name': 'review/production',
          'approval_rules': [
            {'id': 38, 'group_id': 134, 'required_approvals': 3},
          ],
        },
      );
    });
    await client.protectedEnvironments.editApprovalCount(
      'team/app',
      'review/production',
      ruleId: 38,
      requiredApprovals: 3,
    );
    expect(calls, 1);
    expect(request.method, 'PUT');
    expect(
      request.path,
      '/projects/team%2Fapp/protected_environments/review%2Fproduction',
    );
    expect(request.data, {
      'approval_rules': [
        {'id': 38, 'required_approvals': 3},
      ],
    });
    expect(request.followRedirects, isFalse);
    expect(request.extra['labfox_no_auth_retry'], isTrue);
  });

  test('approval count rejects invalid arguments without dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, headers: const {}, body: {});
    });
    for (final args in [
      (name: '', id: 38, count: 2),
      (name: ' production', id: 38, count: 2),
      (name: 'production', id: 0, count: 2),
      (name: 'production', id: 38, count: 0),
      (name: 'production', id: 38, count: 6),
    ]) {
      await expectLater(
        client.protectedEnvironments.editApprovalCount(
          7,
          args.name,
          ruleId: args.id,
          requiredApprovals: args.count,
        ),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });

  for (final status in [201, 301, 400, 401, 403, 404, 409, 422, 429, 500]) {
    test('approval count maps HTTP $status before payload parsing', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: 'private response'),
      );
      await expectLater(
        client.protectedEnvironments.editApprovalCount(
          7,
          'production',
          ruleId: 38,
          requiredApprovals: 2,
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

  for (final rules in [
    <Object?>[],
    [
      {'id': 39, 'required_approvals': 2},
    ],
    [
      {'id': 38, 'required_approvals': 1},
    ],
    [
      {'id': 38, 'required_approvals': 2.0},
    ],
    [
      {'id': 38, 'required_approvals': 2},
      {'id': 38, 'required_approvals': 2},
    ],
    [
      {'id': 38, 'required_approvals': 2},
      null,
    ],
  ]) {
    test('approval count rejects unconfirmed rules $rules', () async {
      final client = _client(
        (_) => (
          status: 200,
          headers: const {},
          body: {'name': 'production', 'approval_rules': rules},
        ),
      );
      await expectLater(
        client.protectedEnvironments.editApprovalCount(
          7,
          'production',
          ruleId: 38,
          requiredApprovals: 2,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }

  test('approval count never refreshes or replays OAuth writes', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (_) => true));
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
      client.protectedEnvironments.editApprovalCount(
        7,
        'production',
        ruleId: 38,
        requiredApprovals: 2,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test(
    'edits one deploy grant by ID with an encoded non-retrying PUT',
    () async {
      late RequestOptions request;
      var calls = 0;
      final client = _client((options) {
        calls++;
        request = options;
        return (
          status: 200,
          headers: const {},
          body: {
            'name': 'review/production',
            'deploy_access_levels': [
              {'id': 12, 'access_level': 40},
            ],
          },
        );
      });
      await client.protectedEnvironments.editDeployRole(
        'team/app',
        'review/production',
        grantId: 12,
        accessLevel: 40,
      );
      expect(calls, 1);
      expect(request.method, 'PUT');
      expect(
        request.path,
        '/projects/team%2Fapp/protected_environments/review%2Fproduction',
      );
      expect(request.data, {
        'deploy_access_levels': [
          {'id': 12, 'access_level': 40},
        ],
      });
      expect(request.followRedirects, isFalse);
      expect(request.extra['labfox_no_auth_retry'], isTrue);
    },
  );

  test('edit role validates arguments before dispatch', () async {
    var calls = 0;
    final client = _client((_) {
      calls++;
      return (status: 200, headers: const {}, body: {});
    });
    for (final args in [
      (name: '', id: 12, role: 40),
      (name: ' production', id: 12, role: 40),
      (name: 'production', id: 0, role: 40),
      (name: 'production', id: 12, role: 50),
    ]) {
      await expectLater(
        client.protectedEnvironments.editDeployRole(
          7,
          args.name,
          grantId: args.id,
          accessLevel: args.role,
        ),
        throwsArgumentError,
      );
    }
    expect(calls, 0);
  });

  for (final status in [201, 301, 400, 401, 403, 404, 409, 422, 429, 500]) {
    test('edit role maps HTTP $status before parsing', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: 'private payload'),
      );
      await expectLater(
        client.protectedEnvironments.editDeployRole(
          7,
          'production',
          grantId: 12,
          accessLevel: 40,
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

  for (final grants in [
    <Object?>[],
    [
      {'id': 12, 'access_level': 30},
    ],
    [
      {'id': 13, 'access_level': 40},
    ],
    [
      {'id': 12, 'access_level': 40, 'user_id': 3},
    ],
    [
      {'id': 12, 'access_level': 40},
      {'id': 12, 'access_level': 40},
    ],
    [
      {'id': 12, 'access_level': 40},
      null,
    ],
  ]) {
    test('edit role rejects unconfirmed response $grants', () async {
      final client = _client(
        (_) => (
          status: 200,
          headers: const {},
          body: {'name': 'production', 'deploy_access_levels': grants},
        ),
      );
      await expectLater(
        client.protectedEnvironments.editDeployRole(
          7,
          'production',
          grantId: 12,
          accessLevel: 40,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }

  test('edit role does not refresh or replay OAuth 401', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (_) => true));
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
      client.protectedEnvironments.editDeployRole(
        7,
        'production',
        grantId: 12,
        accessLevel: 40,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test('removes only one encoded project deploy grant with one PUT', () async {
    late RequestOptions request;
    var calls = 0;
    final client = _client((options) {
      calls++;
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {
          'name': 'review/production',
          'deploy_access_levels': [
            {'id': 13, 'access_level': 40},
          ],
        },
      );
    });
    await client.protectedEnvironments.removeDeployRole(
      'team/app',
      'review/production',
      grantId: 12,
    );
    expect(calls, 1);
    expect(request.method, 'PUT');
    expect(
      request.path,
      '/projects/team%2Fapp/protected_environments/review%2Fproduction',
    );
    expect(request.data, {
      'deploy_access_levels': [
        {'id': 12, '_destroy': true},
      ],
    });
    expect(request.followRedirects, isFalse);
    expect(request.extra['labfox_no_auth_retry'], isTrue);
  });

  for (final status in [201, 301, 400, 401, 403, 404, 409, 422, 429, 500]) {
    test('remove deploy role rejects HTTP $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedEnvironments.removeDeployRole(
          7,
          'production',
          grantId: 12,
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

  test(
    'remove deploy role rejects unconfirmed responses and invalid ID',
    () async {
      final client = _client(
        (_) => (
          status: 200,
          headers: const {},
          body: {
            'name': 'production',
            'deploy_access_levels': [
              {'id': 12, 'access_level': 30},
            ],
          },
        ),
      );
      await expectLater(
        client.protectedEnvironments.removeDeployRole(
          7,
          'production',
          grantId: 12,
        ),
        throwsA(isA<GitLabServerException>()),
      );
      await expectLater(
        client.protectedEnvironments.removeDeployRole(
          7,
          'production',
          grantId: 0,
        ),
        throwsArgumentError,
      );
    },
  );

  test('remove deploy role does not refresh or replay OAuth 401', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (status) => true));
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
      client.protectedEnvironments.removeDeployRole(
        7,
        'production',
        grantId: 12,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test('adds one role grant with an encoded, non-retrying PUT', () async {
    late RequestOptions request;
    var calls = 0;
    final client = _client((options) {
      calls++;
      request = options;
      return (
        status: 200,
        headers: const {},
        body: {
          'name': 'review/production',
          'deploy_access_levels': [
            {'id': 12, 'access_level': 30, 'user_id': null, 'group_id': null},
          ],
        },
      );
    });
    await client.protectedEnvironments.addDeployRole(
      'team/app',
      'review/production',
      accessLevel: 30,
    );
    expect(calls, 1);
    expect(request.method, 'PUT');
    expect(
      request.path,
      '/projects/team%2Fapp/protected_environments/review%2Fproduction',
    );
    expect(request.data, {
      'deploy_access_levels': [
        {'access_level': 30},
      ],
    });
    expect(request.followRedirects, isFalse);
    expect(request.extra['labfox_no_auth_retry'], isTrue);
  });

  for (final status in [201, 301, 400, 401, 403, 404, 409, 422, 429, 500]) {
    test('add deploy role rejects HTTP $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedEnvironments.addDeployRole(
          7,
          'production',
          accessLevel: 30,
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

  test(
    'add deploy role rejects unsupported role and unconfirmed response',
    () async {
      final client = _client(
        (_) => (
          status: 200,
          headers: const {},
          body: {'name': 'production', 'deploy_access_levels': []},
        ),
      );
      await expectLater(
        client.protectedEnvironments.addDeployRole(
          7,
          'production',
          accessLevel: 30,
        ),
        throwsA(isA<GitLabServerException>()),
      );
      await expectLater(
        client.protectedEnvironments.addDeployRole(
          7,
          'production',
          accessLevel: 60,
        ),
        throwsArgumentError,
      );
    },
  );

  test('add deploy role does not refresh or replay OAuth 401', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (status) => true));
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
      client.protectedEnvironments.addDeployRole(
        7,
        'production',
        accessLevel: 30,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test('unprotects the exact encoded project rule with one DELETE', () async {
    late RequestOptions request;
    var calls = 0;
    final client = _client((options) {
      calls++;
      request = options;
      return (status: 204, headers: const {}, body: null);
    });
    await client.protectedEnvironments.unprotect(
      'team/app',
      'review/production',
    );
    expect(calls, 1);
    expect(request.method, 'DELETE');
    expect(
      request.path,
      '/projects/team%2Fapp/protected_environments/review%2Fproduction',
    );
    expect(request.data, isNull);
    expect(request.followRedirects, isFalse);
    expect(request.extra['labfox_no_auth_retry'], isTrue);
  });

  for (final status in [200, 301, 400, 401, 403, 404, 409, 429, 500]) {
    test('unprotect rejects HTTP $status', () async {
      final client = _client(
        (_) => (status: status, headers: const {}, body: {}),
      );
      await expectLater(
        client.protectedEnvironments.unprotect(7, 'production'),
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

  test('unprotect does not refresh or replay OAuth 401', () async {
    var calls = 0;
    var refreshes = 0;
    final dio = Dio(BaseOptions(validateStatus: (status) => true));
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
      client.protectedEnvironments.unprotect(7, 'production'),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(calls, 1);
    expect(refreshes, 0);
  });

  test(
    'complete preflight rejects omitted grants and mismatched identity',
    () async {
      final incomplete = _client(
        (_) => (
          status: 200,
          headers: const {},
          body: {'name': 'production', 'deploy_access_levels': []},
        ),
      );
      await expectLater(
        incomplete.protectedEnvironments.getComplete(7, 'production'),
        throwsA(isA<GitLabServerException>()),
      );
      final mismatched = _client(
        (_) => (
          status: 200,
          headers: const {},
          body: {
            'name': 'staging',
            'deploy_access_levels': [],
            'approval_rules': [],
            'required_approval_count': 0,
          },
        ),
      );
      await expectLater(
        mismatched.protectedEnvironments.getComplete(7, 'production'),
        throwsA(isA<GitLabServerException>()),
      );
    },
  );

  test(
    'creates one role-only project rule without replaying the write',
    () async {
      late RequestOptions request;
      var attempts = 0;
      final client = _client((options) {
        attempts++;
        request = options;
        return (
          status: 201,
          headers: <String, List<String>>{},
          body: {
            'name': 'production',
            'deploy_access_levels': [
              {'id': 12, 'access_level': 40, 'user_id': null, 'group_id': null},
            ],
            'approval_rules': <Object>[],
            'required_approval_count': 0,
          },
        );
      });

      final created = await client.protectedEnvironments.createRoleOnly(
        'team/app',
        'production',
        accessLevel: 40,
      );
      expect(attempts, 1);
      expect(request.method, 'POST');
      expect(request.path, '/projects/team%2Fapp/protected_environments');
      expect(request.data, {
        'name': 'production',
        'deploy_access_levels': [
          {'access_level': 40},
        ],
      });
      expect(request.followRedirects, isFalse);
      expect(request.extra['labfox_no_auth_retry'], isTrue);
      expect(created.deployAccessLevels.single.accessLevel, 40);
    },
  );

  test('rejects unconfirmed creation and unsupported deploy role', () async {
    final client = _client(
      (_) => (
        status: 201,
        headers: <String, List<String>>{},
        body: {
          'name': 'production',
          'deploy_access_levels': [
            {'id': 12, 'access_level': 30},
          ],
        },
      ),
    );
    await expectLater(
      client.protectedEnvironments.createRoleOnly(
        7,
        'production',
        accessLevel: 40,
      ),
      throwsA(isA<GitLabServerException>()),
    );
    await expectLater(
      client.protectedEnvironments.createRoleOnly(
        7,
        'production',
        accessLevel: 60,
      ),
      throwsArgumentError,
    );
  });

  test('rejects an incomplete list instead of treating it as empty', () async {
    final client = _client(
      (_) => (status: 200, headers: <String, List<String>>{}, body: null),
    );
    await expectLater(
      client.protectedEnvironments.list(7),
      throwsA(isA<GitLabServerException>()),
    );
  });

  test(
    'lists protected environments and parses deployment approval rules',
    () async {
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
              'name': 'production',
              'required_approval_count': 2,
              'deploy_access_levels': [
                {
                  'id': 12,
                  'access_level': 40,
                  'access_level_description': 'Maintainers',
                },
              ],
              'approval_rules': [
                {
                  'id': 38,
                  'group_id': 134,
                  'access_level_description': 'Release team',
                  'required_approvals': 2,
                },
              ],
            },
          ],
        );
      });

      final page = await client.protectedEnvironments.list('team/app');
      expect(request.path, '/projects/team%2Fapp/protected_environments');
      expect(request.queryParameters['page'], 1);
      expect(page.nextPage, 2);
      final environment = page.items.single;
      expect(environment.name, 'production');
      expect(environment.requiredApprovalCount, 2);
      expect(environment.deployAccessLevels.single.description, 'Maintainers');
      expect(environment.approvalRules.single.requiredApprovals, 2);
      expect(environment.approvalRules.single.groupId, 134);
    },
  );

  test('gets an encoded environment name and maps forbidden access', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      return (
        status: 200,
        headers: <String, List<String>>{},
        body: {'name': 'review/production', 'deploy_access_levels': []},
      );
    });
    final environment = await client.protectedEnvironments.get(
      7,
      'review/production',
    );
    expect(
      request.path,
      '/projects/7/protected_environments/review%2Fproduction',
    );
    expect(environment.name, 'review/production');
    expect(environment.approvalRules, isEmpty);

    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.protectedEnvironments.list(7),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });

  test('lists group rules with pagination and reads a tier detail', () async {
    late RequestOptions request;
    final client = _client((options) {
      request = options;
      if (options.path.endsWith('/production')) {
        return (
          status: 200,
          headers: <String, List<String>>{},
          body: {
            'name': 'production',
            'deploy_access_levels': [
              {'access_level_description': 'Maintainers'},
            ],
            'approval_rules': [
              {
                'group_id': 135,
                'access_level_description': 'Security team',
                'required_approvals': 2,
              },
            ],
          },
        );
      }
      return (
        status: 200,
        headers: {
          'x-next-page': ['2'],
        },
        body: [
          {'name': 'production', 'required_approval_count': 2},
        ],
      );
    });

    final page = await client.groupProtectedEnvironments.list('team/release');
    expect(request.path, '/groups/team%2Frelease/protected_environments');
    expect(page.nextPage, 2);
    expect(page.items.single.requiredApprovalCount, 2);
    final detail = await client.groupProtectedEnvironments.get(7, 'production');
    expect(request.path, '/groups/7/protected_environments/production');
    expect(detail.approvalRules.single.requiredApprovals, 2);

    final forbidden = _client(
      (_) => (status: 403, headers: const {}, body: const {}),
    );
    await expectLater(
      forbidden.groupProtectedEnvironments.list(7),
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
