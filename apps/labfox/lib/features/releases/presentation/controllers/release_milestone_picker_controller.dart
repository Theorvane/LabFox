import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'releases_controller.dart';

typedef ReleaseMilestoneQuery = ({int projectId, String search});

/// Each query owns its pages so late responses cannot replace another search.
class ReleaseMilestonePickerController
    extends
        FamilyAsyncNotifier<Paginated<GitLabMilestone>, ReleaseMilestoneQuery> {
  bool _loadingMore = false;

  @override
  Future<Paginated<GitLabMilestone>> build(ReleaseMilestoneQuery arg) async {
    final repository = await ref.watch(releasesRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.listMilestones(arg.projectId, search: arg.search);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (_loadingMore || current == null || current.nextPage == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.listMilestones(
        arg.projectId,
        search: arg.search,
        page: current.nextPage!,
      );
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
      // Failed pagination leaves current rows intact and remains retryable.
      _loadingMore = false;
    }
  }
}

final releaseMilestonePickerControllerProvider =
    AsyncNotifierProvider.family<
      ReleaseMilestonePickerController,
      Paginated<GitLabMilestone>,
      ReleaseMilestoneQuery
    >(ReleaseMilestonePickerController.new);
