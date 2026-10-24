import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'group_overview.dart';

/// Loads a group and the first page of its direct children.
class GroupDetailRepository {
  GroupDetailRepository(this._client);

  final GitLabClient _client;

  Future<GroupOverview> load(int groupId) async => GroupOverview(
    group: await _client.groups.get(groupId),
    projects: await projectsPage(groupId),
    subgroups: await subgroupsPage(groupId),
  );

  Future<Paginated<Project>> projectsPage(int groupId, {int page = 1}) =>
      _client.groups.listProjects(groupId: groupId, page: page);

  Future<Paginated<Group>> subgroupsPage(int groupId, {int page = 1}) =>
      _client.groups.listSubgroups(groupId: groupId, page: page);
}
