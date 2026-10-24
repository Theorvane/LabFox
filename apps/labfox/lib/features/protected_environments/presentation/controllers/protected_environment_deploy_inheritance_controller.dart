import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'protected_environments_controller.dart';

class ProtectedEnvironmentDeployInheritanceController
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

  Future<void> edit({
    required ProtectedEnvironment expected,
    required int grantId,
    required int groupInheritanceType,
  }) async {
    if (state.isLoading) {
      throw StateError('Deploy membership update already pending');
    }
    if (expected.name != arg.name ||
        arg.name.trim().isEmpty ||
        arg.name != arg.name.trim() ||
        grantId <= 0 ||
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
      final matches = current.deployAccessLevels
          .where((rule) => rule.id == grantId)
          .toList();
      if (matches.length != 1 ||
          !editableDeployGroupMembership(matches.single) ||
          matches.single.groupInheritanceType == groupInheritanceType) {
        throw const GitLabConflictException(
          'Deploy membership is unavailable or unchanged',
        );
      }
      final intended = expected.copyWith(
        deployAccessLevels: [
          for (final rule in expected.deployAccessLevels)
            rule.id == grantId
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
      final updated = await repository.editDeployGroupInheritance(
        arg.projectId,
        arg.name,
        grantId: grantId,
        groupInheritanceType: groupInheritanceType,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (updated != intended) {
        throw const GitLabServerException(
          'Unconfirmed environment deploy membership',
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
          'Unconfirmed environment deploy membership',
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

bool editableDeployGroupMembership(ProtectedEnvironmentAccess rule) =>
    rule.id != null &&
    rule.id! > 0 &&
    rule.groupId != null &&
    rule.groupId! > 0 &&
    rule.userId == null &&
    {0, 1}.contains(rule.groupInheritanceType);

final protectedEnvironmentDeployInheritanceControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentDeployInheritanceController,
      void,
      ProtectedEnvironmentRef
    >(ProtectedEnvironmentDeployInheritanceController.new);
