import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'container_registry_controllers.dart';

/// Deletes the confirmed tag; a rejected write leaves the caches untouched.
class ContainerTagDeleteController
    extends FamilyAsyncNotifier<void, RegistryTagRef> {
  @override
  void build(RegistryTagRef arg) {}

  Future<void> delete() async {
    if (state.isLoading) {
      throw StateError('Container tag deletion is already pending');
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      await repository.deleteTag(
        arg.repository.projectId,
        arg.repository.repositoryId,
        arg.name,
      );
      ref.invalidate(containerTagsControllerProvider(arg.repository));
      ref.invalidate(
        containerRepositoriesControllerProvider(arg.repository.projectId),
      );
      ref.invalidate(containerTagProvider(arg));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final containerTagDeleteControllerProvider =
    AsyncNotifierProvider.family<
      ContainerTagDeleteController,
      void,
      RegistryTagRef
    >(ContainerTagDeleteController.new);
