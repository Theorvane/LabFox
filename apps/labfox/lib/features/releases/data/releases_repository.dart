import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Project Releases data for one authenticated GitLab client.
class ReleasesRepository {
  const ReleasesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<GitLabRelease>> list(int projectId, {int page = 1}) =>
      client.releases.list(projectId, page: page);

  Future<GitLabRelease> get(int projectId, String tagName) =>
      client.releases.get(projectId, tagName);

  Future<GitLabRelease> update(
    int projectId,
    String tagName, {
    required String name,
    required String description,
  }) => client.releases.update(
    projectId,
    tagName,
    name: name,
    description: description,
  );

  Future<GitLabRelease> create(
    int projectId, {
    required String tagName,
    String? ref,
    String? name,
    String? description,
  }) => client.releases.create(
    projectId,
    tagName: tagName,
    ref: ref,
    name: name,
    description: description,
  );
}
