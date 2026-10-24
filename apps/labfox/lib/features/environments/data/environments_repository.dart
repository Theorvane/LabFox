import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only project environments through one authenticated GitLab client.
class EnvironmentsRepository {
  const EnvironmentsRepository(this.client);

  final GitLabClient client;

  Future<Paginated<GitLabEnvironment>> list(
    int projectId, {
    String? state,
    String? search,
    int page = 1,
  }) => client.environments.list(
    projectId,
    state: state,
    search: search,
    page: page,
  );

  Future<GitLabEnvironment> get(int projectId, int environmentId) =>
      client.environments.get(projectId, environmentId);
}
