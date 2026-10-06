import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import '../../../packages/gitlab_api/test/mr_commits_api_test.dart' as b;
import '../../../packages/gitlab_api/test/mr_detail_identity_api_test.dart'
    as d;

void main() {
  for (final source in [8, 19, null]) {
    test(
      'fresh captured target and global MR identity preserve source $source',
      () async {
        var calls = 0;
        final c = b.client((o) {
          calls++;
          expect(o.path, '/projects/8/merge_requests/142');
          expect(o.method, 'GET');
          return b.response({...d.mr(), 'source_project_id': source});
        });
        addTearDown(c.close);
        final result = await MergeRequestsRepository(c).commitReviewContext(
          projectId: 8,
          iid: 142,
          mergeRequestId: 55123,
          isCurrent: () => true,
        );
        expect(result!.id, 55123);
        expect(result.iid, 142);
        expect(result.targetProjectId, 8);
        expect(result.sourceProjectId, source);
        expect(calls, 1);
      },
    );
  }
  for (final change in [
    {'id': 55124},
    {'target_project_id': null},
    {'target_project_id': 9},
    {'iid': 143},
  ]) {
    test('current identity mismatch or unknown target fails $change', () async {
      final c = b.client((o) => b.response({...d.mr(), ...change}));
      addTearDown(c.close);
      await expectLater(
        MergeRequestsRepository(c).commitReviewContext(
          projectId: 8,
          iid: 142,
          mergeRequestId: 55123,
          isCurrent: () => true,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  test(
    'missing target is never filled from the screen project or project_id',
    () async {
      final body = d.mr()..remove('target_project_id');
      final c = b.client((o) => b.response(body));
      addTearDown(c.close);
      await expectLater(
        MergeRequestsRepository(c).commitReviewContext(
          projectId: 8,
          iid: 142,
          mergeRequestId: 55123,
          isCurrent: () => true,
        ),
        throwsA(isA<GitLabServerException>()),
      );
    },
  );
  test(
    'unknown project_id does not prevent a confirmed target identity',
    () async {
      final body = d.mr()..remove('project_id');
      final c = b.client((o) => b.response(body));
      addTearDown(c.close);
      final result = await MergeRequestsRepository(c).commitReviewContext(
        projectId: 8,
        iid: 142,
        mergeRequestId: 55123,
        isCurrent: () => true,
      );
      expect(result!.projectId, isNull);
      expect(result.targetProjectId, 8);
    },
  );
  for (final (project, iid, id) in [
    (0, 142, 55123),
    (8, 0, 55123),
    (8, 142, 0),
    (-1, 142, 55123),
    (8, -1, 55123),
    (8, 142, -1),
  ]) {
    test(
      'invalid captured identity fails before dispatch $project $iid $id',
      () async {
        var calls = 0;
        final c = b.client((o) {
          calls++;
          return b.response(d.mr());
        });
        addTearDown(c.close);
        await expectLater(
          MergeRequestsRepository(c).commitReviewContext(
            projectId: project,
            iid: iid,
            mergeRequestId: id,
            isCurrent: () => true,
          ),
          throwsArgumentError,
        );
        expect(calls, 0);
      },
    );
  }
  test('already obsolete origin dispatches nothing', () async {
    var calls = 0;
    final c = b.client((o) {
      calls++;
      return b.response(d.mr());
    });
    addTearDown(c.close);
    expect(
      await MergeRequestsRepository(c).commitReviewContext(
        projectId: 8,
        iid: 142,
        mergeRequestId: 55123,
        isCurrent: () => false,
      ),
      isNull,
    );
    expect(calls, 0);
  });
  for (final status in [200, 403, 404, 429, 500]) {
    test(
      'origin replacement discards late response or typed failure $status',
      () async {
        final started = Completer<void>(), answer = Completer<void>();
        var current = true;
        final c = b.client((o) async {
          started.complete();
          await answer.future;
          return b.response(d.mr(), status: status);
        });
        addTearDown(c.close);
        final result = MergeRequestsRepository(c).commitReviewContext(
          projectId: 8,
          iid: 142,
          mergeRequestId: 55123,
          isCurrent: () => current,
        );
        await Future.any<Object?>([started.future, result]);
        expect(started.isCompleted, isTrue);
        current = false;
        answer.complete();
        expect(await result, isNull);
      },
    );
  }
  test('final exposure guard discards a previously current result', () async {
    var checks = 0;
    final c = b.client((o) => b.response(d.mr()));
    addTearDown(c.close);
    expect(
      await MergeRequestsRepository(c).commitReviewContext(
        projectId: 8,
        iid: 142,
        mergeRequestId: 55123,
        isCurrent: () => ++checks < 3,
      ),
      isNull,
    );
    expect(checks, 3);
  });
  test('current forbidden failure remains typed', () async {
    final c = b.client((o) => b.response('bad', status: 403, raw: true));
    addTearDown(c.close);
    await expectLater(
      MergeRequestsRepository(c).commitReviewContext(
        projectId: 8,
        iid: 142,
        mergeRequestId: 55123,
        isCurrent: () => true,
      ),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
}
