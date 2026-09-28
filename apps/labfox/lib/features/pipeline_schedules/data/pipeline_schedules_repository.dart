import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Authenticated project pipeline schedule access.
class PipelineSchedulesRepository {
  const PipelineSchedulesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) => client.pipelineSchedules.list(projectId, active: active, page: page);

  Future<PipelineSchedule> get(int projectId, int scheduleId) =>
      client.pipelineSchedules.get(projectId, scheduleId);

  Future<PipelineSchedule> updateExecution(
    int projectId,
    int scheduleId, {
    String? ref,
    bool? active,
  }) => client.pipelineSchedules.updateExecution(
    projectId,
    scheduleId,
    ref: ref,
    active: active,
  );

  Future<void> play(int projectId, int scheduleId) =>
      client.pipelineSchedules.play(projectId, scheduleId);
}
