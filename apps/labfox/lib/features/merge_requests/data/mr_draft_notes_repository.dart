import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Reads and modifies private review notes using one account-bound client.
class MrDraftNotesRepository {
  MrDraftNotesRepository(this._client, {required this.authorId}) {
    if (authorId < 1) throw ArgumentError.value(authorId, 'authorId');
  }

  final GitLabClient _client;
  final int authorId;

  /// Requires the authoritative global MR ID separately from its route IID.
  /// A caller still checks session/resource freshness before and after dispatch.
  Future<MergeRequestDraftNote> create({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String note,
    DiffNotePosition? position,
  }) async {
    if (mergeRequestId < 1) {
      throw ArgumentError.value(mergeRequestId, 'mergeRequestId');
    }
    final draft = await _client.mergeRequests.createDraftNote(
      projectId,
      iid: iid,
      note: note,
      position: position,
    );
    if (draft.authorId != authorId || draft.mergeRequestId != mergeRequestId) {
      throw const GitLabServerException(
        'Invalid draft note creation identity.',
      );
    }
    return draft;
  }

  /// Saves a text-positioned commit draft through the captured client/author.
  /// Callers must verify commit membership and session/resource freshness;
  /// this foundation neither reserves controller writes nor recovers failures.
  Future<MergeRequestDraftNote> createCommit({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String commitId,
    required String note,
    required DiffNotePosition position,
  }) async {
    if (mergeRequestId < 1) {
      throw ArgumentError.value(mergeRequestId, 'mergeRequestId');
    }
    final draft = await _client.mergeRequests.createCommitDraftNote(
      projectId,
      iid: iid,
      commitId: commitId,
      note: note,
      position: position,
    );
    if (draft.authorId != authorId || draft.mergeRequestId != mergeRequestId) {
      throw const GitLabServerException(
        'Invalid private commit draft identity.',
      );
    }
    return draft;
  }

  /// Saves a reply through the same captured author and authoritative MR.
  Future<MergeRequestDraftNote> createReply({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required String discussionId,
    required String note,
  }) async {
    if (mergeRequestId < 1) {
      throw ArgumentError.value(mergeRequestId, 'mergeRequestId');
    }
    final draft = await _client.mergeRequests.createDraftReply(
      projectId,
      iid: iid,
      discussionId: discussionId,
      note: note,
    );
    if (draft.authorId != authorId || draft.mergeRequestId != mergeRequestId) {
      throw const GitLabServerException('Invalid private reply identity.');
    }
    return draft;
  }

  /// The selected draft and authoritative global MR ID must still be current.
  /// Preserves original text anchors and confirms unchanged non-body metadata.
  Future<MergeRequestDraftNote> update({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
    required String note,
  }) async {
    _validateTarget(draft, mergeRequestId);
    final position = _positionForUpdate(draft);
    final updated = await _client.mergeRequests.updateDraftNote(
      projectId,
      iid: iid,
      draftNoteId: draft.id,
      note: note,
      position: position,
    );
    // The API confirms the exact body/target and semantic original position.
    // Other modeled metadata, including unknown values, must not change unexpectedly.
    if (updated.copyWith(note: draft.note, position: draft.position) != draft) {
      throw const GitLabServerException(
        'Invalid draft note update identity or metadata.',
      );
    }
    return updated;
  }

  /// Validates captured ownership/global identity before one private delete.
  /// A 204 acknowledges the route; it is not a durable or atomic review snapshot.
  Future<void> delete({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
  }) async {
    _validateTarget(draft, mergeRequestId);
    await _client.mergeRequests.deleteDraftNote(
      projectId,
      iid: iid,
      draftNoteId: draft.id,
    );
  }

  /// Publishes one captured owned target without reconstructing its position.
  /// Fresh target confirmation belongs to the shared discussion controller.
  Future<void> publishNote({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    required MergeRequestDraftNote draft,
  }) async {
    _validateTarget(draft, mergeRequestId);
    await _client.mergeRequests.publishDraftNote(
      projectId,
      iid: iid,
      draftNoteId: draft.id,
    );
  }

  /// Publishes the captured account's entire pending review in one request.
  /// The controller confirms a complete fresh snapshot before dispatch.
  Future<void> publish({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    String? summaryNote,
    ReviewerSubmissionState? reviewerState,
  }) async {
    if (mergeRequestId < 1) {
      throw ArgumentError.value(mergeRequestId, 'mergeRequestId');
    }
    await _client.mergeRequests.publishDraftNotes(
      projectId,
      iid: iid,
      summaryNote: summaryNote,
      reviewerState: reviewerState,
    );
  }

  /// Captures reviewer reads on the same authenticated client as publication.
  Future<Paginated<MergeRequestReviewer>> reviewers({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) => _client.mergeRequests.reviewers(
    projectId,
    iid: iid,
    page: page,
    perPage: perPage,
  );

  /// Only regular drafts and complete original text anchors can be edited.
  static bool canUpdate(MergeRequestDraftNote draft) {
    try {
      final position = _positionForUpdate(draft);
      return position == null || validTextDiscussionPosition(position);
    } on ArgumentError {
      return false;
    }
  }

  void _validateTarget(MergeRequestDraftNote draft, int mergeRequestId) {
    if (mergeRequestId < 1 ||
        draft.id < 1 ||
        draft.authorId != authorId ||
        draft.mergeRequestId != mergeRequestId) {
      throw ArgumentError(
        'A current owned draft and global MR identity are required.',
        'draft',
      );
    }
  }

  static DiffNotePosition? _positionForUpdate(MergeRequestDraftNote draft) {
    final p = draft.position;
    final regular =
        p == null ||
        ((p.positionType == null || p.positionType == 'text') &&
            [
              p.baseSha,
              p.startSha,
              p.headSha,
              p.oldPath,
              p.newPath,
              p.oldLine,
              p.newLine,
              p.lineRange,
              p.width,
              p.height,
              p.x,
              p.y,
            ].every((field) => field == null));
    if (regular) {
      if (draft.lineCode != null) {
        throw ArgumentError(
          'The original draft position is unavailable.',
          'draft',
        );
      }
      return null;
    }
    // The API rejects incomplete, image/file/future anchors before dispatch.
    return p;
  }

  Future<Paginated<MergeRequestDraftNote>> list({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    final pageResult = await _client.mergeRequests.draftNotes(
      projectId,
      iid: iid,
      page: page,
      perPage: perPage,
    );
    if (pageResult.items.any((draft) => draft.authorId != authorId)) {
      throw const GitLabServerException('Invalid draft notes ownership.');
    }
    return pageResult;
  }
}
