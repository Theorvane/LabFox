import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import 'container_registry_controllers.dart';
import 'container_repository_protection_controller.dart';

class ContainerRepositoryProtectionCreateController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> create({
    required String repositoryPathPattern,
    String? minimumAccessLevelForPush,
    String? minimumAccessLevelForDelete,
  }) async {
    if (state.isLoading) throw StateError('Rule creation is already pending');
    const roles = {'maintainer', 'owner', 'admin'};
    if (arg <= 0 ||
        repositoryPathPattern.trim().isEmpty ||
        (minimumAccessLevelForPush == null &&
            minimumAccessLevelForDelete == null) ||
        (minimumAccessLevelForPush != null &&
            !roles.contains(minimumAccessLevelForPush)) ||
        (minimumAccessLevelForDelete != null &&
            !roles.contains(minimumAccessLevelForDelete))) {
      throw ArgumentError(
        'A path pattern and at least one supported role are required',
      );
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final created = await repository.createRepositoryProtectionRule(
        arg,
        repositoryPathPattern: repositoryPathPattern,
        minimumAccessLevelForPush: minimumAccessLevelForPush,
        minimumAccessLevelForDelete: minimumAccessLevelForDelete,
      );
      if (created.id <= 0 ||
          created.projectId != arg ||
          created.repositoryPathPattern != repositoryPathPattern ||
          created.minimumAccessLevelForPush != minimumAccessLevelForPush ||
          created.minimumAccessLevelForDelete != minimumAccessLevelForDelete) {
        throw const GitLabServerException(
          'Creation response did not confirm requested criteria',
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

final containerRepositoryProtectionCreateControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoryProtectionCreateController,
      void,
      int
    >(ContainerRepositoryProtectionCreateController.new);
