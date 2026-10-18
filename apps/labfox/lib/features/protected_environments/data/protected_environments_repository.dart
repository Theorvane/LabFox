import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Protected environment rules for one authenticated account.
class ProtectedEnvironmentsRepository {
  const ProtectedEnvironmentsRepository(this.client);

  final GitLabClient client;

  Future<Paginated<ProtectedEnvironment>> list(int projectId, {int page = 1}) =>
      client.protectedEnvironments.list(projectId, page: page);

  Future<ProtectedEnvironment> get(int projectId, String name) =>
      client.protectedEnvironments.get(projectId, name);

  Future<ProtectedEnvironment> getComplete(int projectId, String name) =>
      client.protectedEnvironments.getComplete(projectId, name);

  Future<void> ensureUniqueName(int projectId, String name) async {
    var page = 1;
    var matches = 0;
    while (true) {
      final result = await list(projectId, page: page);
      matches += result.items.where((rule) => rule.name == name).length;
      if (matches > 1) {
        throw const GitLabConflictException('Duplicate environment protection');
      }
      final next = result.nextPage;
      if (next == null) break;
      if (next <= page) {
        throw const GitLabServerException('Invalid protection pagination');
      }
      page = next;
    }
    if (matches == 0) {
      throw const GitLabNotFoundException('Environment protection not found');
    }
  }

  Future<void> unprotect(int projectId, String name) =>
      client.protectedEnvironments.unprotect(projectId, name);

  Future<void> addDeployRole(
    int projectId,
    String name, {
    required int accessLevel,
  }) => client.protectedEnvironments.addDeployRole(
    projectId,
    name,
    accessLevel: accessLevel,
  );

  Future<void> removeDeployRole(
    int projectId,
    String name, {
    required int grantId,
  }) => client.protectedEnvironments.removeDeployRole(
    projectId,
    name,
    grantId: grantId,
  );

  Future<void> editDeployRole(
    int projectId,
    String name, {
    required int grantId,
    required int accessLevel,
  }) => client.protectedEnvironments.editDeployRole(
    projectId,
    name,
    grantId: grantId,
    accessLevel: accessLevel,
  );

  Future<void> ensureNameAvailable(int projectId, String name) async {
    var page = 1;
    while (true) {
      final result = await list(projectId, page: page);
      if (result.items.any((rule) => rule.name == name)) {
        throw const GitLabConflictException('Environment is already protected');
      }
      final next = result.nextPage;
      if (next == null) return;
      if (next <= page) {
        throw const GitLabServerException('Invalid protection pagination');
      }
      page = next;
    }
  }

  Future<void> editApprovalCount(
    int projectId,
    String name, {
    required int ruleId,
    required int requiredApprovals,
  }) => client.protectedEnvironments.editApprovalCount(
    projectId,
    name,
    ruleId: ruleId,
    requiredApprovals: requiredApprovals,
  );

  Future<ProtectedEnvironment> createRoleOnly(
    int projectId,
    String name, {
    required int accessLevel,
  }) => client.protectedEnvironments.createRoleOnly(
    projectId,
    name,
    accessLevel: accessLevel,
  );

  Future<ProtectedEnvironment> getForApprovalGroupEdit(
    int projectId,
    String name,
  ) => client.protectedEnvironments.getForApprovalGroupEdit(projectId, name);

  Future<ProtectedEnvironment> addApprovalGroup(
    int projectId,
    String name, {
    required int groupId,
    required int requiredApprovals,
  }) => client.protectedEnvironments.addApprovalGroup(
    projectId,
    name,
    groupId: groupId,
    requiredApprovals: requiredApprovals,
  );

  Future<Paginated<ProtectedEnvironment>> listGroup(
    int groupId, {
    int page = 1,
  }) => client.groupProtectedEnvironments.list(groupId, page: page);

  Future<ProtectedEnvironment> getGroup(int groupId, String name) =>
      client.groupProtectedEnvironments.get(groupId, name);
}
