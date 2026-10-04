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
  final calls = <({PipelineRef key, PipelineJobStatusFilter? status})>[];
  final pending = <PipelineJobStatusFilter?, Completer<List<Job>>>{};
  bool fail = false;
  bool failAction = false;
  @override
  Future<List<Job>> jobs({
    required int projectId,
    required int pipelineId,
    PipelineJobStatusFilter? status,
    bool includeRetried = false,
  }) async {
    calls.add((
      key: PipelineRef(projectId: projectId, pipelineId: pipelineId),
      status: status,
    ));
    if (pending[status] case final request?) return request.future;
    if (fail) throw const GitLabForbiddenException('private');
    return [
      Job(
        id: 1,
        name: status?.name ?? 'all',
        status: status?.name ?? 'waiting_for_callback',
      ),
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
  final provider = pipelineJobsControllerProvider(key);
  final filter = pipelineJobStatusFilterProvider(key);
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
    'all status mappings, clear, refresh and error retry retain the selected scope',
    () async {
      expect(
        (await c.read(provider.future)).single.status,
        'waiting_for_callback',
      );
      for (final status in PipelineJobStatusFilter.values) {
        c.read(filter.notifier).state = status;
        expect((await c.read(provider.future)).single.status, status.name);
        expect(repo.calls.last.status, status);
      }
      repo.fail = true;
      await expectLater(
        c.refresh(provider.future),
        throwsA(isA<GitLabForbiddenException>()),
      );
      repo.fail = false;
      expect((await c.refresh(provider.future)).single.status, 'manual');
      c.read(filter.notifier).state = null;
      expect(
        (await c.read(provider.future)).single.status,
        'waiting_for_callback',
      );
    },
  );
  test('project and pipeline families have independent selections', () async {
    c.read(filter.notifier).state = PipelineJobStatusFilter.failed;
    await c.read(provider.future);
    for (final other in [
      const PipelineRef(projectId: 7, pipelineId: 945),
      const PipelineRef(projectId: 8, pipelineId: 944),
    ]) {
      expect(c.read(pipelineJobStatusFilterProvider(other)), isNull);
      expect(
        (await c.read(
          pipelineJobsControllerProvider(other).future,
        )).single.status,
        'waiting_for_callback',
      );
    }
    expect(c.read(filter), PipelineJobStatusFilter.failed);
  });
  test(
    'old filter and refresh completions cannot replace the current job set',
    () async {
      repo.pending[null] = Completer();
      c.listen(provider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final old = repo.pending[null]!;
      c.read(filter.notifier).state = PipelineJobStatusFilter.failed;
      expect((await c.read(provider.future)).single.status, 'failed');
      old.complete([const Job(id: 999, name: 'old', status: 'success')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(provider).requireValue.single.status, 'failed');
      repo.pending[PipelineJobStatusFilter.failed] = Completer();
      c.invalidate(provider);
      await Future<void>.delayed(Duration.zero);
      final stale = repo.pending.remove(PipelineJobStatusFilter.failed)!;
      await c.refresh(provider.future);
      stale.complete([const Job(id: 998, name: 'stale', status: 'success')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(provider).requireValue.single.status, 'failed');
    },
  );
  test(
    'account replacement and logout isolate pending filtered jobs',
    () async {
      c.read(filter.notifier).state = PipelineJobStatusFilter.failed;
      repo.pending[PipelineJobStatusFilter.failed] = Completer();
      c.listen(provider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final old = repo.pending[PipelineJobStatusFilter.failed]!;
      final replacement = Repository();
      c.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((_) async => replacement),
      ]);
      c.invalidate(pipelinesRepositoryProvider);
      expect((await c.read(provider.future)).single.status, 'failed');
      old.complete([const Job(id: 999, name: 'private', status: 'success')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(provider).requireValue.single.status, 'failed');
      replacement.pending[PipelineJobStatusFilter.failed] = Completer();
      c.invalidate(provider);
      await Future<void>.delayed(Duration.zero);
      final pending = replacement.pending[PipelineJobStatusFilter.failed]!;
      c.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((_) async => null),
      ]);
      c.invalidate(pipelinesRepositoryProvider);
      await expectLater(c.read(provider.future), throwsA(isA<StateError>()));
      pending.complete([const Job(id: 999, name: 'private', status: 'failed')]);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(provider).hasError, isTrue);
    },
  );
  test(
    'successful actions reload filtered jobs; failed actions preserve state',
    () async {
      c.read(filter.notifier).state = PipelineJobStatusFilter.failed;
      await c.read(provider.future);
      final action = c.read(pipelineActionsControllerProvider(key).notifier);
      await action.retry();
      await c.read(provider.future);
      await action.cancel();
      await c.read(provider.future);
      expect(repo.calls.map((a) => a.status), [
        PipelineJobStatusFilter.failed,
        PipelineJobStatusFilter.failed,
        PipelineJobStatusFilter.failed,
      ]);
      repo.failAction = true;
      await expectLater(
        action.retry(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      await c.read(provider.future);
      expect(repo.calls.length, 3);
      expect(c.read(filter), PipelineJobStatusFilter.failed);
    },
  );
}
