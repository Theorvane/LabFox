import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Project protection rules through one GitLab client.
class ProtectedBranchesRepository {
  const ProtectedBranchesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) =>
      client.protectedBranches.list(projectId, page: page);

  Future<ProtectedBranch> protect(
    int projectId, {
    required String name,
    required int pushAccessLevel,
    required int mergeAccessLevel,
  }) => client.protectedBranches.protect(
    projectId,
    name: name,
    pushAccessLevel: pushAccessLevel,
    mergeAccessLevel: mergeAccessLevel,
  );

  /// Completes an inventory scan before accepting an exact rule name.
  Future<bool> containsName(int projectId, String name) async {
    var page = 1;
    final visited = <int>{};
    final names = <String>{};
    var found = false;
    while (true) {
      if (!visited.add(page)) {
        throw const GitLabServerException('Repeated protected branch page');
      }
      final result = await list(projectId, page: page);
      for (final rule in result.items) {
        if (rule.name.isEmpty || !names.add(rule.name)) {
          throw const GitLabServerException('Ambiguous protected branch list');
        }
        if (rule.name == name) found = true;
      }
      final next = result.nextPage;
      if (next == null) return found;
      if (next != page + 1) {
        throw const GitLabServerException(
          'Invalid protected branch pagination',
        );
      }
      page = next;
    }
  }

  Future<ProtectedBranch> get(int projectId, String name) =>
      client.protectedBranches.get(projectId, name);
}
