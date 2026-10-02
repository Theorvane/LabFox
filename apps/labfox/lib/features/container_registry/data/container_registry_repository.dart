import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Container registry operations for one authenticated client.
class ContainerRegistryRepository {
  const ContainerRegistryRepository(this.client);

  final GitLabClient client;

  Future<ContainerTagProtectionRule> createTagProtectionRule(
    int projectId, {
    required String tagNamePattern,
    required String minimumAccessLevelForPush,
    required String minimumAccessLevelForDelete,
  }) => client.containerRegistry.createTagProtectionRule(
    projectId,
    tagNamePattern: tagNamePattern,
    minimumAccessLevelForPush: minimumAccessLevelForPush,
    minimumAccessLevelForDelete: minimumAccessLevelForDelete,
  );

  Future<List<ContainerTagProtectionRule>> tagProtectionRules(int projectId) =>
      client.containerRegistry.listTagProtectionRules(projectId);

  Future<void> deleteTag(int projectId, int repositoryId, String tagName) =>
      client.containerRegistry.deleteTag(projectId, repositoryId, tagName);

  Future<ContainerTagProtectionRule> updateTagProtectionPattern(
    int projectId,
    int ruleId,
    String pattern,
  ) => client.containerRegistry.updateTagProtectionPattern(
    projectId,
    ruleId,
    pattern,
  );

  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async =>
      (await client.projects.get(projectId)).containerExpirationPolicy;

  Future<void> setCleanupPolicyCadence(
    int projectId, {
    required String cadence,
  }) async {
    await client.projects.setCleanupPolicyCadence(projectId, cadence: cadence);
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
