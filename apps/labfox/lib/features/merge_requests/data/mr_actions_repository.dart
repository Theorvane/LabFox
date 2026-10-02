import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Approve, unapprove, and merge actions for a merge request.
class MrActionsRepository {
  MrActionsRepository(this._client);

  final GitLabClient _client;

  Future<MergeRequestApprovals?> approvals({
    required int projectId,
    required int iid,
  }) async {
    try {
      return await _client.mergeRequests.approvals(projectId, iid: iid);
    } on GitLabNotFoundException {
      // Approvals are not available on every plan or instance. Treat their
      // absence as "no approval info" rather than failing the whole screen.
      return null;
    }
  }

  Future<void> approve({required int projectId, required int iid}) =>
      _client.mergeRequests.approve(projectId, iid: iid);

  Future<void> unapprove({required int projectId, required int iid}) =>
      _client.mergeRequests.unapprove(projectId, iid: iid);

  Future<MergeRequest> merge({
    required int projectId,
    required int iid,
    bool squash = false,
  }) => _client.mergeRequests.merge(projectId, iid: iid, squash: squash);

  Future<MergeRequest> setOpen({
    required int projectId,
    required int iid,
    required bool open,
  }) => _client.mergeRequests.setOpen(projectId, iid: iid, open: open);

  Future<MergeRequest> setDraft({
    required int projectId,
    required int iid,
    required bool draft,
    required String title,
  }) => _client.mergeRequests.setDraft(
    projectId,
    iid: iid,
    draft: draft,
    title: title,
  );

  Future<void> rebase({required int projectId, required int iid}) =>
      _client.mergeRequests.rebase(projectId, iid: iid);

  Future<MergeRequest?> setSubscription({
    required int projectId,
    required int iid,
    required bool subscribed,
  }) => _client.mergeRequests.setSubscription(
    projectId,
    iid: iid,
    subscribed: subscribed,
  );

  Future<Todo?> createTodo({required int projectId, required int iid}) =>
      _client.mergeRequests.createTodo(projectId, iid: iid);
}
