import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../commits/data/history_repository.dart';

/// A read aggregate of existing DTOs, without inferred original coordinates.
typedef MrOriginalCommitContext = ({
  MergeRequest mergeRequest,
  Commit commit,
  List<CommitDiffFile> files,
});

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

  /// Refreshes MR identity through this captured account before commit review.
  /// Requires the known global MR ID and a reported target project; omitted
  /// source metadata stays unknown. Null means the caller's origin expired.
  /// Callers recheck currency after awaiting and separately validate membership,
  /// commit availability and original references before any private write.
  Future<MergeRequest?> commitReviewContext({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required bool Function() isCurrent,
  }) async {
    if (projectId < 1) throw ArgumentError.value(projectId, 'projectId');
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (mergeRequestId < 1) {
      throw ArgumentError.value(mergeRequestId, 'mergeRequestId');
    }
    if (!isCurrent()) return null;
    final MergeRequest result;
    try {
      result = await _client.mergeRequests.get(projectId, iid: iid);
    } on GitLabException {
      if (!isCurrent()) return null;
      rethrow;
    }
    if (!isCurrent()) return null;
    if (result.id != mergeRequestId || result.targetProjectId != projectId) {
      throw const GitLabServerException('Invalid MR commit review context.');
    }
    if (!isCurrent()) return null;
    return result;
  }

  /// Combines literal original commit reads through one captured account.
  /// Reconfirms MR origin and membership after fetching the target commit/diff.
  /// Null means the caller's origin expired. Sequential reads are not atomic;
  /// callers recheck currency and original coordinates before private writes.
  Future<MrOriginalCommitContext?> originalCommitContext({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String commitId,
    required bool Function() isCurrent,
  }) async {
    if (projectId < 1) throw ArgumentError.value(projectId, 'projectId');
    if (iid < 1) throw ArgumentError.value(iid, 'iid');
    if (mergeRequestId < 1) {
      throw ArgumentError.value(mergeRequestId, 'mergeRequestId');
    }
    if (commitId.length != 40 || RegExp(r'[^0-9a-f]').hasMatch(commitId)) {
      throw ArgumentError.value(commitId, 'commitId');
    }
    if (!isCurrent()) return null;
    final history = HistoryRepository(_client);
    try {
      final initial = await commitReviewContext(
        projectId: projectId,
        iid: iid,
        mergeRequestId: mergeRequestId,
        isCurrent: isCurrent,
      );
      if (initial == null || !isCurrent()) return null;
      final members = await commits(
        projectId: projectId,
        iid: iid,
        isCurrent: isCurrent,
      );
      if (members == null || !isCurrent()) return null;
      final member = _selectedMember(members, commitId);
      final selected = await history.originalCommit(
        projectId: initial.targetProjectId!,
        commitId: commitId,
        isCurrent: isCurrent,
      );
      if (selected == null || !isCurrent()) return null;
      _confirmReportedParents(member, selected);
      final files = await history.originalCommitDiff(
        projectId: initial.targetProjectId!,
        commitId: commitId,
        isCurrent: isCurrent,
      );
      if (files == null || !isCurrent()) return null;
      final refreshed = await commitReviewContext(
        projectId: projectId,
        iid: iid,
        mergeRequestId: mergeRequestId,
        isCurrent: isCurrent,
      );
      if (refreshed == null || !isCurrent()) return null;
      if (initial.sourceProjectId != refreshed.sourceProjectId ||
          initial.targetProjectId != refreshed.targetProjectId ||
          initial.sourceBranch != refreshed.sourceBranch ||
          initial.targetBranch != refreshed.targetBranch) {
        throw const GitLabConflictException(
          'The MR commit origin changed. Reload before continuing.',
        );
      }
      final confirmedMembers = await commits(
        projectId: projectId,
        iid: iid,
        isCurrent: isCurrent,
      );
      if (confirmedMembers == null || !isCurrent()) return null;
      _confirmReportedParents(
        _selectedMember(confirmedMembers, commitId),
        selected,
      );
      if (!isCurrent()) return null;
      return (mergeRequest: refreshed, commit: selected, files: files);
    } on GitLabException {
      if (!isCurrent()) return null;
      rethrow;
    }
  }

  static Commit _selectedMember(List<Commit> members, String commitId) {
    for (final member in members) {
      if (member.id == commitId) return member;
    }
    throw const GitLabConflictException(
      'The selected commit is no longer in the MR. Reload before continuing.',
    );
  }

  static void _confirmReportedParents(Commit member, Commit selected) {
    final reported = member.parentIds, authoritative = selected.parentIds;
    if (reported == null || authoritative == null) return;
    if (reported.length != authoritative.length ||
        Iterable<int>.generate(
          reported.length,
        ).any((i) => reported[i] != authoritative[i])) {
      throw const GitLabServerException(
        'Inconsistent original commit parents.',
      );
    }
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
