import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package_controllers.dart';

/// Deletes a confirmed package without changing caches on rejection.
class PackageDeleteController extends FamilyAsyncNotifier<void, PackageRef> {
  @override
  void build(PackageRef arg) {}

  Future<void> delete() async {
    if (state.isLoading) {
      throw StateError('Package deletion is already pending');
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        packageRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      await repository.delete(arg.projectId, arg.packageId);
      ref.invalidate(packageListControllerProvider(arg.projectId));
      ref.invalidate(packageDetailControllerProvider(arg));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final packageDeleteControllerProvider =
    AsyncNotifierProvider.family<PackageDeleteController, void, PackageRef>(
      PackageDeleteController.new,
    );
