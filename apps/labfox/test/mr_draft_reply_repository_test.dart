import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import '../../../packages/gitlab_api/test/mr_draft_note_maintenance_api_test.dart'
    as b;

void main() {
  for (final ids in [(23, 1100), (24, 1100), (23, 142), (23, 1101)]) {
    test('reply binds captured author and global MR $ids', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        expect(o.path, '/projects/8/merge_requests/142/draft_notes');
        expect(o.method, 'POST');
        expect(o.data, {
          'note': b.note,
          'in_reply_to_discussion_id': 'thread',
          'resolve_discussion': false,
        });
        return (
          status: 201,
          body: {
            'id': 7,
            'author_id': ids.$1,
            'merge_request_id': ids.$2,
            'note': b.note,
            'discussion_id': 'thread',
            'resolve_discussion': false,
          },
        );
      });
      addTearDown(c.close);
      final result = MrDraftNotesRepository(c, authorId: 23).createReply(
        projectId: 8,
        iid: 142,
        mergeRequestId: 1100,
        discussionId: 'thread',
        note: b.note,
      );
      if (ids == (23, 1100)) {
        expect((await result).discussionId, 'thread');
      } else {
        await expectLater(result, throwsA(isA<GitLabServerException>()));
      }
      expect(calls, 1);
    });
  }
  for (final id in [0, -1]) {
    test('invalid global identity prevents private reply $id', () async {
      var calls = 0;
      final c = b.makeClient((o) {
        calls++;
        return (status: 201, body: null);
      });
      addTearDown(c.close);
      await expectLater(
        MrDraftNotesRepository(c, authorId: 23).createReply(
          projectId: 8,
          iid: 142,
          mergeRequestId: id,
          discussionId: 'thread',
          note: b.note,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
}
