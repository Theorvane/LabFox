import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

const _note = '  **Private review**\n\n```suggestion\nupdated\n```  ';
const _position = DiffNotePosition(
  baseSha: 'base',
  startSha: 'start',
  headSha: 'head',
  oldPath: 'old path/#file.dart',
  newPath: 'new path/%file.dart',
  positionType: 'text',
  newLine: 29,
);
Map<String, Object?> _draft({DiffNotePosition? position}) => {
  'id': 5,
  'author_id': 23,
  'merge_request_id': 1100,
  'note': _note,
  'resolve_discussion': false,
  'discussion_id': null,
  'commit_id': null,
  'line_code': position == null ? null : 'server-line-code',
  'position': position?.toJson() ?? {'position_type': 'text'},
};
DiffNotePosition _range({bool old = false, bool mixed = false}) {
  final hash = sha1.convert(utf8.encode(_position.newPath!)).toString();
  return _position.copyWith(
    oldLine: old ? 30 : null,
    newLine: old ? null : 32,
    lineRange: DiffNoteLineRange(
      start: DiffNoteRangeEndpoint(
        lineCode: '${hash}_27_29',
        type: old || mixed ? 'old' : 'new',
        oldLine: old || mixed ? 27 : null,
        newLine: old || mixed ? null : 29,
      ),
      end: DiffNoteRangeEndpoint(
        lineCode: '${hash}_30_32',
        type: old ? 'old' : 'new',
        oldLine: old ? 30 : null,
        newLine: old ? null : 32,
      ),
    ),
  );
}

