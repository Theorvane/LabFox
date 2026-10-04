import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

const _position = DiffNotePosition(
  baseSha: 'base',
  startSha: 'start',
  headSha: 'head',
  oldPath: 'old path/#file.dart',
  newPath: 'new path/%file.dart',
  positionType: 'text',
  newLine: 29,
);
Map<String, Object?> _thread(DiffNotePosition p) => {
  'id': 'created-thread',
  'individual_note': false,
  'notes': [
    {
      'id': 301,
      'body': 'Created comment',
      'type': 'DiffNote',
      'system': false,
      'resolvable': true,
      'resolved': false,
      'position': p.toJson(),
      'author': {'id': 7, 'username': 'reviewer', 'name': 'Reviewer'},
    },
  ],
};
void main() {
  for (final project in [8, 'group/project']) {
    for (final p in [
      _position,
      _position.copyWith(oldLine: 27, newLine: null),
      _position.copyWith(oldLine: 27),
    ]) {
      test(
        'preserves positioned request $project ${p.oldLine}/${p.newLine}',
        () async {
          late RequestOptions request;
          var writes = 0;
          final client = _client((o) {
            request = o;
            writes++;
            return (status: 201, body: _thread(p));
          });
          addTearDown(client.close);
          const body = '  **Review**\n\nKeep the draft.  ';
          final result = await client.mergeRequests.createPositionedDiscussion(
            project,
            iid: 142,
            body: body,
            position: p,
          );
          expect(
            request.path,
            '/projects/${project is int ? project : 'group%2Fproject'}/merge_requests/142/discussions',
          );
          expect(request.baseUrl, 'https://gitlab.example.com/api/v4');
          expect(request.method, 'POST');
          expect(request.queryParameters, isEmpty);
          expect(request.data, {
            'body': body,
            'position': p.toJson()..removeWhere((_, value) => value == null),
          });
          expect(request.followRedirects, false);
          expect(request.extra['labfox_no_auth_retry'], true);
          expect(writes, 1);
          expect(result.id, 'created-thread');
          expect(result.individualNote, false);
          expect(result.notes.single.position, p);
        },
      );
    }
  }
  final invalid = [
    _position.copyWith(positionType: null),
    _position.copyWith(positionType: 'image'),
    _position.copyWith(positionType: 'file'),
    _position.copyWith(positionType: 'future'),
    _position.copyWith(baseSha: null),
    _position.copyWith(baseSha: ''),
    _position.copyWith(startSha: '  '),
    _position.copyWith(headSha: null),
    _position.copyWith(oldPath: null),
    _position.copyWith(oldPath: ''),
    _position.copyWith(newPath: null),
    _position.copyWith(newPath: ''),
    _position.copyWith(newLine: null),
    _position.copyWith(newLine: 0),
    _position.copyWith(newLine: -1),
    _position.copyWith(oldLine: 0),
    _position.copyWith(oldLine: -1),
    _position.copyWith(lineRange: const DiffNoteLineRange()),
    _position.copyWith(width: 2),
    _position.copyWith(height: 2),
    _position.copyWith(x: 0),
    _position.copyWith(y: 0),
  ];
  for (var i = 0; i < invalid.length; i++) {
    test(
      'rejects unsupported or incomplete position $i before dispatch',
      () async {
        var writes = 0;
        final client = _client((_) {
          writes++;
          return (status: 201, body: _thread(_position));
        });
        addTearDown(client.close);
        await expectLater(
          client.mergeRequests.createPositionedDiscussion(
            8,
            iid: 142,
            body: 'Comment',
            position: invalid[i],
          ),
          throwsArgumentError,
        );
        expect(writes, 0);
      },
    );
  }
  for (final input in [
    (iid: 0, body: 'Comment'),
    (iid: -1, body: 'Comment'),
    (iid: 142, body: ''),
    (iid: 142, body: ' \n\t'),
  ]) {
    test('rejects input $input before dispatch', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 201, body: _thread(_position));
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createPositionedDiscussion(
          8,
          iid: input.iid,
          body: input.body,
          position: _position,
        ),
        throwsArgumentError,
      );
      expect(writes, 0);
    });
  }
  final mismatches = [
    _position.copyWith(baseSha: 'other'),
    _position.copyWith(startSha: 'other'),
    _position.copyWith(headSha: 'other'),
    _position.copyWith(oldPath: 'other'),
    _position.copyWith(newPath: 'other'),
    _position.copyWith(newLine: 30),
    _position.copyWith(oldLine: 27),
    _position.copyWith(positionType: 'file'),
    _position.copyWith(lineRange: const DiffNoteLineRange()),
  ];
  final good = _thread(_position);
  final note = (good['notes'] as List).single as Map<String, Object?>;
  final malformed = <String, Object?>{
    'null': null,
    'list': [good],
    'scalar': 'private-content-marker',
    'empty': {},
    'missing ID': {...good, 'id': null},
    'empty ID': {...good, 'id': ''},
    'whitespace ID': {...good, 'id': '  '},
    'individual': {...good, 'individual_note': true},
    'no group type': {...good, 'individual_note': null},
    'empty notes': {...good, 'notes': []},
    for (final id in [null, 0, -1, 301.5, '301'])
      'bad note ID $id': {
        ...good,
        'notes': [
          {...note, 'id': id},
        ],
      },
    for (final type in [null, 'DiscussionNote', 'FutureNote'])
      'bad type $type': {
        ...good,
        'notes': [
          {...note, 'type': type},
        ],
      },
    'system root': {
      ...good,
      'notes': [
        {...note, 'system': true},
      ],
    },
    'missing position': {
      ...good,
      'notes': [
        {...note, 'position': null},
      ],
    },
    'bad body': {
      ...good,
      'notes': [
        {...note, 'body': 7},
      ],
    },
    'bad timestamp': {
      ...good,
      'notes': [
        {...note, 'created_at': 'private-content-marker'},
      ],
    },
    'bad position number': {
      ...good,
      'notes': [
        {
          ...note,
          'position': {..._position.toJson(), 'new_line': 29.5},
        },
      ],
    },
    for (var i = 0; i < mismatches.length; i++)
      'mismatch $i': _thread(mismatches[i]),
  };
  for (final entry in malformed.entries) {
    test('rejects unconfirmed creation ${entry.key}', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 201, body: entry.value);
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createPositionedDiscussion(
          8,
          iid: 142,
          body: 'Comment',
          position: _position,
        ),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid positioned discussion response.',
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  for (final status in [
    200,
    204,
    301,
    302,
    307,
    308,
    400,
    401,
    403,
    404,
    422,
    429,
    500,
    503,
  ]) {
    test('maps status $status without parse or replay', () async {
      var writes = 0;
      final client = _client(
        (_) {
          writes++;
          return (status: status, body: 'private-content-marker');
        },
        headers: {
          'retry-after': ['17'],
        },
      );
      addTearDown(client.close);
      final matcher = switch (status) {
        401 => isA<GitLabAuthException>(),
        403 => isA<GitLabForbiddenException>(),
        404 => isA<GitLabNotFoundException>(),
        429 => isA<GitLabRateLimitException>().having(
          (e) => e.retryAfter,
          'retry',
          const Duration(seconds: 17),
        ),
        _ => isA<GitLabServerException>(),
      };
      await expectLater(
        client.mergeRequests.createPositionedDiscussion(
          8,
          iid: 142,
          body: 'Comment',
          position: _position,
        ),
        throwsA(
          allOf(
            matcher,
            isA<GitLabException>()
                .having((e) => e.statusCode, 'status', status)
                .having(
                  (e) => e.message,
                  'sanitized',
                  isNot(contains('private-content-marker')),
                ),
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('maps transport $type without replay', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        throw DioException(
          requestOptions: o,
          type: type,
          error: 'private-content-marker',
        );
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createPositionedDiscussion(
          8,
          iid: 142,
          body: 'Comment',
          position: _position,
        ),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.message,
            'sanitized',
            isNot(contains('private-content-marker')),
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  test(
    'OAuth failure does not refresh or replay positioned creation',
    () async {
      var writes = 0;
      var refreshes = 0;
      final client = _client(
        (_) {
          writes++;
          return (status: 401, body: {});
        },
        onUnauthorized: () async {
          refreshes++;
          return 'dummy-refreshed-token';
        },
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createPositionedDiscussion(
          8,
          iid: 142,
          body: 'Comment',
          position: _position,
        ),
        throwsA(isA<GitLabAuthException>()),
      );
      expect(writes, 1);
      expect(refreshes, 0);
    },
  );
  test('preserves whitespace paths and server normalized body', () async {
    final p = _position.copyWith(oldPath: ' ', newPath: '\t');
    final client = _client((_) => (status: 201, body: _thread(p)));
    addTearDown(client.close);
    final result = await client.mergeRequests.createPositionedDiscussion(
      8,
      iid: 142,
      body: 'Comment /quick_action',
      position: p,
    );
    expect(result.notes.single.body, 'Created comment');
    expect(result.notes.single.position, p);
  });
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  Map<String, List<String>> headers = const {},
  Future<String?> Function()? onUnauthorized,
}) {
  final dio = Dio()..httpClientAdapter = _Adapter(handler, headers);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    bearer: onUnauthorized != null,
    onUnauthorized: onUnauthorized,
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler, this.headers);
  final ({int status, Object? body}) Function(RequestOptions) handler;
  final Map<String, List<String>> headers;
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
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
