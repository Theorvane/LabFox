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
  final pages = <int>[];
  bool fail = false;
  Completer<void>? pending;
  @override
  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    PipelineStatusFilter? status,
    String? ref,
    PipelineSourceFilter? source,
  }) async {
    expect(projectId, 7);
    pages.add(page);
    if (fail) throw StateError('Rejected');
    if (page != 1) await pending?.future;
    return page == 1
        ? const Paginated(
            items: [Pipeline(id: 332, status: 'running')],
            nextPage: 4,
          )
        : const Paginated(
            items: [
              Pipeline(id: 332, status: 'success'),
              Pipeline(id: 331, status: 'failed'),
            ],
          );
  }
}

void main() {
  final provider = pipelinesControllerProvider(7);
  late _Repository repository;
  late ProviderContainer container;
  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [
        pipelinesRepositoryProvider.overrideWith((_) async => repository),
      ],
    );
  });
  tearDown(() => container.dispose());
  test(
    'preserves header cursor, deduplicates metadata and stops on last page',
    () async {
      await container.read(provider.future);
      await container.read(provider.notifier).loadMore();
      await container.read(provider.notifier).loadMore();
      expect(repository.pages, [1, 4]);
      expect(
        container.read(provider).requireValue.items.map((item) => item.id),
        [332, 331],
      );
      expect(
        container.read(provider).requireValue.items.first.status,
        'success',
      );
    },
  );
  test(
    'retains rows and cursor after failure and performs real retry',
    () async {
      await container.read(provider.future);
      repository.fail = true;
      await expectLater(
        container.read(provider.notifier).loadMore(),
        throwsStateError,
      );
      expect(container.read(provider).requireValue.items.single.id, 332);
      expect(container.read(provider).requireValue.nextPage, 4);
      repository.fail = false;
      await container.read(provider.notifier).loadMore();
      expect(repository.pages, [1, 4, 4]);
    },
  );
  test(
    'blocks duplicate requests and ignores an old page after refresh',
    () async {
      await container.read(provider.future);
      repository.pending = Completer<void>();
      final request = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      await container.read(provider.notifier).loadMore();
      expect(repository.pages, [1, 4]);
      await container.refresh(provider.future);
      repository.pending!.complete();
      await request;
      expect(
        container.read(provider).requireValue.items.single.status,
        'running',
      );
      expect(container.read(provider).requireValue.nextPage, 4);
    },
  );
  test('initial failure can be refreshed', () async {
    repository.fail = true;
    await expectLater(container.read(provider.future), throwsStateError);
    repository.fail = false;
    await container.refresh(provider.future);
    expect(repository.pages, [1, 1]);
  });
}
