import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../data/protected_tags_repository.dart';

final protectedTagsRepositoryProvider =
    FutureProvider<ProtectedTagsRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProtectedTagsRepository(client);
    });

class ProtectedTagsController
    extends FamilyAsyncNotifier<Paginated<ProtectedTag>, int> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<Paginated<ProtectedTag>> build(int projectId) async {
    _generation++;
    _loadingMore = false;
    ref.onDispose(() => _generation++);
    final repository = await ref.watch(protectedTagsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(projectId);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    final generation = _generation;
    _loadingMore = true;
    try {
      final repository = await ref.read(protectedTagsRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(arg, page: page);
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

final protectedTagsControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedTagsController,
      Paginated<ProtectedTag>,
      int
    >(ProtectedTagsController.new);

class ProtectedTagRef {
  const ProtectedTagRef({required this.projectId, required this.name});

  final int projectId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ProtectedTagRef &&
      projectId == other.projectId &&
      name == other.name;

  @override
  int get hashCode => Object.hash(projectId, name);
}

final protectedTagDetailProvider =
    FutureProvider.family<ProtectedTag, ProtectedTagRef>((ref, key) async {
      final repository = await ref.watch(
        protectedTagsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(key.projectId, key.name);
    });

/// Session-bound, best-effort compare-and-unprotect for one frozen rule.
class ProtectedTagUnprotectController
    extends FamilyAsyncNotifier<void, ProtectedTagRef> {
  bool _disposed = false;
  @override
  void build(ProtectedTagRef arg) {
    ref.watch(protectedTagsRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<void> unprotect({required ProtectedTag expected}) async {
    if (state.isLoading) {
      throw StateError('Tag unprotection is already pending');
    }
    if (expected.name != arg.name || expected.name.trim().isEmpty) {
      throw ArgumentError('Exact frozen rule identity required');
    }
    final session = ref.read(protectedTagsRepositoryProvider.future);
    bool isCurrent() =>
        !_disposed &&
        identical(session, ref.read(protectedTagsRepositoryProvider.future));
    void checkSession() {
      if (!isCurrent()) {
        throw const GitLabConflictException('Tag unprotection session changed');
      }
    }

    state = const AsyncLoading();
    try {
      final repository = await session;
      checkSession();
      if (repository == null) throw StateError('No authenticated account');
      final current = await repository.get(arg.projectId, arg.name);
      checkSession();
      if (current != expected) {
        throw const GitLabConflictException('Tag protection rule changed');
      }
      await repository.unprotect(arg.projectId, arg.name);
      checkSession();
      state = const AsyncData(null);
      ref.invalidate(protectedTagsControllerProvider(arg.projectId));
      ref.invalidate(protectedTagDetailProvider(arg));
      ref.invalidate(tagsControllerProvider(arg.projectId));
      // A wildcard can affect any tag detail. Invalidate the family rather
      // than attempting to infer GitLab matching or overlapping rules.
      ref.invalidate(tagProvider);
    } catch (error, stackTrace) {
      if (isCurrent()) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final protectedTagUnprotectControllerProvider =
    AsyncNotifierProvider.family<
      ProtectedTagUnprotectController,
      void,
      ProtectedTagRef
    >(ProtectedTagUnprotectController.new);
