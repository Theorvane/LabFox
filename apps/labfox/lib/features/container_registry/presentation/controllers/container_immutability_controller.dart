import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'container_registry_controllers.dart';

class ContainerImmutabilityController
    extends FamilyAsyncNotifier<List<ContainerTagImmutabilityRule>, int> {
  @override
  Future<List<ContainerTagImmutabilityRule>> build(int arg) async {
    final repository = await ref.watch(
      containerRegistryRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.immutableTagRules(arg);
  }
}

final containerImmutabilityControllerProvider =
    AsyncNotifierProvider.family<
      ContainerImmutabilityController,
      List<ContainerTagImmutabilityRule>,
      int
    >(ContainerImmutabilityController.new);
