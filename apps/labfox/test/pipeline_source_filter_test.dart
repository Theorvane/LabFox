import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';

class _Repository extends PipelinesRepository {
  @override
  Future<Paginated<PipelineTriggerJob>> triggerJobs({
    required int projectId,
    required int pipelineId,
    int page = 1,
  }) async => const Paginated(items: []);
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final calls =
      <
        ({
          int project,
          int page,
          String? ref,
          PipelineStatusFilter? status,
          PipelineSourceFilter? source,
        })
      >[];
  Completer<Paginated<Pipeline>>? pending;
  bool fail = false;
  final firstPages = <PipelineSourceFilter?, Completer<Paginated<Pipeline>>>{};
  @override
  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    String? ref,
    PipelineSourceFilter? source,
    PipelineStatusFilter? status,
  }) async {
    calls.add((
      project: projectId,
      page: page,
      ref: ref,
      status: status,
      source: source,
    ));
    if (page == 1 && firstPages[source] != null) {
      return firstPages[source]!.future;
    }
    if (page == 4 && pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('Rejected');
    return Paginated(
      items: [
        Pipeline(
          id: page == 1 ? 33 : 32,
          ref: ref ?? 'main',
          status: status?.name ?? 'success',
          source: source?.apiValue ?? 'push',
        ),
      ],
      nextPage: page == 1 ? 4 : null,
    );
  }

  @override
  Future<Pipeline> retry({
    required int projectId,
    required int pipelineId,
  }) async => Pipeline(id: pipelineId, status: 'pending');
}

void main() {
  late _Repository repository;
  late ProviderContainer container;
  final provider = pipelinesControllerProvider(7);
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
    'child source resets to page one and retains all filters for retries, refresh and actions',
    () async {
      container.read(pipelineStatusFilterProvider(7).notifier).state =
          PipelineStatusFilter.failed;
      container.read(pipelineRefFilterProvider(7).notifier).state =
          'release/v1+fix';
      await container.read(provider.future);
      container.read(pipelineSourceFilterProvider(7).notifier).state =
          PipelineSourceFilter.parentPipeline;
      expect(
        (await container.read(provider.future)).items.single.source,
        'parent_pipeline',
      );
      repository.fail = true;
      await expectLater(
        container.read(provider.notifier).loadMore(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(container.read(provider).requireValue.nextPage, 4);
      repository.fail = false;
      await container.read(provider.notifier).loadMore();
      await container.refresh(provider.future);
      await container
          .read(
            pipelineActionsControllerProvider(
              const PipelineRef(projectId: 7, pipelineId: 33),
            ).notifier,
          )
          .retry();
      await container.read(provider.future);
      expect(
        repository.calls
            .skip(1)
            .every(
              (c) =>
                  c.source == PipelineSourceFilter.parentPipeline &&
                  c.ref == 'release/v1+fix' &&
                  c.status == PipelineStatusFilter.failed,
            ),
        isTrue,
      );
      expect(repository.calls.map((c) => c.page), [1, 1, 4, 4, 1, 1]);
      container.read(pipelineSourceFilterProvider(7).notifier).state = null;
      await container.read(provider.future);
      expect(repository.calls.last.source, isNull);
      expect(repository.calls.last.ref, 'release/v1+fix');
      expect(repository.calls.last.status, PipelineStatusFilter.failed);
    },
  );
  test(
    'late continuation cannot replace a new source; other projects keep their own selection',
    () async {
      await container.read(provider.future);
      repository.pending = Completer();
      final old = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      container.read(pipelineSourceFilterProvider(7).notifier).state =
          PipelineSourceFilter.schedule;
      expect(
        (await container.read(provider.future)).items.single.source,
        'schedule',
      );
      repository.pending!.complete(
        const Paginated(
          items: [Pipeline(id: 999, status: 'success')],
          nextPage: 9,
        ),
      );
      await old;
      expect(container.read(provider).requireValue.items.map((p) => p.id), [
        33,
      ]);
      expect(container.read(provider).requireValue.nextPage, 4);
      await container.read(pipelinesControllerProvider(8).future);
      expect(repository.calls.last.source, isNull);
    },
  );
  test(
    'late first page and account-source continuation cannot overwrite the current source',
    () async {
      await container.read(provider.future);
      final first = Completer<Paginated<Pipeline>>();
      repository.firstPages[PipelineSourceFilter.web] = first;
      container.read(pipelineSourceFilterProvider(7).notifier).state =
          PipelineSourceFilter.web;
      await Future<void>.delayed(Duration.zero);
      container.read(pipelineSourceFilterProvider(7).notifier).state =
          PipelineSourceFilter.parentPipeline;
      expect(
        (await container.read(provider.future)).items.single.source,
        'parent_pipeline',
      );
      first.complete(
        const Paginated(
          items: [Pipeline(id: 999, status: 'success', source: 'web')],
        ),
      );
      await Future<void>.delayed(Duration.zero);
      repository.pending = Completer();
      final old = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      final replacement = _Repository();
      container.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((ref) async => replacement),
      ]);
      container.invalidate(pipelinesRepositoryProvider);
      expect(
        (await container.read(provider.future)).items.single.source,
        'parent_pipeline',
      );
      repository.pending!.complete(
        const Paginated(
          items: [Pipeline(id: 888, status: 'success')],
          nextPage: 9,
        ),
      );
      await old;
      expect(container.read(provider).requireValue.items.map((p) => p.id), [
        33,
      ]);
      expect(
        replacement.calls.last.source,
        PipelineSourceFilter.parentPipeline,
      );
    },
  );
}
