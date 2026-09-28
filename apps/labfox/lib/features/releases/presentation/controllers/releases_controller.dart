import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/releases_repository.dart';

final releasesRepositoryProvider = FutureProvider<ReleasesRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : ReleasesRepository(client);
});

class ReleaseRef {
  const ReleaseRef({required this.projectId, required this.tagName});

  final int projectId;
  final String tagName;

  @override
  bool operator ==(Object other) =>
      other is ReleaseRef &&
      projectId == other.projectId &&
      tagName == other.tagName;

  @override
  int get hashCode => Object.hash(projectId, tagName);
}

/// Paginated project Releases list.
class ReleaseListController
    extends FamilyAsyncNotifier<Paginated<GitLabRelease>, int> {
  bool _loadingMore = false;

  @override
  Future<Paginated<GitLabRelease>> build(int arg) async {
    final repository = await ref.watch(releasesRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(arg);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
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

  Future<GitLabRelease> create({
    required String tagName,
    String? ref,
    String? name,
    String? description,
  }) async {
    final trimmedTag = tagName.trim();
    if (trimmedTag.isEmpty) throw ArgumentError.value(tagName, 'tagName');
    final repository = await this.ref.read(releasesRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    final created = await repository.create(
      arg,
      tagName: trimmedTag,
      ref: ref?.trim().isEmpty == true ? null : ref?.trim(),
      name: name?.trim().isEmpty == true ? null : name?.trim(),
      description: description?.trim().isEmpty == true
          ? null
          : description?.trim(),
    );
    this.ref.invalidateSelf();
    return created;
  }
}

final releaseListControllerProvider =
    AsyncNotifierProvider.family<
      ReleaseListController,
      Paginated<GitLabRelease>,
      int
    >(ReleaseListController.new);

final releaseDetailProvider = FutureProvider.family<GitLabRelease, ReleaseRef>((
  ref,
  key,
) async {
  final repository = await ref.watch(releasesRepositoryProvider.future);
  if (repository == null) throw StateError('No authenticated account');
  return repository.get(key.projectId, key.tagName);
});

class ReleaseEditController extends FamilyAsyncNotifier<void, ReleaseRef> {
  @override
  Future<void> build(ReleaseRef arg) async {}

  Future<GitLabRelease> save({
    required String name,
    required String description,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) throw ArgumentError.value(name, 'name');
    state = const AsyncLoading();
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final updated = await repository.update(
        arg.projectId,
        arg.tagName,
        name: trimmedName,
        description: description.trim(),
      );
      ref.invalidate(releaseDetailProvider(arg));
      ref.invalidate(releaseListControllerProvider(arg.projectId));
      state = const AsyncData(null);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final releaseEditControllerProvider =
    AsyncNotifierProvider.family<ReleaseEditController, void, ReleaseRef>(
      ReleaseEditController.new,
    );

class ReleaseScheduleController extends FamilyAsyncNotifier<void, ReleaseRef> {
  @override
  Future<void> build(ReleaseRef arg) async {}

  Future<void> save(DateTime releasedAt) async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      await repository.updateReleasedAt(
        arg.projectId,
        arg.tagName,
        releasedAt.toUtc(),
      );
      ref.invalidate(releaseDetailProvider(arg));
      ref.invalidate(releaseListControllerProvider(arg.projectId));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final releaseScheduleControllerProvider =
    AsyncNotifierProvider.family<ReleaseScheduleController, void, ReleaseRef>(
      ReleaseScheduleController.new,
    );

class ReleaseAssetLinkController extends FamilyAsyncNotifier<void, ReleaseRef> {
  @override
  Future<void> build(ReleaseRef arg) async {}

  Future<ReleaseAssetLink> create({
    required String name,
    required String url,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final link = await repository.createAssetLink(
        arg.projectId,
        arg.tagName,
        name: name.trim(),
        url: url.trim(),
      );
      ref.invalidate(releaseDetailProvider(arg));
      ref.invalidate(releaseListControllerProvider(arg.projectId));
      state = const AsyncData(null);
      return link;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final releaseAssetLinkControllerProvider =
    AsyncNotifierProvider.family<ReleaseAssetLinkController, void, ReleaseRef>(
      ReleaseAssetLinkController.new,
    );

class ReleaseDeleteController extends FamilyAsyncNotifier<void, ReleaseRef> {
  @override
  Future<void> build(ReleaseRef arg) async {}

  Future<void> delete() async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      await repository.delete(arg.projectId, arg.tagName);
      ref.invalidate(releaseListControllerProvider(arg.projectId));
      ref.invalidate(releaseDetailProvider(arg));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final releaseDeleteControllerProvider =
    AsyncNotifierProvider.family<ReleaseDeleteController, void, ReleaseRef>(
      ReleaseDeleteController.new,
    );

class ReleaseAssetLinkEditController
    extends FamilyAsyncNotifier<void, ReleaseRef> {
  @override
  Future<void> build(ReleaseRef arg) async {}

  Future<ReleaseAssetLink> save(
    int linkId, {
    required String name,
    required String url,
    String? linkType,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final link = await repository.updateAssetLink(
        arg.projectId,
        arg.tagName,
        linkId,
        name: name.trim(),
        url: url.trim(),
        linkType: linkType,
      );
      ref.invalidate(releaseDetailProvider(arg));
      ref.invalidate(releaseListControllerProvider(arg.projectId));
      state = const AsyncData(null);
      return link;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final releaseAssetLinkEditControllerProvider =
    AsyncNotifierProvider.family<
      ReleaseAssetLinkEditController,
      void,
      ReleaseRef
    >(ReleaseAssetLinkEditController.new);

class ReleaseAssetLinkDeleteController
    extends FamilyAsyncNotifier<void, ReleaseRef> {
  @override
  Future<void> build(ReleaseRef arg) async {}

  Future<void> delete(int linkId) async {
    state = const AsyncLoading();
    try {
      final repository = await ref.read(releasesRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      await repository.deleteAssetLink(arg.projectId, arg.tagName, linkId);
      ref.invalidate(releaseDetailProvider(arg));
      ref.invalidate(releaseListControllerProvider(arg.projectId));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final releaseAssetLinkDeleteControllerProvider =
    AsyncNotifierProvider.family<
      ReleaseAssetLinkDeleteController,
      void,
      ReleaseRef
    >(ReleaseAssetLinkDeleteController.new);
