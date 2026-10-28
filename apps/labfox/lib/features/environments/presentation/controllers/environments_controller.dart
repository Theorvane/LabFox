import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/environments_repository.dart';

final environmentsRepositoryProvider = FutureProvider<EnvironmentsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : EnvironmentsRepository(client);
});

class EnvironmentListRef {
  const EnvironmentListRef({required this.projectId, this.state, this.search});

  final int projectId;
  final String? state;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is EnvironmentListRef &&
      projectId == other.projectId &&
      state == other.state &&
      search == other.search;

  @override
  int get hashCode => Object.hash(projectId, state, search);
}

class EnvironmentRef {
  const EnvironmentRef({required this.projectId, required this.environmentId});
  final int projectId;
  final int environmentId;

  @override
  bool operator ==(Object other) =>
      other is EnvironmentRef &&
      projectId == other.projectId &&
      environmentId == other.environmentId;

  @override
  int get hashCode => Object.hash(projectId, environmentId);
}

class EnvironmentListController
    extends
        FamilyAsyncNotifier<Paginated<GitLabEnvironment>, EnvironmentListRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<GitLabEnvironment>> build(EnvironmentListRef arg) async {
    final repository = await ref.watch(environmentsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(arg.projectId, state: arg.state, search: arg.search);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(environmentsRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.projectId,
        state: arg.state,
        search: arg.search,
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

final environmentListControllerProvider =
    AsyncNotifierProvider.family<
      EnvironmentListController,
      Paginated<GitLabEnvironment>,
      EnvironmentListRef
    >(EnvironmentListController.new);

final environmentDetailProvider =
    FutureProvider.family<GitLabEnvironment, EnvironmentRef>((ref, key) async {
      final repository = await ref.watch(environmentsRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.environmentId);
    });
