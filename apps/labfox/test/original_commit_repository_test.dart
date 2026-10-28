import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/commits/data/history_repository.dart';
import '../../../packages/gitlab_api/test/mr_commits_api_test.dart' as b;

void main() {
  for (final parents in [
    null,
    <String>[],
    [b.parent],
    [b.second, b.parent],
  ]) {
    test('captured fixed detail preserves parent context $parents', () async {
      var calls = 0;
      final c = b.client((o) {
        calls++;
        expect(o.path, '/projects/8/repository/commits/${b.head}');
        expect(o.method, 'GET');
        return b.response({...b.commit(), 'parent_ids': parents});
      });
      addTearDown(c.close);
      final result = await HistoryRepository(
        c,
      ).originalCommit(projectId: 8, commitId: b.head, isCurrent: () => true);
      expect(result!.id, b.head);
      expect(result.parentIds, parents);
      expect(calls, 1);
    });
  }
  for (final (project, sha) in [
    (0, b.head),
    (-1, b.head),
    (8, 'main'),
    (8, ''),
    (8, b.head.toUpperCase()),
  ]) {
    test('invalid identity never dispatches $project $sha', () async {
      var calls = 0;
      final c = b.client((o) {
        calls++;
        return b.response(b.commit());
      });
      addTearDown(c.close);
      await expectLater(
        HistoryRepository(c).originalCommit(
          projectId: project,
          commitId: sha,
          isCurrent: () => true,
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  test('obsolete origin performs no read', () async {
    var calls = 0;
    final c = b.client((o) {
      calls++;
      return b.response(b.commit());
    });
    addTearDown(c.close);
    expect(
      await HistoryRepository(
        c,
      ).originalCommit(projectId: 8, commitId: b.head, isCurrent: () => false),
      isNull,
    );
    expect(calls, 0);
  });
  for (final status in [200, 403, 404, 429, 500]) {
    test('obsolete late success or failure is discarded $status', () async {
      final started = Completer<void>(), answer = Completer<void>();
      var current = true;
      final c = b.client((o) async {
        started.complete();
        await answer.future;
        return b.response(b.commit(), status: status);
      });
      addTearDown(c.close);
      final result = HistoryRepository(c).originalCommit(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => current,
      );
      await Future.any<Object?>([started.future, result]);
      expect(started.isCompleted, isTrue);
      current = false;
      answer.complete();
      expect(await result, isNull);
    });
  }
  test('final exposure rechecks currency', () async {
    var checks = 0;
    final c = b.client((o) => b.response(b.commit()));
    addTearDown(c.close);
    expect(
      await HistoryRepository(c).originalCommit(
        projectId: 8,
        commitId: b.head,
        isCurrent: () => ++checks < 2,
      ),
      isNull,
    );
    expect(checks, 2);
  });
  test('current head mismatch stays a typed failure', () async {
    final c = b.client((o) => b.response(b.commit(id: b.parent)));
    addTearDown(c.close);
    await expectLater(
      HistoryRepository(
        c,
      ).originalCommit(projectId: 8, commitId: b.head, isCurrent: () => true),
      throwsA(isA<GitLabServerException>()),
    );
  });
  test('current unavailable target commit stays not found', () async {
    final c = b.client((o) => b.response('invalid', status: 404, raw: true));
    addTearDown(c.close);
    await expectLater(
      HistoryRepository(
        c,
      ).originalCommit(projectId: 8, commitId: b.head, isCurrent: () => true),
      throwsA(isA<GitLabNotFoundException>()),
    );
  });
}
