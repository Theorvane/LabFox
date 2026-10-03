import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package_controllers.dart';

/// Identifies one file without trusting server-provided URLs or display names.
class PackageFileRef {
  const PackageFileRef({
    required this.projectId,
    required this.packageId,
    required this.fileId,
  });
  final int projectId;
  final int packageId;
  final int fileId;

  PackageRef get packageRef =>
      PackageRef(projectId: projectId, packageId: packageId);

  @override
  bool operator ==(Object other) =>
      other is PackageFileRef &&
      projectId == other.projectId &&
      packageId == other.packageId &&
      fileId == other.fileId;
  @override
  int get hashCode => Object.hash(projectId, packageId, fileId);
}

/// Rejected writes preserve cached files; successful writes refresh the parent.
class PackageFileDeleteController
    extends FamilyAsyncNotifier<void, PackageFileRef> {
  @override
  void build(PackageFileRef arg) {}

  Future<void> delete() async {
    if (state.isLoading) {
      throw StateError('Package file deletion is already pending');
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        packageRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      await repository.deleteFile(arg.projectId, arg.packageId, arg.fileId);
      ref.invalidate(packageListControllerProvider(arg.projectId));
      ref.invalidate(packageDetailControllerProvider(arg.packageRef));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final packageFileDeleteControllerProvider =
    AsyncNotifierProvider.family<
      PackageFileDeleteController,
      void,
      PackageFileRef
    >(PackageFileDeleteController.new);
