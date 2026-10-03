import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';

const cleanupCreationCadences = ['1d', '7d', '14d', '1month', '3month'];
const cleanupCreationKeepCounts = [1, 5, 10, 25, 50, 100];
// Supported API values are documented under "Use the cleanup policy API":
// https://docs.gitlab.com/user/packages/container_registry/reduce_container_registry_storage/
const cleanupCreationAges = [
  '1d',
  '3d',
  '7d',
  '14d',
  '30d',
  '60d',
  '90d',
  '180d',
  '365d',
  '730d',
  '1095d',
];

/// Only explicit absence is actionable; omitted information is not absence.
bool canCreateCleanupPolicy(ContainerCleanupPolicySnapshot snapshot) =>
    snapshot.reported && snapshot.policy == null;

class CleanupPolicySnapshotController
    extends FamilyAsyncNotifier<ContainerCleanupPolicySnapshot, int> {
  @override
  Future<ContainerCleanupPolicySnapshot> build(int arg) async {
    final repository = await ref.watch(
      containerRegistryRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.cleanupPolicySnapshot(arg);
  }
}

final cleanupPolicySnapshotControllerProvider =
    AsyncNotifierProvider.family<
      CleanupPolicySnapshotController,
      ContainerCleanupPolicySnapshot,
      int
    >(CleanupPolicySnapshotController.new);

class CleanupPolicyCreateController extends FamilyAsyncNotifier<void, int> {
  bool _disposed = false;
  @override
  void build(int arg) {
    ref.watch(containerRegistryRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<void> create({
    required ContainerCleanupPolicySnapshot expected,
    bool enabled = false,
    required String cadence,
    required int keepN,
    required String olderThan,
    required String nameRegexDelete,
    required String nameRegexKeep,
  }) async {
    if (state.isLoading) throw StateError('Policy creation is already pending');
    if (!canCreateCleanupPolicy(expected) ||
        !cleanupCreationCadences.contains(cadence) ||
        !cleanupCreationKeepCounts.contains(keepN) ||
        !cleanupCreationAges.contains(olderThan) ||
        nameRegexDelete.trim().isEmpty) {
      throw ArgumentError(
        'Explicit absence and supported complete criteria required',
      );
    }
    final session = ref.read(containerRegistryRepositoryProvider.future);
    bool isCurrentSession() =>
        !_disposed &&
        identical(
          session,
          ref.read(containerRegistryRepositoryProvider.future),
        );
    void requireCurrentSession() {
      if (!isCurrentSession()) {
        throw const GitLabConflictException('Cleanup creation session changed');
      }
    }

    state = const AsyncLoading();
    try {
      final repository = await session;
      requireCurrentSession();
      if (repository == null) throw StateError('No authenticated account');
      final current = await repository.cleanupPolicySnapshot(arg);
      requireCurrentSession();
      if (current != expected || !canCreateCleanupPolicy(current)) {
        throw const GitLabConflictException(
          'Policy is no longer explicitly absent',
        );
      }
      await repository.createCleanupPolicy(
        arg,
        enabled: enabled,
        cadence: cadence,
        keepN: keepN,
        olderThan: olderThan,
        nameRegexDelete: nameRegexDelete,
        nameRegexKeep: nameRegexKeep,
      );
      requireCurrentSession();
      state = const AsyncData(null);
      ref.invalidate(cleanupPolicySnapshotControllerProvider(arg));
    } catch (error, stackTrace) {
      if (isCurrentSession()) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyCreateControllerProvider =
    AsyncNotifierProvider.family<CleanupPolicyCreateController, void, int>(
      CleanupPolicyCreateController.new,
    );
