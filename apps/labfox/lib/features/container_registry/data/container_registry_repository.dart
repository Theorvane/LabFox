import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Container image browsing and cleanup settings for one authenticated client.
class ContainerRegistryRepository {
  const ContainerRegistryRepository(this.client);

  final GitLabClient client;

  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async =>
      (await client.projects.get(projectId)).containerExpirationPolicy;

  Future<void> setCleanupPolicyDeletePattern(
    int projectId, {
    required String nameRegexDelete,
  }) async {
    await client.projects.setCleanupPolicyDeletePattern(
      projectId,
      nameRegexDelete: nameRegexDelete,
    );
  }

  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) => client.containerRegistry.listRepositories(projectId, page: page);

  Future<Paginated<RegistryTag>> tags(
    int projectId,
    int repositoryId, {
    int page = 1,
  }) => client.containerRegistry.listTags(projectId, repositoryId, page: page);

  Future<RegistryTag> tag(int projectId, int repositoryId, String tagName) =>
      client.containerRegistry.getTag(projectId, repositoryId, tagName);
}
