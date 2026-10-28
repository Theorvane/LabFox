import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_original_review_controller.dart';

import '../../../packages/gitlab_api/test/mr_commits_api_test.dart' as api;

const head = '0123456789abcdef0123456789abcdef01234567';
const parent = '1123456789abcdef0123456789abcdef01234567';
const other = '2123456789abcdef0123456789abcdef01234567';
const arg = (projectId: 8, iid: 142, mergeRequestId: 1100, commitId: head);
const account = Account(
  instanceUrl: 'https://gitlab.example.com',
  user: User(id: 23, username: 'reviewer', name: 'Reviewer'),
);
const raw = '@@ -1,2 +1,2 @@\n same\n-old  \n+new\n';
const literal = CommitDiffFile(
  oldPath: 'a.dart',
  newPath: 'a.dart',
  isNew: false,
  isDeleted: false,
  isRenamed: false,
  diff: raw,
);
const mr = MergeRequest(
  id: 1100,
  iid: 142,
  title: 'Review',
  state: 'opened',
  sourceBranch: 'feature',
  targetBranch: 'dev',
  sourceProjectId: 19,
  targetProjectId: 8,
);
MrOriginalCommitContext context({
  List<String>? parents = const [parent],
  List<CommitDiffFile> files = const [literal],
  MergeRequest detail = mr,
  String sha = head,
}) => (
  mergeRequest: detail,
  commit: Commit(id: sha, title: 'Commit', parentIds: parents),
  files: files,
);
MrOriginalReviewSnapshot snapshot({MrOriginalCommitContext? value}) =>
    MrOriginalReviewSnapshot.fromContext(value ?? context());

final source = StateProvider<Future<MergeRequestsRepository?>>(
  (ref) async => null,
);
final accountState = StateProvider<Account?>((ref) => account);

class Repo extends MergeRequestsRepository {
  Repo(this.result)
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final Object result;
  final calls = <MrOriginalReviewRef>[];
  bool Function()? guard;
  @override
  Future<MrOriginalCommitContext?> originalCommitContext({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String commitId,
    required bool Function() isCurrent,
  }) async {
    calls.add((
      projectId: projectId,
      iid: iid,
      mergeRequestId: mergeRequestId,
      commitId: commitId,
    ));
    guard = isCurrent;
    if (result is Future<MrOriginalCommitContext?>) {
      return result as Future<MrOriginalCommitContext?>;
    }
    if (result is MrOriginalCommitContext) {
      return result as MrOriginalCommitContext;
    }
    throw result;
  }
}

