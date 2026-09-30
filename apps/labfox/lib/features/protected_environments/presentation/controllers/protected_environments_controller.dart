import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/protected_environments_repository.dart';

final protectedEnvironmentsRepositoryProvider =
    FutureProvider<ProtectedEnvironmentsRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProtectedEnvironmentsRepository(client);
    });

class ProtectedEnvironmentsController
    extends FamilyAsyncNotifier<Paginated<ProtectedEnvironment>, int> {
  bool _loadingMore = false;

  @override
  Future<Paginated<ProtectedEnvironment>> build(int projectId) async {
    final repository = await ref.watch(
      protectedEnvironmentsRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(projectId);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        protectedEnvironmentsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(arg, page: page);
      state = AsyncData(
        Paginated(
          items: [...current.items, ...next.items],
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _loadingMore = false;
    }
  }
}

final protectedEnvironmentsControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentsController,
      Paginated<ProtectedEnvironment>,
      int
    >(ProtectedEnvironmentsController.new);

class ProtectedEnvironmentRef {
  const ProtectedEnvironmentRef({required this.projectId, required this.name});

  final int projectId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ProtectedEnvironmentRef &&
      projectId == other.projectId &&
      name == other.name;

  @override
  int get hashCode => Object.hash(projectId, name);
}

final protectedEnvironmentDetailProvider =
    FutureProvider.family<ProtectedEnvironment, ProtectedEnvironmentRef>((
      ref,
      key,
    ) async {
      final repository = await ref.watch(
        protectedEnvironmentsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.name);
    });

/// Creates one project rule after checking every currently listed page.
class ProtectedEnvironmentCreateController
    extends FamilyAsyncNotifier<void, int> {
  bool _disposed = false;

  @override
  void build(int projectId) {
    ref.watch(protectedEnvironmentsRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<void> inspectName(String name) async {
    final session = ref.read(protectedEnvironmentsRepositoryProvider.future);
    final repository = await session;
    if (_disposed ||
        !identical(
          session,
          ref.read(protectedEnvironmentsRepositoryProvider.future),
        )) {
      throw const GitLabConflictException('Protection session changed');
    }
    if (repository == null) throw StateError('No authenticated account');
    await repository.ensureNameAvailable(arg, name);
    if (_disposed ||
        !identical(
          session,
          ref.read(protectedEnvironmentsRepositoryProvider.future),
        )) {
      throw const GitLabConflictException('Protection session changed');
    }
  }

  Future<void> create(String name, {required int accessLevel}) async {
    if (state.isLoading) {
      throw StateError('Environment creation already pending');
    }
    if (name.trim().isEmpty ||
        name != name.trim() ||
        name.contains('*') ||
        !{30, 40}.contains(accessLevel)) {
      throw ArgumentError(
        'Exact environment name and supported deploy role required',
      );
    }
    final session = ref.read(protectedEnvironmentsRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(
          session,
          ref.read(protectedEnvironmentsRepositoryProvider.future),
        );
    var attempted = false;
    state = const AsyncLoading();
    try {
      await inspectName(name);
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      final repository = await session;
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      final created = await repository.createRoleOnly(
        arg,
        name,
        accessLevel: accessLevel,
      );
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (created.name != name ||
          created.deployAccessLevels.length != 1 ||
          created.deployAccessLevels.single.id == null ||
          created.deployAccessLevels.single.accessLevel != accessLevel ||
          created.deployAccessLevels.single.userId != null ||
          created.deployAccessLevels.single.groupId != null ||
          created.approvalRules.isNotEmpty ||
          created.requiredApprovalCount != 0) {
        throw const GitLabConflictException(
          'Unconfirmed environment protection',
        );
      }
      state = const AsyncData(null);
      ref.invalidate(protectedEnvironmentsControllerProvider(arg));
      ref.invalidate(
        protectedEnvironmentDetailProvider(
          ProtectedEnvironmentRef(projectId: arg, name: name),
        ),
      );
    } catch (error, stackTrace) {
      if (isCurrent()) {
        state = AsyncError(error, stackTrace);
        if (attempted) {
          ref.invalidate(protectedEnvironmentsControllerProvider(arg));
        }
      }
      rethrow;
    }
  }
}

final protectedEnvironmentCreateControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentCreateController,
      void,
      int
    >(ProtectedEnvironmentCreateController.new);

/// Session-bound compare-and-unprotect for one frozen project rule.
class ProtectedEnvironmentUnprotectController
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
    final detail = await repository.getComplete(arg.projectId, arg.name);
    if (!isCurrent()) {
      throw const GitLabConflictException('Protection session changed');
    }
    return detail;
  }

  Future<void> unprotect({required ProtectedEnvironment expected}) async {
    if (state.isLoading) {
      throw StateError('Environment unprotection already pending');
    }
    if (expected.name != arg.name || expected.name.trim().isEmpty) {
      throw ArgumentError('Exact frozen environment rule required');
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
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
      }
      if (current != expected) {
        throw const GitLabConflictException('Protection rule changed');
      }
      final repository = await session;
      if (repository == null) throw StateError('No authenticated account');
      attempted = true;
      await repository.unprotect(arg.projectId, arg.name);
      if (!isCurrent()) {
        throw const GitLabConflictException('Protection session changed');
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

final protectedEnvironmentUnprotectControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedEnvironmentUnprotectController,
      void,
      ProtectedEnvironmentRef
    >(ProtectedEnvironmentUnprotectController.new);

class GroupProtectedEnvironmentsController
    extends FamilyAsyncNotifier<Paginated<ProtectedEnvironment>, int> {
  bool _loadingMore = false;

  @override
  Future<Paginated<ProtectedEnvironment>> build(int groupId) async {
    final repository = await ref.watch(
      protectedEnvironmentsRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.listGroup(groupId);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        protectedEnvironmentsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.listGroup(arg, page: page);
      state = AsyncData(
        Paginated(
          items: [...current.items, ...next.items],
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _loadingMore = false;
    }
  }
}

final groupProtectedEnvironmentsControllerProvider =
    AsyncNotifierProvider.family<
      GroupProtectedEnvironmentsController,
      Paginated<ProtectedEnvironment>,
      int
    >(GroupProtectedEnvironmentsController.new);

class GroupProtectedEnvironmentRef {
  const GroupProtectedEnvironmentRef({
    required this.groupId,
    required this.name,
  });

  final int groupId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is GroupProtectedEnvironmentRef &&
      groupId == other.groupId &&
      name == other.name;

  @override
  int get hashCode => Object.hash(groupId, name);
}

final groupProtectedEnvironmentDetailProvider =
    FutureProvider.family<ProtectedEnvironment, GroupProtectedEnvironmentRef>((
      ref,
      key,
    ) async {
      final repository = await ref.watch(
        protectedEnvironmentsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.getGroup(key.groupId, key.name);
    });
