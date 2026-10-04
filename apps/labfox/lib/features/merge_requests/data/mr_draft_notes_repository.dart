import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Reads private pending review notes using one account-bound client.
class MrDraftNotesRepository {
  MrDraftNotesRepository(this._client, {required this.authorId}) {
    if (authorId < 1) throw ArgumentError.value(authorId, 'authorId');
  }

  final GitLabClient _client;
  final int authorId;

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
