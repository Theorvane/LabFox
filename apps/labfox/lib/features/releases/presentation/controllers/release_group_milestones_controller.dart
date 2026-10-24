import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/release_group_milestones_repository.dart';

final releaseGroupMilestonesRepositoryProvider =
    FutureProvider<ReleaseGroupMilestonesRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ReleaseGroupMilestonesRepository(client);
    });

typedef ReleaseGroupMilestoneQuery = ({int projectId, String search});

/// Search pages are isolated by query; group identity is never inferred from paths.
class ReleaseGroupMilestonesController
    extends
        FamilyAsyncNotifier<
          Paginated<GitLabMilestone>,
          ReleaseGroupMilestoneQuery
        > {
  int _generation = 0;
  int? _groupId;
  bool _loadingMore = false;

  @override
  Future<Paginated<GitLabMilestone>> build(
    ReleaseGroupMilestoneQuery arg,
  ) async {
    final generation = ++_generation;
    _loadingMore = false;
    _groupId = null;
    ref.onDispose(() => _generation++);
    final repository = await ref.watch(
      releaseGroupMilestonesRepositoryProvider.future,
    );
    if (generation != _generation) return const Paginated(items: []);
    if (repository == null) throw StateError('No authenticated account');
    final groupId = await repository.getDirectGroupId(arg.projectId);
    if (generation != _generation) return const Paginated(items: []);
    _groupId = groupId;
    if (_groupId == null) return const Paginated(items: []);
    return repository.list(_groupId!, search: arg.search.trim());
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    final groupId = _groupId;
    if (state.isLoading ||
        _loadingMore ||
        current == null ||
        current.nextPage == null ||
        groupId == null) {
      return;
    }
    final generation = _generation;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        releaseGroupMilestonesRepositoryProvider.future,
      );
      if (generation != _generation) return;
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        groupId,
        search: arg.search.trim(),
        page: current.nextPage!,
      );
      if (generation != _generation) return;
      state = AsyncData(
        Paginated(
          items: {
            for (final milestone in [...current.items, ...next.items])
              milestone.id: milestone,
          }.values.toList(growable: false),
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } finally {
      if (generation == _generation) _loadingMore = false;
    }
  }
}

final releaseGroupMilestonesControllerProvider =
    AsyncNotifierProvider.family<
      ReleaseGroupMilestonesController,
      Paginated<GitLabMilestone>,
      ReleaseGroupMilestoneQuery
    >(ReleaseGroupMilestonesController.new);
