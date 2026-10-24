import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';

class Repository extends PipelinesRepository {
  Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final calls =
      <({int page, PipelineJobStatusFilter? status, bool attempts})>[];
  final pending = <int, Completer<Paginated<Job>>>{};
  bool fail = false;
  bool failAction = false;
  @override
  Future<Paginated<Job>> jobsPage({
    required int projectId,
    required int pipelineId,
    int page = 1,
    PipelineJobStatusFilter? status,
    bool includeRetried = false,
  }) async {
    calls.add((page: page, status: status, attempts: includeRetried));
    if (pending[page] case final request?) return request.future;
    if (fail) throw const GitLabForbiddenException('private');
    return switch (page) {
      1 => const Paginated(
        items: [Job(id: 10, name: 'same', status: 'failed', stage: 'test')],
        nextPage: 4,
      ),
      4 => const Paginated(items: [], nextPage: 9),
      _ => const Paginated(
        items: [
          Job(id: 10, name: 'same', status: 'success', stage: 'test'),
          Job(id: 9, name: 'same', status: 'failed', stage: 'test'),
        ],
      ),
    };
  }

  @override
  Future<Pipeline> retry({
    required int projectId,
    required int pipelineId,
  }) async {
    if (failAction) throw const GitLabForbiddenException('private');
    return Pipeline(id: pipelineId, status: 'pending');
  }

  @override
  Future<Pipeline> cancel({required int projectId, required int pipelineId}) =>
      retry(projectId: projectId, pipelineId: pipelineId);
}

