import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
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

DiffNotePosition _rangePosition({bool old = false, bool mixed = false}) {
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

void main() {
  for (final old in [false, true]) {
    for (final mixed in [false, true]) {
      for (final project in [8, 'group/project']) {
        test('preserves and confirms range $old $mixed $project', () async {
          final p = _rangePosition(old: old, mixed: mixed);
          late RequestOptions request;
          final client = _client((o) {
            request = o;
            return (status: 201, body: _thread(p));
          });
          addTearDown(client.close);
          final result = await client.mergeRequests.createPositionedDiscussion(
            project,
            iid: 142,
            body: '  Markdown\n  ',
            position: p,
          );
          expect(
            request.path,
            '/projects/${project is int ? project : 'group%2Fproject'}/merge_requests/142/discussions',
          );
          expect(request.baseUrl, 'https://gitlab.example.com/api/v4');
          expect(request.followRedirects, false);
          expect(request.extra['labfox_no_auth_retry'], true);
          final data = jsonDecode(jsonEncode(request.data)) as Map;
          expect(data['body'], '  Markdown\n  ');
          expect((data['position'] as Map)['line_range'], {
            'start': p.lineRange!.start!.toJson()
              ..removeWhere((_, v) => v == null),
            'end': p.lineRange!.end!.toJson()..removeWhere((_, v) => v == null),
          });
          expect(result.notes.single.position, p);
        });
      }
    }
  }
  final good = _rangePosition();
  final r = good.lineRange!;
  final invalid = [
    good.copyWith(lineRange: const DiffNoteLineRange()),
    good.copyWith(lineRange: r.copyWith(start: null)),
    good.copyWith(lineRange: r.copyWith(end: null)),
    good.copyWith(
      lineRange: r.copyWith(start: r.start!.copyWith(type: 'future')),
    ),
    good.copyWith(
      lineRange: r.copyWith(start: r.start!.copyWith(lineCode: 'invalid')),
    ),
    good.copyWith(
      lineRange: r.copyWith(
        start: r.start!.copyWith(lineCode: '${'a' * 40}_27_29'),
      ),
    ),
    good.copyWith(lineRange: r.copyWith(start: r.start!.copyWith(newLine: 0))),
    good.copyWith(lineRange: r.copyWith(start: r.start!.copyWith(newLine: 30))),
    good.copyWith(
      lineRange: r.copyWith(
        start: r.start!.copyWith(
          lineCode:
              '${sha1.convert(utf8.encode(good.newPath!))}_${'9' * 100}_29',
        ),
      ),
    ),
    good.copyWith(
      lineRange: r.copyWith(start: r.end, end: r.start),
    ),
    good.copyWith(newLine: 31),
    good.copyWith(oldLine: 31),
  ];
  for (var i = 0; i < invalid.length; i++) {
    test('rejects invalid range $i without dispatch', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 201, body: _thread(good));
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createPositionedDiscussion(
          8,
          iid: 142,
          body: 'Draft',
          position: invalid[i],
        ),
        throwsArgumentError,
      );
      expect(writes, 0);
    });
  }
  for (final p in [
    good.copyWith(lineRange: null),
    good.copyWith(lineRange: r.copyWith(start: r.end)),
    good.copyWith(
      lineRange: r.copyWith(end: r.end!.copyWith(type: 'old')),
    ),
    good.copyWith(lineRange: r.copyWith(start: r.start!.copyWith(newLine: 99))),
  ]) {
    test('rejects substituted returned range ${p.lineRange}', () async {
      var writes = 0;
      final client = _client((_) {
        writes++;
        return (status: 201, body: _thread(p));
      });
      addTearDown(client.close);
      await expectLater(
        client.mergeRequests.createPositionedDiscussion(
          8,
          iid: 142,
          body: 'Draft',
          position: good,
        ),
        throwsA(isA<GitLabServerException>()),
      );
      expect(writes, 1);
    });
  }
  test('server may omit optional endpoint display coordinates', () async {
    final returned = good.copyWith(
      lineRange: DiffNoteLineRange(
        start: r.start!.copyWith(oldLine: null, newLine: null),
        end: r.end!.copyWith(oldLine: null, newLine: null),
      ),
    );
    final client = _client((_) => (status: 201, body: _thread(returned)));
    addTearDown(client.close);
    expect(
      (await client.mergeRequests.createPositionedDiscussion(
        8,
        iid: 142,
        body: 'Draft',
        position: good,
      )).notes.single.position,
      returned,
    );
  });
  test('range OAuth failure never refreshes or replays', () async {
    var writes = 0, refreshes = 0;
    final client = _client(
      (_) {
        writes++;
        return (status: 401, body: {});
      },
      onUnauthorized: () async {
        refreshes++;
        return 'dummy';
      },
    );
    addTearDown(client.close);
    await expectLater(
      client.mergeRequests.createPositionedDiscussion(
        8,
        iid: 142,
        body: 'Draft',
        position: good,
      ),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(writes, 1);
    expect(refreshes, 0);
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
