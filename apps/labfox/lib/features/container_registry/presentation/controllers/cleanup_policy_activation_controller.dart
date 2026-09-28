import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_cleanup_policy_controller.dart';
import 'container_registry_controllers.dart';

/// Changes activation only, after a best-effort check of reviewed settings.
class CleanupPolicyActivationController extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> setEnabled({
    required ContainerCleanupPolicy expected,
    required bool enabled,
  }) async {
    if (state.isLoading) throw StateError('A policy update is already pending');
    if (expected.enabled == null ||
        expected.enabled == enabled ||
        enabled && !canEnableCleanupPolicy(expected)) {
      throw ArgumentError('A known policy status must change');
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final current = await repository.cleanupPolicy(arg);
      if (current == null ||
          current.enabled == null ||
          current.copyWith(nextRunAt: null) !=
              expected.copyWith(nextRunAt: null)) {
        throw const GitLabConflictException(
          'Cleanup policy changed since confirmation',
        );
      }
      await repository.setCleanupPolicyEnabled(arg, enabled: enabled);
      state = const AsyncData(null);
      ref.invalidate(containerCleanupPolicyControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final cleanupPolicyActivationControllerProvider =
    AsyncNotifierProvider.family<CleanupPolicyActivationController, void, int>(
      CleanupPolicyActivationController.new,
    );

/// Never activate against unknown core deletion/retention criteria.
bool canEnableCleanupPolicy(ContainerCleanupPolicy policy) =>
    policy.cadence?.isNotEmpty == true &&
    policy.keepN != null &&
    policy.keepN! >= 0 &&
    policy.olderThan?.isNotEmpty == true &&
    (policy.nameRegexDelete ?? policy.nameRegex)?.isNotEmpty == true;
