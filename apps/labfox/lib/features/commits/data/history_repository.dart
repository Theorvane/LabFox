import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads branches and commit history for a project.
class HistoryRepository {
  HistoryRepository(this._client);

  final GitLabClient _client;

  Future<Branch> createBranch({
    required int projectId,
    required String name,
    required String ref,
  }) {
    return _client.repository.createBranch(projectId, name: name, ref: ref);
  }

  Future<List<Branch>> branches(int projectId) async {
    final page = await _client.repository.branches(projectId);
    return page.items;
  }

  Future<List<Commit>> commits({
    required int projectId,
    required String ref,
  }) async {
    final page = await _client.repository.commits(projectId, ref: ref);
    return page.items;
  }

  /// Reads the advertised original-diff pages through this captured account.
  /// Null means the caller's origin expired; no partial or obsolete files escape.
  /// The project must be chosen from authoritative context by the caller.
  /// Diff limits and missing metadata mean traversal is not proof of full coverage.
  /// Recheck currency after awaiting; this is not an MR/private-write preflight.
  Future<List<CommitDiffFile>?> originalCommitDiff({
    required int projectId,
    required String commitId,
    required bool Function() isCurrent,
  }) async {
    if (projectId < 1) throw ArgumentError.value(projectId, 'projectId');
    if (commitId.length != 40 || RegExp(r'[^0-9a-f]').hasMatch(commitId)) {
      throw ArgumentError.value(commitId, 'commitId');
    }
    final items = <CommitDiffFile>[];
    final paths = <(String, String)>{};
    int? page = 1;
    while (page != null) {
      if (!isCurrent()) return null;
      final Paginated<CommitDiffFile> result;
      try {
        result = await _client.repository.commitDiffPage(
          projectId,
          commitId: commitId,
          page: page,
          perPage: 100,
        );
      } on GitLabException {
        if (!isCurrent()) return null;
        rethrow;
      }
      if (!isCurrent()) return null;
      if ((result.nextPage != null && result.nextPage! <= page) ||
          result.items.any(
            (file) => !paths.add((file.oldPath, file.newPath)),
          )) {
        throw const GitLabServerException(
          'Invalid original commit diff traversal.',
        );
      }
      items.addAll(result.items);
      page = result.nextPage;
    }
    if (!isCurrent()) return null;
    return List<CommitDiffFile>.unmodifiable(items);
  }

  Future<Commit> commit({required int projectId, required String sha}) {
    return _client.repository.commit(projectId, sha: sha);
  }
}
