import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';
import 'container_tag_protection_controller.dart';

class ContainerTagProtectionDeleteRoleController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> saveDeleteRole({
    required ContainerTagProtectionRule expected,
    required String role,
  }) async {
    if (state.isLoading) throw StateError('Delete role update already pending');
    const roles = {'maintainer', 'owner', 'admin'};
    final current = expected.minimumAccessLevelForDelete;
    if (arg <= 0 ||
        expected.projectId != arg ||
        expected.id <= 0 ||
        expected.tagNamePattern.trim().isEmpty ||
        !roles.contains(role) ||
        (current != null && current != '' && !roles.contains(current)) ||
        role == current) {
      throw ArgumentError(
        'An exact valid rule and changed supported delete role are required',
      );
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final matches = (await repository.tagProtectionRules(
        arg,
      )).where((rule) => rule.id == expected.id).toList();
      if (matches.length != 1 || matches.single != expected) {
        throw const GitLabConflictException('Rule changed since confirmation');
      }
      final updated = await repository.updateTagProtectionDeleteRole(
        arg,
        expected.id,
        role,
      );
      if (updated != expected.copyWith(minimumAccessLevelForDelete: role)) {
        throw const GitLabServerException(
          'Response did not confirm the requested delete role and retained criteria',
        );
      }
      state = const AsyncData(null);
      ref.invalidate(containerTagProtectionControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final containerTagProtectionDeleteRoleControllerProvider =
    AsyncNotifierProvider.family<
      ContainerTagProtectionDeleteRoleController,
      void,
      int
    >(ContainerTagProtectionDeleteRoleController.new);
