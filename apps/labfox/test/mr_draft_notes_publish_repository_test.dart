import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import '../../../packages/gitlab_api/test/mr_draft_note_maintenance_api_test.dart'
    show makeClient;

void main() {
  test(
    'captured client publishes the route IID with separate global MR identity',
    () async {
      final requests = <RequestOptions>[];
      final c = makeClient((o) {
        requests.add(o);
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      final repo = MrDraftNotesRepository(c, authorId: 23);
      await repo.publish(projectId: 8, iid: 142, mergeRequestId: 1100);
      expect(
        requests.single.path,
        '/projects/8/merge_requests/142/draft_notes/bulk_publish',
      );
      expect(requests.single.data, isNull);
      expect(requests.single.queryParameters, isEmpty);
    },
  );
  for (final global in [0, -1]) {
    test('invalid global identity $global prevents publication', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      final repo = MrDraftNotesRepository(c, authorId: 23);
      await expectLater(
        repo.publish(projectId: 8, iid: 142, mergeRequestId: global),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  test('repository propagates uncertainty once without fallback', () async {
    var calls = 0;
    final c = makeClient((o) {
      calls++;
      return (status: 500, body: 'private-marker');
    });
    addTearDown(c.close);
    final repo = MrDraftNotesRepository(c, authorId: 23);
    await expectLater(
      repo.publish(projectId: 8, iid: 142, mergeRequestId: 1100),
      throwsA(isA<GitLabServerException>()),
    );
    expect(calls, 1);
  });
}
