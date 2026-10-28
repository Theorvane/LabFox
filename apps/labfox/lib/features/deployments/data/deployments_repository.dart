import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only project deployments through one authenticated GitLab client.
class DeploymentsRepository {
  const DeploymentsRepository(this.client);

  final GitLabClient client;

  Future<Paginated<GitLabDeployment>> list(
    int projectId, {
    String? environment,
    String? status,
    int page = 1,
  }) => client.deployments.list(
    projectId,
    environment: environment,
    status: status,
    page: page,
  );

  Future<GitLabDeployment> get(int projectId, int deploymentId) =>
      client.deployments.get(projectId, deploymentId);
}
