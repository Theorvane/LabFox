import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

Map<String, Object?> _note(Object? position) => {
  'id': 301,
  'body': 'Review',
  'type': 'DiffNote',
  'resolvable': true,
  'resolved': true,
  'position': position,
};
Map<String, Object?> _thread(Object? position) => {
  'id': 'thread',
  'individual_note': false,
  'notes': [_note(position)],
};
Future<Note> _read(GitLabClient client, String operation) async {
  if (operation == 'reply') {
    return client.mergeRequests.replyToDiscussion(
      'group/project',
      iid: 142,
      discussionId: 'thread',
      body: 'Reply',
    );
  }
  return (await client.mergeRequests.discussions(
    'group/project',
    iid: 142,
  )).items.single.notes.single;
}

void main() {
  final positions = <String, Map<String, Object?>>{
    'context': {
      'position_type': 'text',
      'base_sha': 'base',
      'head_sha': 'head',
      'start_sha': 'start',
      'old_path': 'old.dart',
      'new_path': 'new.dart',
      'old_line': 27,
      'new_line': 29,
    },
    'added': {'position_type': 'text', 'new_line': 10},
    'deleted': {'position_type': 'text', 'old_line': 10},
    'multiline': {
      'position_type': 'text',
      'line_range': {
        'start': {'line_code': 'hash_0_10', 'type': 'new', 'new_line': 10},
        'end': {
          'line_code': 'hash_11_11',
          'type': 'old',
          'old_line': 11,
          'new_line': 11,
        },
      },
    },
    'image': {
      'position_type': 'image',
      'width': 640,
      'height': 480,
      'x': 0,
      'y': 12.5,
    },
    'file': {'position_type': 'file', 'new_path': 'file.dart'},
    'future': {'position_type': 'future-type'},
    'sparse': {
      'line_range': {'start': <String, dynamic>{}},
    },
  };
  final malformed = <String, Object?>{
    'scalar': 'private-content-marker',
    'list': [],
    'fractional old line': {'old_line': 1.5},
    'fractional new line': {'new_line': 1.5},
    'zero line': {'new_line': 0},
    'negative line': {'old_line': -1},
    'string line': {'new_line': '12'},
    'bool line': {'new_line': true},
    'invalid SHA': {'head_sha': 12},
    'invalid type': {'position_type': true},
    'invalid path': {'old_path': []},
    'fractional image width': {'width': 10.5},
    'zero image height': {'height': 0},
    'string x': {'x': '12'},
    'negative y': {'y': -1},
    'scalar range': {'line_range': 'private-content-marker'},
    'scalar start': {
      'line_range': {'start': 12},
    },
    'list end': {
      'line_range': {'end': []},
    },
    'fractional start': {
      'line_range': {
        'start': {'new_line': 1.5},
      },
    },
    'zero end': {
      'line_range': {
        'end': {'old_line': 0},
      },
    },
    'invalid code': {
      'line_range': {
        'start': {'line_code': true},
      },
    },
    'invalid endpoint type': {
      'line_range': {
        'end': {'type': 12},
      },
    },
  };
  for (final operation in ['read', 'reply']) {
    for (final entry in positions.entries) {
      test('$operation preserves ${entry.key} positions', () async {
        var requests = 0;
        final client = _client((o) {
          requests++;
          return (
            status: operation == 'reply' ? 201 : 200,
            body: operation == 'reply'
                ? _note(entry.value)
                : [_thread(entry.value)],
          );
        });
        addTearDown(client.close);
        final note = await _read(client, operation);
        expect(note.position, DiffNotePosition.fromJson(entry.value));
        expect(requests, 1);
        if (entry.key == 'context') {
          expect(note.position!.headSha, 'head');
          expect(note.position!.oldPath, 'old.dart');
          expect(note.position!.newPath, 'new.dart');
          expect(note.position!.oldLine, 27);
          expect(note.position!.newLine, 29);
        }
      });
    }
    test('$operation retains a legacy note without position', () async {
      final client = _client(
        (_) => (
          status: operation == 'reply' ? 201 : 200,
          body: operation == 'reply' ? _note(null) : [_thread(null)],
        ),
      );
      addTearDown(client.close);
      expect((await _read(client, operation)).position, isNull);
    });
    for (final entry in malformed.entries) {
      test('$operation rejects malformed position: ${entry.key}', () async {
        final client = _client(
          (_) => (
            status: operation == 'reply' ? 201 : 200,
            body: operation == 'reply'
                ? _note(entry.value)
                : [_thread(entry.value)],
          ),
        );
        addTearDown(client.close);
        await expectLater(
          _read(client, operation),
          throwsA(
            isA<GitLabServerException>().having(
              (e) => e.message,
              'sanitized message',
              operation == 'reply'
                  ? 'Invalid discussion reply response.'
                  : 'Invalid discussions response.',
            ),
          ),
        );
      });
    }
    for (final status in [401, 403, 404, 429, 500]) {
      test(
        '$operation maps status $status before malformed position',
        () async {
          final client = _client(
            (_) => (
              status: status,
              body: operation == 'reply'
                  ? _note('private-content-marker')
                  : [_thread('private-content-marker')],
            ),
          );
          addTearDown(client.close);
          await expectLater(
            _read(client, operation),
            throwsA(switch (status) {
              401 => isA<GitLabAuthException>(),
              403 => isA<GitLabForbiddenException>(),
              404 => isA<GitLabNotFoundException>(),
              429 => isA<GitLabRateLimitException>(),
              _ => isA<GitLabServerException>().having(
                (e) => e.message,
                'HTTP context',
                isNot(contains('Invalid discussion')),
              ),
            }),
          );
        },
      );
    }
  }
}

GitLabClient _client(
  ({int status, Object? body}) Function(RequestOptions) handler, {
  Map<String, List<String>> headers = const {},
}) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500));
  dio.httpClientAdapter = _Adapter(handler, headers);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler, this.headers);
  final Map<String, List<String>> headers;
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
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
