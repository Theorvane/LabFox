import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';
import 'mr_draft_note_maintenance_api_test.dart' as b;

const target = 'discussion +/#opaque';
Map<String, Object?> reply() => {
  'id': 7,
  'author_id': 23,
  'merge_request_id': 1100,
  'note': b.note,
  'discussion_id': target,
  'resolve_discussion': false,
};
Future<Object?> save(
  GitLabClient c, {
  Object project = 8,
  int iid = 142,
  String discussion = target,
  String note = b.note,
}) => c.mergeRequests.createDraftReply(
  project,
  iid: iid,
  discussionId: discussion,
  note: note,
);
void main() {
  for (final project in [8, 'group/project +']) {
    test(
      'private reply preserves exact body, target and non-resolution $project',
      () async {
        final requests = <RequestOptions>[];
        final c = b.makeClient((o) {
          requests.add(o);
          return (status: 201, body: reply());
        });
        addTearDown(c.close);
        final result = await save(c, project: project);
        expect(result, isNotNull);
        final o = requests.single;
        expect(
          o.path,
          '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/merge_requests/142/draft_notes',
        );
        expect(o.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
        expect(o.method, 'POST');
        expect(o.queryParameters, isEmpty);
        expect(o.data, {
          'note': b.note,
          'in_reply_to_discussion_id': target,
          'resolve_discussion': false,
        });
        expect(o.followRedirects, false);
        expect(o.extra['labfox_no_auth_retry'], true);
      },
    );
  }
  for (final invalid in [0, -1, '', '  ', 8.5]) {
    test('invalid project prevents reply dispatch $invalid', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        return (status: 201, body: reply());
      });
      addTearDown(c.close);
      await expectLater(save(c, project: invalid), throwsArgumentError);
      expect(calls, 0);
    });
  }
  for (final args in [
    (0, target, b.note),
    (-1, target, b.note),
    (142, '', b.note),
    (142, '  ', b.note),
    (142, target, ''),
    (142, target, ' \n '),
  ]) {
    test('invalid reply arguments prevent dispatch $args', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        return (status: 201, body: reply());
      });
      addTearDown(c.close);
      await expectLater(
        save(c, iid: args.$1, discussion: args.$2, note: args.$3),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final status in [
    200,
    202,
    204,
    302,
    307,
    400,
    401,
    403,
    404,
    409,
    412,
    422,
    429,
    500,
  ]) {
    test(
      'reply status $status is typed before malformed body decoding',
      () async {
        var calls = 0, refreshes = 0;
        final c = b.makeClient(
          (o) {
            calls++;
            return (status: status, body: '{private-marker');
          },
          raw: true,
          onUnauthorized: () async {
            refreshes++;
            return 'dummy-refreshed-token';
          },
        );
        addTearDown(c.close);
        final kind = switch (status) {
          401 => isA<GitLabAuthException>(),
          403 => isA<GitLabForbiddenException>(),
          404 => isA<GitLabNotFoundException>(),
          409 || 412 || 422 => isA<GitLabConflictException>(),
          429 => isA<GitLabRateLimitException>(),
          _ => isA<GitLabServerException>(),
        };
        await expectLater(
          save(c),
          throwsA(
            allOf(
              kind,
              isA<GitLabException>()
                  .having((e) => e.statusCode, 'status', status)
                  .having(
                    (e) => e.toString(),
                    'sanitized',
                    isNot(contains('private-marker')),
                  ),
            ),
          ),
        );
        expect(calls, 1);
        expect(refreshes, 0);
      },
    );
  }
  final malformed = <Object?>[
    null,
    [],
    {},
    'private-marker',
    {...reply(), 'id': 0},
    {...reply(), 'id': 7.5},
    {...reply(), 'author_id': 23.5},
    {...reply(), 'merge_request_id': 1100.5},
    {...reply(), 'note': b.note.trim()},
    {...reply(), 'discussion_id': null},
    {...reply(), 'discussion_id': 'another'},
    {...reply(), 'resolve_discussion': true},
    {...reply(), 'resolve_discussion': null},
    {...reply(), 'commit_id': 'commit'},
    {...reply(), 'line_code': 'anchor'},
    {...reply(), 'position': b.position.toJson()},
    {
      ...reply(),
      'position': {'position_type': 'future'},
    },
  ];
  for (var i = 0; i < malformed.length; i++) {
    test(
      'reply acknowledgement $i cannot confirm a changed or malformed target',
      () async {
        var calls = 0;
        final c = b.makeClient((o) {
          calls++;
          return (status: 201, body: malformed[i]);
        });
        addTearDown(c.close);
        await expectLater(
          save(c),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.toString(),
              'sanitized',
              isNot(contains('private-marker')),
            ),
          ),
        );
        expect(calls, 1);
      },
    );
  }
  test(
    'empty text placeholder position confirms an unpositioned reply',
    () async {
      final c = b.makeClient(
        (o) => (
          status: 201,
          body: {
            ...reply(),
            'position': {'position_type': 'text'},
          },
        ),
      );
      addTearDown(c.close);
      expect(await save(c), isNotNull);
    },
  );
  test('malformed 201 JSON remains sanitized', () async {
    final c = b.makeClient(
      (o) => (status: 201, body: '{private-marker'),
      raw: true,
    );
    addTearDown(c.close);
    await expectLater(
      save(c),
      throwsA(
        isA<GitLabServerException>().having(
          (e) => e.toString(),
          'sanitized',
          isNot(contains('private-marker')),
        ),
      ),
    );
  });
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  ]) {
    test('uncertain transport $type never replays or posts publicly', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        throw DioException(
          requestOptions: o,
          type: type,
          message: 'private-marker',
        );
      });
      addTearDown(c.close);
      await expectLater(
        save(c),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.toString(),
            'sanitized',
            isNot(contains('private-marker')),
          ),
        ),
      );
      expect(calls, 1);
    });
  }
}
