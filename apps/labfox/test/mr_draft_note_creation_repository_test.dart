import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';

const _note = '  **Private**\n\nKeep the exact draft.  ';
const _position = DiffNotePosition(
  baseSha: 'base',
  startSha: 'start',
  headSha: 'head',
  oldPath: 'old.dart',
  newPath: 'new.dart',
  positionType: 'text',
  newLine: 9,
);
Map<String, Object?> _draft({
  DiffNotePosition? position,
  int authorId = 23,
  int mergeRequestId = 1100,
}) => {
  'id': 5,
  'author_id': authorId,
  'merge_request_id': mergeRequestId,
  'note': _note,
  'resolve_discussion': false,
  'discussion_id': null,
  'commit_id': null,
  'position': position?.toJson(),
};
void main() {
  for (final position in [null, _position]) {
    test(
      'repository creates one captured-author/global-MR draft $position',
      () async {
        final writes = <RequestOptions>[];
        final client = _client((o) {
          writes.add(o);
          return _draft(position: position);
        });
        addTearDown(client.close);
        final result = await MrDraftNotesRepository(client, authorId: 23)
            .create(
              projectId: 8,
              iid: 142,
              mergeRequestId: 1100,
              note: _note,
              position: position,
            );
        expect(
          writes.single.path,
          '/projects/8/merge_requests/142/draft_notes',
        );
        expect(writes.single.method, 'POST');
        expect((writes.single.data as Map)['note'], _note);
        expect(result.authorId, 23);
        expect(result.mergeRequestId, 1100);
        expect(result.note, _note);
      },
    );
  }
  for (final ids in [(24, 1100), (23, 142), (23, 1101)]) {
    test('unconfirmed author/global-MR identity $ids fails once', () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        return _draft(authorId: ids.$1, mergeRequestId: ids.$2);
      });
      addTearDown(client.close);
      await expectLater(
        MrDraftNotesRepository(
          client,
          authorId: 23,
        ).create(projectId: 8, iid: 142, mergeRequestId: 1100, note: _note),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid draft note creation identity.',
          ),
        ),
      );
      expect(writes, 1);
    });
  }
  for (final mergeRequestId in [0, -1]) {
    test(
      'invalid global MR ID $mergeRequestId fails before dispatch',
      () async {
        var writes = 0;
        final client = _client((o) {
          writes++;
          return _draft();
        });
        addTearDown(client.close);
        await expectLater(
          MrDraftNotesRepository(client, authorId: 23).create(
            projectId: 8,
            iid: 142,
            mergeRequestId: mergeRequestId,
            note: _note,
          ),
          throwsArgumentError,
        );
        expect(writes, 0);
      },
    );
  }
  test(
    'API rejection remains typed and does not fall back to a published comment',
    () async {
      var writes = 0;
      final client = _client((o) {
        writes++;
        throw DioException(
          requestOptions: o,
          response: Response<Object?>(requestOptions: o, statusCode: 403),
        );
      });
      addTearDown(client.close);
      await expectLater(
        MrDraftNotesRepository(
          client,
          authorId: 23,
        ).create(projectId: 8, iid: 142, mergeRequestId: 1100, note: _note),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(writes, 1);
    },
  );
  test(
    'confirmed creation can be inspected through the existing private reader',
    () async {
      final methods = <String>[];
      final client = _client((o) {
        methods.add(o.method);
        return o.method == 'GET' ? [_draft()] : _draft();
      });
      addTearDown(client.close);
      final repo = MrDraftNotesRepository(client, authorId: 23);
      final created = await repo.create(
        projectId: 8,
        iid: 142,
        mergeRequestId: 1100,
        note: _note,
      );
      final page = await repo.list(projectId: 8, iid: 142);
      expect(page.items.single, created);
      expect(methods, ['POST', 'GET']);
    },
  );
}

GitLabClient _client(Object? Function(RequestOptions) handler) {
  final dio = Dio()..httpClientAdapter = _Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final Object? Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    json.encode(handler(options)),
    options.method == 'GET' ? 200 : 201,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
  @override
  void close({bool force = false}) {}
}
