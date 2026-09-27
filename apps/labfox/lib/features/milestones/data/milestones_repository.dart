import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

/// Project milestones through one authenticated GitLab client.
class MilestonesRepository {
  const MilestonesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<GitLabMilestone>> list(
    int projectId, {
    required String state,
    int page = 1,
    bool includeAncestors = false,
  }) => client.milestones.list(
    projectId,
    state: state,
    page: page,
    includeAncestors: includeAncestors,
  );

  Future<GitLabMilestone> get(int projectId, int milestoneId) =>
      client.milestones.get(projectId, milestoneId);

  Future<void> delete(int projectId, int milestoneId) =>
      client.milestones.delete(projectId, milestoneId);

  Future<GitLabMilestone> create(
    int projectId, {
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
  }) {
    final wireDate = DateFormat('yyyy-MM-dd');
    return client.milestones.create(
      projectId,
      title: title,
      description: description,
      startDate: startDate == null ? null : wireDate.format(startDate),
      dueDate: dueDate == null ? null : wireDate.format(dueDate),
    );
  }

  Future<GitLabMilestone> update(
    int projectId,
    int milestoneId, {
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? dueDate,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) {
    final wireDate = DateFormat('yyyy-MM-dd');
    return client.milestones.update(
      projectId,
      milestoneId,
      title: title,
      description: description,
      startDate: startDate == null ? null : wireDate.format(startDate),
      dueDate: dueDate == null ? null : wireDate.format(dueDate),
      clearStartDate: clearStartDate,
      clearDueDate: clearDueDate,
    );
  }

  Future<GitLabMilestone> setStateEvent(
    int projectId,
    int milestoneId, {
    required String stateEvent,
  }) => client.milestones.setStateEvent(
    projectId,
    milestoneId,
    stateEvent: stateEvent,
  );
}
