import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Project protected tag rules through one GitLab client.
class ProtectedTagsRepository {
  const ProtectedTagsRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProtectedTag>> list(int projectId, {int page = 1}) =>
      client.protectedTags.list(projectId, page: page);

  Future<ProtectedTag> protect(
    int projectId, {
    required String name,
    required int createAccessLevel,
  }) => client.protectedTags.protect(
    projectId,
    name: name,
    createAccessLevel: createAccessLevel,
  );

  /// Scans every page before authorizing a name that may be a wildcard.
  Future<bool> containsName(int projectId, String name) async {
    var page = 1;
    final visited = <int>{};
    var found = false;
    final names = <String>{};
    while (true) {
      if (!visited.add(page)) {
        throw const GitLabServerException('Repeated protected tag page');
      }
      final result = await list(projectId, page: page);
      for (final rule in result.items) {
        if (rule.name.isEmpty || !names.add(rule.name)) {
          throw const GitLabServerException('Ambiguous protected tag list');
        }
        if (rule.name == name) found = true;
      }
      final next = result.nextPage;
      if (next == null) return found;
      if (next != page + 1) {
        throw const GitLabServerException('Invalid protected tag pagination');
      }
      page = next;
    }
  }

  Future<void> unprotect(int projectId, String name) =>
      client.protectedTags.unprotect(projectId, name);

  Future<ProtectedTag> get(int projectId, String name) =>
      client.protectedTags.get(projectId, name);
}
