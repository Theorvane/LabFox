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

  Future<ProtectedBranch> updateForcePush(
    int projectId,
    String name, {
    required bool allowForcePush,
  }) => client.protectedBranches.updateForcePush(
    projectId,
    name,
    allowForcePush: allowForcePush,
  );

  /// Read every page so an exact name cannot be confused with another rule.
  Future<ProtectedBranch> findUnique(int projectId, String name) async {
    ProtectedBranch? found;
    var page = 1;
    while (true) {
      final result = await list(projectId, page: page);
      for (final rule in result.items) {
        if (rule.name.trim().isEmpty) {
          throw const GitLabServerException('Malformed protected branch rule');
        }
        if (rule.name == name) {
          if (found != null) {
            throw const GitLabConflictException(
              'Duplicate protected branch name',
            );
          }
          found = rule;
        }
      }
      final next = result.nextPage;
      if (next == null) break;
      if (next != page + 1) {
        throw const GitLabServerException(
          'Invalid protected branch pagination',
        );
      }
      page = next;
    }
    if (found == null) {
      throw const GitLabNotFoundException('Protected branch rule missing');
    }
    return found;
  }
}
