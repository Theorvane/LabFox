import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_cleanup_policy_controller.dart';
import 'container_registry_controllers.dart';

/// Documented cleanup API intervals; unknown current values remain readable.
const cleanupPolicyCadences = ['1d', '7d', '14d', '1month', '3month'];

/// Do not reschedule cleanup against unreported deletion/retention criteria.
bool canEditCleanupCadence(ContainerCleanupPolicy? policy) =>
    policy != null &&
    policy.enabled != null &&
    policy.cadence != null &&
    policy.keepN != null &&
    policy.keepN! >= 0 &&
    policy.olderThan?.isNotEmpty == true &&
    (policy.nameRegexDelete ?? policy.nameRegex)?.isNotEmpty == true;

class CleanupPolicyCadenceController extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> setCadence({
    required ContainerCleanupPolicy expected,
    required String cadence,
  }) async {
    if (state.isLoading) {
      throw StateError('A cadence update is already pending');
    }
    if (!cleanupPolicyCadences.contains(cadence) ||
        cadence == expected.cadence ||
        !canEditCleanupCadence(expected)) {
      throw ArgumentError(
        'Explicit supported replacement and reported policy required',
      );
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final current = await repository.cleanupPolicy(arg);
      if (current == null ||
          current.copyWith(nextRunAt: null) !=
              expected.copyWith(nextRunAt: null)) {
        throw const GitLabConflictException(
          'Cleanup policy changed since confirmation',
        );
      }
      await repository.setCleanupPolicyCadence(arg, cadence: cadence);
      state = const AsyncData(null);
      ref.invalidate(containerCleanupPolicyControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyCadenceControllerProvider =
    AsyncNotifierProvider.family<CleanupPolicyCadenceController, void, int>(
      CleanupPolicyCadenceController.new,
    );
