import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'protected_environments_controller.dart';

class ProtectedEnvironmentApprovalInheritanceController
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

  Future<void> edit({
    required ProtectedEnvironment expected,
    required int ruleId,
    required int groupInheritanceType,
  }) async {
    if (state.isLoading) {
      throw StateError('Approval membership update already pending');
    }
    if (expected.name != arg.name ||
        arg.name.trim().isEmpty ||
        arg.name != arg.name.trim() ||
        ruleId <= 0 ||
        !{0, 1}.contains(groupInheritanceType)) {
      throw ArgumentError(
        'Exact environment rule, rule ID and supported membership required',
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

    var attempted = false;
    state = const AsyncLoading();
    try {
      final current = await inspect();
      if (!isCurrent() || current != expected) {
        throw const GitLabConflictException('Protection rule changed');
      }
      final matches = current.approvalRules
          .where((rule) => rule.id == ruleId)
          .toList();
      if (matches.length != 1 ||
          !editableApprovalGroupMembership(matches.single) ||
          matches.single.groupInheritanceType == groupInheritanceType) {
        throw const GitLabConflictException(
          'Approval membership is unavailable or unchanged',
        );
      }
      final intended = expected.copyWith(
        approvalRules: [
          for (final rule in expected.approvalRules)
            rule.id == ruleId
                ? rule.copyWith(groupInheritanceType: groupInheritanceType)
                : rule,
        ],
      );
      final repository = await session;
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final updated = await repository.editApprovalGroupInheritance(
        arg.projectId,
        arg.name,
        ruleId: ruleId,
        groupInheritanceType: groupInheritanceType,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (updated != intended) {
        throw const GitLabServerException(
          'Unconfirmed environment approval membership',
        );
      }
      final confirmed = await repository.getForApprovalGroupEdit(
        arg.projectId,
        arg.name,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (confirmed != intended) {
        throw const GitLabServerException(
          'Unconfirmed environment approval membership',
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

bool editableApprovalGroupMembership(ProtectedEnvironmentAccess rule) =>
    rule.id != null &&
    rule.id! > 0 &&
    rule.groupId != null &&
    rule.groupId! > 0 &&
    rule.userId == null &&
    rule.accessLevel == null &&
    rule.requiredApprovals != null &&
    rule.requiredApprovals! > 0 &&
    {0, 1}.contains(rule.groupInheritanceType);

final protectedEnvironmentApprovalInheritanceControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentApprovalInheritanceController,
      void,
      ProtectedEnvironmentRef
    >(ProtectedEnvironmentApprovalInheritanceController.new);
