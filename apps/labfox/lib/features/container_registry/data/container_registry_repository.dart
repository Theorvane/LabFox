import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Container registry operations for one authenticated client.
class ContainerRegistryRepository {
  const ContainerRegistryRepository(this.client);

  final GitLabClient client;

  /// Preflight is best effort, not an atomic uniqueness or permission check.
  Future<ContainerTagImmutabilityRule> createImmutableTagRule(
    int projectId,
    String pattern, {
    bool Function()? isCurrent,
  }) async {
    if (projectId <= 0 ||
        pattern.trim().isEmpty ||
        pattern.runes.length > 100) {
      throw ArgumentError(
        'Positive project ID and a valid pattern length are required',
      );
    }
    final existing = await immutableTagRules(projectId);
    if (existing.any((r) => r.tagNamePattern == pattern)) {
      throw const GitLabConflictException(
        'An immutable rule already has this pattern',
      );
    }
    final project = await client.projects.get(projectId);
    if (project.id != projectId || project.pathWithNamespace.trim().isEmpty) {
      throw const GitLabServerException(
        'Project identity could not be confirmed',
      );
    }
    if (isCurrent != null && !isCurrent()) {
      throw StateError('Authenticated session changed before mutation');
    }
    return client.containerImmutability.createRule(
      project.pathWithNamespace,
      pattern,
    );
  }

  /// Scan the whole connection before exposing a filtered immutable list.
  Future<List<ContainerTagImmutabilityRule>> immutableTagRules(
    int projectId,
  ) async {
    if (projectId <= 0) throw ArgumentError('Project ID must be positive');
    final project = await client.projects.get(projectId);
    if (project.id != projectId || project.pathWithNamespace.trim().isEmpty) {
      throw const GitLabServerException(
        'Project identity could not be confirmed',
      );
    }
    final rules = <ContainerTagImmutabilityRule>[];
    final cursors = <String>{};
    final ids = <String>{};
    String? after;
    while (true) {
      final page = await client.containerImmutability.listRules(
        project.pathWithNamespace,
        after: after,
      );
      for (final rule in page.nodes) {
        if (!ids.add(rule.id)) {
          throw const GitLabServerException('Ambiguous tag rule connection');
        }
        if (rule.immutable) rules.add(rule);
      }
      if (!page.pageInfo.hasNextPage) return List.unmodifiable(rules);
      final next = page.pageInfo.endCursor!;
      if (!cursors.add(next)) {
        throw const GitLabServerException('Tag rule cursor did not progress');
      }
      after = next;
    }
  }

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

  Future<List<ContainerTagProtectionRule>> tagProtectionRules(int projectId) =>
      client.containerRegistry.listTagProtectionRules(projectId);

  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async =>
      (await client.projects.get(projectId)).containerExpirationPolicy;

  Future<void> setCleanupPolicyKeepPattern(
    int projectId, {
    required String nameRegexKeep,
  }) async {
    await client.projects.setCleanupPolicyKeepPattern(
      projectId,
      nameRegexKeep: nameRegexKeep,
    );
  }

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
