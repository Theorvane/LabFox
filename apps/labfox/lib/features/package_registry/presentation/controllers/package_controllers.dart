import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/package_overview.dart';
import '../../data/package_registry_repository.dart';

final packageRegistryRepositoryProvider =
    FutureProvider<PackageRegistryRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : PackageRegistryRepository(client);
    });

/// Lists a project's packages and advances through response-header pagination.
class PackageListController
    extends FamilyAsyncNotifier<Paginated<GitLabPackage>, int> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<Paginated<GitLabPackage>> build(int arg) async {
    _generation++;
    _loadingMore = false;
    final repository = await ref.watch(
      packageRegistryRepositoryProvider.future,
    );
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.list(arg);
  }

  Future<void> loadMore() async {
    if (_loadingMore || state.isLoading) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final repository = await ref.read(
        packageRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(arg, page: page);
      if (generation != _generation) return;
      state = AsyncData(
        Paginated<GitLabPackage>(
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

final packageListControllerProvider =
    AsyncNotifierProvider.family<
      PackageListController,
      Paginated<GitLabPackage>,
      int
    >(PackageListController.new);

/// A package belongs to one project but has its own global package ID.
class PackageRef {
  const PackageRef({required this.projectId, required this.packageId});

  final int projectId;
  final int packageId;

  @override
  bool operator ==(Object other) =>
      other is PackageRef &&
      other.projectId == projectId &&
      other.packageId == packageId;

  @override
  int get hashCode => Object.hash(projectId, packageId);
}

/// Loads package metadata and advances its file list independently.
class PackageDetailController
    extends FamilyAsyncNotifier<PackageOverview, PackageRef> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<PackageOverview> build(PackageRef arg) async {
    _generation++;
    _loadingMore = false;
    final repository = await ref.watch(
      packageRegistryRepositoryProvider.future,
    );
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.load(arg.projectId, arg.packageId);
  }

  Future<void> loadMoreFiles() async {
    if (_loadingMore || state.isLoading) return;
    final current = state.valueOrNull;
    final page = current?.files.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final repository = await ref.read(
        packageRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.files(
        arg.projectId,
        arg.packageId,
        page: page,
      );
      if (generation != _generation) return;
      state = AsyncData(
        current.withFiles(
          Paginated<PackageFile>(
            items: [...current.files.items, ...next.items],
            nextPage: next.nextPage,
            total: next.total,
            totalPages: next.totalPages,
          ),
        ),
      );
    } catch (error, stackTrace) {
      if (generation == _generation) state = AsyncError(error, stackTrace);
    } finally {
      if (generation == _generation) _loadingMore = false;
    }
  }
}

final packageDetailControllerProvider =
    AsyncNotifierProvider.family<
      PackageDetailController,
      PackageOverview,
      PackageRef
    >(PackageDetailController.new);
