import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Authenticated project pipeline schedule access.
class PipelineSchedulesRepository {
  const PipelineSchedulesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<Pipeline>> listPipelines(
    int projectId,
    int scheduleId, {
    int page = 1,
  }) =>
      client.pipelineSchedules.listPipelines(projectId, scheduleId, page: page);

  Future<Paginated<PipelineSchedule>> list(
    int projectId, {
    bool? active,
    int page = 1,
  }) => client.pipelineSchedules.list(projectId, active: active, page: page);

  Future<PipelineSchedule> get(int projectId, int scheduleId) =>
      client.pipelineSchedules.get(projectId, scheduleId);

  Future<void> play(int projectId, int scheduleId) =>
      client.pipelineSchedules.play(projectId, scheduleId);
}
