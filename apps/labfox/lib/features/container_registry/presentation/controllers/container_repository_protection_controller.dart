import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';

/// Account-scoped read-only protection rule discovery for a project.
class ContainerRepositoryProtectionController
    extends FamilyAsyncNotifier<List<ContainerRepositoryProtectionRule>, int> {
  @override
  Future<List<ContainerRepositoryProtectionRule>> build(int arg) async {
    final repository = await ref.watch(
      containerRegistryRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.repositoryProtectionRules(arg);
  }
}

final containerRepositoryProtectionControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoryProtectionController,
      List<ContainerRepositoryProtectionRule>,
      int
    >(ContainerRepositoryProtectionController.new);
