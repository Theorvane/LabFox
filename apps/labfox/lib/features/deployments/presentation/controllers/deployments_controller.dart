import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/deployments_repository.dart';

final deploymentsRepositoryProvider = FutureProvider<DeploymentsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : DeploymentsRepository(client);
});

class DeploymentListRef {
  const DeploymentListRef({
    required this.projectId,
    this.environment,
    this.status,
  });

  final int projectId;
  final String? environment;
  final String? status;

  @override
  bool operator ==(Object other) =>
      other is DeploymentListRef &&
      projectId == other.projectId &&
      environment == other.environment &&
      status == other.status;

  @override
  int get hashCode => Object.hash(projectId, environment, status);
}

class DeploymentRef {
  const DeploymentRef({required this.projectId, required this.deploymentId});

  final int projectId;
  final int deploymentId;

  @override
  bool operator ==(Object other) =>
      other is DeploymentRef &&
      projectId == other.projectId &&
      deploymentId == other.deploymentId;

  @override
  int get hashCode => Object.hash(projectId, deploymentId);
}

class DeploymentListController
    extends
        FamilyAsyncNotifier<Paginated<GitLabDeployment>, DeploymentListRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<GitLabDeployment>> build(DeploymentListRef arg) async {
    final repository = await ref.watch(deploymentsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(
      arg.projectId,
      environment: arg.environment,
      status: arg.status,
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(deploymentsRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.projectId,
        environment: arg.environment,
        status: arg.status,
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

final deploymentListControllerProvider =
    AsyncNotifierProvider.family<
      DeploymentListController,
      Paginated<GitLabDeployment>,
      DeploymentListRef
    >(DeploymentListController.new);

final deploymentDetailProvider =
    FutureProvider.family<GitLabDeployment, DeploymentRef>((ref, key) async {
      final repository = await ref.watch(deploymentsRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.deploymentId);
    });
