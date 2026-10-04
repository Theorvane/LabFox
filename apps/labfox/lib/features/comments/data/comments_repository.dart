import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads and posts comments on an issue or merge request.
class CommentsRepository {
  CommentsRepository(this._client);

  final GitLabClient _client;

  Future<List<Note>> list({
    required NoteableType type,
    required int projectId,
    required int iid,
  }) {
    return _client.notes.list(type, projectId: projectId, iid: iid);
  }

  Future<Paginated<Discussion>> discussions({
    required int projectId,
    required int iid,
    int page = 1,
  }) => _client.mergeRequests.discussions(projectId, iid: iid, page: page);

  Future<Note> replyToDiscussion({
    required int projectId,
    required int iid,
    required String discussionId,
    required String body,
  }) => _client.mergeRequests.replyToDiscussion(
    projectId,
    iid: iid,
    discussionId: discussionId,
    body: body,
  );

  Future<Note> post({
    required NoteableType type,
    required int projectId,
    required int iid,
    required String body,
  }) {
    return _client.notes.create(
      type,
      projectId: projectId,
      iid: iid,
      body: body,
    );
  }
}
