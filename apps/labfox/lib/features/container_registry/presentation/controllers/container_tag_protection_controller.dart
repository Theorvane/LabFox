import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';

/// Account-scoped read-only protection rule discovery for a project.
class ContainerTagProtectionController
    extends FamilyAsyncNotifier<List<ContainerTagProtectionRule>, int> {
  @override
  Future<List<ContainerTagProtectionRule>> build(int arg) async {
    final repository = await ref.watch(
      containerRegistryRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.tagProtectionRules(arg);
  }
}

final containerTagProtectionControllerProvider =
    AsyncNotifierProvider.family<
      ContainerTagProtectionController,
      List<ContainerTagProtectionRule>,
      int
    >(ContainerTagProtectionController.new);
