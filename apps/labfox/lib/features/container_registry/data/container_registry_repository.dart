import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Container registry operations for one authenticated client.
class ContainerRegistryRepository {
  const ContainerRegistryRepository(this.client);

  final GitLabClient client;

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

  Future<void> setCleanupPolicyEnabled(
    int projectId, {
    required bool enabled,
  }) async {
    await client.projects.setCleanupPolicyEnabled(projectId, enabled: enabled);
  }

  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async =>
      (await client.projects.get(projectId)).containerExpirationPolicy;

  Future<ContainerRepositoryProtectionRule> createRepositoryProtectionRule(
    int projectId, {
    required String repositoryPathPattern,
    String? minimumAccessLevelForPush,
    String? minimumAccessLevelForDelete,
  }) => client.containerRegistry.createRepositoryProtectionRule(
    projectId,
    repositoryPathPattern: repositoryPathPattern,
    minimumAccessLevelForPush: minimumAccessLevelForPush,
    minimumAccessLevelForDelete: minimumAccessLevelForDelete,
  );

  Future<void> deleteRepositoryProtectionRule(int projectId, int ruleId) =>
      client.containerRegistry.deleteRepositoryProtectionRule(
        projectId,
        ruleId,
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

  Future<void> setCleanupPolicyKeepPattern(
    int projectId, {
    required String nameRegexKeep,
  }) async {
    await client.projects.setCleanupPolicyKeepPattern(
      projectId,
      nameRegexKeep: nameRegexKeep,
    );
  }

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

  Future<ContainerCleanupPolicySnapshot> cleanupPolicySnapshot(int projectId) =>
      client.projects.cleanupPolicySnapshot(projectId);
  Future<void> createDisabledCleanupPolicy(
    int projectId, {
    required String cadence,
    required int keepN,
    required String olderThan,
    required String nameRegexDelete,
    required String nameRegexKeep,
  }) async {
    await client.projects.createDisabledCleanupPolicy(
      projectId,
      cadence: cadence,
      keepN: keepN,
      olderThan: olderThan,
      nameRegexDelete: nameRegexDelete,
      nameRegexKeep: nameRegexKeep,
    );
  }

  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) => client.containerRegistry.listRepositories(projectId, page: page);

  Future<void> cleanupTags(
    int projectId,
    int repositoryId, {
    required String nameRegexDelete,
    String? nameRegexKeep,
    int? keepN,
    String? olderThan,
  }) => client.containerRegistry.deleteTags(
    projectId,
    repositoryId,
    nameRegexDelete: nameRegexDelete,
    nameRegexKeep: nameRegexKeep,
    keepN: keepN,
    olderThan: olderThan,
  );

  Future<Paginated<RegistryTag>> tags(
    int projectId,
    int repositoryId, {
    int page = 1,
  }) => client.containerRegistry.listTags(projectId, repositoryId, page: page);

  Future<RegistryTag> tag(int projectId, int repositoryId, String tagName) =>
      client.containerRegistry.getTag(projectId, repositoryId, tagName);
  Future<void> deleteTagProtectionRule(int projectId, int ruleId) =>
      client.containerRegistry.deleteTagProtectionRule(projectId, ruleId);
}
