import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'pipeline_schedules_controller.dart';

class PipelineScheduleCreateController extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<PipelineSchedule> create({
    required String description,
    required String ref,
    required String cron,
    String? cronTimezone,
    bool active = true,
  }) async {
    if (state.isLoading) {
      throw StateError('Schedule creation is already pending');
    }
    state = const AsyncLoading();
    try {
      final repository = await this.ref.read(
        pipelineSchedulesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final schedule = await repository.create(
        arg,
        description: description,
        ref: ref,
        cron: cron,
        cronTimezone: cronTimezone,
        active: active,
      );
      for (final filter in <bool?>[null, true, false]) {
        this.ref.invalidate(
          pipelineScheduleListControllerProvider(
            PipelineScheduleListRef(projectId: arg, active: filter),
          ),
        );
      }
      state = const AsyncData(null);
      return schedule;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final pipelineScheduleCreateControllerProvider =
    AsyncNotifierProvider.family<PipelineScheduleCreateController, void, int>(
      PipelineScheduleCreateController.new,
    );
