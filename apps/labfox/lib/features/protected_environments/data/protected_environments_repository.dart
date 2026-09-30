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

  Future<ProtectedEnvironment> createRoleOnly(
    int projectId,
    String name, {
    required int accessLevel,
  }) => client.protectedEnvironments.createRoleOnly(
    projectId,
    name,
    accessLevel: accessLevel,
  );

  Future<Paginated<ProtectedEnvironment>> listGroup(
    int groupId, {
    int page = 1,
  }) => client.groupProtectedEnvironments.list(groupId, page: page);

  Future<ProtectedEnvironment> getGroup(int groupId, String name) =>
      client.groupProtectedEnvironments.get(groupId, name);
}
