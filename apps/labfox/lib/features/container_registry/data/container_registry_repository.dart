import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Read-only container image browsing for one authenticated GitLab client.
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
