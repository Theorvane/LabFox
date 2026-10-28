import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pipeline_schedules_controller.dart';

class PipelineScheduleOwnershipController
    extends FamilyAsyncNotifier<void, PipelineScheduleRef> {
  @override
  void build(PipelineScheduleRef arg) {}

  Future<void> takeOwnership() async {
    if (state.isLoading) {
      throw StateError('Schedule ownership transfer is already pending');
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        pipelineSchedulesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      await repository.takeOwnership(arg.projectId, arg.scheduleId);
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

final pipelineScheduleOwnershipControllerProvider =
    AsyncNotifierProvider.family<
      PipelineScheduleOwnershipController,
      void,
      PipelineScheduleRef
    >(PipelineScheduleOwnershipController.new);
