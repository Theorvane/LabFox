import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'container_registry_controllers.dart';

/// True means deletion was accepted for scheduling, not that removal completed.
class ContainerRepositoryDeleteController
    extends FamilyAsyncNotifier<bool, RegistryRef> {
  @override
  bool build(RegistryRef arg) => false;

  Future<void> delete() async {
    if (state.isLoading || state.valueOrNull == true) {
      throw StateError('Container repository deletion is already pending');
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      await repository.deleteRepository(arg.projectId, arg.repositoryId);
      ref.invalidate(containerRepositoriesControllerProvider(arg.projectId));
      ref.invalidate(containerTagsControllerProvider(arg));
      state = const AsyncData(true);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final containerRepositoryDeleteControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoryDeleteController,
      bool,
      RegistryRef
    >(ContainerRepositoryDeleteController.new);
