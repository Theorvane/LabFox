import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'pipeline_schedules_controller.dart';

/// Schedule-specific execution history with retryable header pagination.
class PipelineScheduleHistoryController
    extends FamilyAsyncNotifier<Paginated<Pipeline>, PipelineScheduleRef> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<Paginated<Pipeline>> build(PipelineScheduleRef arg) async {
    _generation++;
    _loadingMore = false;
    final repository = await ref.watch(
      pipelineSchedulesRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.listPipelines(arg.projectId, arg.scheduleId);
  }

  Future<void> loadMore() async {
    if (_loadingMore || state.isLoading) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    final generation = _generation;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        pipelineSchedulesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.listPipelines(
        arg.projectId,
        arg.scheduleId,
        page: page,
      );
      if (generation != _generation) return;
      final items = {for (final item in current.items) item.id: item};
      for (final item in next.items) {
        items[item.id] = item;
      }
      state = AsyncData(
        Paginated(
          items: items.values.toList(growable: false),
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } finally {
      // A rejected page leaves the current rows/cursor intact; the UI offers retry.
      if (generation == _generation) _loadingMore = false;
    }
  }
}

final pipelineScheduleHistoryControllerProvider =
    AsyncNotifierProvider.family<
      PipelineScheduleHistoryController,
      Paginated<Pipeline>,
      PipelineScheduleRef
    >(PipelineScheduleHistoryController.new);
