import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipeline_schedules/data/pipeline_schedules_repository.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedule_history_controller.dart';
import 'package:labfox/features/pipeline_schedules/presentation/controllers/pipeline_schedules_controller.dart';

class _Repository extends PipelineSchedulesRepository {
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
  Future<Paginated<Pipeline>> listPipelines(
    int projectId,
    int scheduleId, {
    int page = 1,
  }) async {
    expect(projectId, 7);
    expect(scheduleId, 13);
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
  const key = PipelineScheduleRef(projectId: 7, scheduleId: 13);
  final provider = pipelineScheduleHistoryControllerProvider(key);
  late _Repository repository;
  late ProviderContainer container;
  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [
        pipelineSchedulesRepositoryProvider.overrideWith(
          (_) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());

  test(
    'uses server cursor, deduplicates by id and stops at last page',
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
  test('failed next page retains rows and cursor for a real retry', () async {
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
  });
  test('initial failure can be retried by refreshing', () async {
    repository.fail = true;
    await expectLater(container.read(provider.future), throwsStateError);
    repository.fail = false;
    await container.refresh(provider.future);
    expect(repository.pages, [1, 1]);
    expect(container.read(provider).hasValue, true);
  });
  test('blocks duplicate next-page requests', () async {
    await container.read(provider.future);
    repository.pending = Completer<void>();
    final request = container.read(provider.notifier).loadMore();
    await Future<void>.delayed(Duration.zero);
    await container.read(provider.notifier).loadMore();
    expect(repository.pages, [1, 4]);
    repository.pending!.complete();
    await request;
  });
  test(
    'a late next page cannot overwrite refreshed first-page history',
    () async {
      await container.read(provider.future);
      repository.pending = Completer<void>();
      final request = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      await container.refresh(provider.future);
      repository.pending!.complete();
      await request;
      expect(repository.pages, [1, 4, 1]);
      expect(
        container.read(provider).requireValue.items.single.status,
        'running',
      );
      expect(container.read(provider).requireValue.nextPage, 4);
    },
  );
}
