import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';

const cleanupCreationCadences = ['1d', '7d', '14d', '1month', '3month'];
const cleanupCreationKeepCounts = [1, 5, 10, 25, 50, 100];
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
  @override
  void build(int arg) {}

  Future<void> create({
    required ContainerCleanupPolicySnapshot expected,
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
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final current = await repository.cleanupPolicySnapshot(arg);
      if (current != expected || !canCreateCleanupPolicy(current)) {
        throw const GitLabConflictException(
          'Policy is no longer explicitly absent',
        );
      }
      await repository.createDisabledCleanupPolicy(
        arg,
        cadence: cadence,
        keepN: keepN,
        olderThan: olderThan,
        nameRegexDelete: nameRegexDelete,
        nameRegexKeep: nameRegexKeep,
      );
      state = const AsyncData(null);
      ref.invalidate(cleanupPolicySnapshotControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyCreateControllerProvider =
    AsyncNotifierProvider.family<CleanupPolicyCreateController, void, int>(
      CleanupPolicyCreateController.new,
    );
