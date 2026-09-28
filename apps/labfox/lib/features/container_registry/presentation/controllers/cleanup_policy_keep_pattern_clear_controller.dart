import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_cleanup_policy_controller.dart';
import 'container_registry_controllers.dart';

/// Do not change retention against unreported deletion/retention criteria.
bool canClearCleanupKeepPattern(ContainerCleanupPolicy? policy) =>
    policy != null &&
    policy.enabled != null &&
    policy.nameRegexKeep?.isNotEmpty == true &&
    policy.cadence?.isNotEmpty == true &&
    policy.keepN != null &&
    policy.keepN! >= 0 &&
    policy.olderThan?.isNotEmpty == true &&
    (policy.nameRegexDelete ?? policy.nameRegex)?.isNotEmpty == true;

class CleanupPolicyKeepPatternClearController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> clearKeepPattern({
    required ContainerCleanupPolicy expected,
  }) async {
    if (state.isLoading) {
      throw StateError('A keep pattern update is already pending');
    }
    if (!canClearCleanupKeepPattern(expected)) {
      throw ArgumentError(
        'Reported existing nonempty keep pattern and policy required',
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
      await repository.clearCleanupPolicyKeepPattern(arg);
      state = const AsyncData(null);
      ref.invalidate(containerCleanupPolicyControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyKeepPatternClearControllerProvider =
    AsyncNotifierProvider.family<
      CleanupPolicyKeepPatternClearController,
      void,
      int
    >(CleanupPolicyKeepPatternClearController.new);
