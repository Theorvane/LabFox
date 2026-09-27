import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Reads pages from a project's wiki.
class WikiRepository {
  WikiRepository(this._client);

  final GitLabClient _client;

  Future<List<WikiPage>> pages(int projectId) => _client.wikis.list(projectId);

  Future<WikiPage> page(int projectId, String slug) =>
      _client.wikis.get(projectId, slug);

  Future<WikiPage> create(
    int projectId, {
    required String title,
    required String content,
  }) => _client.wikis.create(projectId, title: title, content: content);
}
