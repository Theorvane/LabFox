import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads the file diffs for a commit or a merge request.
class DiffRepository {
  DiffRepository(this._client);

  final GitLabClient _client;

  Future<List<FileDiff>> commitDiff({
    required int projectId,
    required String sha,
  }) {
    return _client.repository.commitDiff(projectId, sha: sha);
  }

  Future<Paginated<MergeRequestDiffVersion>> mergeRequestDiffVersions({
    required int projectId,
    required int iid,
    int page = 1,
  }) => _client.mergeRequests.diffVersions(projectId, iid: iid, page: page);

  Future<MergeRequestDiffVersion> mergeRequestDiffVersion({
    required int projectId,
    required int iid,
    required int versionId,
  }) => _client.mergeRequests.diffVersion(
    projectId,
    iid: iid,
    versionId: versionId,
  );

  Future<List<FileDiff>> mergeRequestDiff({
    required int projectId,
    required int iid,
  }) {
    return _client.mergeRequests.diffs(projectId, iid: iid);
  }
}
