import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import '../../../packages/gitlab_api/test/mr_commit_draft_api_test.dart' as c;
import '../../../packages/gitlab_api/test/mr_draft_note_maintenance_api_test.dart'
    as b;

void main() {
  for (final ids in [(23, 1100), (24, 1100), (23, 142), (23, 1101)]) {
    test('commit creation binds captured author and global MR $ids', () async {
      var calls = 0;
      final client = b.makeClient((o) {
        calls++;
        expect(o.path, '/projects/8/merge_requests/142/draft_notes');
        expect(o.method, 'POST');
        expect(o.data, {
          'note': b.note,
          'commit_id': c.commit,
          'resolve_discussion': false,
          'position': b.withoutNulls(c.position.toJson()),
        });
        return (
          status: 201,
          body: {...c.draft(), 'author_id': ids.$1, 'merge_request_id': ids.$2},
        );
      });
      addTearDown(client.close);
      final result = MrDraftNotesRepository(client, authorId: 23).createCommit(
        projectId: 8,
        iid: 142,
        mergeRequestId: 1100,
        note: b.note,
        commitId: c.commit,
        position: c.position,
      );
      if (ids == (23, 1100)) {
        final draft = await result;
        expect(draft.commitId, c.commit);
        expect(draft.position, c.position);
      } else {
        await expectLater(result, throwsA(isA<GitLabServerException>()));
      }
      expect(calls, 1);
    });
  }
  for (final id in [0, -1]) {
    test(
      'invalid authoritative MR identity prevents commit draft $id',
      () async {
        var calls = 0;
        final client = b.makeClient((o) {
          calls++;
          return (status: 201, body: c.draft());
        });
        addTearDown(client.close);
        await expectLater(
          MrDraftNotesRepository(client, authorId: 23).createCommit(
            projectId: 8,
            iid: 142,
            mergeRequestId: id,
            note: b.note,
            commitId: c.commit,
            position: c.position,
          ),
          throwsArgumentError,
        );
        expect(calls, 0);
      },
    );
  }
}
