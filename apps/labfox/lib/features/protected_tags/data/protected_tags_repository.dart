import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Project protected tag rules through one GitLab client.
class ProtectedTagsRepository {
  const ProtectedTagsRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProtectedTag>> list(int projectId, {int page = 1}) =>
      client.protectedTags.list(projectId, page: page);

  Future<void> unprotect(int projectId, String name) =>
      client.protectedTags.unprotect(projectId, name);

  Future<ProtectedTag> get(int projectId, String name) =>
      client.protectedTags.get(projectId, name);
}
