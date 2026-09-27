import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

/// Group milestones through one authenticated GitLab client.
class GroupMilestonesRepository {
  const GroupMilestonesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<GitLabMilestone>> list(
    int groupId, {
    required String state,
    int page = 1,
  }) => client.groupMilestones.list(groupId, state: state, page: page);

  Future<GitLabMilestone> get(int groupId, int milestoneId) =>
      client.groupMilestones.get(groupId, milestoneId);

  Future<void> delete(int groupId, int milestoneId) =>
      client.groupMilestones.delete(groupId, milestoneId);

  Future<GitLabMilestone> create(
    int groupId, {
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
  }) {
    final wireDate = DateFormat('yyyy-MM-dd');
    return client.groupMilestones.create(
      groupId,
      title: title,
      description: description,
      startDate: startDate == null ? null : wireDate.format(startDate),
      dueDate: dueDate == null ? null : wireDate.format(dueDate),
    );
  }

  Future<GitLabMilestone> update(
    int groupId,
    int milestoneId, {
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? dueDate,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) {
    final wireDate = DateFormat('yyyy-MM-dd');
    return client.groupMilestones.update(
      groupId,
      milestoneId,
      title: title,
      description: description,
      startDate: startDate == null ? null : wireDate.format(startDate),
      dueDate: dueDate == null ? null : wireDate.format(dueDate),
      clearStartDate: clearStartDate,
      clearDueDate: clearDueDate,
    );
  }
}
