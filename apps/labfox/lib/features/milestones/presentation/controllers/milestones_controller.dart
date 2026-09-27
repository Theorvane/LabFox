import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/group_milestones_repository.dart';
import '../../data/milestones_repository.dart';

final milestonesRepositoryProvider = FutureProvider<MilestonesRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : MilestonesRepository(client);
});

class MilestoneListRef {
  const MilestoneListRef({
    required this.projectId,
    required this.state,
    this.includeAncestors = false,
  });

  final int projectId;
  final String state;
  final bool includeAncestors;

  @override
  bool operator ==(Object other) =>
      other is MilestoneListRef &&
      projectId == other.projectId &&
      state == other.state &&
      includeAncestors == other.includeAncestors;

  @override
  int get hashCode => Object.hash(projectId, state, includeAncestors);
}

class MilestoneRef {
  const MilestoneRef({required this.projectId, required this.milestoneId});

  final int projectId;
  final int milestoneId;

  @override
  bool operator ==(Object other) =>
      other is MilestoneRef &&
      projectId == other.projectId &&
      milestoneId == other.milestoneId;

  @override
  int get hashCode => Object.hash(projectId, milestoneId);
}

/// Lists one milestone state and advances via response-header pagination.
class MilestoneListController
    extends FamilyAsyncNotifier<Paginated<GitLabMilestone>, MilestoneListRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<GitLabMilestone>> build(MilestoneListRef arg) async {
    final repository = await ref.watch(milestonesRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(
      arg.projectId,
      state: arg.state,
      includeAncestors: arg.includeAncestors,
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(milestonesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.projectId,
        state: arg.state,
        page: page,
        includeAncestors: arg.includeAncestors,
      );
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

  Future<GitLabMilestone> create({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) throw ArgumentError.value(title, 'title');
    if (startDate != null && dueDate != null && startDate.isAfter(dueDate)) {
      throw ArgumentError('Start date must not follow due date');
    }
    final repository = await ref.read(milestonesRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    final created = await repository.create(
      arg.projectId,
      title: trimmedTitle,
      description: description,
      startDate: startDate,
      dueDate: dueDate,
    );
    ref.invalidate(
      milestoneListControllerProvider(
        MilestoneListRef(projectId: arg.projectId, state: 'active'),
      ),
    );
    return created;
  }
}

final milestoneListControllerProvider =
    AsyncNotifierProvider.family<
      MilestoneListController,
      Paginated<GitLabMilestone>,
      MilestoneListRef
    >(MilestoneListController.new);

final milestoneDetailProvider =
    FutureProvider.family<GitLabMilestone, MilestoneRef>((ref, key) async {
      final repository = await ref.watch(milestonesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.milestoneId);
    });

class MilestoneEditController extends FamilyAsyncNotifier<void, MilestoneRef> {
  @override
  Future<void> build(MilestoneRef arg) async {}

  Future<GitLabMilestone> save({
    required String title,
    required String description,
    DateTime? startDate,
    DateTime? dueDate,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) throw ArgumentError.value(title, 'title');
    if (startDate != null && dueDate != null && startDate.isAfter(dueDate)) {
      throw ArgumentError.value(dueDate, 'dueDate');
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(milestonesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final updated = await repository.update(
        arg.projectId,
        arg.milestoneId,
        title: trimmedTitle,
        description: description,
        startDate: startDate,
        dueDate: dueDate,
        clearStartDate: clearStartDate,
        clearDueDate: clearDueDate,
      );
      ref.invalidate(milestoneDetailProvider(arg));
      ref.invalidate(milestoneListControllerProvider);
      state = const AsyncData(null);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final milestoneEditControllerProvider =
    AsyncNotifierProvider.family<MilestoneEditController, void, MilestoneRef>(
      MilestoneEditController.new,
    );

class MilestoneStateController extends FamilyAsyncNotifier<void, MilestoneRef> {
  @override
  Future<void> build(MilestoneRef arg) async {}

  Future<GitLabMilestone> change({required bool close}) async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(milestonesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final updated = await repository.setStateEvent(
        arg.projectId,
        arg.milestoneId,
        stateEvent: close ? 'close' : 'activate',
      );
      ref.invalidate(milestoneDetailProvider(arg));
      ref.invalidate(milestoneListControllerProvider);
      state = const AsyncData(null);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final milestoneStateControllerProvider =
    AsyncNotifierProvider.family<MilestoneStateController, void, MilestoneRef>(
      MilestoneStateController.new,
    );

final groupMilestonesRepositoryProvider =
    FutureProvider<GroupMilestonesRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : GroupMilestonesRepository(client);
    });

class GroupMilestoneListRef {
  const GroupMilestoneListRef({required this.groupId, required this.state});

  final int groupId;
  final String state;

  @override
  bool operator ==(Object other) =>
      other is GroupMilestoneListRef &&
      groupId == other.groupId &&
      state == other.state;

  @override
  int get hashCode => Object.hash(groupId, state);
}

class GroupMilestoneRef {
  const GroupMilestoneRef({required this.groupId, required this.milestoneId});

  final int groupId;
  final int milestoneId;

  @override
  bool operator ==(Object other) =>
      other is GroupMilestoneRef &&
      groupId == other.groupId &&
      milestoneId == other.milestoneId;

  @override
  int get hashCode => Object.hash(groupId, milestoneId);
}

class GroupMilestoneListController
    extends
        FamilyAsyncNotifier<Paginated<GitLabMilestone>, GroupMilestoneListRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<GitLabMilestone>> build(GroupMilestoneListRef arg) async {
    final repository = await ref.watch(
      groupMilestonesRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(arg.groupId, state: arg.state);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        groupMilestonesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.groupId,
        state: arg.state,
        page: page,
      );
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

final groupMilestoneListControllerProvider =
    AsyncNotifierProvider.family<
      GroupMilestoneListController,
      Paginated<GitLabMilestone>,
      GroupMilestoneListRef
    >(GroupMilestoneListController.new);

final groupMilestoneDetailProvider =
    FutureProvider.family<GitLabMilestone, GroupMilestoneRef>((ref, key) async {
      final repository = await ref.watch(
        groupMilestonesRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.groupId, key.milestoneId);
    });
