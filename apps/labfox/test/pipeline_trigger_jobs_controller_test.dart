import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';

class _Repository extends PipelinesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final calls = <({int project, int pipeline, int page})>[];
  final pages = <int, Paginated<PipelineTriggerJob>>{
    1: const Paginated(
      items: [PipelineTriggerJob(id: 10, name: 'deploy', status: 'pending')],
      nextPage: 4,
    ),
    4: const Paginated(items: [], nextPage: 9),
    9: const Paginated(
      items: [
        PipelineTriggerJob(id: 10, name: 'deploy', status: 'success'),
        PipelineTriggerJob(id: 11, name: 'release', status: 'running'),
      ],
    ),
  };
  bool fail = false;
  bool failAction = false;
  Completer<Paginated<PipelineTriggerJob>>? pending;
  @override
  Future<Paginated<PipelineTriggerJob>> triggerJobs({
    required int projectId,
    required int pipelineId,
    int page = 1,
  }) async {
    calls.add((project: projectId, pipeline: pipelineId, page: page));
    if (page != 1 && pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('Private response');
    return pages[page]!;
  }

  @override
  Future<Pipeline> retry({
    required int projectId,
    required int pipelineId,
  }) async {
    if (failAction) throw const GitLabForbiddenException('Private response');
    return Pipeline(id: pipelineId, status: 'pending');
  }

  @override
  Future<Pipeline> cancel({required int projectId, required int pipelineId}) =>
      retry(projectId: projectId, pipelineId: pipelineId);
}

void main() {
  const key = PipelineRef(projectId: 7, pipelineId: 944);
  final provider = pipelineTriggerJobsControllerProvider(key);
  late _Repository repository;
  late ProviderContainer container;
  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [
        pipelinesRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
  });
  tearDown(() => container.dispose());
  test(
    'follows empty continuation pages, retains failed cursor, retries and updates duplicate rows',
    () async {
      expect((await container.read(provider.future)).items.single.id, 10);
      await container.read(provider.notifier).loadMore();
      expect(container.read(provider).requireValue.nextPage, 9);
      repository.fail = true;
      await expectLater(
        container.read(provider.notifier).loadMore(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(container.read(provider).requireValue.items.single.id, 10);
      expect(container.read(provider).requireValue.nextPage, 9);
      repository.fail = false;
      await container.read(provider.notifier).loadMore();
      expect(container.read(provider).requireValue.items.map((j) => j.id), [
        10,
        11,
      ]);
      expect(
        container.read(provider).requireValue.items.first.status,
        'success',
      );
      expect(repository.calls.map((c) => c.page), [1, 4, 9, 9]);
      await container.refresh(provider.future);
      expect(repository.calls.last.page, 1);
    },
  );
  test(
    'account-source replacement ignores old pages; pipeline families stay isolated',
    () async {
      await container.read(provider.future);
      repository.pending = Completer();
      final old = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      final replacement = _Repository();
      container.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((ref) async => replacement),
      ]);
      container.invalidate(pipelinesRepositoryProvider);
      await container.read(provider.future);
      repository.pending!.complete(
        const Paginated(
          items: [PipelineTriggerJob(id: 999, name: 'old', status: 'success')],
          nextPage: 99,
        ),
      );
      await old;
      expect(container.read(provider).requireValue.items.map((j) => j.id), [
        10,
      ]);
      expect(container.read(provider).requireValue.nextPage, 4);
      await container.read(
        pipelineTriggerJobsControllerProvider(
          const PipelineRef(projectId: 8, pipelineId: 33),
        ).future,
      );
      expect(replacement.calls.last, (project: 8, pipeline: 33, page: 1));
    },
  );
  test(
    'only successful retry and cancel invalidate downstream lists',
    () async {
      await container.read(provider.future);
      final action = container.read(
        pipelineActionsControllerProvider(key).notifier,
      );
      await action.retry();
      await container.read(provider.future);
      await action.cancel();
      await container.read(provider.future);
      expect(repository.calls.length, 3);
      repository.failAction = true;
      await expectLater(
        action.retry(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      await container.read(provider.future);
      expect(repository.calls.length, 3);
    },
  );
  test(
    'logging out prevents an old continuation from restoring private rows',
    () async {
      await container.read(provider.future);
      repository.pending = Completer();
      final old = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      container.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((ref) async => null),
      ]);
      container.invalidate(pipelinesRepositoryProvider);
      await expectLater(
        container.read(provider.future),
        throwsA(isA<StateError>()),
      );
      repository.pending!.complete(
        const Paginated(
          items: [
            PipelineTriggerJob(id: 999, name: 'private', status: 'success'),
          ],
        ),
      );
      await old;
      expect(container.read(provider).hasError, isTrue);
      expect(
        container
            .read(provider)
            .when(
              skipLoadingOnRefresh: false,
              data: (page) => page.items,
              loading: () => const <PipelineTriggerJob>[],
              error: (_, _) => const <PipelineTriggerJob>[],
            ),
        isEmpty,
      );
    },
  );
}
