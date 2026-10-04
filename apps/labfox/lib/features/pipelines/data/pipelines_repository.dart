import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads pipelines and their jobs for a project.
class PipelinesRepository {
  PipelinesRepository(this._client);

  final GitLabClient _client;

  Future<Paginated<Pipeline>> list(
    int projectId, {
    int page = 1,
    PipelineStatusFilter? status,
    String? ref,
    PipelineSourceFilter? source,
  }) => _client.pipelines.list(
    projectId,
    page: page,
    status: status,
    ref: ref,
    source: source,
  );

  Future<Paginated<PipelineTriggerJob>> triggerJobs({
    required int projectId,
    required int pipelineId,
    int page = 1,
  }) => _client.pipelines.triggerJobs(
    projectId,
    pipelineId: pipelineId,
    page: page,
  );

  Future<PipelineUpstream?> upstream({
    required int projectId,
    required int pipelineId,
  }) async {
    if (projectId <= 0 || pipelineId <= 0) {
      throw ArgumentError('Positive source IDs are required');
    }
    try {
      final project = await _client.projects.get(projectId);
      if (project.id != projectId || project.pathWithNamespace.trim().isEmpty) {
        throw const GitLabServerException('Invalid source project identity');
      }
      return _client.pipelineRelations.upstream(
        project.pathWithNamespace,
        projectId: projectId,
        pipelineId: pipelineId,
      );
    } on TypeError {
      throw const GitLabServerException('Invalid source project response');
    } on FormatException {
      throw const GitLabServerException('Invalid source project response');
    }
  }

  Future<Pipeline> get({required int projectId, required int pipelineId}) {
    return _client.pipelines.get(projectId, pipelineId: pipelineId);
  }

  Future<List<Job>> jobs({
    required int projectId,
    required int pipelineId,
    PipelineJobStatusFilter? status,
  }) {
    return _client.pipelines.jobs(
      projectId,
      pipelineId: pipelineId,
      status: status,
    );
  }

  Future<Pipeline> retry({required int projectId, required int pipelineId}) =>
      _client.pipelines.retry(projectId, pipelineId: pipelineId);

  Future<Pipeline> cancel({required int projectId, required int pipelineId}) =>
      _client.pipelines.cancel(projectId, pipelineId: pipelineId);
}
