import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pipeline_schedules_controller.dart';

class PipelineScheduleExecutionController
    extends FamilyAsyncNotifier<void, PipelineScheduleRef> {
  @override
  void build(PipelineScheduleRef arg) {}

  Future<void> save({String? ref, bool? active}) async {
    if (ref == null && active == null) return;
    if (state.isLoading) {
      throw StateError('Execution settings update is already pending');
    }
    state = const AsyncLoading();
    try {
      final repository = await this.ref.read(
        pipelineSchedulesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      await repository.updateExecution(
        arg.projectId,
        arg.scheduleId,
        ref: ref,
        active: active,
      );
      this.ref.invalidate(pipelineScheduleDetailProvider(arg));
      for (final filter in <bool?>[null, true, false]) {
        this.ref.invalidate(
          pipelineScheduleListControllerProvider(
            PipelineScheduleListRef(projectId: arg.projectId, active: filter),
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

final pipelineScheduleExecutionControllerProvider =
    AsyncNotifierProvider.family<
      PipelineScheduleExecutionController,
      void,
      PipelineScheduleRef
    >(PipelineScheduleExecutionController.new);
