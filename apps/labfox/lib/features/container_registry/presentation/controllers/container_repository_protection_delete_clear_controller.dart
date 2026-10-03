import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';
import 'container_repository_protection_controller.dart';

class ContainerRepositoryProtectionDeleteClearController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> clearDeleteRole({
    required ContainerRepositoryProtectionRule expected,
  }) async {
    if (state.isLoading) {
      throw StateError('Delete restriction clear already pending');
    }
    const roles = {'maintainer', 'owner', 'admin'};
    if (arg <= 0 ||
        expected.projectId != arg ||
        expected.id <= 0 ||
        expected.repositoryPathPattern.isEmpty ||
        !roles.contains(expected.minimumAccessLevelForDelete) ||
        !roles.contains(expected.minimumAccessLevelForPush)) {
      throw ArgumentError(
        'A valid rule with supported delete and retained push restrictions is required',
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
      final updated = await repository.clearRepositoryProtectionDeleteRole(
        arg,
        expected.id,
      );
      final cleared = updated.minimumAccessLevelForDelete;
      if ((cleared != null && cleared != '') ||
          updated.copyWith(
                minimumAccessLevelForDelete:
                    expected.minimumAccessLevelForDelete,
              ) !=
              expected) {
        throw const GitLabServerException(
          'Response did not confirm cleared delete role and retained criteria',
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

final containerRepositoryProtectionDeleteClearControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoryProtectionDeleteClearController,
      void,
      int
    >(ContainerRepositoryProtectionDeleteClearController.new);
