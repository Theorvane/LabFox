import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'protected_environments_controller.dart';

class ProtectedEnvironmentDeployGroupController
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

  Future<void> add({
    required ProtectedEnvironment expected,
    required int groupId,
  }) async {
    if (state.isLoading) {
      throw StateError('Deploy group update already pending');
    }
    if (expected.name != arg.name ||
        arg.name.trim().isEmpty ||
        arg.name != arg.name.trim() ||
        groupId <= 0) {
      throw ArgumentError('Exact environment rule, positive group ID required');
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

    void confirm(ProtectedEnvironment updated) {
      final added = updated.deployAccessLevels
          .where((rule) => !expected.deployAccessLevels.contains(rule))
          .toList();
      if (updated.copyWith(deployAccessLevels: expected.deployAccessLevels) !=
              expected ||
          updated.deployAccessLevels.length !=
              expected.deployAccessLevels.length + 1 ||
          !expected.deployAccessLevels.every(
            updated.deployAccessLevels.contains,
          ) ||
          added.length != 1 ||
          added.single.id == null ||
          added.single.id! <= 0 ||
          expected.deployAccessLevels.any(
            (rule) => rule.id == added.single.id,
          ) ||
          added.single.groupId != groupId ||
          added.single.groupInheritanceType != 0 ||
          added.single.userId != null ||
          added.single.requiredApprovals != null) {
        throw const GitLabServerException(
          'Unconfirmed environment deploy group',
        );
      }
    }

    var attempted = false;
    state = const AsyncLoading();
    try {
      final current = await inspect();
      if (!isCurrent() || current != expected) {
        throw const GitLabConflictException('Protection rule changed');
      }
      if (current.deployAccessLevels.any((rule) => rule.groupId == groupId)) {
        throw const GitLabConflictException('Deploy group already granted');
      }
      final repository = await session;
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final updated = await repository.addDeployGroup(
        arg.projectId,
        arg.name,
        groupId: groupId,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      confirm(updated);
      final confirmed = await repository.getForDeployGroupEdit(
        arg.projectId,
        arg.name,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      confirm(confirmed);
      if (confirmed != updated) {
        throw const GitLabServerException(
          'Environment deploy group changed during confirmation',
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

final protectedEnvironmentDeployGroupControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentDeployGroupController,
      void,
      ProtectedEnvironmentRef
    >(ProtectedEnvironmentDeployGroupController.new);
