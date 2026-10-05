import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

const note = '  **Updated private note**\n\n```suggestion\nreplacement\n```  ';
const position = DiffNotePosition(
  baseSha: 'base',
  startSha: 'start',
  headSha: 'head',
  oldPath: 'old path/#file.dart',
  newPath: 'new path/%file.dart',
  positionType: 'text',
  newLine: 29,
);
DiffNotePosition range() {
  final hash = sha1.convert(utf8.encode(position.newPath!)).toString();
  return position.copyWith(
    newLine: 32,
    lineRange: DiffNoteLineRange(
      start: DiffNoteRangeEndpoint(
        lineCode: '${hash}_27_29',
        type: 'new',
        newLine: 29,
      ),
      end: DiffNoteRangeEndpoint(
        lineCode: '${hash}_30_32',
        type: 'new',
        newLine: 32,
      ),
    ),
  );
}

Map<String, Object?> draft({DiffNotePosition? p}) => {
  'id': 5,
  'author_id': 23,
  'merge_request_id': 1100,
  'note': note,
  'resolve_discussion': true,
  'discussion_id': 'existing-thread',
  'commit_id': 'original-commit',
  'line_code': p == null ? null : 'original-line-code',
  'position': p?.toJson(),
};
Future<Object?> run(
  GitLabClient client,
  String op, {
  Object project = 8,
  int iid = 142,
  int id = 5,
  String body = note,
  DiffNotePosition? p,
}) async {
  if (op == 'update') {
    return client.mergeRequests.updateDraftNote(
      project,
      iid: iid,
      draftNoteId: id,
      note: body,
      position: p,
    );
  }
  await client.mergeRequests.deleteDraftNote(
    project,
    iid: iid,
    draftNoteId: id,
  );
  return null;
}

