import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Discovers only milestones belonging to a release project's direct group.
class ReleaseGroupMilestonesRepository {
  const ReleaseGroupMilestonesRepository(this.client);
  final GitLabClient client;

  Future<int?> getDirectGroupId(int projectId) async {
    final project = await client.projects.get(projectId);
    final namespace = project.namespaceDetails;
    final id = namespace?.id;
    return namespace?.kind == 'group' && id != null && id > 0 ? id : null;
  }

  Future<Paginated<GitLabMilestone>> list(
    int groupId, {
    String search = '',
    int page = 1,
  }) => client.groupMilestones.list(
    groupId,
    search: search.isEmpty ? null : search,
    page: page,
  );
}
