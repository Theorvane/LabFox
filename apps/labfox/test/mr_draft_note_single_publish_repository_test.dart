import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import '../../../packages/gitlab_api/test/mr_draft_note_maintenance_api_test.dart'
    show makeClient;

const draft = MergeRequestDraftNote(
  id: 7,
  authorId: 23,
  mergeRequestId: 1100,
  note: 'Private',
);
void main() {
  for (final position in [
    null,
    const DiffNotePosition(positionType: 'image'),
    const DiffNotePosition(positionType: 'file'),
    const DiffNotePosition(positionType: 'future'),
  ]) {
    test(
      'captured identity publishes selected saved note with opaque metadata $position',
      () async {
        final requests = <RequestOptions>[];
        final c = makeClient((o) {
          requests.add(o);
          return (status: 204, body: null);
        });
        addTearDown(c.close);
        await MrDraftNotesRepository(c, authorId: 23).publishNote(
          projectId: 8,
          iid: 142,
          mergeRequestId: 1100,
          draft: draft.copyWith(position: position),
        );
        expect(
          requests.single.path,
          '/projects/8/merge_requests/142/draft_notes/7/publish',
        );
        expect(requests.single.method, 'PUT');
        expect(requests.single.data, isNull);
        expect(requests.single.queryParameters, isEmpty);
      },
    );
  }
  for (final target in [
    draft.copyWith(id: 0),
    draft.copyWith(authorId: 24),
    draft.copyWith(mergeRequestId: 142),
  ]) {
    test('invalid captured target $target prevents dispatch', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      await expectLater(
        MrDraftNotesRepository(c, authorId: 23).publishNote(
          projectId: 8,
          iid: 142,
          mergeRequestId: 1100,
          draft: target,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final global in [0, -1]) {
    test('invalid global $global prevents publication', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      await expectLater(
        MrDraftNotesRepository(c, authorId: 23).publishNote(
          projectId: 8,
          iid: 142,
          mergeRequestId: global,
          draft: draft,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  test('uncertain publication does not fall back to bulk', () async {
    final requests = <RequestOptions>[];
    final c = makeClient((o) {
      requests.add(o);
      return (status: 500, body: 'private-marker');
    });
    addTearDown(c.close);
    await expectLater(
      MrDraftNotesRepository(
        c,
        authorId: 23,
      ).publishNote(projectId: 8, iid: 142, mergeRequestId: 1100, draft: draft),
      throwsA(isA<GitLabServerException>()),
    );
    expect(requests.length, 1);
    expect(requests.single.path, endsWith('/7/publish'));
  });
}
