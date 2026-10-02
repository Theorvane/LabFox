import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads pipelines and their jobs for a project.
class PipelinesRepository {
  PipelinesRepository(this._client);

  final GitLabClient _client;

  Future<Paginated<Pipeline>> list(int projectId, {int page = 1}) =>
      _client.pipelines.list(projectId, page: page);

  Future<Pipeline> get({required int projectId, required int pipelineId}) {
    return _client.pipelines.get(projectId, pipelineId: pipelineId);
  }

  Future<List<Job>> jobs({required int projectId, required int pipelineId}) {
    return _client.pipelines.jobs(projectId, pipelineId: pipelineId);
  }

  Future<Pipeline> retry({required int projectId, required int pipelineId}) =>
      _client.pipelines.retry(projectId, pipelineId: pipelineId);

  Future<Pipeline> cancel({required int projectId, required int pipelineId}) =>
      _client.pipelines.cancel(projectId, pipelineId: pipelineId);
}
