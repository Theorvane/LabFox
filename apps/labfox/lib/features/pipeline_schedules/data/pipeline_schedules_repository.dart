import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Authenticated project pipeline schedule access.
class PipelineSchedulesRepository {
  const PipelineSchedulesRepository(this.client);

  final GitLabClient client;

  Future<PipelineSchedule> create(
    int projectId, {
    required String description,
    required String ref,
    required String cron,
    String? cronTimezone,
    bool active = true,
  }) => client.pipelineSchedules.create(
    projectId,
    description: description,
    ref: ref,
    cron: cron,
    cronTimezone: cronTimezone,
    active: active,
  );

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

  Future<PipelineSchedule> takeOwnership(int projectId, int scheduleId) =>
      client.pipelineSchedules.takeOwnership(projectId, scheduleId);

  Future<void> play(int projectId, int scheduleId) =>
      client.pipelineSchedules.play(projectId, scheduleId);

  Future<void> delete(int projectId, int scheduleId) =>
      client.pipelineSchedules.delete(projectId, scheduleId);

  Future<PipelineSchedule> update(
    int projectId,
    int scheduleId, {
    String? description,
    String? cron,
    String? cronTimezone,
  }) => client.pipelineSchedules.update(
    projectId,
    scheduleId,
    description: description,
    cron: cron,
    cronTimezone: cronTimezone,
  );
}
