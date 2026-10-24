import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_cleanup_policy_controller.dart';
import 'container_registry_controllers.dart';

/// Do not change retention against unreported deletion/retention criteria.
bool canEditCleanupDeletePattern(ContainerCleanupPolicy? policy) =>
    policy != null &&
    policy.enabled != null &&
    policy.nameRegexKeep != null &&
    policy.cadence?.isNotEmpty == true &&
    policy.keepN != null &&
    policy.keepN! >= 0 &&
    policy.olderThan?.isNotEmpty == true &&
    (policy.nameRegexDelete ?? policy.nameRegex)?.isNotEmpty == true;

class CleanupPolicyDeletePatternController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> setDeletePattern({
    required ContainerCleanupPolicy expected,
    required String nameRegexDelete,
  }) async {
    if (state.isLoading) {
      throw StateError('A delete pattern update is already pending');
    }
    if (nameRegexDelete.trim().isEmpty ||
        nameRegexDelete == (expected.nameRegexDelete ?? expected.nameRegex) ||
        !canEditCleanupDeletePattern(expected)) {
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
      await repository.setCleanupPolicyDeletePattern(
        arg,
        nameRegexDelete: nameRegexDelete,
      );
      state = const AsyncData(null);
      ref.invalidate(containerCleanupPolicyControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyDeletePatternControllerProvider =
    AsyncNotifierProvider.family<
      CleanupPolicyDeletePatternController,
      void,
      int
    >(CleanupPolicyDeletePatternController.new);
