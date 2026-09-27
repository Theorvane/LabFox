import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads a project's issues and single issues.
class IssuesRepository {
  IssuesRepository(this._client);

  final GitLabClient _client;

  Future<List<Issue>> list({
    required int projectId,
    required IssueState state,
    String? search,
  }) async {
    final page = await _client.issues.list(
      projectId,
      state: state,
      search: search,
    );
    return page.items;
  }

  /// The current user's issues across every project, by scope.
  Future<List<Issue>> listMine({
    required IssueScope scope,
    required IssueState state,
  }) async {
    final page = await _client.issues.listMine(scope: scope, state: state);
    return page.items;
  }

  Future<Issue> get({required int projectId, required int iid}) {
    return _client.issues.get(projectId, iid: iid);
  }

  Future<Issue> create({
    required int projectId,
    required String title,
    String? description,
  }) {
    return _client.issues.create(
      projectId,
      title: title,
      description: description,
    );
  }

  Future<Issue> setOpen({
    required int projectId,
    required int iid,
    required bool open,
  }) {
    return _client.issues.setOpen(projectId, iid: iid, open: open);
  }

  Future<Issue> update({
    required int projectId,
    required int iid,
    required String title,
    required String description,
  }) {
    return _client.issues.update(
      projectId,
      iid: iid,
      title: title,
      description: description,
    );
  }
}
