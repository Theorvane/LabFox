import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Effective group membership from one authenticated GitLab client.
class GroupMembersRepository {
  const GroupMembersRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProjectMember>> list(
    int groupId, {
    String? query,
    int page = 1,
  }) => client.groupMembers.list(groupId, query: query, page: page);
}
