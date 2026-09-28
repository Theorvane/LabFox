import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/pipeline_schedules_repository.dart';
import 'pipeline_schedule_history_controller.dart';

final pipelineSchedulesRepositoryProvider =
    FutureProvider<PipelineSchedulesRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : PipelineSchedulesRepository(client);
    });

class PipelineScheduleListRef {
  const PipelineScheduleListRef({required this.projectId, this.active});
  final int projectId;
  final bool? active;

  @override
  bool operator ==(Object other) =>
      other is PipelineScheduleListRef &&
      projectId == other.projectId &&
      active == other.active;

  @override
  int get hashCode => Object.hash(projectId, active);
}

class PipelineScheduleRef {
  const PipelineScheduleRef({
    required this.projectId,
    required this.scheduleId,
  });
  final int projectId;
  final int scheduleId;

  @override
  bool operator ==(Object other) =>
      other is PipelineScheduleRef &&
      projectId == other.projectId &&
      scheduleId == other.scheduleId;

  @override
  int get hashCode => Object.hash(projectId, scheduleId);
}

class PipelineScheduleListController
    extends
        FamilyAsyncNotifier<
          Paginated<PipelineSchedule>,
          PipelineScheduleListRef
        > {
  bool _loadingMore = false;

  @override
  Future<Paginated<PipelineSchedule>> build(PipelineScheduleListRef arg) async {
    final repository = await ref.watch(
      pipelineSchedulesRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(arg.projectId, active: arg.active);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        pipelineSchedulesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.projectId,
        active: arg.active,
        page: page,
      );
      state = AsyncData(
        Paginated(
          items: [...current.items, ...next.items],
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _loadingMore = false;
    }
  }
}

final pipelineScheduleListControllerProvider =
    AsyncNotifierProvider.family<
      PipelineScheduleListController,
      Paginated<PipelineSchedule>,
      PipelineScheduleListRef
    >(PipelineScheduleListController.new);

final pipelineScheduleDetailProvider =
    FutureProvider.family<PipelineSchedule, PipelineScheduleRef>((
      ref,
      key,
    ) async {
      final repository = await ref.watch(
        pipelineSchedulesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.scheduleId);
    });

class PipelineScheduleActionController
    extends FamilyAsyncNotifier<void, PipelineScheduleRef> {
  @override
  Future<void> build(PipelineScheduleRef arg) async {}

  Future<void> play() async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        pipelineSchedulesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      await repository.play(arg.projectId, arg.scheduleId);
      ref.invalidate(pipelineScheduleHistoryControllerProvider(arg));
      ref.invalidate(pipelineScheduleDetailProvider(arg));
      for (final active in <bool?>[null, true, false]) {
        ref.invalidate(
          pipelineScheduleListControllerProvider(
            PipelineScheduleListRef(projectId: arg.projectId, active: active),
          ),
        );
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final pipelineScheduleActionControllerProvider =
    AsyncNotifierProvider.family<
      PipelineScheduleActionController,
      void,
      PipelineScheduleRef
    >(PipelineScheduleActionController.new);