Map<String, Object?> withoutNulls(Map<String, dynamic> value) => {
  for (final entry in value.entries)
    if (entry.value != null)
      entry.key: entry.value is Map<String, dynamic>
          ? withoutNulls(entry.value as Map<String, dynamic>)
          : entry.value,
};
void main() {
  for (final project in [8, 'group/project +']) {
    for (final p in [null, position, range()]) {
      test('update keeps exact body and original position $project $p', () async {
        final requests = <RequestOptions>[];
        final client = makeClient((o) {
          requests.add(o);
          return (status: 200, body: draft(p: p));
        });
        addTearDown(client.close);
        final result =
            await run(client, 'update', project: project, p: p)
                as MergeRequestDraftNote;
        final request = requests.single;
        expect(
          request.path,
          '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/merge_requests/142/draft_notes/5',
        );
        expect(request.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
        expect(request.method, 'PUT');
        expect(request.queryParameters, isEmpty);
        expect(request.data, {
          'note': note,
          if (p != null) 'position': withoutNulls(p.toJson()),
        });
        expect(request.followRedirects, false);
        expect(request.extra['labfox_no_auth_retry'], true);
        expect(result.id, 5);
        expect(result.mergeRequestId, 1100);
        expect(result.note, note);
        expect(result.position, p);
        expect(result.discussionId, 'existing-thread');
        expect(result.commitId, 'original-commit');
        expect(result.resolveDiscussion, true);
      });
    }
    test(
      'delete acknowledges one exact routed private target $project',
      () async {
        final requests = <RequestOptions>[];
        final client = makeClient((o) {
          requests.add(o);
          return (status: 204, body: null);
        });
        addTearDown(client.close);
        await run(client, 'delete', project: project);
        final request = requests.single;
        expect(
          request.path,
          '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/merge_requests/142/draft_notes/5',
        );
        expect(request.method, 'DELETE');
        expect(request.data, isNull);
        expect(request.queryParameters, isEmpty);
        expect(request.followRedirects, false);
        expect(request.extra['labfox_no_auth_retry'], true);
      },
    );
  }
  for (final op in ['update', 'delete']) {
    for (final ids in [(0, 5), (-1, 5), (142, 0), (142, -1)]) {
      test('$op invalid IID/draft ID $ids prevents dispatch', () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: 200, body: draft());
        });
        addTearDown(client.close);
        await expectLater(
          run(client, op, iid: ids.$1, id: ids.$2),
          throwsArgumentError,
        );
        expect(calls, 0);
      });
    }
    for (final project in [0, -1, '', '  ', 8.5]) {
      test('$op invalid project $project prevents dispatch', () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: 200, body: draft());
        });
        addTearDown(client.close);
        await expectLater(
          run(client, op, project: project),
          throwsArgumentError,
        );
        expect(calls, 0);
      });
    }
    for (final status in [
      200,
      201,
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
      if (status == (op == 'update' ? 200 : 204)) continue;
      test('$op maps status $status before parsing private payload', () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: status, body: 'private-error-marker');
        });
        addTearDown(client.close);
        final matcher = switch (status) {
          401 => isA<GitLabAuthException>(),
          403 => isA<GitLabForbiddenException>(),
          404 => isA<GitLabNotFoundException>(),
          409 || 412 || 422 => isA<GitLabConflictException>(),
          429 => isA<GitLabRateLimitException>(),
          _ => isA<GitLabServerException>(),
        };
        await expectLater(
          run(client, op),
          throwsA(
            allOf(
              matcher,
              isA<GitLabException>()
                  .having((e) => e.statusCode, 'status', status)
                  .having(
                    (e) => e.toString(),
                    'sanitized',
                    isNot(contains('private-error-marker')),
                  ),
            ),
          ),
        );
        expect(calls, 1);
      });
    }
    for (final status in [401, 403, 404, 409, 412, 422, 429, 500]) {
      test(
        '$op thrown Dio response $status stays typed and sanitized',
        () async {
          var calls = 0;
          final client = makeClient((o) {
            calls++;
            throw DioException(
              requestOptions: o,
              type: DioExceptionType.badResponse,
              message: 'private-error-marker',
              response: Response<Object?>(
                requestOptions: o,
                statusCode: status,
                data: 'private-error-marker',
              ),
            );
          });
          addTearDown(client.close);
          final matcher = switch (status) {
            401 => isA<GitLabAuthException>(),
            403 => isA<GitLabForbiddenException>(),
            404 => isA<GitLabNotFoundException>(),
            409 || 412 || 422 => isA<GitLabConflictException>(),
            429 => isA<GitLabRateLimitException>(),
            _ => isA<GitLabServerException>(),
          };
          await expectLater(
            run(client, op),
            throwsA(
              allOf(
                matcher,
                isA<GitLabException>()
                    .having((e) => e.statusCode, 'status', status)
                    .having(
                      (e) => e.toString(),
                      'sanitized',
                      isNot(contains('private-error-marker')),
                    ),
              ),
            ),
          );
          expect(calls, 1);
        },
      );
    }
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.badCertificate,
    ]) {
      test('$op transport $type is sanitized and never replayed', () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          throw DioException(
            requestOptions: o,
            type: type,
            message: 'private-error-marker',
            error: 'private-error-marker',
          );
        });
        addTearDown(client.close);
        await expectLater(
          run(client, op),
          throwsA(
            isA<GitLabConnectionException>().having(
              (e) => e.toString(),
              'sanitized',
              isNot(contains('private-error-marker')),
            ),
          ),
        );
        expect(calls, 1);
      });
    }
    test('$op OAuth failure cannot refresh or replay', () async {
      var calls = 0, refreshes = 0;
      final client = makeClient(
        (o) {
          calls++;
          return (status: 401, body: null);
        },
        onUnauthorized: () async {
          refreshes++;
          return 'dummy-refreshed-token';
        },
      );
      addTearDown(client.close);
      await expectLater(run(client, op), throwsA(isA<GitLabAuthException>()));
      expect(calls, 1);
      expect(refreshes, 0);
    });
  }
  for (final body in ['', '  \n\t ']) {
    test('update rejects blank body before dispatch', () async {
      var calls = 0;
      final client = makeClient((o) {
        calls++;
        return (status: 200, body: draft());
      });
      addTearDown(client.close);
      await expectLater(run(client, 'update', body: body), throwsArgumentError);
      expect(calls, 0);
    });
  }
  for (final p in [
    position.copyWith(baseSha: null),
    position.copyWith(newLine: 0),
    position.copyWith(newLine: null),
    position.copyWith(positionType: 'image'),
    position.copyWith(positionType: 'future'),
    range().copyWith(lineRange: const DiffNoteLineRange()),
  ]) {
    test(
      'update rejects incomplete or unsupported original position $p',
      () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: 200, body: draft());
        });
        addTearDown(client.close);
        await expectLater(run(client, 'update', p: p), throwsArgumentError);
        expect(calls, 0);
      },
    );
  }
  final malformed = <Object?>[
    null,
    [],
    {},
    'private-error-marker',
    {...draft(), 'id': 6},
    {...draft(), 'note': note.trim()},
    {...draft(), 'author_id': null},
    {...draft(), 'merge_request_id': 142.5},
    {...draft(), 'resolve_discussion': 'true'},
    {
      ...draft(),
      'position': {'new_line': 0},
    },
    {...draft(), 'discussion_id': false},
  ];
  for (var i = 0; i < malformed.length; i++) {
    test(
      'update malformed or unconfirmed payload $i fails once without private details',
      () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: 200, body: malformed[i]);
        });
        addTearDown(client.close);
        await expectLater(
          run(client, 'update'),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message,
              'sanitized',
              'Invalid draft note update response.',
            ),
          ),
        );
        expect(calls, 1);
      },
    );
  }
  for (final p in [
    null,
    position.copyWith(headSha: 'changed'),
    position.copyWith(newLine: 30),
    range().copyWith(newLine: 33),
  ]) {
    test(
      'update cannot confirm lost or changed original position $p',
      () async {
        final client = makeClient((o) => (status: 200, body: draft(p: p)));
        addTearDown(client.close);
        await expectLater(
          run(client, 'update', p: position),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  test('regular update cannot confirm a returned positioned note', () async {
    final client = makeClient((o) => (status: 200, body: draft(p: position)));
    addTearDown(client.close);
    await expectLater(
      run(client, 'update'),
      throwsA(isA<GitLabServerException>()),
    );
  });
  test(
    'multiline update accepts omitted optional display counters with original codes and sides',
    () async {
      final p = range();
      final json = p.toJson();
      final r = json['line_range'] as Map<String, dynamic>;
      for (final key in ['start', 'end']) {
        (r[key] as Map<String, dynamic>).removeWhere(
          (k, _) => k == 'old_line' || k == 'new_line',
        );
      }
      final client = makeClient(
        (o) => (
          status: 200,
          body: {
            ...draft(p: p),
            'position': json,
          },
        ),
      );
      addTearDown(client.close);
      final result = await run(client, 'update', p: p) as MergeRequestDraftNote;
      expect(
        result.position!.lineRange!.start!.lineCode,
        p.lineRange!.start!.lineCode,
      );
      expect(result.position!.lineRange!.start!.newLine, isNull);
    },
  );
  for (final status in [400, 401, 403, 404, 409, 412, 422, 429, 500]) {
    test(
      'update raw invalid JSON HTTP $status preserves status before decoding',
      () async {
        final client = makeClient(
          (o) => (status: status, body: '{private-error-marker'),
          raw: true,
        );
        addTearDown(client.close);
        await expectLater(
          run(client, 'update'),
          throwsA(
            isA<GitLabException>()
                .having((e) => e.statusCode, 'status before decode', status)
                .having(
                  (e) => e.toString(),
                  'sanitized',
                  isNot(contains('private-error-marker')),
                ),
          ),
        );
      },
    );
  }
  test('update raw malformed success JSON is sanitized', () async {
    final client = makeClient(
      (o) => (status: 200, body: '{private-error-marker'),
      raw: true,
    );
    addTearDown(client.close);
    await expectLater(
      run(client, 'update'),
      throwsA(
        isA<GitLabServerException>().having(
          (e) => e.message,
          'sanitized',
          'Invalid draft note update response.',
        ),
      ),
    );
  });
  test('delete raw malformed 204 body is not parsed or exposed', () async {
    final client = makeClient(
      (o) => (status: 204, body: '{private-error-marker'),
      raw: true,
    );
    addTearDown(client.close);
    await run(client, 'delete');
  });
}

GitLabClient makeClient(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  Future<String?> Function()? onUnauthorized,
  bool raw = false,
}) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500))
    ..httpClientAdapter = Adapter(handler, raw: raw);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com/subpath',
    token: 'glpat-xxxxxxxxxxxx',
    bearer: onUnauthorized != null,
    onUnauthorized: onUnauthorized,
    dio: dio,
  );
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler, {this.raw = false});
  final bool raw;
  final ({int status, Object? body}) Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    final result = handler(o);
    return ResponseBody.fromString(
      result.body == null
          ? ''
          : raw
          ? '${result.body}'
          : json.encode(result.body),
      result.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
