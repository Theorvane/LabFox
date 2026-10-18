import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'protected_environments_controller.dart';

class ProtectedEnvironmentApprovalGroupEditController
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
    required int groupId,
  }) async {
    if (state.isLoading) {
      throw StateError('Approval group replacement already pending');
    }
    if (expected.name != arg.name ||
        arg.name.trim().isEmpty ||
        arg.name != arg.name.trim() ||
        ruleId <= 0 ||
        groupId <= 0) {
      throw ArgumentError(
        'Exact environment rule and positive record and group IDs required',
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

    void confirm(ProtectedEnvironment actual) {
      final matches = actual.approvalRules
          .where((rule) => rule.id == ruleId)
          .toList();
      if (matches.length != 1) {
        throw const GitLabServerException(
          'Unconfirmed approval group replacement',
        );
      }
      final intended = expected.copyWith(
        approvalRules: [
          for (final rule in expected.approvalRules)
            rule.id == ruleId
                ? rule.copyWith(
                    groupId: groupId,
                    description: matches.single.description,
                  )
                : rule,
        ],
      );
      if (actual != intended) {
        throw const GitLabServerException(
          'Unconfirmed approval group replacement',
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
      final matches = current.approvalRules
          .where((rule) => rule.id == ruleId)
          .toList();
      if (matches.length != 1 ||
          !editableApprovalGroupTarget(matches.single) ||
          current.approvalRules.any((rule) => rule.groupId == groupId)) {
        throw const GitLabConflictException(
          'Approval group is unavailable, unchanged or already represented',
        );
      }
      final repository = await session;
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final updated = await repository.editApprovalGroup(
        arg.projectId,
        arg.name,
        ruleId: ruleId,
        groupId: groupId,
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
          'Approval group changed during confirmation',
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

bool editableApprovalGroupTarget(ProtectedEnvironmentAccess rule) =>
    rule.id != null &&
    rule.id! > 0 &&
    rule.groupId != null &&
    rule.groupId! > 0 &&
    rule.userId == null &&
    rule.accessLevel == null &&
    rule.requiredApprovals != null &&
    rule.requiredApprovals! > 0 &&
    {0, 1}.contains(rule.groupInheritanceType);

final protectedEnvironmentApprovalGroupEditControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentApprovalGroupEditController,
      void,
      ProtectedEnvironmentRef
    >(ProtectedEnvironmentApprovalGroupEditController.new);
