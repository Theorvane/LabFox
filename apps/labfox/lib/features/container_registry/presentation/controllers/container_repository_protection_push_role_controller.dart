import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';
import 'container_repository_protection_controller.dart';

class ContainerRepositoryProtectionPushRoleController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> savePushRole({
    required ContainerRepositoryProtectionRule expected,
    required String role,
  }) async {
    if (state.isLoading) throw StateError('Push role update already pending');
    const roles = {'maintainer', 'owner', 'admin'};
    final current = expected.minimumAccessLevelForPush;
    if (arg <= 0 ||
        expected.projectId != arg ||
        expected.id <= 0 ||
        expected.repositoryPathPattern.isEmpty ||
        !roles.contains(role) ||
        (current != null && current != '' && !roles.contains(current)) ||
        role == current) {
      throw ArgumentError(
        'An exact valid rule and changed supported push role are required',
      );
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final matches = (await repository.repositoryProtectionRules(
        arg,
      )).where((rule) => rule.id == expected.id).toList();
      if (matches.length != 1 || matches.single != expected) {
        throw const GitLabConflictException('Rule changed since confirmation');
      }
      final updated = await repository.updateRepositoryProtectionPushRole(
        arg,
        expected.id,
        role,
      );
      if (updated != expected.copyWith(minimumAccessLevelForPush: role)) {
        throw const GitLabServerException(
          'Response did not confirm the requested push role and retained criteria',
        );
      }
      state = const AsyncData(null);
      ref.invalidate(containerRepositoryProtectionControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final containerRepositoryProtectionPushRoleControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoryProtectionPushRoleController,
      void,
      int
    >(ContainerRepositoryProtectionPushRoleController.new);
