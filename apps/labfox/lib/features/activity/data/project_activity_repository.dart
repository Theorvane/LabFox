import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only activity for one project through its authenticated GitLab client.
class ProjectActivityRepository {
  const ProjectActivityRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProjectEvent>> list(
    int projectId, {
    String? targetType,
    int page = 1,
  }) =>
      client.events.listProject(projectId, targetType: targetType, page: page);
}
