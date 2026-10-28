import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../commits/presentation/controllers/history_controllers.dart';
import 'protected_branches_controller.dart';

const protectedBranchRoleLevels = [0, 30, 40];

/// Creates one project rule after a complete best-effort duplicate scan.
class ProtectedBranchProtectController extends FamilyAsyncNotifier<void, int> {
  bool _disposed = false;

  @override
  void build(int arg) {
    ref.watch(protectedBranchesRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  bool _isCurrent(Object session) =>
      !_disposed &&
      identical(session, ref.read(protectedBranchesRepositoryProvider.future));

  void _requireCurrent(Object session) {
    if (!_isCurrent(session)) {
      throw const GitLabConflictException('Protected branch session changed');
    }
  }

  Future<bool> inspect(String name) async {
    if (state.isLoading) throw StateError('Creation is already pending');
    if (name.trim().isEmpty) throw ArgumentError('Exact rule name required');
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    final repository = await session;
    _requireCurrent(session);
    if (repository == null) throw StateError('No authenticated account');
    final exists = await repository.containsName(arg, name);
    _requireCurrent(session);
    return exists;
  }

  Future<void> protect({
    required String name,
    required int pushAccessLevel,
    required int mergeAccessLevel,
  }) async {
    if (state.isLoading) throw StateError('Creation is already pending');
    if (name.trim().isEmpty ||
        !protectedBranchRoleLevels.contains(pushAccessLevel) ||
        !protectedBranchRoleLevels.contains(mergeAccessLevel)) {
      throw ArgumentError(
        'Exact name and supported push and merge roles required',
      );
    }
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    state = const AsyncLoading();
    try {
      final repository = await session;
      _requireCurrent(session);
      if (repository == null) throw StateError('No authenticated account');
      final exists = await repository.containsName(arg, name);
      _requireCurrent(session);
      if (exists) {
        throw const GitLabConflictException(
          'Protected branch rule already exists',
        );
      }
      final created = await repository.protect(
        arg,
        name: name,
        pushAccessLevel: pushAccessLevel,
        mergeAccessLevel: mergeAccessLevel,
      );
      _requireCurrent(session);
      if (created.name != name ||
          created.pushAccessLevels.length != 1 ||
          created.mergeAccessLevels.length != 1 ||
          created.pushAccessLevels.single.accessLevel != pushAccessLevel ||
          created.mergeAccessLevels.single.accessLevel != mergeAccessLevel ||
          created.allowForcePush ||
          created.codeOwnerApprovalRequired ||
          created.inherited == true) {
        throw const GitLabServerException(
          'Unconfirmed protected branch creation',
        );
      }
      state = const AsyncData(null);
      ref.invalidate(protectedBranchesControllerProvider(arg));
      ref.invalidate(
        protectedBranchDetailProvider(
          ProtectedBranchRef(projectId: arg, name: name),
        ),
      );
      ref.invalidate(branchesControllerProvider(arg));
    } catch (error, stackTrace) {
      if (_isCurrent(session)) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final protectedBranchProtectControllerProvider =
    AsyncNotifierProvider.family<ProtectedBranchProtectController, void, int>(
      ProtectedBranchProtectController.new,
    );
