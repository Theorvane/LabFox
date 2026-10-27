import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import 'container_registry_controllers.dart';

/// True means deletion was accepted for scheduling, not that removal completed.
class ContainerRepositoryDeleteController
    extends FamilyAsyncNotifier<bool, RegistryRef> {
  int _generation = 0;

  @override
  bool build(RegistryRef arg) {
    ref.watch(currentAccountProvider);
    _generation++;
    return false;
  }

  Future<void> delete() async {
    if (state.isLoading || state.valueOrNull == true) {
      throw StateError('Container repository deletion is already pending');
    }
    final generation = _generation;
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (generation != _generation) return;
      if (repository == null) throw StateError('No authenticated account');
      await repository.deleteRepository(arg.projectId, arg.repositoryId);
      if (generation != _generation) return;
      ref.invalidate(containerRepositoriesControllerProvider(arg.projectId));
      ref.invalidate(containerTagsControllerProvider(arg));
      state = const AsyncData(true);
    } catch (error, stackTrace) {
      if (generation != _generation) return;
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
