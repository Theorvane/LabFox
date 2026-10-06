import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads a project's merge requests and single merge requests.
class MergeRequestsRepository {
  MergeRequestsRepository(this._client);

  final GitLabClient _client;

  Future<List<MergeRequest>> list({
    required int projectId,
    required MergeRequestState state,
    String? search,
  }) async {
    final page = await _client.mergeRequests.list(
      projectId,
      state: state,
      search: search,
    );
    return page.items;
  }

  /// The current user's merge requests across every project, by scope.
  Future<List<MergeRequest>> listMine({
    required MergeRequestScope scope,
    required MergeRequestState state,
  }) async {
    final page = await _client.mergeRequests.listMine(
      scope: scope,
      state: state,
    );
    return page.items;
  }

  /// Open merge requests where [username] is a requested reviewer.
  Future<List<MergeRequest>> listForReview(
    String username, {
    required MergeRequestState state,
  }) async {
    final page = await _client.mergeRequests.listForReview(
      username,
      state: state,
    );
    return page.items;
  }

  /// Reads every advertised MR commit page through this captured account client.
  /// Null means the caller's origin/session guard expired; no partial list escapes.
  /// Callers still recheck currency after awaiting and refresh authoritative MR
  /// identity and original diff membership before any subsequent private write.
  Future<List<Commit>?> commits({
    required int projectId,
    required int iid,
    required bool Function() isCurrent,
  }) async {
    if (projectId < 1) throw ArgumentError.value(projectId, 'projectId');
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    final items = <Commit>[];
    final ids = <String>{};
    int? page = 1;
    while (page != null) {
      if (!isCurrent()) return null;
      final Paginated<Commit> result;
      try {
        result = await _client.mergeRequests.commits(
          projectId,
          iid: iid,
          page: page,
          perPage: 100,
        );
      } on GitLabException {
        if (!isCurrent()) return null;
        rethrow;
      }
      if (!isCurrent()) return null;
      if ((result.nextPage != null && result.nextPage! <= page) ||
          result.items.any((commit) => !ids.add(commit.id))) {
        throw const GitLabServerException('Invalid MR commit traversal.');
      }
      items.addAll(result.items);
      page = result.nextPage;
    }
    if (!isCurrent()) return null;
    return List<Commit>.unmodifiable(items);
  }

  Future<MergeRequest> get({required int projectId, required int iid}) {
    return _client.mergeRequests.get(projectId, iid: iid);
  }

  Future<MergeRequest> create({
    required int projectId,
    required String sourceBranch,
    required String targetBranch,
    required String title,
    String? description,
  }) {
    return _client.mergeRequests.create(
      projectId,
      sourceBranch: sourceBranch,
      targetBranch: targetBranch,
      title: title,
      description: description,
    );
  }
}
