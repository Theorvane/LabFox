import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Reads and saves private review notes using one account-bound client.
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
