import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Project protection rules through one GitLab client.
class ProtectedBranchesRepository {
  const ProtectedBranchesRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) =>
      client.protectedBranches.list(projectId, page: page);

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

  Future<ProtectedBranch> updateMergeRole(
    int projectId,
    String name, {
    required int accessRecordId,
    required int accessLevel,
  }) => client.protectedBranches.updateMergeRole(
    projectId,
    name,
    accessRecordId: accessRecordId,
    accessLevel: accessLevel,
  );

  Future<ProtectedBranch> updatePushRole(
    int projectId,
    String name, {
    required int accessRecordId,
    required int accessLevel,
  }) => client.protectedBranches.updatePushRole(
    projectId,
    name,
    accessRecordId: accessRecordId,
    accessLevel: accessLevel,
  );

  Future<void> unprotect(int projectId, String name) =>
      client.protectedBranches.unprotect(projectId, name);

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
