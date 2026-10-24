import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Repository tags and their associated commits.
class TagsRepository {
  const TagsRepository(this._client);

  final GitLabClient _client;

  Future<List<RepositoryTag>> list(int projectId) async {
    final tags = <RepositoryTag>[];
    var page = 1;
    while (true) {
      final result = await _client.repository.tags(projectId, page: page);
      tags.addAll(result.items);
      if (result.nextPage == null) return tags;
      page = result.nextPage!;
    }
  }

  Future<RepositoryTag> get(int projectId, String name) =>
      _client.repository.tag(projectId, name);

  Future<RepositoryTag> create(
    int projectId, {
    required String name,
    required String ref,
    String? message,
  }) => _client.repository.createTag(
    projectId,
    name: name,
    ref: ref,
    message: message,
  );
}
