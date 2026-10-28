import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/project_activity_repository.dart';

final projectActivityRepositoryProvider =
    FutureProvider<ProjectActivityRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProjectActivityRepository(client);
    });

class ProjectActivityRef {
  const ProjectActivityRef({required this.projectId, this.targetType});

  final int projectId;
  final String? targetType;

  @override
  bool operator ==(Object other) =>
      other is ProjectActivityRef &&
      projectId == other.projectId &&
      targetType == other.targetType;

  @override
  int get hashCode => Object.hash(projectId, targetType);
}

class ProjectActivityController
    extends FamilyAsyncNotifier<Paginated<ProjectEvent>, ProjectActivityRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<ProjectEvent>> build(ProjectActivityRef arg) async {
    final repository = await ref.watch(
      projectActivityRepositoryProvider.future,
    );
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(arg.projectId, targetType: arg.targetType);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(
        projectActivityRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.projectId,
        targetType: arg.targetType,
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

final projectActivityControllerProvider =
    AsyncNotifierProvider.family<
      ProjectActivityController,
      Paginated<ProjectEvent>,
      ProjectActivityRef
    >(ProjectActivityController.new);
