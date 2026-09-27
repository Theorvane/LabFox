import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Project snippets, independent of widget and routing concerns.
class SnippetsRepository {
  const SnippetsRepository(this._client);

  final GitLabClient _client;

  Future<Snippet> updateMetadata(
    int projectId,
    int snippetId, {
    required String title,
    required String description,
    String? visibility,
  }) => _client.snippets.updateMetadata(
    projectId,
    snippetId,
    title: title,
    description: description,
    visibility: visibility,
  );

  Future<Snippet> create(
    int projectId, {
    required String title,
    required String description,
    required String visibility,
    required String filePath,
    required String content,
  }) => _client.snippets.create(
    projectId,
    title: title,
    description: description,
    visibility: visibility,
    filePath: filePath,
    content: content,
  );

  Future<void> delete(int projectId, int snippetId) =>
      _client.snippets.delete(projectId, snippetId);

  Future<List<Snippet>> list(int projectId) async {
    final items = <Snippet>[];
    var page = 1;
    while (true) {
      final result = await _client.snippets.list(projectId, page: page);
      items.addAll(result.items);
      if (result.nextPage == null) return items;
      page = result.nextPage!;
    }
  }

  Future<Snippet> get(int projectId, int snippetId) =>
      _client.snippets.get(projectId, snippetId);

  Future<String> raw(int projectId, int snippetId) =>
      _client.snippets.raw(projectId, snippetId);

  Future<String> file(int projectId, int snippetId, SnippetFile file) =>
      _client.snippets.file(
        projectId,
        snippetId,
        ref: snippetRefForFile(file),
        path: file.path,
      );
}

/// The file URL identifies the snippet repository branch on GitLab versions
/// that still use `master`; newer snippets usually use `main`.
String snippetRefForFile(SnippetFile file) {
  final segments =
      Uri.tryParse(file.rawUrl ?? '')?.pathSegments ?? const <String>[];
  final rawIndex = segments.indexOf('raw');
  if (rawIndex >= 0 && rawIndex + 1 < segments.length) {
    return segments[rawIndex + 1];
  }
  return 'main';
}
