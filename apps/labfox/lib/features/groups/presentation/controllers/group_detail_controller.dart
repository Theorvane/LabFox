import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/group_detail_repository.dart';
import '../../data/group_overview.dart';

final groupDetailRepositoryProvider = FutureProvider<GroupDetailRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : GroupDetailRepository(client);
});

/// Loads one group and advances its project and subgroup lists independently.
class GroupDetailController extends FamilyAsyncNotifier<GroupOverview, int> {
  @override
  Future<GroupOverview> build(int arg) async {
    final repository = await ref.watch(groupDetailRepositoryProvider.future);
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.load(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(groupDetailRepositoryProvider.future);
      if (repository == null) {
        throw StateError('No authenticated account');
      }
      return repository.load(arg);
    });
  }

  Future<void> loadMoreProjects() async {
    final current = state.valueOrNull;
    final page = current?.projects.nextPage;
    if (current == null || page == null) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(groupDetailRepositoryProvider.future);
      if (repository == null) {
        throw StateError('No authenticated account');
      }
      final next = await repository.projectsPage(arg, page: page);
      return current.withProjects(
        Paginated<Project>(
          items: [...current.projects.items, ...next.items],
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    });
  }

  Future<void> loadMoreSubgroups() async {
    final current = state.valueOrNull;
    final page = current?.subgroups.nextPage;
    if (current == null || page == null) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(groupDetailRepositoryProvider.future);
      if (repository == null) {
        throw StateError('No authenticated account');
      }
      final next = await repository.subgroupsPage(arg, page: page);
      return current.withSubgroups(
        Paginated<Group>(
          items: [...current.subgroups.items, ...next.items],
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    });
  }
}

final groupDetailControllerProvider =
    AsyncNotifierProvider.family<GroupDetailController, GroupOverview, int>(
      GroupDetailController.new,
    );
