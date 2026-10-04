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
  final calls = <({bool attempts, PipelineJobStatusFilter? status})>[];
  final pending = <bool, Completer<List<Job>>>{};
  bool fail = false;
  bool failAction = false;
  @override
  Future<List<Job>> jobs({
    required int projectId,
    required int pipelineId,
    PipelineJobStatusFilter? status,
    bool includeRetried = false,
  }) async {
    calls.add((attempts: includeRetried, status: status));
    if (pending[includeRetried] case final request?) return request.future;
    if (fail) throw const GitLabForbiddenException('private');
    return [
      const Job(id: 902, name: 'test', status: 'failed'),
      if (includeRetried) const Job(id: 901, name: 'test', status: 'failed'),
    ];
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
  final jobs = pipelineJobsControllerProvider(key);
  final attempts = pipelineJobIncludeRetriedProvider(key);
  final status = pipelineJobStatusFilterProvider(key);
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
    'attempts default, combined status, clear, refresh and recovery',
    () async {
      expect(c.read(attempts), false);
      expect((await c.read(jobs.future)).map((j) => j.id), [902]);
      c.read(attempts.notifier).state = true;
      expect((await c.read(jobs.future)).map((j) => j.id), [902, 901]);
      for (final value in PipelineJobStatusFilter.values) {
        c.read(status.notifier).state = value;
        await c.read(jobs.future);
        expect(repo.calls.last, (attempts: true, status: value));
      }
      c.read(status.notifier).state = null;
      await c.read(jobs.future);
      expect(repo.calls.last, (attempts: true, status: null));
      repo.fail = true;
      await expectLater(
        c.refresh(jobs.future),
        throwsA(isA<GitLabForbiddenException>()),
      );
      repo.fail = false;
      await c.refresh(jobs.future);
      expect(repo.calls.last, (attempts: true, status: null));
      c.read(attempts.notifier).state = false;
      expect((await c.read(jobs.future)).length, 1);
    },
  );
  test(
    'attempt selections are independent across projects and pipelines',
    () async {
      c.read(attempts.notifier).state = true;
      await c.read(jobs.future);
      for (final other in [
        const PipelineRef(projectId: 7, pipelineId: 945),
        const PipelineRef(projectId: 8, pipelineId: 944),
      ]) {
        expect(c.read(pipelineJobIncludeRetriedProvider(other)), false);
        expect(
          (await c.read(pipelineJobsControllerProvider(other).future)).length,
          1,
        );
      }
      expect(c.read(attempts), true);
    },
  );
  test(
    'stale attempt and refresh responses cannot replace current jobs',
    () async {
      repo.pending[false] = Completer();
      c.listen(jobs, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final old = repo.pending[false]!;
      c.read(attempts.notifier).state = true;
      expect((await c.read(jobs.future)).length, 2);
      old.complete([const Job(id: 999, name: 'old', status: 'success')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(jobs).requireValue.map((j) => j.id), [902, 901]);
      repo.pending[true] = Completer();
      c.invalidate(jobs);
      await Future<void>.delayed(Duration.zero);
      final stale = repo.pending.remove(true)!;
      await c.refresh(jobs.future);
      stale.complete([const Job(id: 999, name: 'stale', status: 'success')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(jobs).requireValue.length, 2);
    },
  );
  test(
    'account replacement and logout isolate pending all-attempt reads',
    () async {
      c.read(attempts.notifier).state = true;
      repo.pending[true] = Completer();
      c.listen(jobs, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final old = repo.pending[true]!;
      final replacement = Repository();
      c.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((_) async => replacement),
      ]);
      c.invalidate(pipelinesRepositoryProvider);
      expect((await c.read(jobs.future)).length, 2);
      old.complete([const Job(id: 999, name: 'private', status: 'failed')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(jobs).requireValue.length, 2);
      replacement.pending[true] = Completer();
      c.invalidate(jobs);
      await Future<void>.delayed(Duration.zero);
      final late = replacement.pending[true]!;
      c.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((_) async => null),
      ]);
      c.invalidate(pipelinesRepositoryProvider);
      await expectLater(c.read(jobs.future), throwsA(isA<StateError>()));
      late.complete([const Job(id: 999, name: 'private', status: 'failed')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(jobs).hasError, true);
    },
  );
  test(
    'successful actions preserve both filters and failed actions do not reload',
    () async {
      c.read(attempts.notifier).state = true;
      c.read(status.notifier).state = PipelineJobStatusFilter.failed;
      await c.read(jobs.future);
      final action = c.read(pipelineActionsControllerProvider(key).notifier);
      await action.retry();
      await c.read(jobs.future);
      await action.cancel();
      await c.read(jobs.future);
      expect(
        repo.calls,
        List.filled(3, (
          attempts: true,
          status: PipelineJobStatusFilter.failed,
        )),
      );
      repo.failAction = true;
      await expectLater(
        action.retry(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      await c.read(jobs.future);
      expect(repo.calls.length, 3);
    },
  );
}
