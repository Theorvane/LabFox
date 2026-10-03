import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Container registry operations for one authenticated client.
class ContainerRegistryRepository {
  const ContainerRegistryRepository(this.client);

  final GitLabClient client;
  Future<void> deleteImmutableTagRule(
    int projectId,
    ContainerTagImmutabilityRule expected, {
    bool Function()? isCurrent,
  }) async {
    if (projectId <= 0 ||
        !expected.immutable ||
        expected.id.trim().isEmpty ||
        expected.tagNamePattern.trim().isEmpty) {
      throw ArgumentError(
        'A positive project ID and complete immutable rule are required',
      );
    }
    final rules = await immutableTagRules(projectId);
    final matching = rules.where((r) => r.id == expected.id).toList();
    if (matching.isEmpty) {
      throw const GitLabNotFoundException('Immutable rule is unavailable');
    }
    if (matching.length != 1 || matching.single != expected) {
      throw const GitLabConflictException(
        'Rule changed; reload before deleting',
      );
    }
    if (isCurrent != null && !isCurrent()) {
      throw StateError('Authenticated session changed before mutation');
    }
    await client.containerImmutability.deleteRule(expected);
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

  Future<ContainerRepositoryProtectionRule> updateRepositoryProtectionPushRole(
    int projectId,
    int ruleId,
    String role,
  ) => client.containerRegistry.updateRepositoryProtectionPushRole(
    projectId,
    ruleId,
    role,
  );

  Future<List<ContainerRepositoryProtectionRule>> repositoryProtectionRules(
    int projectId,
  ) => client.containerRegistry.listRepositoryProtectionRules(projectId);

  Future<void> deleteRepository(int projectId, int repositoryId) =>
      client.containerRegistry.deleteRepository(projectId, repositoryId);

  Future<ContainerTagProtectionRule> clearTagProtectionPushRole(
    int projectId,
    int ruleId,
  ) => client.containerRegistry.clearTagProtectionPushRole(projectId, ruleId);

  Future<List<ContainerTagProtectionRule>> tagProtectionRules(int projectId) =>
      client.containerRegistry.listTagProtectionRules(projectId);

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

  Future<void> setCleanupPolicyKeepCount(
    int projectId, {
    required int keepN,
  }) async {
    await client.projects.setCleanupPolicyKeepCount(projectId, keepN: keepN);
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