Map<String, Object?> _withoutNulls(Map<String, dynamic> json) => {
  for (final entry in json.entries)
    if (entry.value != null)
      entry.key: entry.value is Map<String, dynamic>
          ? _withoutNulls(entry.value as Map<String, dynamic>)
          : entry.value,
};
void main() {
  for (final project in [8, 'group/project +']) {
    for (final position in <DiffNotePosition?>[
      null,
      _position,
      _position.copyWith(oldLine: 27, newLine: null),
      _position.copyWith(oldLine: 27),
      _range(),
      _range(old: true),
      _range(mixed: true),
    ]) {
      test('saves exact private draft $project $position', () async {
        late RequestOptions request;
        var writes = 0;
        final client = _client((o) {
          request = o;
          writes++;
          return (status: 201, body: _draft(position: position));
        });
        addTearDown(client.close);
        final result = await client.mergeRequests.createDraftNote(
          project,
          iid: 142,
          note: _note,
          position: position,
        );
        expect(
          request.path,
          '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/merge_requests/142/draft_notes',
        );
        expect(request.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
        expect(request.method, 'POST');
        expect(request.queryParameters, isEmpty);
        expect(request.data, {
          'note': _note,
          'resolve_discussion': false,
          if (position != null) 'position': _withoutNulls(position.toJson()),
        });
        expect(request.followRedirects, false);
        expect(request.extra['labfox_no_auth_retry'], true);
        expect(writes, 1);
        expect(result.id, 5);
        expect(result.authorId, 23);
        expect(result.mergeRequestId, 1100);
        expect(result.note, _note);
        expect(result.resolveDiscussion, false);
        expect(result.discussionId, isNull);
        if (position != null) {
          expect(result.position, position);
        }
      });
    }
  }
  for (final returned in [
    null,
    <String, Object?>{},
    {'position_type': 'text'},
    {
      'base_sha': null,
      'start_sha': null,
      'head_sha': null,
      'old_path': null,
      'new_path': null,
      'position_type': 'text',
      'old_line': null,
      'new_line': null,
      'line_range': null,
    },
  ]) {
    test(
      'accepts regular-note absent/null placeholder position: $returned',
      () async {
        final client = _client(
          (o) => (status: 201, body: {..._draft(), 'position': returned}),
        );
        addTearDown(client.close);
        expect(
          (await client.mergeRequests.createDraftNote(
            8,
            iid: 142,
            note: _note,
          )).note,
          _note,
        );
      },
    );
  }
  final invalidPositions = [
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
    _position.copyWith(width: 2),
    _position.copyWith(height: 2),
    _position.copyWith(x: 0),
    _position.copyWith(y: 0),
    _position.copyWith(lineRange: const DiffNoteLineRange()),
    _range().copyWith(newLine: 33),
    _range().copyWith(lineRange: _range().lineRange!.copyWith(start: null)),
    _range().copyWith(
      lineRange: _range().lineRange!.copyWith(
        end: _range().lineRange!.end!.copyWith(type: 'future'),
      ),
    ),
    _range().copyWith(
      lineRange: _range().lineRange!.copyWith(
        start: _range().lineRange!.start!.copyWith(
          lineCode: 'private-content-marker',
        ),
      ),
    ),
    _range().copyWith(
      lineRange: _range().lineRange!.copyWith(
        start: _range().lineRange!.start!.copyWith(newLine: 28),
      ),
    ),
    _range().copyWith(
      lineRange: _range().lineRange!.copyWith(
        start: _range().lineRange!.end,
        end: _range().lineRange!.start,
      ),
    ),
  ];
  for (var i = 0; i < invalidPositions.length; i++) {
    test(
      'invalid/incomplete original position $i fails before dispatch',
      () async {
        var writes = 0;
        final client = _client((o) {
          writes++;
          return (status: 201, body: _draft());
        });
        addTearDown(client.close);
        await expectLater(
          client.mergeRequests.createDraftNote(
            8,
            iid: 142,
            note: _note,
            position: invalidPositions[i],
          ),
          throwsArgumentError,
        );
        expect(writes, 0);
      },
    );
  }
  for (final input in [(0, _note), (-1, _note), (142, ''), (142, ' \n\t')]) {
    test('invalid draft input $input fails before dispatch', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        return (status: 201, body: _draft());
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createDraftNote(8, iid: input.$1, note: input.$2),
        throwsArgumentError,
      );
      expect(writes, 0);
    });
  }
  final malformed = <String, Object?>{
    'null': null,
    'scalar': 'private-content-marker',
    'array': [_draft()],
    'empty': {},
    'missing note': {..._draft()}..remove('note'),
    'nonstring note': {..._draft(), 'note': 8},
    'normalized note': {..._draft(), 'note': _note.trim()},
    'different note': {..._draft(), 'note': 'private-content-marker'},
    'missing resolution': {..._draft()}..remove('resolve_discussion'),
    'null resolution': {..._draft(), 'resolve_discussion': null},
    'wrong resolution type': {..._draft(), 'resolve_discussion': 'false'},
    'resolve intent': {..._draft(), 'resolve_discussion': true},
    'unexpected reply': {
      ..._draft(),
      'discussion_id': 'private-content-marker',
    },
    'unexpected commit': {..._draft(), 'commit_id': 'private-content-marker'},
    'wrong position type': {..._draft(), 'position': []},
    'unexpected regular position': _draft(position: _position),
    'unexpected regular line code': {
      ..._draft(),
      'line_code': 'private-content-marker',
    },
  };
  for (final field in ['id', 'author_id', 'merge_request_id']) {
    for (final value in [null, 0, -1, 5.5, 5.0, '5']) {
      malformed['$field=$value (${value.runtimeType})'] = {
        ..._draft(),
        field: value,
      };
    }
  }
  for (final position in [
    {'position_type': 'image'},
    {'position_type': 'file'},
    {'position_type': 'future'},
    {'base_sha': 'base'},
    {'old_path': 'file'},
    {'new_line': 2},
    {'line_range': {}},
    {'x': 0},
  ]) {
    malformed['unexpected regular metadata $position'] = {
      ..._draft(),
      'position': position,
    };
  }
  for (final entry in malformed.entries) {
    test('unconfirmed regular creation fails once: ${entry.key}', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        return (status: 201, body: entry.value);
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createDraftNote(8, iid: 142, note: _note),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid draft note creation response.',
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  final wrongPositions = <String, Object?>{
    'missing': null,
    'object': {},
    'base': _position.copyWith(baseSha: 'other').toJson(),
    'start': _position.copyWith(startSha: 'other').toJson(),
    'head': _position.copyWith(headSha: 'other').toJson(),
    'old path': _position.copyWith(oldPath: 'other').toJson(),
    'new path': _position.copyWith(newPath: 'other').toJson(),
    'new line': _position.copyWith(newLine: 30).toJson(),
    'extra old line': _position.copyWith(oldLine: 27).toJson(),
    'range': _range().toJson(),
    'type': _position.copyWith(positionType: 'file').toJson(),
    'fractional': {..._position.toJson(), 'new_line': 29.5},
    'extra image': _position.copyWith(x: 0).toJson(),
  };
  for (final entry in wrongPositions.entries) {
    test('changed original positioned creation fails: ${entry.key}', () async {
      final client = _client(
        (o) => (
          status: 201,
          body: {
            ..._draft(position: _position),
            'position': entry.value,
          },
        ),
      );
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createDraftNote(
          8,
          iid: 142,
          note: _note,
          position: _position,
        ),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid draft note creation response.',
          ),
        ),
      );
    });
  }
  test(
    'returned range display coordinates may be omitted with exact codes and sides',
    () async {
      final position = _range(mixed: true);
      final json = position.toJson();
      final range = json['line_range'] as Map<String, dynamic>;
      for (final key in ['start', 'end']) {
        (range[key] as Map<String, dynamic>).removeWhere(
          (key, _) => key == 'old_line' || key == 'new_line',
        );
      }
      final client = _client(
        (o) => (
          status: 201,
          body: {
            ..._draft(position: position),
            'position': json,
          },
        ),
      );
      addTearDown(client.close);
      final result = await client.mergeRequests.createDraftNote(
        8,
        iid: 142,
        note: _note,
        position: position,
      );
      expect(
        result.position!.lineRange!.start!.lineCode,
        position.lineRange!.start!.lineCode,
      );
      expect(result.position!.lineRange!.end!.newLine, isNull);
    },
  );
  final range = _range();
  final changedRanges = [
    range.copyWith(lineRange: null),
    range.copyWith(lineRange: range.lineRange!.copyWith(start: null)),
    range.copyWith(
      lineRange: range.lineRange!.copyWith(
        start: range.lineRange!.start!.copyWith(type: 'old'),
      ),
    ),
    range.copyWith(
      lineRange: range.lineRange!.copyWith(
        start: range.lineRange!.start!.copyWith(newLine: 28),
      ),
    ),
    range.copyWith(
      lineRange: range.lineRange!.copyWith(
        end: range.lineRange!.end!.copyWith(lineCode: 'private-content-marker'),
      ),
    ),
    range.copyWith(
      lineRange: range.lineRange!.copyWith(
        start: range.lineRange!.end,
        end: range.lineRange!.start,
      ),
    ),
  ];
  for (var i = 0; i < changedRanges.length; i++) {
    test(
      'changed/missing range $i cannot confirm the original selection',
      () async {
        final client = _client(
          (o) => (status: 201, body: _draft(position: changedRanges[i])),
        );
        addTearDown(client.close);
        await expectLater(
          client.mergeRequests.createDraftNote(
            8,
            iid: 142,
            note: _note,
            position: range,
          ),
          throwsA(isA<GitLabServerException>()),
        );
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
    422,
    429,
    500,
  ]) {
    test('maps HTTP $status before parsing the write response', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        return (status: status, body: 'private-content-marker');
      });
      addTearDown(client.close);
      final matcher = switch (status) {
        401 => isA<GitLabAuthException>(),
        403 => isA<GitLabForbiddenException>(),
        404 => isA<GitLabNotFoundException>(),
        409 || 422 => isA<GitLabConflictException>(),
        429 => isA<GitLabRateLimitException>(),
        _ => isA<GitLabServerException>(),
      };
      await expectLater(
        client.mergeRequests.createDraftNote(8, iid: 142, note: _note),
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
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('transport failure $type is sanitized and never retried', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        throw DioException(
          requestOptions: o,
          type: type,
          message: 'private-content-marker',
          error: 'private-content-marker',
        );
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createDraftNote(8, iid: 142, note: _note),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.toString(),
            'sanitized',
            isNot(contains('private-content-marker')),
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  for (final status in [409, 422]) {
    test(
      'Dio rejection preserves conflict status $status without replay',
      () async {
        var writes = 0;
        final client = _client((o) {
          writes++;
          throw DioException(
            requestOptions: o,
            type: DioExceptionType.badResponse,
            message: 'private-content-marker',
            response: Response<Object?>(
              requestOptions: o,
              statusCode: status,
              data: 'private-content-marker',
            ),
          );
        });
        addTearDown(client.close);
        await expectLater(
          client.mergeRequests.createDraftNote(8, iid: 142, note: _note),
          throwsA(
            isA<GitLabConflictException>()
                .having((e) => e.statusCode, 'status', status)
                .having(
                  (e) => e.message,
                  'sanitized',
                  isNot(contains('private-content-marker')),
                ),
          ),
        );
        expect(writes, 1);
      },
    );
  }
  test('OAuth failure never refreshes or replays draft creation', () async {
    var writes = 0, refreshes = 0;
    final client = _client(
      (o) {
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
      client.mergeRequests.createDraftNote(8, iid: 142, note: _note),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(writes, 1);
    expect(refreshes, 0);
  });
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  Future<String?> Function()? onUnauthorized,
}) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com/subpath',
    token: 'glpat-xxxxxxxxxxxx',
    bearer: onUnauthorized != null,
    onUnauthorized: onUnauthorized,
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
      result.body == null ? '' : json.encode(result.body),
      result.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
