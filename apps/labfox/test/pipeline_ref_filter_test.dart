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
  final calls =
      <({int project, int page, String? ref, PipelineStatusFilter? status})>[];
  Completer<Paginated<Pipeline>>? pending;
  bool fail = false;
  final firstPages = <String?, Completer<Paginated<Pipeline>>>{};
  @override
  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    String? ref,
    PipelineStatusFilter? status,
  }) async {
    calls.add((project: projectId, page: page, ref: ref, status: status));
    if (page == 1 && firstPages[ref] != null) return firstPages[ref]!.future;
    if (page == 4 && pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('Rejected');
    return Paginated(
      items: [
        Pipeline(
          id: page == 1 ? 33 : 32,
          ref: ref ?? 'main',
          status: status?.name ?? 'success',
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
    'ref and status survive cursor failure, retry, refresh and actions; clearing ref retains status',
    () async {
      container.read(pipelineStatusFilterProvider(7).notifier).state =
          PipelineStatusFilter.failed;
      await container.read(provider.future);
      container.read(pipelineRefFilterProvider(7).notifier).state =
          'release/v1+fix';
      expect(
        (await container.read(provider.future)).items.single.ref,
        'release/v1+fix',
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
                  c.ref == 'release/v1+fix' &&
                  c.status == PipelineStatusFilter.failed,
            ),
        isTrue,
      );
      expect(repository.calls.map((c) => c.page), [1, 1, 4, 4, 1, 1]);
      container.read(pipelineRefFilterProvider(7).notifier).state = null;
      await container.read(provider.future);
      expect(repository.calls.last.ref, isNull);
      expect(repository.calls.last.status, PipelineStatusFilter.failed);
    },
  );
  test(
    'changing ref isolates late continuation and leaves other projects unfiltered',
    () async {
      await container.read(provider.future);
      repository.pending = Completer();
      final old = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      container.read(pipelineRefFilterProvider(7).notifier).state =
          'feature/new';
      expect(
        (await container.read(provider.future)).items.single.ref,
        'feature/new',
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
      expect(repository.calls.last.ref, isNull);
    },
  );
  test('late first-page results cannot replace a newer ref', () async {
    await container.read(provider.future);
    final old = Completer<Paginated<Pipeline>>();
    repository.firstPages['old/ref'] = old;
    container.read(pipelineRefFilterProvider(7).notifier).state = 'old/ref';
    await Future<void>.delayed(Duration.zero);
    container.read(pipelineRefFilterProvider(7).notifier).state = 'new/ref';
    expect((await container.read(provider.future)).items.single.ref, 'new/ref');
    old.complete(
      const Paginated(
        items: [Pipeline(id: 999, status: 'success', ref: 'old/ref')],
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(container.read(provider).requireValue.items.single.ref, 'new/ref');
  });
}
