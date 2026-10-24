import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// A group and the currently loaded pages of its direct children.
class GroupOverview {
  const GroupOverview({
    required this.group,
    required this.projects,
    required this.subgroups,
  });

  final Group group;
  final Paginated<Project> projects;
  final Paginated<Group> subgroups;

  GroupOverview withProjects(Paginated<Project> value) =>
      GroupOverview(group: group, projects: value, subgroups: subgroups);

  GroupOverview withSubgroups(Paginated<Group> value) =>
      GroupOverview(group: group, projects: projects, subgroups: value);
}
