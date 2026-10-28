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
  oldPath: 'a.dart',
  newPath: 'a.dart',
  positionType: 'text',
  oldLine: 27,
  newLine: 27,
);
const _suggestion = <String, Object?>{
  'id': 5,
  'from_line': 27,
  'to_line': 28,
  'appliable': true,
  'applied': false,
  'from_content': '  original\n',
  'to_content': '  replacement\n',
};

enum _Operation { read, reply, resolve, create }

Map<String, Object?> _note(Object? suggestions, {bool omit = false}) => {
  'id': 301,
  'body': 'Review suggestion',
  'type': 'DiffNote',
  'system': false,
  'position': _position.toJson(),
  'resolvable': true,
  'resolved': true,
  if (!omit) 'suggestions': suggestions,
};
Map<String, Object?> _thread(Map<String, Object?> note) => {
  'id': 'thread',
  'individual_note': false,
  'notes': [note],
};
Future<Note> _read(GitLabClient c, _Operation op) async => switch (op) {
  _Operation.read => (await c.mergeRequests.discussions(
    8,
    iid: 142,
  )).items.single.notes.single,
  _Operation.reply => await c.mergeRequests.replyToDiscussion(
    8,
    iid: 142,
    discussionId: 'thread',
    body: 'Reply',
  ),
  _Operation.resolve => (await c.mergeRequests.setDiscussionResolved(
    8,
    iid: 142,
    discussionId: 'thread',
    resolved: true,
  )).notes.single,
  _Operation.create => (await c.mergeRequests.createPositionedDiscussion(
    8,
    iid: 142,
    body: 'Review',
    position: _position,
  )).notes.single,
};
Object _payload(_Operation op, Map<String, Object?> note) => switch (op) {
  _Operation.read => [_thread(note)],
  _Operation.reply => note,
  _ => _thread(note),
};
void main() {
  for (final op in _Operation.values) {
    for (final shape in [
      'omitted',
      'null',
      'empty',
      'legacy',
      'documented',
      'same aliases',
      'sparse',
      'two',
    ]) {
      test('$op preserves suggestion metadata $shape', () async {
        final value = switch (shape) {
          'omitted' || 'null' => null,
          'empty' => <Object?>[],
          'legacy' => [_suggestion],
          'documented' => [
            {..._suggestion, 'appliable': null, 'applicable': true},
          ],
          'same aliases' => [
            {..._suggestion, 'applicable': true},
          ],
          'sparse' => [
            {'id': 5},
          ],
          'two' => [
            _suggestion,
            {..._suggestion, 'id': 6, 'to_content': ''},
          ],
          _ => throw StateError('fixture'),
        };
        final note = _note(value, omit: shape == 'omitted');
        final client = _client(
          (_) => (
            status: op == _Operation.reply || op == _Operation.create
                ? 201
                : 200,
            body: _payload(op, note),
          ),
        );
        addTearDown(client.close);
        final result = await _read(client, op);
        if (shape == 'omitted' || shape == 'null') {
          expect(result.suggestions, isNull);
        } else if (shape == 'empty') {
          expect(result.suggestions, isEmpty);
        } else {
          final item = result.suggestions!.first;
          expect(item.id, 5);
          if (shape == 'sparse') {
            expect(item.fromLine, isNull);
            expect(item.toContent, isNull);
            expect(item.patchApplicable, isNull);
            expect(item.applied, isNull);
          } else {
            expect(item.fromLine, 27);
            expect(item.toLine, 28);
            expect(item.fromContent, '  original\n');
            expect(item.toContent, '  replacement\n');
            expect(item.patchApplicable, true);
            expect(item.applied, false);
          }
          expect(() => result.suggestions!.add(item), throwsUnsupportedError);
          if (shape == 'two') {
            expect(result.suggestions![1].id, 6);
            expect(result.suggestions![1].toContent, '');
          }
        }
      });
    }
    final bad = <String, Object?>{
      'scalar': 'private-content-marker',
      'map': _suggestion,
      'invalid entry': [null],
      'list entry': [[]],
      for (final id in [null, 0, -1, 5.5, '5'])
        'ID $id': [
          {..._suggestion, 'id': id},
        ],
      for (final key in ['from_line', 'to_line'])
        for (final line in [0, -1, 27.5, '27'])
          '$key $line': [
            {..._suggestion, key: line},
          ],
      'reversed range': [
        {..._suggestion, 'from_line': 29},
      ],
      for (final key in ['from_content', 'to_content'])
        '$key shape': [
          {..._suggestion, key: []},
        ],
      for (final key in ['appliable', 'applicable', 'applied'])
        for (final flag in [1, 'true', []])
          '$key flag $flag': [
            {..._suggestion, key: flag},
          ],
      'duplicate IDs': [_suggestion, _suggestion],
      'conflicting aliases': [
        {..._suggestion, 'applicable': false},
      ],
    };
    for (final entry in bad.entries) {
      test('$op rejects malformed suggestion ${entry.key}', () async {
        final client = _client(
          (_) => (
            status: op == _Operation.reply || op == _Operation.create
                ? 201
                : 200,
            body: _payload(op, _note(entry.value)),
          ),
        );
        addTearDown(client.close);
        await expectLater(
          _read(client, op),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message,
              'sanitized',
              isNot(contains('private-content-marker')),
            ),
          ),
        );
      });
    }
    if (op != _Operation.reply) {
      test('$op rejects duplicate suggestion identity across notes', () async {
        final first = _note([_suggestion]);
        final second = {...first, 'id': 302};
        final group = {
          ..._thread(first),
          'notes': [first, second],
        };
        final client = _client(
          (_) => (
            status: op == _Operation.create ? 201 : 200,
            body: op == _Operation.read ? [group] : group,
          ),
        );
        addTearDown(client.close);
        await expectLater(
          _read(client, op),
          throwsA(isA<GitLabServerException>()),
        );
      });
    }
    if (op == _Operation.read) {
      test(
        'read rejects duplicate suggestion identity across groups',
        () async {
          final first = _note([_suggestion]);
          final second = {...first, 'id': 302};
          final client = _client(
            (_) => (
              status: 200,
              body: [
                _thread(first),
                {..._thread(second), 'id': 'other-thread'},
              ],
            ),
          );
          addTearDown(client.close);
          await expectLater(
            _read(client, op),
            throwsA(isA<GitLabServerException>()),
          );
        },
      );
    }
    test('$op maps status before malformed suggestion decoding', () async {
      final client = _client(
        (_) => (
          status: 401,
          body: _payload(
            op,
            _note([
              {'id': 5.5},
            ]),
          ),
        ),
      );
      addTearDown(client.close);
      await expectLater(_read(client, op), throwsA(isA<GitLabAuthException>()));
    });
  }
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
