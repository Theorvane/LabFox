import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'protected_environments_controller.dart';

class ProtectedEnvironmentApprovalGroupController
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
    final detail = await repository.getForApprovalGroupEdit(
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
    required int requiredApprovals,
  }) async {
    if (state.isLoading) {
      throw StateError('Approval group update already pending');
    }
    if (expected.name != arg.name ||
        arg.name.trim().isEmpty ||
        arg.name != arg.name.trim() ||
        groupId <= 0 ||
        requiredApprovals < 1 ||
        requiredApprovals > 5) {
      throw ArgumentError(
        'Exact environment rule, positive group ID and supported approval count required',
      );
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
      final added = updated.approvalRules
          .where((rule) => !expected.approvalRules.contains(rule))
          .toList();
      if (updated.copyWith(approvalRules: expected.approvalRules) != expected ||
          updated.approvalRules.length != expected.approvalRules.length + 1 ||
          !expected.approvalRules.every(updated.approvalRules.contains) ||
          added.length != 1 ||
          added.single.id == null ||
          added.single.id! <= 0 ||
          expected.approvalRules.any((rule) => rule.id == added.single.id) ||
          added.single.groupId != groupId ||
          added.single.requiredApprovals != requiredApprovals ||
          added.single.groupInheritanceType != 0 ||
          added.single.userId != null ||
          added.single.accessLevel != null) {
        throw const GitLabServerException(
          'Unconfirmed environment approval group',
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
      if (current.approvalRules.any((rule) => rule.groupId == groupId)) {
        throw const GitLabConflictException('Approval group already granted');
      }
      final repository = await session;
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final updated = await repository.addApprovalGroup(
        arg.projectId,
        arg.name,
        groupId: groupId,
        requiredApprovals: requiredApprovals,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      confirm(updated);
      final confirmed = await repository.getForApprovalGroupEdit(
        arg.projectId,
        arg.name,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      confirm(confirmed);
      if (confirmed != updated) {
        throw const GitLabServerException(
          'Environment approval group changed during confirmation',
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

final protectedEnvironmentApprovalGroupControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentApprovalGroupController,
      void,
      ProtectedEnvironmentRef
    >(ProtectedEnvironmentApprovalGroupController.new);
