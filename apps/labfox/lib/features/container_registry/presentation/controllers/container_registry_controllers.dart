import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/container_registry_repository.dart';

final containerRegistryRepositoryProvider =
    FutureProvider<ContainerRegistryRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ContainerRegistryRepository(client);
    });

Future<ContainerRegistryRepository> _repository(Ref ref) async {
  final repository = await ref.watch(
    containerRegistryRepositoryProvider.future,
  );
  if (repository == null) throw StateError('No authenticated account');
  return repository;
}

class RegistryRef {
  const RegistryRef({required this.projectId, required this.repositoryId});

  final int projectId;
  final int repositoryId;

  @override
  bool operator ==(Object other) =>
      other is RegistryRef &&
      projectId == other.projectId &&
      repositoryId == other.repositoryId;

  @override
  int get hashCode => Object.hash(projectId, repositoryId);
}

class RegistryTagRef {
  const RegistryTagRef({required this.repository, required this.name});

  final RegistryRef repository;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is RegistryTagRef &&
      repository == other.repository &&
      name == other.name;

  @override
  int get hashCode => Object.hash(repository, name);
}

/// Image repository list with response-header pagination.
class ContainerRepositoriesController
    extends FamilyAsyncNotifier<Paginated<RegistryRepository>, int> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<Paginated<RegistryRepository>> build(int arg) async {
    _generation++;
    _loadingMore = false;
    return (await _repository(ref)).repositories(arg);
  }

  Future<void> loadMore() async {
    if (_loadingMore || state.isLoading) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final next = await (await _repository(ref)).repositories(arg, page: page);
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

final containerRepositoriesControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoriesController,
      Paginated<RegistryRepository>,
      int
    >(ContainerRepositoriesController.new);

/// Tags in one image repository.
class ContainerTagsController
    extends FamilyAsyncNotifier<Paginated<RegistryTag>, RegistryRef> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<Paginated<RegistryTag>> build(RegistryRef arg) async {
    _generation++;
    _loadingMore = false;
    return (await _repository(ref)).tags(arg.projectId, arg.repositoryId);
  }

  Future<void> loadMore() async {
    if (_loadingMore || state.isLoading) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final next = await (await _repository(
        ref,
      )).tags(arg.projectId, arg.repositoryId, page: page);
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

final containerTagsControllerProvider =
    AsyncNotifierProvider.family<
      ContainerTagsController,
      Paginated<RegistryTag>,
      RegistryRef
    >(ContainerTagsController.new);

final containerTagProvider = FutureProvider.family<RegistryTag, RegistryTagRef>(
  (ref, key) async => (await _repository(
    ref,
  )).tag(key.repository.projectId, key.repository.repositoryId, key.name),
);
