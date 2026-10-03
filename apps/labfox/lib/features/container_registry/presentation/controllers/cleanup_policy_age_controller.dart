import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_cleanup_policy_controller.dart';
import 'container_registry_controllers.dart';

/// Documented cleanup age codes; unknown current values stay readable.
const cleanupPolicyAges = [
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

/// Do not change retention against unreported deletion/retention criteria.
bool canEditCleanupAge(ContainerCleanupPolicy? policy) =>
    policy != null &&
    policy.enabled != null &&
    policy.nameRegexKeep != null &&
    policy.cadence?.isNotEmpty == true &&
    policy.keepN != null &&
    policy.keepN! >= 0 &&
    policy.olderThan?.isNotEmpty == true &&
    (policy.nameRegexDelete ?? policy.nameRegex)?.isNotEmpty == true;

class CleanupPolicyAgeController extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> setAge({
    required ContainerCleanupPolicy expected,
    required String olderThan,
  }) async {
    if (state.isLoading) {
      throw StateError('A age limit update is already pending');
    }
    if (!cleanupPolicyAges.contains(olderThan) ||
        olderThan == expected.olderThan ||
        !canEditCleanupAge(expected)) {
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
      await repository.setCleanupPolicyAge(arg, olderThan: olderThan);
      state = const AsyncData(null);
      ref.invalidate(containerCleanupPolicyControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyAgeControllerProvider =
    AsyncNotifierProvider.family<CleanupPolicyAgeController, void, int>(
      CleanupPolicyAgeController.new,
    );
