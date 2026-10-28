import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Effective project membership from one authenticated GitLab client.
class ProjectMembersRepository {
  const ProjectMembersRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProjectMember>> list(
    int projectId, {
    String? query,
    int page = 1,
  }) => client.projectMembers.list(projectId, query: query, page: page);
}
