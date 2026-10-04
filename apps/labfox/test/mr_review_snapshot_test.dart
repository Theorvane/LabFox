import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/diff/data/diff_repository.dart';
import 'package:labfox/features/diff/presentation/controllers/diff_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_review_snapshot_controller.dart';

const _arg = MergeRequestRef(projectId: 8, iid: 142);
const _raw =
    '@@ -27,2 +29,2 @@\n final count = items.length;\n-return count;\n+return pending.length;\n';
MergeRequestDiffVersion _version({
  List<MergeRequestVersionFile>? files,
  String? head = 'head',
  String? state = 'collected',
}) => MergeRequestDiffVersion(
  id: 110,
  baseCommitSha: 'base',
  startCommitSha: 'start',
  headCommitSha: head,
  state: state,
  files:
      files ??
      [
        const MergeRequestVersionFile(
          oldPath: 'old.dart',
          newPath: 'new.dart',
          diff: _raw,
          isRenamed: true,
        ),
      ],
);

class _Repo extends DiffRepository {
  _Repo()
    : this._(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  _Repo._(this.client) : super(client);
  final GitLabClient client;
  Object list = Paginated<MergeRequestDiffVersion>(items: [_version()]);
  Object detail = _version();
  final reads = <(int, int, int)>[];
  final snapshots = <(int, int, int)>[];
  @override
  Future<Paginated<MergeRequestDiffVersion>> mergeRequestDiffVersions({
    required int projectId,
    required int iid,
    int page = 1,
  }) async {
    reads.add((projectId, iid, page));
    if (list is Paginated<MergeRequestDiffVersion>) {
      return list as Paginated<MergeRequestDiffVersion>;
    }
    if (list is Future<Paginated<MergeRequestDiffVersion>>) {
      return list as Future<Paginated<MergeRequestDiffVersion>>;
    }
    throw list;
  }

  @override
  Future<MergeRequestDiffVersion> mergeRequestDiffVersion({
    required int projectId,
    required int iid,
    required int versionId,
  }) async {
    snapshots.add((projectId, iid, versionId));
    if (detail is MergeRequestDiffVersion) {
      return detail as MergeRequestDiffVersion;
    }
    if (detail is Future<MergeRequestDiffVersion>) {
      return detail as Future<MergeRequestDiffVersion>;
    }
    throw detail;
  }

  @override
  Future<List<FileDiff>> mergeRequestDiff({
    required int projectId,
    required int iid,
  }) async => throw StateError('No current diff fallback');
}

final _session = StateProvider<Future<DiffRepository?>>((ref) async => null);
ProviderContainer _container(_Repo repo) {
  final c = ProviderContainer(
    overrides: [
      _session.overrideWith((ref) async => repo),
      diffRepositoryProvider.overrideWith((ref) => ref.watch(_session)),
    ],
  );
  addTearDown(c.dispose);
  addTearDown(repo.client.close);
  return c;
}

void main() {
  test('uses only the latest version with exact IDs and SHA triplet', () async {
    final repo = _Repo()
      ..list = Paginated<MergeRequestDiffVersion>(
        items: [
          _version(),
          _version().copyWith(id: 99, headCommitSha: 'older'),
        ],
        nextPage: 2,
      );
    final c = _container(repo);
    final result = await c.read(
      mrReviewSnapshotControllerProvider(_arg).future,
    );
    expect(repo.reads, [(8, 142, 1)]);
    expect(repo.snapshots, [(8, 142, 110)]);
    expect(result.version!.id, 110);
    expect(result.files.single.displayPath, 'old.dart → new.dart');
  });
  for (final side in DiffLineType.values) {
    test('derives exact $side original position', () async {
      final c = _container(_Repo());
      final result = await c.read(
        mrReviewSnapshotControllerProvider(_arg).future,
      );
      final file = result.files.single;
      final line = file.hunks.single.lines.singleWhere((l) => l.type == side);
      final p = result.positionFor(file, line)!;
      expect(p.baseSha, 'base');
      expect(p.startSha, 'start');
      expect(p.headSha, 'head');
      expect(p.oldPath, 'old.dart');
      expect(p.newPath, 'new.dart');
      expect(p.oldLine, line.oldLine);
      expect(p.newLine, line.newLine);
      expect(p.positionType, 'text');
    });
  }
  for (final metadata in [
    _version().copyWith(baseCommitSha: null),
    _version().copyWith(startCommitSha: ''),
    _version(head: null),
  ]) {
    test(
      'incomplete version never fetches or guesses an anchor $metadata',
      () async {
        final repo = _Repo()..list = Paginated(items: [metadata]);
        final c = _container(repo);
        final result = await c.read(
          mrReviewSnapshotControllerProvider(_arg).future,
        );
        expect(result.unavailable, true);
        expect(repo.snapshots, isEmpty);
      },
    );
  }
  test('empty versions do not fall back to current diffs', () async {
    final repo = _Repo()
      ..list = const Paginated<MergeRequestDiffVersion>(items: []);
    final c = _container(repo);
    expect(
      (await c.read(
        mrReviewSnapshotControllerProvider(_arg).future,
      )).unavailable,
      true,
    );
    expect(repo.snapshots, isEmpty);
  });
  for (final snapshot in [
    _version().copyWith(id: 111),
    _version(head: 'changed'),
    _version().copyWith(baseCommitSha: 'changed'),
    _version().copyWith(startCommitSha: 'changed'),
  ]) {
    test('rejects changed snapshot identity $snapshot', () async {
      final repo = _Repo()..detail = snapshot;
      final c = _container(repo);
      await expectLater(
        c.read(mrReviewSnapshotControllerProvider(_arg).future),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  for (final snapshot in [
    _version().copyWith(files: null),
    _version(state: 'overflow'),
    _version(state: 'without_files'),
  ]) {
    test('unavailable collection is not invented $snapshot', () async {
      final c = _container(_Repo()..detail = snapshot);
      final result = await c.read(
        mrReviewSnapshotControllerProvider(_arg).future,
      );
      expect(result.unavailable, true);
      expect(result.files, isEmpty);
    });
  }
  test('empty collected snapshot remains empty', () async {
    final c = _container(_Repo()..detail = _version(files: []));
    final result = await c.read(
      mrReviewSnapshotControllerProvider(_arg).future,
    );
    expect(result.unavailable, false);
    expect(result.files, isEmpty);
  });
  for (final file in [
    const MergeRequestVersionFile(oldPath: 'a', newPath: 'a', diff: null),
    const MergeRequestVersionFile(oldPath: 'a', newPath: 'a', diff: ''),
    const MergeRequestVersionFile(
      oldPath: 'a',
      newPath: 'a',
      diff: _raw,
      isTooLarge: true,
    ),
    const MergeRequestVersionFile(
      oldPath: 'a',
      newPath: 'a',
      diff: _raw,
      isCollapsed: true,
    ),
  ]) {
    test('unavailable file never offers writable coordinates $file', () async {
      final c = _container(_Repo()..detail = _version(files: [file]));
      final result = await c.read(
        mrReviewSnapshotControllerProvider(_arg).future,
      );
      final f = result.files.single;
      for (final line in f.hunks.expand((h) => h.lines)) {
        expect(result.positionFor(f, line), isNull);
      }
      if (file.diff == null) expect(f.isOmitted, true);
    });
  }
  test(
    'rejects a foreign file or line and duplicate path/coordinates',
    () async {
      final c = _container(_Repo());
      final a = await c.read(mrReviewSnapshotControllerProvider(_arg).future);
      final f = a.files.single;
      final foreign = FileDiff(
        oldPath: f.oldPath,
        newPath: f.newPath,
        isNew: false,
        isDeleted: false,
        isRenamed: true,
        diff: _raw,
      );
      expect(a.positionFor(foreign, foreign.hunks.single.lines.first), isNull);
      expect(a.positionFor(f, foreign.hunks.single.lines.first), isNull);
      final repo = _Repo()
        ..detail = _version(
          files: [..._version().files!, ..._version().files!],
        );
      final dup = await _container(
        repo,
      ).read(mrReviewSnapshotControllerProvider(_arg).future);
      expect(
        dup.positionFor(
          dup.files.first,
          dup.files.first.hunks.single.lines.first,
        ),
        isNull,
      );
      final repo2 = _Repo()
        ..detail = _version(
          files: [
            const MergeRequestVersionFile(
              oldPath: 'old.dart',
              newPath: 'new.dart',
              diff: _raw + _raw,
            ),
          ],
        );
      final dupLine = await _container(
        repo2,
      ).read(mrReviewSnapshotControllerProvider(_arg).future);
      expect(
        dupLine.positionFor(
          dupLine.files.single,
          dupLine.files.single.hunks.first.lines.first,
        ),
        isNull,
      );
    },
  );
  test('account replacement prevents old list follow-up', () async {
    final pending = Completer<Paginated<MergeRequestDiffVersion>>();
    final old = _Repo()..list = pending.future;
    final next = _Repo();
    addTearDown(next.client.close);
    final c = _container(old);
    final p = mrReviewSnapshotControllerProvider(_arg);
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    unawaited(c.read(p.future));
    await Future<void>.delayed(Duration.zero);
    c.read(_session.notifier).state = Future.value(next);
    await c.read(p.future);
    pending.complete(Paginated(items: [_version()]));
    await Future<void>.delayed(Duration.zero);
    expect(old.snapshots, isEmpty);
    expect(c.read(p).value!.version!.id, 110);
  });
  for (final fails in [false, true]) {
    test(
      'late detail completion after account replacement fails=$fails',
      () async {
        final pending = Completer<MergeRequestDiffVersion>();
        final old = _Repo()..detail = pending.future;
        final next = _Repo()..detail = _version().copyWith(id: 110);
        addTearDown(next.client.close);
        final c = _container(old);
        final p = mrReviewSnapshotControllerProvider(_arg);
        final sub = c.listen(p, (_, _) {});
        addTearDown(sub.close);
        unawaited(c.read(p.future));
        await Future<void>.delayed(Duration.zero);
        c.read(_session.notifier).state = Future.value(next);
        await c.read(p.future);
        if (fails) {
          pending.completeError(const GitLabServerException('Old failure'));
        } else {
          pending.complete(_version(head: 'old'));
        }
        await Future<void>.delayed(Duration.zero);
        expect(c.read(p).value!.version!.headCommitSha, 'head');
        expect(c.read(p).hasError, false);
      },
    );
  }
  test('disposal prevents old list follow-up', () async {
    final pending = Completer<Paginated<MergeRequestDiffVersion>>();
    final old = _Repo()..list = pending.future;
    final c = _container(old);
    final p = mrReviewSnapshotControllerProvider(_arg);
    final sub = c.listen(p, (_, _) {});
    unawaited(c.read(p.future));
    await Future<void>.delayed(Duration.zero);
    sub.close();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    pending.complete(Paginated(items: [_version()]));
    await Future<void>.delayed(Duration.zero);
    expect(old.snapshots, isEmpty);
  });
}
