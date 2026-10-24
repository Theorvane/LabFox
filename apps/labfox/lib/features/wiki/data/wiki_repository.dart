import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// The draft was based on a page that has since changed on the server.
class WikiEditConflictException implements Exception {
  const WikiEditConflictException();
}

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

  /// Best-effort stale-page check before GitLab's unconditional delete.
  Future<void> delete({
    required int projectId,
    required WikiPage original,
  }) async {
    final latest = await page(projectId, original.slug);
    if (latest.title != original.title ||
        latest.content != original.content ||
        latest.format != original.format) {
      throw const WikiEditConflictException();
    }
    await _client.wikis.delete(projectId, original.slug);
  }

  /// Best-effort stale-draft check before GitLab's unconditional wiki update.
  Future<WikiPage> update({
    required int projectId,
    required WikiPage original,
    required String title,
    required String content,
  }) async {
    final latest = await page(projectId, original.slug);
    if (latest.title != original.title ||
        latest.content != original.content ||
        latest.format != original.format) {
      throw const WikiEditConflictException();
    }
    return _client.wikis.update(
      projectId,
      slug: original.slug,
      title: title,
      content: content,
      format: original.format,
    );
  }
}
