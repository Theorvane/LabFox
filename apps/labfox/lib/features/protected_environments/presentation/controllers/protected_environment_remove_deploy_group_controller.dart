import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'protected_environments_controller.dart';

class ProtectedEnvironmentRemoveDeployGroupController
    extends FamilyAsyncNotifier<void, ProtectedEnvironmentRef> {
  bool _disposed = false;

  @override
  void build(ProtectedEnvironmentRef arg) {
    ref.watch(protectedEnvironmentsRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<ProtectedEnvironment> inspect() async {
    final session = ref.read(protectedEnvironmentsRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedEnvironmentsRepositoryProvider.future),
        );
    final repository = await session;
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (repository == null) throw StateError('No authenticated account');
    await repository.ensureUniqueName(arg.projectId, arg.name);
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    final detail = await repository.getForDeployGroupEdit(
      arg.projectId,
      arg.name,
    );
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    return detail;
  }

  Future<void> remove({
    required ProtectedEnvironment expected,
    required int grantId,
  }) async {
    if (state.isLoading) {
      throw StateError('Deploy group removal already pending');
    }
    if (expected.name != arg.name ||
        arg.name.trim().isEmpty ||
        arg.name != arg.name.trim() ||
        grantId <= 0) {
      throw ArgumentError('Exact environment rule, deploy grant ID required');
    }
    final session = ref.read(protectedEnvironmentsRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedEnvironmentsRepositoryProvider.future),
        );
    void invalidate() {
      ref.invalidate(protectedEnvironmentsControllerProvider(arg.projectId));
      ref.invalidate(protectedEnvironmentDetailProvider(arg));
    }

    var attempted = false;
    state = const AsyncLoading();
    try {
      final current = await inspect();
      if (!isCurrent() || current != expected) {
        throw const GitLabConflictException('Protection rule changed');
      }
      final matches = current.deployAccessLevels
          .where((rule) => rule.id == grantId)
          .toList();
      if (matches.length != 1 || !removableDeployGroup(matches.single)) {
        throw const GitLabConflictException(
          'Deploy group removal is unavailable',
        );
      }
      final intended = expected.copyWith(
        deployAccessLevels: [
          for (final rule in expected.deployAccessLevels)
            if (rule.id != grantId) rule,
        ],
      );
      final repository = await session;
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final updated = await repository.removeDeployGroup(
        arg.projectId,
        arg.name,
        grantId: grantId,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (updated != intended) {
        throw const GitLabServerException(
          'Unconfirmed environment deploy group removal',
        );
      }
      final confirmed = await repository.getForDeployGroupEdit(
        arg.projectId,
        arg.name,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (confirmed != intended) {
        throw const GitLabServerException(
          'Unconfirmed environment deploy group removal',
        );
      }
      state = const AsyncData(null);
      invalidate();
    } catch (error, stackTrace) {
      if (isCurrent()) {
        state = AsyncError(error, stackTrace);
        if (attempted) invalidate();
      }
      rethrow;
    }
  }
}

bool removableDeployGroup(ProtectedEnvironmentAccess rule) =>
    rule.id != null &&
    rule.id! > 0 &&
    rule.groupId != null &&
    rule.groupId! > 0 &&
    rule.userId == null &&
    {0, 1}.contains(rule.groupInheritanceType);

final protectedEnvironmentRemoveDeployGroupControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentRemoveDeployGroupController,
      void,
      ProtectedEnvironmentRef
    >(ProtectedEnvironmentRemoveDeployGroupController.new);
