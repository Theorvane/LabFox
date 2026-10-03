import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';
import 'container_repository_protection_controller.dart';

class ContainerRepositoryProtectionPushClearController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> clearPushRole({
    required ContainerRepositoryProtectionRule expected,
  }) async {
    if (state.isLoading) {
      throw StateError('Push restriction clear already pending');
    }
    const roles = {'maintainer', 'owner', 'admin'};
    if (arg <= 0 ||
        expected.projectId != arg ||
        expected.id <= 0 ||
        expected.repositoryPathPattern.isEmpty ||
        !roles.contains(expected.minimumAccessLevelForPush) ||
        !roles.contains(expected.minimumAccessLevelForDelete)) {
      throw ArgumentError(
        'A valid rule with supported push and retained delete restrictions is required',
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
      )).where((r) => r.id == expected.id).toList();
      if (matches.length != 1 || matches.single != expected) {
        throw const GitLabConflictException('Rule changed since confirmation');
      }
      final updated = await repository.clearRepositoryProtectionPushRole(
        arg,
        expected.id,
      );
      final cleared = updated.minimumAccessLevelForPush;
      if ((cleared != null && cleared != '') ||
          updated.copyWith(
                minimumAccessLevelForPush: expected.minimumAccessLevelForPush,
              ) !=
              expected) {
        throw const GitLabServerException(
          'Response did not confirm cleared push role and retained criteria',
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

final containerRepositoryProtectionPushClearControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoryProtectionPushClearController,
      void,
      int
    >(ContainerRepositoryProtectionPushClearController.new);
