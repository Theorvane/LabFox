import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_cleanup_policy_controller.dart';
import 'container_registry_controllers.dart';

/// Documented matching-tag retention counts; unknown current values stay readable.
const cleanupPolicyKeepCounts = [1, 5, 10, 25, 50, 100];

/// Do not change retention against unreported deletion/retention criteria.
bool canEditCleanupKeepCount(ContainerCleanupPolicy? policy) =>
    policy != null &&
    policy.enabled != null &&
    policy.cadence?.isNotEmpty == true &&
    policy.keepN != null &&
    policy.keepN! >= 0 &&
    policy.olderThan?.isNotEmpty == true &&
    (policy.nameRegexDelete ?? policy.nameRegex)?.isNotEmpty == true;

class CleanupPolicyKeepCountController extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> setKeepCount({
    required ContainerCleanupPolicy expected,
    required int keepN,
  }) async {
    if (state.isLoading) {
      throw StateError('A retention count update is already pending');
    }
    if (!cleanupPolicyKeepCounts.contains(keepN) ||
        keepN == expected.keepN ||
        !canEditCleanupKeepCount(expected)) {
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
      await repository.setCleanupPolicyKeepCount(arg, keepN: keepN);
      state = const AsyncData(null);
      ref.invalidate(containerCleanupPolicyControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyKeepCountControllerProvider =
    AsyncNotifierProvider.family<CleanupPolicyKeepCountController, void, int>(
      CleanupPolicyKeepCountController.new,
    );
