import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';

const body = '  **Changed private Markdown**\n\nKeep the whitespace.  ';
const textPosition = DiffNotePosition(
  baseSha: 'base',
  startSha: 'start',
  headSha: 'head',
  oldPath: 'old.dart',
  newPath: 'new.dart',
  positionType: 'text',
  newLine: 9,
);
MergeRequestDraftNote target({DiffNotePosition? position}) =>
    MergeRequestDraftNote(
      id: 5,
      authorId: 23,
      mergeRequestId: 1100,
      note: 'Original private note',
      resolveDiscussion: true,
      discussionId: 'original-thread',
      commitId: 'original-commit',
      lineCode: position?.baseSha == null ? null : 'original-code',
      position: position,
    );
Future<Object?> run(
  MrDraftNotesRepository repo,
  String op,
  MergeRequestDraftNote draft, {
  int global = 1100,
}) async {
  if (op == 'update') {
    return repo.update(
      projectId: 8,
      iid: 142,
      mergeRequestId: global,
      draft: draft,
      note: body,
    );
  }
  await repo.delete(
    projectId: 8,
    iid: 142,
    mergeRequestId: global,
    draft: draft,
  );
  return null;
}

void main() {
  for (final p in [
    null,
    const DiffNotePosition(),
    const DiffNotePosition(positionType: 'text'),
    textPosition,
  ]) {
    test(
      'update binds author/global identity and preserves metadata $p',
      () async {
        final selected = target(position: p);
        final requests = <RequestOptions>[];
        final client = makeClient((o) {
          requests.add(o);
          return (status: 200, body: selected.copyWith(note: body).toJson());
        });
        addTearDown(client.close);
        final returned = await run(
          MrDraftNotesRepository(client, authorId: 23),
          'update',
          selected,
        );
        expect(returned, selected.copyWith(note: body));
        expect(requests.single.method, 'PUT');
        expect(
          requests.single.path,
          '/projects/8/merge_requests/142/draft_notes/5',
        );
        final data = requests.single.data as Map;
        expect(data['note'], body);
        expect(data.containsKey('position'), p == textPosition);
        expect(data.containsKey('resolve_discussion'), false);
        expect(data.containsKey('commit_id'), false);
        expect(data.containsKey('discussion_id'), false);
      },
    );
  }
  for (final op in ['update', 'delete']) {
    for (final selected in [
      target().copyWith(id: 0),
      target().copyWith(authorId: 24),
      target().copyWith(mergeRequestId: 142),
      target().copyWith(mergeRequestId: 1101),
    ]) {
      test(
        '$op rejects invalid/unowned/wrong MR selected draft ${selected.id}/${selected.authorId}/${selected.mergeRequestId} before dispatch',
        () async {
          var calls = 0;
          final client = makeClient((o) {
            calls++;
            return (status: 200, body: target().toJson());
          });
          addTearDown(client.close);
          await expectLater(
            run(MrDraftNotesRepository(client, authorId: 23), op, selected),
            throwsArgumentError,
          );
          expect(calls, 0);
        },
      );
    }
    for (final global in [0, -1]) {
      test('$op invalid global identity $global prevents dispatch', () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: 200, body: target().toJson());
        });
        addTearDown(client.close);
        await expectLater(
          run(
            MrDraftNotesRepository(client, authorId: 23),
            op,
            target(),
            global: global,
          ),
          throwsArgumentError,
        );
        expect(calls, 0);
      });
    }
    for (final status in [401, 403, 404, 409, 422, 500]) {
      test(
        '$op keeps typed API status $status with no private or public fallback',
        () async {
          final requests = <RequestOptions>[];
          final client = makeClient((o) {
            requests.add(o);
            return (status: status, body: 'private-server-marker');
          });
          addTearDown(client.close);
          await expectLater(
            run(MrDraftNotesRepository(client, authorId: 23), op, target()),
            throwsA(
              isA<GitLabException>()
                  .having((e) => e.statusCode, 'status', status)
                  .having(
                    (e) => e.toString(),
                    'sanitized',
                    isNot(contains('private-server-marker')),
                  ),
            ),
          );
          expect(requests.length, 1);
          expect(requests.single.path, endsWith('/draft_notes/5'));
        },
      );
    }
  }
  final original = target(position: textPosition);
  for (final returned in [
    original.copyWith(authorId: 24),
    original.copyWith(mergeRequestId: 142),
    original.copyWith(discussionId: 'another-thread'),
    original.copyWith(commitId: 'another-commit'),
    original.copyWith(resolveDiscussion: false),
    original.copyWith(lineCode: 'different-code'),
    original.copyWith(discussionId: null),
    original.copyWith(commitId: null),
    original.copyWith(resolveDiscussion: null),
  ]) {
    test(
      'update cannot confirm changed identity or original metadata $returned',
      () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: 200, body: returned.copyWith(note: body).toJson());
        });
        addTearDown(client.close);
        await expectLater(
          run(MrDraftNotesRepository(client, authorId: 23), 'update', original),
          throwsA(isA<GitLabServerException>()),
        );
        expect(calls, 1);
      },
    );
  }
  for (final selected in [
    target().copyWith(lineCode: 'opaque-original-code'),
    target(
      position: const DiffNotePosition(
        positionType: 'image',
        width: 10,
        height: 20,
        x: 1,
        y: 2,
      ),
    ),
    target(
      position: const DiffNotePosition(
        positionType: 'file',
        newPath: 'file.dart',
      ),
    ),
    target(position: const DiffNotePosition(positionType: 'future')),
    target(position: textPosition.copyWith(headSha: null)),
  ]) {
    test(
      'update rejects unsupported/incomplete original metadata before dispatch $selected',
      () async {
        var calls = 0;
        final client = makeClient((o) {
          calls++;
          return (status: 200, body: selected.copyWith(note: body).toJson());
        });
        addTearDown(client.close);
        await expectLater(
          run(MrDraftNotesRepository(client, authorId: 23), 'update', selected),
          throwsArgumentError,
        );
        expect(calls, 0);
      },
    );
    test(
      'delete can target private positioned/opaque note without retargeting $selected',
      () async {
        final requests = <RequestOptions>[];
        final client = makeClient((o) {
          requests.add(o);
          return (status: 204, body: null);
        });
        addTearDown(client.close);
        await run(
          MrDraftNotesRepository(client, authorId: 23),
          'delete',
          selected,
        );
        expect(requests.single.method, 'DELETE');
        expect(requests.single.data, isNull);
        expect(
          requests.single.path,
          '/projects/8/merge_requests/142/draft_notes/5',
        );
      },
    );
  }
  test(
    'unknown optional metadata remains unknown after regular update',
    () async {
      final selected = target().copyWith(
        resolveDiscussion: null,
        discussionId: null,
        commitId: null,
      );
      final client = makeClient(
        (o) => (status: 200, body: selected.copyWith(note: body).toJson()),
      );
      addTearDown(client.close);
      final updated =
          await run(
                MrDraftNotesRepository(client, authorId: 23),
                'update',
                selected,
              )
              as MergeRequestDraftNote;
      expect(updated.resolveDiscussion, isNull);
      expect(updated.discussionId, isNull);
      expect(updated.commitId, isNull);
    },
  );
}

GitLabClient makeClient(
  ({int status, Object? body}) Function(RequestOptions) handler,
) {
  final dio = Dio(BaseOptions(validateStatus: (s) => s != null && s < 500))
    ..httpClientAdapter = Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final ({int status, Object? body}) Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    final r = handler(o);
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
