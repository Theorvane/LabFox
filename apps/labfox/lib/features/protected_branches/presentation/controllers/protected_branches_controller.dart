import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../../commits/presentation/controllers/history_controllers.dart';
import '../../data/protected_branches_repository.dart';

final protectedBranchesRepositoryProvider =
    FutureProvider<ProtectedBranchesRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProtectedBranchesRepository(client);
    });

class ProtectedBranchesController
    extends FamilyAsyncNotifier<Paginated<ProtectedBranch>, int> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<Paginated<ProtectedBranch>> build(int projectId) async {
    _generation++;
    _loadingMore = false;
    ref.onDispose(() => _generation++);
    final repository = await ref.watch(
      protectedBranchesRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(projectId);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    final generation = _generation;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        protectedBranchesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(arg, page: page);
      if (generation != _generation) return;
      state = AsyncData(
        Paginated(
          items: [...current.items, ...next.items],
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } catch (error, stackTrace) {
      if (generation == _generation) state = AsyncError(error, stackTrace);
    } finally {
      if (generation == _generation) _loadingMore = false;
    }
  }
}

final protectedBranchesControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedBranchesController,
      Paginated<ProtectedBranch>,
      int
    >(ProtectedBranchesController.new);

class ProtectedBranchRef {
  const ProtectedBranchRef({required this.projectId, required this.name});

  final int projectId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ProtectedBranchRef &&
      projectId == other.projectId &&
      name == other.name;

  @override
  int get hashCode => Object.hash(projectId, name);
}

final protectedBranchDetailProvider =
    FutureProvider.family<ProtectedBranch, ProtectedBranchRef>((
      ref,
      key,
    ) async {
      final repository = await ref.watch(
        protectedBranchesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.name);
    });

/// Session-bound, best-effort update of one frozen project rule.
class ProtectedBranchForcePushController
    extends FamilyAsyncNotifier<void, ProtectedBranchRef> {
  bool _disposed = false;

  @override
  void build(ProtectedBranchRef arg) {
    ref.watch(protectedBranchesRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<ProtectedBranch> inspect() async {
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        );
    final repository = await session;
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (repository == null) throw StateError('No authenticated account');
    final listed = await repository.findUnique(arg.projectId, arg.name);
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    final detail = await repository.get(arg.projectId, arg.name);
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (listed != detail) {
      throw const GitLabConflictException('Protection rule changed');
    }
    return detail;
  }

  Future<void> setForcePush({
    required ProtectedBranch expected,
    required bool allowForcePush,
  }) async {
    if (state.isLoading) throw StateError('Branch update is already pending');
    if (expected.name != arg.name || expected.name.trim().isEmpty) {
      throw ArgumentError('Exact frozen rule identity required');
    }
    if (expected.allowForcePush == allowForcePush) {
      throw ArgumentError('Force-push value must change');
    }
    if (expected.inherited == true) {
      throw const GitLabForbiddenException('Inherited protection rule');
    }
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        );
    void invalidate() {
      ref.invalidate(protectedBranchesControllerProvider(arg.projectId));
      ref.invalidate(protectedBranchDetailProvider(arg));
      ref.invalidate(branchesControllerProvider(arg.projectId));
    }

    var attempted = false;
    state = const AsyncLoading();
    try {
      final current = await inspect();
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (current != expected) {
        throw const GitLabConflictException('Protection rule changed');
      }
      if (current.inherited == true) {
        throw const GitLabForbiddenException('Inherited protection rule');
      }
      final repository = await session;
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final changed = await repository.updateForcePush(
        arg.projectId,
        arg.name,
        allowForcePush: allowForcePush,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (changed != expected.copyWith(allowForcePush: allowForcePush)) {
        throw const GitLabConflictException('Unconfirmed protection update');
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

final protectedBranchForcePushControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedBranchForcePushController,
      void,
      ProtectedBranchRef
    >(ProtectedBranchForcePushController.new);

/// Role-only rules can be edited without disturbing other merge grants.
ProtectedBranchAccess? editableProtectedBranchMergeAccess(
  ProtectedBranch rule,
) {
  if (rule.inherited == true || rule.mergeAccessLevels.length != 1) {
    return null;
  }
  final entry = rule.mergeAccessLevels.single;
  if (entry.id == null ||
      entry.id! <= 0 ||
      !{0, 30, 40}.contains(entry.accessLevel) ||
      entry.userId != null ||
      entry.groupId != null ||
      entry.deployKeyId != null ||
      entry.memberRoleId != null) {
    return null;
  }
  return entry;
}

/// Session-bound, best-effort update of one existing merge role record.
class ProtectedBranchMergeRoleController
    extends FamilyAsyncNotifier<void, ProtectedBranchRef> {
  bool _disposed = false;

  @override
  void build(ProtectedBranchRef arg) {
    ref.watch(protectedBranchesRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<ProtectedBranch> inspect() async {
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        );
    final repository = await session;
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (repository == null) throw StateError('No authenticated account');
    final listed = await repository.findUnique(arg.projectId, arg.name);
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    final detail = await repository.get(arg.projectId, arg.name);
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (listed != detail) {
      throw const GitLabConflictException('Protection rule changed');
    }
    return detail;
  }

  Future<void> setMergeRole({
    required ProtectedBranch expected,
    required int accessLevel,
  }) async {
    if (state.isLoading) throw StateError('Branch update is already pending');
    if (expected.name != arg.name || expected.name.trim().isEmpty) {
      throw ArgumentError('Exact frozen rule identity required');
    }
    if (expected.inherited == true) {
      throw const GitLabForbiddenException('Inherited protection rule');
    }
    final entry = editableProtectedBranchMergeAccess(expected);
    if (entry == null ||
        !{0, 30, 40}.contains(accessLevel) ||
        entry.accessLevel == accessLevel) {
      throw ArgumentError('One changed role-based merge record required');
    }
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        );
    void invalidate() {
      ref.invalidate(protectedBranchesControllerProvider(arg.projectId));
      ref.invalidate(protectedBranchDetailProvider(arg));
      ref.invalidate(branchesControllerProvider(arg.projectId));
    }

    var attempted = false;
    state = const AsyncLoading();
    try {
      final current = await inspect();
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (current != expected) {
        throw const GitLabConflictException('Protection rule changed');
      }
      if (editableProtectedBranchMergeAccess(current) == null) {
        throw const GitLabConflictException('Unsupported protection rule');
      }
      final repository = await session;
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final changed = await repository.updateMergeRole(
        arg.projectId,
        arg.name,
        accessRecordId: entry.id!,
        accessLevel: accessLevel,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      final changedEntry = editableProtectedBranchMergeAccess(changed);
      if (changedEntry == null ||
          changedEntry.id != entry.id ||
          changedEntry.accessLevel != accessLevel ||
          changed !=
              expected.copyWith(
                mergeAccessLevels: [
                  entry.copyWith(
                    accessLevel: accessLevel,
                    description: changedEntry.description,
                  ),
                ],
              )) {
        throw const GitLabConflictException('Unconfirmed protection update');
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

final protectedBranchMergeRoleControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedBranchMergeRoleController,
      void,
      ProtectedBranchRef
    >(ProtectedBranchMergeRoleController.new);

/// Best-effort compare-and-unprotect for an exact project rule.
class ProtectedBranchUnprotectController
    extends FamilyAsyncNotifier<void, ProtectedBranchRef> {
  bool _disposed = false;

  @override
  void build(ProtectedBranchRef arg) {
    ref.watch(protectedBranchesRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<ProtectedBranch> inspect() async {
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    final repository = await session;
    if (_disposed ||
        !identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        )) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (repository == null) throw StateError('No authenticated account');
    final listed = await repository.findUnique(arg.projectId, arg.name);
    if (_disposed ||
        !identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        )) {
      throw const GitLabConflictException('Protection session changed');
    }
    final detail = await repository.get(arg.projectId, arg.name);
    if (_disposed ||
        !identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        )) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (listed != detail) {
      throw const GitLabConflictException('Protection rule changed');
    }
    return detail;
  }

  Future<void> unprotect({required ProtectedBranch expected}) async {
    if (state.isLoading) {
      throw StateError('Branch unprotection is already pending');
    }
    if (expected.name != arg.name || expected.name.trim().isEmpty) {
      throw ArgumentError('Exact frozen rule identity required');
    }
    if (expected.inherited == true) {
      throw const GitLabForbiddenException('Inherited protection rule');
    }
    final session = ref.read(protectedBranchesRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedBranchesRepositoryProvider.future),
        );
    state = const AsyncLoading();
    try {
      final current = await inspect();
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (current != expected) {
        throw const GitLabConflictException('Protection rule changed');
      }
      if (current.inherited == true) {
        throw const GitLabForbiddenException('Inherited protection rule');
      }
      final repository = await session;
      if (repository == null) throw StateError('No authenticated account');
      await repository.unprotect(arg.projectId, arg.name);
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      state = const AsyncData(null);
      ref.invalidate(protectedBranchesControllerProvider(arg.projectId));
      ref.invalidate(protectedBranchDetailProvider(arg));
      ref.invalidate(branchesControllerProvider(arg.projectId));
    } catch (error, stackTrace) {
      if (isCurrent()) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final protectedBranchUnprotectControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedBranchUnprotectController,
      void,
      ProtectedBranchRef
    >(ProtectedBranchUnprotectController.new);