void main() {
  const key = PipelineRef(projectId: 7, pipelineId: 944);
  final p = pipelineJobsControllerProvider(key);
  final status = pipelineJobStatusFilterProvider(key);
  final attempts = pipelineJobIncludeRetriedProvider(key);
  late Repository repo;
  late ProviderContainer c;
  setUp(() {
    repo = Repository();
    c = ProviderContainer(
      overrides: [pipelinesRepositoryProvider.overrideWith((_) async => repo)],
    );
  });
  tearDown(() => c.dispose());
  test(
    'initial page, empty continuation and ID merge preserve distinct same-name attempts',
    () async {
      expect((await c.read(p.future)).nextPage, 4);
      expect(repo.calls.length, 1);
      final n = c.read(p.notifier);
      await n.loadMore();
      expect(c.read(p).requireValue.items.length, 1);
      expect(c.read(p).requireValue.nextPage, 9);
      await n.loadMore();
      expect(c.read(p).requireValue.items.map((j) => j.id), [10, 9]);
      expect(c.read(p).requireValue.items.first.status, 'success');
      expect(c.read(p).requireValue.nextPage, isNull);
      await n.loadMore();
      expect(repo.calls.map((a) => a.page), [1, 4, 9]);
    },
  );
  test(
    'every combined filter continues and resets to page one without losing the other filter',
    () async {
      c.read(attempts.notifier).state = true;
      for (final value in PipelineJobStatusFilter.values) {
        c.read(status.notifier).state = value;
        await c.read(p.future);
        await c.read(p.notifier).loadMore();
        expect(repo.calls.last, (page: 4, status: value, attempts: true));
      }
      c.read(status.notifier).state = null;
      await c.read(p.future);
      expect(repo.calls.last, (page: 1, status: null, attempts: true));
      c.read(attempts.notifier).state = false;
      await c.read(p.future);
      expect(repo.calls.last, (page: 1, status: null, attempts: false));
    },
  );
  test(
    'failed continuation retains loaded jobs and cursor for a filtered retry',
    () async {
      c.read(status.notifier).state = PipelineJobStatusFilter.failed;
      c.read(attempts.notifier).state = true;
      await c.read(p.future);
      repo.fail = true;
      await expectLater(
        c.read(p.notifier).loadMore(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(c.read(p).requireValue.nextPage, 4);
      expect(c.read(p).requireValue.items.single.id, 10);
      repo.fail = false;
      await c.read(p.notifier).loadMore();
      expect(repo.calls.last, (
        page: 4,
        status: PipelineJobStatusFilter.failed,
        attempts: true,
      ));
    },
  );
  test(
    'pending duplicate loads are blocked and stale filter completions or errors are ignored',
    () async {
      await c.read(p.future);
      repo.pending[4] = Completer();
      final old = repo.pending[4]!;
      final n = c.read(p.notifier);
      final loading = n.loadMore();
      await Future<void>.delayed(Duration.zero);
      await n.loadMore();
      expect(repo.calls.length, 2);
      c.read(attempts.notifier).state = true;
      await c.read(p.future);
      old.complete(
        const Paginated(
          items: [Job(id: 99, name: 'old', status: 'success')],
        ),
      );
      await loading;
      expect(c.read(p).requireValue.items.single.id, 10);
      repo.pending[4] = Completer();
      final failed = repo.pending[4]!;
      final stale = n.loadMore();
      await Future<void>.delayed(Duration.zero);
      c.read(status.notifier).state = PipelineJobStatusFilter.failed;
      await c.read(p.future);
      failed.completeError(const GitLabForbiddenException('old'));
      await stale;
      expect(c.read(p).hasError, false);
      expect(c.read(p).requireValue.nextPage, 4);
    },
  );
  test(
    'filter replacement before dispatch cancels the old continuation read',
    () async {
      await c.read(p.future);
      final old = c.read(p.notifier).loadMore();
      c.read(status.notifier).state = PipelineJobStatusFilter.failed;
      await c.read(p.future);
      await old;
      expect(repo.calls.where((call) => call.page != 1), isEmpty);
      expect(repo.calls.last, (
        page: 1,
        status: PipelineJobStatusFilter.failed,
        attempts: false,
      ));
    },
  );
  test(
    'refresh and provider disposal isolate obsolete continuation writes',
    () async {
      await c.read(p.future);
      repo.pending[4] = Completer();
      final old = repo.pending[4]!;
      final request = c.read(p.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      await c.refresh(p.future);
      old.complete(
        const Paginated(
          items: [Job(id: 99, name: 'old', status: 'success')],
        ),
      );
      await request;
      expect(c.read(p).requireValue.items.single.id, 10);
      repo.pending[4] = Completer();
      final disposed = repo.pending[4]!;
      final stale = c.read(p.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      c.invalidate(p);
      disposed.complete(const Paginated(items: []));
      await stale;
      await c.read(p.future);
      expect(c.read(p).requireValue.nextPage, 4);
    },
  );
  test(
    'account replacement and logout isolate in-flight continuation',
    () async {
      await c.read(p.future);
      repo.pending[4] = Completer();
      final old = repo.pending[4]!;
      final request = c.read(p.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      final replacement = Repository();
      c.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((_) async => replacement),
      ]);
      c.invalidate(pipelinesRepositoryProvider);
      await c.read(p.future);
      old.complete(
        const Paginated(
          items: [Job(id: 99, name: 'private', status: 'failed')],
        ),
      );
      await request;
      expect(c.read(p).requireValue.items.single.id, 10);
      replacement.pending[4] = Completer();
      final pending = replacement.pending[4]!;
      final late = c.read(p.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      c.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((_) async => null),
      ]);
      c.invalidate(pipelinesRepositoryProvider);
      await expectLater(c.read(p.future), throwsA(isA<StateError>()));
      pending.complete(const Paginated(items: []));
      await late;
      expect(c.read(p).hasError, true);
    },
  );
  test(
    'successful pipeline actions reload page one with both filters; failure preserves cursor',
    () async {
      c.read(status.notifier).state = PipelineJobStatusFilter.failed;
      c.read(attempts.notifier).state = true;
      await c.read(p.future);
      await c.read(p.notifier).loadMore();
      final action = c.read(pipelineActionsControllerProvider(key).notifier);
      await action.retry();
      expect((await c.read(p.future)).nextPage, 4);
      expect(repo.calls.last, (
        page: 1,
        status: PipelineJobStatusFilter.failed,
        attempts: true,
      ));
      await action.cancel();
      await c.read(p.future);
      repo.failAction = true;
      final count = repo.calls.length;
      await expectLater(
        action.retry(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(repo.calls.length, count);
      expect(c.read(p).requireValue.nextPage, 4);
    },
  );
}
