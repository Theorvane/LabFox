import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';
import 'mr_draft_note_maintenance_api_test.dart' as b;

const commit = '0123456789abcdef0123456789abcdef01234567';
final position = b.position.copyWith(headSha: commit);
Map<String, Object?> draft({DiffNotePosition? p}) => {
  'id': 7,
  'author_id': 23,
  'merge_request_id': 1100,
  'note': b.note,
  'commit_id': commit,
  'resolve_discussion': false,
  'line_code': 'server-line-code',
  'position': (p ?? position).toJson(),
};
Future<MergeRequestDraftNote> save(
  GitLabClient c, {
  Object project = 8,
  int iid = 142,
  String commitId = commit,
  String note = b.note,
  DiffNotePosition? p,
}) => c.mergeRequests.createCommitDraftNote(
  project,
  iid: iid,
  commitId: commitId,
  note: note,
  position: p ?? position,
);

void main() {
  for (final project in [8, 'group/project +']) {
    for (final p in [
      position,
      position.copyWith(oldLine: 27, newLine: null),
      position.copyWith(oldLine: 27),
      b.range().copyWith(headSha: commit),
    ]) {
      test(
        'commit draft keeps exact private body and original position $project $p',
        () async {
          final requests = <RequestOptions>[];
          final c = b.makeClient((o) {
            requests.add(o);
            return (status: 201, body: draft(p: p));
          });
          addTearDown(c.close);
          final result = await save(c, project: project, p: p);
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
            'commit_id': commit,
            'resolve_discussion': false,
            'position': b.withoutNulls(p.toJson()),
          });
          expect(o.responseType, ResponseType.plain);
          expect(o.followRedirects, false);
          expect(o.extra['labfox_no_auth_retry'], true);
          expect(result.id, 7);
          expect(result.authorId, 23);
          expect(result.mergeRequestId, 1100);
          expect(result.note, b.note);
          expect(result.commitId, commit);
          expect(result.resolveDiscussion, false);
          expect(result.discussionId, isNull);
          expect(result.position, p);
        },
      );
    }
  }
  for (final invalid in [0, -1, '', '  ', 8.5]) {
    test('invalid project prevents commit draft dispatch $invalid', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        return (status: 201, body: draft());
      });
      addTearDown(c.close);
      await expectLater(save(c, project: invalid), throwsArgumentError);
      expect(calls, 0);
    });
  }
  for (final invalid in [
    '',
    ' ',
    'undefined',
    'HEAD',
    commit.substring(0, 8),
    '${commit}0',
    '$commit\n',
    ' $commit',
    commit.toUpperCase(),
    'g${commit.substring(1)}',
  ]) {
    test('commit identity must be a full lowercase SHA-1 $invalid', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        return (status: 201, body: draft());
      });
      addTearDown(c.close);
      await expectLater(
        save(
          c,
          commitId: invalid,
          p: position.copyWith(headSha: invalid),
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final input in [(0, b.note), (-1, b.note), (142, ''), (142, ' \n ')]) {
    test('invalid route or private body prevents dispatch $input', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        return (status: 201, body: draft());
      });
      addTearDown(c.close);
      await expectLater(
        save(c, iid: input.$1, note: input.$2),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  final invalidPositions = [
    const DiffNotePosition(),
    position.copyWith(headSha: 'another'),
    position.copyWith(baseSha: null),
    position.copyWith(startSha: ' '),
    position.copyWith(oldPath: null),
    position.copyWith(newPath: ''),
    position.copyWith(newLine: null),
    position.copyWith(newLine: 0),
    position.copyWith(oldLine: -1),
    position.copyWith(positionType: 'image'),
    position.copyWith(positionType: 'file'),
    position.copyWith(positionType: 'future'),
    position.copyWith(width: 20),
    position.copyWith(x: 0.5),
    position.copyWith(lineRange: const DiffNoteLineRange()),
    b.range().copyWith(headSha: commit, newLine: 31),
  ];
  for (var i = 0; i < invalidPositions.length; i++) {
    test(
      'unsupported or mismatched original commit position $i never dispatches',
      () async {
        var calls = 0;
        final c = b.makeClient((o) {
          calls++;
          return (status: 201, body: draft());
        });
        addTearDown(c.close);
        await expectLater(save(c, p: invalidPositions[i]), throwsArgumentError);
        expect(calls, 0);
      },
    );
  }
  final malformed = <Object?>[
    null,
    [],
    {},
    'private-marker',
    {...draft(), 'id': 0},
    {...draft(), 'id': 7.5},
    {...draft(), 'author_id': 0},
    {...draft(), 'author_id': 23.5},
    {...draft(), 'merge_request_id': 0},
    {...draft(), 'merge_request_id': 1100.5},
    {...draft(), 'note': b.note.trim()},
    {...draft(), 'commit_id': null},
    {...draft(), 'commit_id': 'another'},
    {...draft(), 'commit_id': 7},
    {...draft(), 'discussion_id': 'thread'},
    {...draft(), 'resolve_discussion': true},
    {...draft(), 'resolve_discussion': null},
    {...draft(), 'resolve_discussion': 'false'},
    {...draft(), 'position': null},
    {
      ...draft(),
      'position': {'position_type': 'text'},
    },
    {...draft(), 'position': position.copyWith(headSha: 'another').toJson()},
    {...draft(), 'position': position.copyWith(baseSha: 'another').toJson()},
    {...draft(), 'position': position.copyWith(startSha: 'another').toJson()},
    {...draft(), 'position': position.copyWith(newPath: 'another').toJson()},
    {...draft(), 'position': position.copyWith(oldPath: 'another').toJson()},
    {...draft(), 'position': position.copyWith(newLine: 30).toJson()},
    {...draft(), 'position': position.copyWith(oldLine: 27).toJson()},
    {...draft(), 'position': position.copyWith(positionType: 'image').toJson()},
    {...draft(), 'position': position.copyWith(width: 20).toJson()},
    {
      ...draft(),
      'position': {...position.toJson(), 'new_line': 29.5},
    },
    {...draft(), 'line_code': 7},
  ];
  for (var i = 0; i < malformed.length; i++) {
    test(
      'malformed or changed commit acknowledgement $i remains uncertain',
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
      'commit failure $status maps before private body decoding without replay',
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
  test(
    'malformed 201 JSON is sanitized without a second private write',
    () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        return (status: 201, body: '{private-marker');
      }, raw: true);
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
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  ]) {
    test(
      'uncertain commit transport $type never replays or publishes',
      () async {
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
      },
    );
  }
}
