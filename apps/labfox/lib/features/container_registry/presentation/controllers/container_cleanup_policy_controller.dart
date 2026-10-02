import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';

/// Reads project-wide cleanup policy without treating absence as disabled.
class ContainerCleanupPolicyController
    extends FamilyAsyncNotifier<ContainerCleanupPolicy?, int> {
  @override
  Future<ContainerCleanupPolicy?> build(int arg) async {
    final repository = await ref.watch(
      containerRegistryRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.cleanupPolicy(arg);
  }
}

final containerCleanupPolicyControllerProvider =
    AsyncNotifierProvider.family<
      ContainerCleanupPolicyController,
      ContainerCleanupPolicy?,
      int
    >(ContainerCleanupPolicyController.new);
