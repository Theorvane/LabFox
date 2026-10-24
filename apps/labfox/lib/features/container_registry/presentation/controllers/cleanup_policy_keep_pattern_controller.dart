import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_cleanup_policy_controller.dart';
import 'container_registry_controllers.dart';

/// Do not change retention against unreported deletion/retention criteria.
bool canEditCleanupKeepPattern(ContainerCleanupPolicy? policy) =>
    policy != null &&
    policy.enabled != null &&
    policy.nameRegexKeep != null &&
    policy.cadence?.isNotEmpty == true &&
    policy.keepN != null &&
    policy.keepN! >= 0 &&
    policy.olderThan?.isNotEmpty == true &&
    (policy.nameRegexDelete ?? policy.nameRegex)?.isNotEmpty == true;

class CleanupPolicyKeepPatternController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> setKeepPattern({
    required ContainerCleanupPolicy expected,
    required String nameRegexKeep,
  }) async {
    if (state.isLoading) {
      throw StateError('A keep pattern update is already pending');
    }
    if (nameRegexKeep.trim().isEmpty ||
        nameRegexKeep == expected.nameRegexKeep ||
        !canEditCleanupKeepPattern(expected)) {
      throw ArgumentError(
        'Explicit nonblank replacement and reported policy required',
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
      await repository.setCleanupPolicyKeepPattern(
        arg,
        nameRegexKeep: nameRegexKeep,
      );
      state = const AsyncData(null);
      ref.invalidate(containerCleanupPolicyControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyKeepPatternControllerProvider =
    AsyncNotifierProvider.family<CleanupPolicyKeepPatternController, void, int>(
      CleanupPolicyKeepPatternController.new,
    );
