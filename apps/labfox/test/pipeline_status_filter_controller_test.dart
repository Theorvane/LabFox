import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';

class _Repository extends PipelinesRepository {
  @override
  Future<PipelineUpstream?> upstream({
    required int projectId,
    required int pipelineId,
  }) async => null;

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
  final calls = <({int projectId, int page, PipelineStatusFilter? status})>[];
  final pending =
      <(PipelineStatusFilter?, int), Completer<Paginated<Pipeline>>>{};
  bool fail = false;
  int firstId = 33;
  @override
  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    PipelineStatusFilter? status,
    String? ref,
    PipelineSourceFilter? source,
  }) async {
    calls.add((projectId: projectId, page: page, status: status));
    final request = pending[(status, page)];
    if (request != null) return request.future;
    if (fail) throw const GitLabForbiddenException('Rejected');
    return Paginated(
      items: [
        Pipeline(
          id: page == 1 ? firstId : firstId - 1,
          status: status?.name ?? 'scheduled',
        ),
      ],
      nextPage: page == 1 ? 4 : null,
    );
  }
}

void main() {
  late ProviderContainer container;
  late _Repository repository;
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
    'a selected status starts at page one and survives pagination, retry, refresh and clearing',
    () async {
      await container.read(provider.future);
      container.read(pipelineStatusFilterProvider(7).notifier).state =
          PipelineStatusFilter.failed;
      expect(
        (await container.read(provider.future)).items.single.status,
        'failed',
      );
      repository.fail = true;
      await expectLater(
        container.read(provider.notifier).loadMore(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(
        container.read(provider).requireValue.items.single.status,
        'failed',
      );
      expect(container.read(provider).requireValue.nextPage, 4);
      repository.fail = false;
      await container.read(provider.notifier).loadMore();
      await container.refresh(provider.future);
      container.read(pipelineStatusFilterProvider(7).notifier).state = null;
      expect(
        (await container.read(provider.future)).items.single.status,
        'scheduled',
      );
      expect(repository.calls.map((c) => (c.page, c.status)), [
        (1, null),
        (1, PipelineStatusFilter.failed),
        (4, PipelineStatusFilter.failed),
        (4, PipelineStatusFilter.failed),
        (1, PipelineStatusFilter.failed),
        (1, null),
      ]);
    },
  );

  test(
    'a late continuation from the previous filter cannot append rows or overwrite the cursor',
    () async {
      await container.read(provider.future);
      final oldPage = Completer<Paginated<Pipeline>>();
      repository.pending[(null, 4)] = oldPage;
      final request = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      container.read(pipelineStatusFilterProvider(7).notifier).state =
          PipelineStatusFilter.running;
      await container.read(provider.future);
      oldPage.complete(
        const Paginated(items: [Pipeline(id: 999, status: 'failed')]),
      );
      await request;
      final result = container.read(provider).requireValue;
      expect(result.items.map((p) => p.status), ['running']);
      expect(result.nextPage, 4);
      await container.read(provider.notifier).loadMore();
      expect(repository.calls.last.status, PipelineStatusFilter.running);
    },
  );

  test('rapid filter changes ignore a late first page', () async {
    await container.read(provider.future);
    final oldFirst = Completer<Paginated<Pipeline>>();
    repository.pending[(PipelineStatusFilter.failed, 1)] = oldFirst;
    container.read(pipelineStatusFilterProvider(7).notifier).state =
        PipelineStatusFilter.failed;
    final oldRequest = container.read(provider.future);
    await Future<void>.delayed(Duration.zero);
    container.read(pipelineStatusFilterProvider(7).notifier).state =
        PipelineStatusFilter.success;
    await container.read(provider.future);
    oldFirst.complete(
      const Paginated(items: [Pipeline(id: 999, status: 'failed')]),
    );
    await oldRequest;
    expect(
      container.read(provider).requireValue.items.single.status,
      'success',
    );
  });

  test(
    'project and account-source changes reload independently without sharing rows',
    () async {
      container.read(pipelineStatusFilterProvider(7).notifier).state =
          PipelineStatusFilter.manual;
      expect(
        (await container.read(provider.future)).items.single.status,
        'manual',
      );
      expect(
        (await container.read(
          pipelinesControllerProvider(8).future,
        )).items.single.status,
        'scheduled',
      );
      final oldRepository = repository;
      final oldPage = Completer<Paginated<Pipeline>>();
      oldRepository.pending[(PipelineStatusFilter.manual, 4)] = oldPage;
      final oldRequest = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      repository = _Repository()..firstId = 77;
      container.invalidate(pipelinesRepositoryProvider);
      expect((await container.read(provider.future)).items.single.id, 77);
      oldPage.complete(
        const Paginated(items: [Pipeline(id: 999, status: 'manual')]),
      );
      await oldRequest;
      expect(container.read(provider).requireValue.items.single.id, 77);
      expect(container.read(provider).requireValue.nextPage, 4);
      expect(repository.calls.last, (
        projectId: 7,
        page: 1,
        status: PipelineStatusFilter.manual,
      ));
      expect(container.read(pipelineStatusFilterProvider(8)), isNull);
    },
  );
}
