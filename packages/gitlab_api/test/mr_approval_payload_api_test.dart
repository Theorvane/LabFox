import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const _user = {'id': 7, 'username': 'reviewer', 'name': 'Reviewer'};
Map<String, Object?> _payload(Object? approvers) => {
  'approvals_required': 2,
  'approved_by': approvers,
};
void main() {
  final malformed = <String, Object?>{
    'null': null,
    'scalar': 'private-response-marker',
    'array': [],
    'empty object': {},
    'missing approvers': {'approvals_required': 2},
    'null approvers': _payload(null),
    'object approvers': _payload({}),
    'scalar approvers': _payload('private-response-marker'),
    'null entry': _payload([null]),
    'scalar entry': _payload(['private-response-marker']),
    'missing user': _payload([{}]),
    'null user': _payload([
      {'user': null},
    ]),
    'scalar user': _payload([
      {'user': 'private-response-marker'},
    ]),
    'empty user': _payload([
      {'user': {}},
    ]),
    'missing user ID': _payload([
      {
        'user': {'username': 'reviewer', 'name': 'Reviewer'},
      },
    ]),
    'fractional user ID': _payload([
      {
        'user': {..._user, 'id': 7.5},
      },
    ]),
    'zero user ID': _payload([
      {
        'user': {..._user, 'id': 0},
      },
    ]),
    'negative user ID': _payload([
      {
        'user': {..._user, 'id': -7},
      },
    ]),
    'invalid username': _payload([
      {
        'user': {..._user, 'username': 7},
      },
    ]),
    'invalid name': _payload([
      {
        'user': {..._user, 'name': []},
      },
    ]),
    'invalid optional field': _payload([
      {
        'user': {..._user, 'avatar_url': []},
      },
    ]),
    'valid then invalid': _payload([
      {'user': _user},
      {},
    ]),
    'negative count': {'approvals_required': -1, 'approved_by': []},
    'fractional count': {'approvals_required': 2.5, 'approved_by': []},
    'string count': {
      'approvals_required': 'private-response-marker',
      'approved_by': [],
    },
    'null count': {'approvals_required': null, 'approved_by': []},
    'invalid legacy flag': {
      'user_has_approved': 'private-response-marker',
      'approved_by': [],
    },
  };
  for (final entry in malformed.entries) {
    test('rejects malformed approval state: ${entry.key}', () async {
      final client = _client((_) => (status: 200, body: entry.value));
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.approvals('group/project', iid: 142),
        throwsA(
          isA<GitLabServerException>()
              .having(
                (e) => e.message,
                'sanitized message',
                'Invalid approvals response.',
              )
              .having(
                (e) => e.toString().contains('private-response-marker'),
                'payload excluded',
                false,
              ),
        ),
      );
    });
  }
  for (final count in [null, 0, 2]) {
    test('accepts documented approval state count=$count', () async {
      late RequestOptions captured;
      final client = _client((options) {
        captured = options;
        return (
          status: 200,
          body: {
            'approvals_required': ?count,
            'approved_by': [
              {'user': _user, 'approved_at': '2026-10-04T00:00:00Z'},
            ],
            'unknown_future_field': {'value': true},
          },
        );
      });
      addTearDown(client.close);
      final approvals = await client.mergeRequests.approvals(
        'group/project',
        iid: 142,
      );
      expect(captured.method, 'GET');
      expect(
        captured.path,
        '/projects/group%2Fproject/merge_requests/142/approvals',
      );
      expect(approvals.approvalsRequired, count ?? 0);
      expect(approvals.approvedCount, 1);
      expect(approvals.approvedBy.single.id, 7);
      expect(approvals.userHasApproved, false);
    });
  }
  test('accepts explicit empty approver list', () async {
    final client = _client((_) => (status: 200, body: _payload([])));
    addTearDown(client.close);
    expect(
      (await client.mergeRequests.approvals(8, iid: 142)).approvedBy,
      isEmpty,
    );
  });
  final errors = <int, Matcher>{
    401: isA<GitLabAuthException>(),
    403: isA<GitLabForbiddenException>(),
    404: isA<GitLabNotFoundException>(),
    429: isA<GitLabRateLimitException>(),
    500: isA<GitLabServerException>(),
  };
  for (final entry in errors.entries) {
    test('preserves HTTP ${entry.key} despite malformed body', () async {
      final client = _client(
        (_) => (status: entry.key, body: 'private-response-marker'),
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.approvals(8, iid: 142),
        throwsA(entry.value),
      );
    });
  }
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.com',
    token: 'glpat-x',
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
    final r = handler(options);
    return ResponseBody.fromString(
      r.body == null ? '' : json.encode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
