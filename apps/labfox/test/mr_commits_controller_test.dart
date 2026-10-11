import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/features/merge_requests/data/merge_requests_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_commits_controller.dart';

import '../../../packages/gitlab_api/test/mr_commits_api_test.dart' as api;
import 'mr_original_review_snapshot_test.dart' as o;
import 'mr_pending_review_save_test.dart' as b;

class Repo extends b.Details {
  Repo(this.client) : super(client) {
    result = o.mr;
  }
  final GitLabClient client;
  Object members = const [Commit(id: o.head, title: 'Selected')];
  int lists = 0;
  @override
  Future<List<Commit>?> commits({
    required int projectId,
    required int iid,
    required bool Function() isCurrent,
  }) async {
    expect((projectId, iid), (8, 142));
    lists++;
    final v = members;
    if (v is Future<List<Commit>?>) return v;
    if (v is List<Commit>) return v;
    throw v;
  }
}

ProviderContainer container(Repo repo, {bool listen = true}) {
  final c = ProviderContainer(
    overrides: [
      currentAccountProvider.overrideWith((r) => r.watch(b.accountState)),
      b.sourceState.overrideWith((r) async => repo),
      mergeRequestsRepositoryProvider.overrideWith(
        (r) => r.watch(b.sourceState),
      ),
    ],
  );
  addTearDown(c.dispose);
  addTearDown(repo.client.close);
  if (listen) {
    final sub = c.listen(mrCommitsControllerProvider(b.resource), (_, _) {});
    addTearDown(sub.close);
  }
  return c;
}

void main() {
  test(
    'captured commit browser traverses advertised pages including empty pages',
    () async {
      final paths = <String>[];
      final client = api.client((request) {
        expect(request.method, 'GET');
        paths.add(request.path);
        if (!request.path.endsWith('/commits')) {
          return api.response(o.mr.toJson());
        }
        final page = request.queryParameters['page'];
        expect(request.queryParameters['per_page'], 100);
        return api.response(
          page == 1
              ? [api.commit()]
              : page == 3
              ? []
              : [api.commit(id: o.other)],
          headers: page == 4
              ? {}
              : {
                  'x-next-page': ['${page == 1 ? 3 : 4}'],
                },
        );
      });
      addTearDown(client.close);
      final c = ProviderContainer(
        overrides: [
          currentAccountProvider.overrideWithValue(b.account),
          mergeRequestsRepositoryProvider.overrideWith(
            (r) async => MergeRequestsRepository(client),
          ),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(mrCommitsControllerProvider(b.resource), (_, _) {});
      addTearDown(sub.close);
      final commits = await c.read(
        mrCommitsControllerProvider(b.resource).future,
      );
      expect(commits!.map((c) => c.id), [o.head, o.other]);
      expect(paths.length, 4);
    },
  );
  test('repository replacement discards pending old membership', () async {
    final repo = Repo(b.client());
    final lateMembers = Completer<List<Commit>?>();
    repo.members = lateMembers.future;
    final c = container(repo);
    final read = c.read(mrCommitsControllerProvider(b.resource).future);
    await pumpEventQueue();
    final fresh = Repo(b.client())
      ..members = const [Commit(id: o.other, title: 'Fresh')];
    addTearDown(fresh.client.close);
    c.read(b.sourceState.notifier).state = Future.value(fresh);
    await pumpEventQueue();
    lateMembers.complete([const Commit(id: o.head, title: 'Stale')]);
    await read;
    await pumpEventQueue();
    expect(
      c.read(mrCommitsControllerProvider(b.resource)).value!.single.id,
      o.other,
    );
  });

  test(
    'origin separates route IID from global ID and returns immutable complete members',
    () async {
      final repo = Repo(b.client());
      final c = container(repo);
      final members = await c.read(
        mrCommitsControllerProvider(b.resource).future,
      );
      expect(members!.single.id, o.head);
      expect(repo.reads, [(8, 142)]);
      expect(repo.lists, 1);
      expect(() => members.clear(), throwsUnsupportedError);
      expect(
        (await c.read(mrCommitOriginControllerProvider(b.resource).future))!.id,
        1100,
      );
    },
  );
  for (final detail in [
    o.mr.copyWith(id: 0),
    o.mr.copyWith(iid: 143),
    o.mr.copyWith(targetProjectId: null),
    o.mr.copyWith(targetProjectId: 9),
    o.mr.copyWith(projectId: 9),
  ]) {
    test('invalid origin prevents commit list: $detail', () async {
      final repo = Repo(b.client())..result = detail;
      final c = container(repo);
      await expectLater(
        c.read(mrCommitsControllerProvider(b.resource).future),
        throwsA(isA<GitLabServerException>()),
      );
      expect(repo.lists, 0);
    });
  }
  test('empty complete list stays distinct from an obsolete origin', () async {
    final repo = Repo(b.client())..members = <Commit>[];
    final c = container(repo);
    expect(
      await c.read(mrCommitsControllerProvider(b.resource).future),
      isEmpty,
    );
  });
  test('current list failure remains typed', () async {
    final repo = Repo(b.client())
      ..members = const GitLabForbiddenException('Forbidden');
    final c = container(repo);
    await expectLater(
      c.read(mrCommitsControllerProvider(b.resource).future),
      throwsA(isA<GitLabForbiddenException>()),
    );
  });
  for (final phase in ['origin', 'members']) {
    test('account replacement discards obsolete $phase outcomes', () async {
      final repo = Repo(b.client());
      final c = container(repo);
      final detail = Completer<MergeRequest>();
      final members = Completer<List<Commit>?>();
      if (phase == 'origin') {
        repo.result = detail.future;
      } else {
        repo.members = members.future;
      }
      final read = c.read(mrCommitsControllerProvider(b.resource).future);
      await pumpEventQueue();
      c.read(b.accountState.notifier).state = null;
      if (phase == 'origin') {
        detail.complete(o.mr);
      } else {
        members.complete([const Commit(id: o.head, title: 'Late')]);
      }
      expect(await read, null);
      if (phase == 'origin') expect(repo.lists, 0);
    });
  }
  test('invalid route starts no read', () async {
    final repo = Repo(b.client());
    final c = container(repo, listen: false);
    const invalid = MergeRequestRef(projectId: 0, iid: 142);
    final s = c.listen(mrCommitOriginControllerProvider(invalid), (_, _) {});
    addTearDown(s.close);
    await expectLater(
      c.read(mrCommitOriginControllerProvider(invalid).future),
      throwsArgumentError,
    );
    expect(repo.reads, isEmpty);
  });
}