ProviderContainer container(Repo repo) {
  final c = ProviderContainer(
    overrides: [
      source.overrideWith((ref) async => repo),
      mergeRequestsRepositoryProvider.overrideWith((ref) => ref.watch(source)),
      currentAccountProvider.overrideWith((ref) => ref.watch(accountState)),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test(
    'real captured client traverses MR origin, membership and target reads without fallback',
    () async {
      final paths = <String>[];
      final client = api.client((o) {
        expect(o.method, 'GET');
        paths.add(o.path);
        if (o.path == '/projects/8/merge_requests/142') {
          return api.response(mr.toJson());
        }
        if (o.path.endsWith('/merge_requests/142/commits')) {
          return api.response([
            {
              ...api.commit(),
              'parent_ids': [parent],
            },
          ]);
        }
        if (o.path.endsWith('/diff')) return api.response([literal.toJson()]);
        return api.response({
          ...api.commit(),
          'parent_ids': [parent],
        });
      });
      addTearDown(client.close);
      final c = ProviderContainer(
        overrides: [
          currentAccountProvider.overrideWithValue(account),
          mergeRequestsRepositoryProvider.overrideWith(
            (ref) async => MergeRequestsRepository(client),
          ),
        ],
      );
      addTearDown(c.dispose);
      final subscription = c.listen(
        mrOriginalReviewControllerProvider(arg),
        (_, _) {},
      );
      addTearDown(subscription.close);
      final s = await c.read(mrOriginalReviewControllerProvider(arg).future);
      expect(s.canSelect, isTrue);
      expect(paths.length, 6);
      expect(paths.every((p) => p.startsWith('/projects/8/')), isTrue);
      expect(
        s
            .positionFor(
              s.files.single,
              s.files.single.hunks.single.lines.last,
            )!
            .headSha,
        head,
      );
    },
  );
  for (final invalid in [
    (projectId: 0, iid: 142, mergeRequestId: 1100, commitId: head),
    (projectId: 8, iid: 0, mergeRequestId: 1100, commitId: head),
    (projectId: 8, iid: 142, mergeRequestId: 0, commitId: head),
    (projectId: 8, iid: 142, mergeRequestId: 1100, commitId: 'main'),
  ]) {
    test('invalid captured origin prevents dispatch $invalid', () async {
      final repo = Repo(context()), c = container(repo);
      await expectLater(
        c.read(mrOriginalReviewControllerProvider(invalid).future),
        throwsArgumentError,
      );
      expect(repo.calls, isEmpty);
    });
  }
  test('repository identity mismatch cannot expose a snapshot', () async {
    final c = container(Repo(context(detail: mr.copyWith(targetProjectId: 9))));
    await expectLater(
      c.read(mrOriginalReviewControllerProvider(arg).future),
      throwsA(isA<GitLabServerException>()),
    );
  });

  for (final error in [false, true]) {
    test(
      'sign-out during read expires captured guard and suppresses stale outcome $error',
      () async {
        final answer = Completer<MrOriginalCommitContext?>(),
            repo = Repo(answer.future);
        final c = container(repo), p = mrOriginalReviewControllerProvider(arg);
        final sub = c.listen(p, (_, _) {});
        addTearDown(sub.close);
        final pending = c.read(p.future);
        final checked = expectLater(
          pending,
          throwsA(isA<GitLabAuthException>()),
        );
        await Future<void>.delayed(Duration.zero);
        expect(repo.calls, [arg]);
        c.read(accountState.notifier).state = null;
        await Future<void>.delayed(Duration.zero);
        expect(repo.guard!(), isFalse);
        if (error) {
          answer.completeError(const GitLabNotFoundException('Obsolete'));
        } else {
          answer.complete(context());
        }
        await checked;
        expect(c.read(p).error, isA<GitLabAuthException>());
      },
    );
  }
  test('disposal expires the captured read guard', () async {
    final answer = Completer<MrOriginalCommitContext?>(),
        repo = Repo(answer.future);
    final c = container(repo), p = mrOriginalReviewControllerProvider(arg);
    final sub = c.listen(p, (_, _) {});
    final pending = c.read(p.future);
    await Future<void>.delayed(Duration.zero);
    expect(repo.calls, [arg]);
    sub.close();
    await c.pump();
    expect(repo.guard!(), isFalse);
    answer.complete(context());
    expect((await pending).available, isFalse);
  });
  test(
    'repository replacement before initial resolution never dispatches obsolete client',
    () async {
      final sourceAnswer = Completer<MergeRequestsRepository?>(),
          old = Repo(context()),
          fresh = Repo(context());
      final c = container(old);
      c.read(source.notifier).state = sourceAnswer.future;
      final p = mrOriginalReviewControllerProvider(arg),
          sub = c.listen(mrOriginalReviewControllerProvider(arg), (_, _) {});
      addTearDown(sub.close);
      final pending = c.read(p.future);
      await Future<void>.delayed(Duration.zero);
      c.read(source.notifier).state = Future.value(fresh);
      await Future<void>.delayed(Duration.zero);
      sourceAnswer.complete(old);
      expect((await pending).canSelect, isTrue);
      expect(old.calls, isEmpty);
      expect(fresh.calls, [arg]);
    },
  );

  test(
    'single parent supplies original refs and identity-bound literal rows',
    () {
      final s = snapshot(), f = snapshot();
      expect(s.available, isTrue);
      expect(s.canSelect, isTrue);
      final file = s.files.single, rows = file.hunks.single.lines;
      final p = s.positionFor(file, rows.last)!;
      expect((p.baseSha, p.startSha, p.headSha), (parent, parent, head));
      expect((p.oldLine, p.newLine), (null, 2));
      expect(
        s.positionFor(
          file,
          const DiffLine(type: DiffLineType.added, text: 'new', newLine: 2),
        ),
        isNull,
      );
      expect(
        s.positionFor(f.files.single, f.files.single.hunks.single.lines.last),
        isNull,
      );
      expect(() => s.files.clear(), throwsUnsupportedError);
      expect(s.linesForPosition(p).single.text, 'new');
      expect(() => s.linesForPosition(p).clear(), throwsUnsupportedError);
    },
  );
  for (final parents in [
    null,
    <String>[],
    [parent, other],
    ['main'],
    [head],
  ]) {
    test('unsupported original refs stay unselectable $parents', () {
      final s = snapshot(value: context(parents: parents));
      expect(s.available, isTrue);
      expect(s.canSelect, isFalse);
      expect(
        s.positionFor(s.files.single, s.files.single.hunks.single.lines.last),
        isNull,
      );
    });
  }
  for (final files in [
    [literal.copyWith(isCollapsed: true)],
    [literal.copyWith(diff: '@@ -1 +1 @@\n-a\n?ignored\n+b')],
    [literal, literal],
    [literal, literal.copyWith(oldPath: 'old.dart', isRenamed: true)],
  ]) {
    test(
      'omitted malformed or ambiguous paths yield no eligible selection $files',
      () {
        expect(snapshot(value: context(files: files)).canSelect, isFalse);
      },
    );
  }
  test(
    'multiline selection is exact, immutable and rejects reversed or forged rows',
    () {
      final s = snapshot(), f = s.files.single;
      final rows = f.hunks.single.lines;
      final p = s.rangePositionFor(f, rows.first, rows.last)!;
      expect(p.lineRange, isNotNull);
      expect(s.linesForPosition(p).map((l) => l.text), [
        'same',
        'old  ',
        'new',
      ]);
      expect(s.rangePositionFor(f, rows.last, rows.first), isNull);
      expect(s.rangePositionFor(f, rows.first, rows.first), isNull);
      expect(s.linesForPosition(p.copyWith(headSha: other)), isEmpty);
      expect(s.linesForPosition(p.copyWith(newPath: 'other')), isEmpty);
    },
  );
  for (final change in [
    context(detail: mr.copyWith(id: 1101)),
    context(detail: mr.copyWith(sourceProjectId: 20)),
    context(detail: mr.copyWith(sourceBranch: 'replacement')),
    context(detail: mr.copyWith(targetBranch: 'replacement')),
    context(detail: mr.copyWith(targetProjectId: 9)),
    context(parents: [other]),
    context(sha: other),
    context(
      files: [literal.copyWith(diff: raw.replaceFirst('new', 'changed'))],
    ),
    context(
      files: [literal.copyWith(diff: raw.replaceFirst('same', 'different'))],
    ),
    context(files: [literal.copyWith(oldMode: '100755')]),
  ]) {
    test('selection fingerprint rejects changed original context $change', () {
      final s = snapshot(), f = s.files.single;
      final p = s.positionFor(f, f.hunks.single.lines.last)!;
      final selection = MrOriginalReviewSelection.capture(s, p)!;
      expect(selection.matches(snapshot()), isTrue);
      expect(selection.matches(snapshot(value: change)), isFalse);
    });
  }
  test('unrelated fresh MR title does not invalidate literal selection', () {
    final s = snapshot(), f = s.files.single;
    final p = s.positionFor(f, f.hunks.single.lines.last)!;
    expect(
      MrOriginalReviewSelection.capture(s, p)!.matches(
        snapshot(
          value: context(detail: mr.copyWith(title: 'Fresh')),
        ),
      ),
      isTrue,
    );
    expect(
      MrOriginalReviewSelection.capture(s, p.copyWith(baseSha: other)),
      isNull,
    );
  });
  test(
    'controller routes exact captured origin and reload changes session',
    () async {
      final repo = Repo(context()), c = container(repo);
      final p = mrOriginalReviewControllerProvider(arg);
      final sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      final s = await c.read(p.future);
      expect(s.canSelect, isTrue);
      expect(repo.calls, [arg]);
      final old = c.read(p.notifier).session;
      c.invalidate(p);
      await c.read(p.future);
      expect(identical(old, c.read(p.notifier).session), isFalse);
    },
  );
  for (final error in [false, true]) {
    test('provider replacement discards obsolete outcome $error', () async {
      final answer = Completer<MrOriginalCommitContext?>();
      final old = Repo(answer.future), fresh = Repo(context());
      final c = container(old);
      final p = mrOriginalReviewControllerProvider(arg);
      final sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      final pending = c.read(p.future);
      await Future<void>.delayed(Duration.zero);
      expect(old.calls, [arg]);
      c.read(source.notifier).state = Future.value(fresh);
      await Future<void>.delayed(Duration.zero);
      expect(old.guard!(), isFalse);
      if (error) {
        answer.completeError(const GitLabNotFoundException('Missing'));
      } else {
        answer.complete(context());
      }
      expect((await pending).canSelect, isTrue);
      expect((await c.read(p.future)).canSelect, isTrue);
      expect(fresh.calls, [arg]);
    });
  }
  test('current typed failure remains an error', () async {
    final c = container(Repo(const GitLabNotFoundException('Missing')));
    await expectLater(
      c.read(mrOriginalReviewControllerProvider(arg).future),
      throwsA(isA<GitLabNotFoundException>()),
    );
  });
  test('sign-out blocks dispatch and invalidates captured guard', () async {
    final repo = Repo(Future<MrOriginalCommitContext?>.value(context()));
    final c = container(repo);
    c.read(accountState.notifier).state = null;
    await expectLater(
      c.read(mrOriginalReviewControllerProvider(arg).future),
      throwsA(isA<GitLabAuthException>()),
    );
    expect(repo.calls, isEmpty);
  });
}
