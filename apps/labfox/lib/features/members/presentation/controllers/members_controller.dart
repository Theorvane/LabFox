import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/group_members_repository.dart';
import '../../data/project_members_repository.dart';

final projectMembersRepositoryProvider =
    FutureProvider<ProjectMembersRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProjectMembersRepository(client);
    });

final groupMembersRepositoryProvider = FutureProvider<GroupMembersRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : GroupMembersRepository(client);
});

class MemberListRef {
  const MemberListRef({this.projectId, this.groupId, required this.query})
    : assert((projectId == null) != (groupId == null));

  final int? projectId;
  final int? groupId;
  final String query;

  @override
  bool operator ==(Object other) =>
      other is MemberListRef &&
      projectId == other.projectId &&
      groupId == other.groupId &&
      query == other.query;

  @override
  int get hashCode => Object.hash(projectId, groupId, query);
}

/// Server-side member search and response-header pagination.
class ProjectMembersController
    extends FamilyAsyncNotifier<Paginated<ProjectMember>, MemberListRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<ProjectMember>> build(MemberListRef arg) async {
    if (arg.groupId != null) {
      final repository = await ref.watch(groupMembersRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      return repository.list(
        arg.groupId!,
        query: arg.query.isEmpty ? null : arg.query,
      );
    }
    final repository = await ref.watch(projectMembersRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(
      arg.projectId!,
      query: arg.query.isEmpty ? null : arg.query,
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      late final Paginated<ProjectMember> next;
      if (arg.groupId != null) {
        final repository = await ref.read(
          groupMembersRepositoryProvider.future,
        );
        if (repository == null) throw StateError('No authenticated account');
        next = await repository.list(
          arg.groupId!,
          query: arg.query.isEmpty ? null : arg.query,
          page: page,
        );
      } else {
        final repository = await ref.read(
          projectMembersRepositoryProvider.future,
        );
        if (repository == null) throw StateError('No authenticated account');
        next = await repository.list(
          arg.projectId!,
          query: arg.query.isEmpty ? null : arg.query,
          page: page,
        );
      }
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

final projectMembersControllerProvider =
    AsyncNotifierProvider.family<
      ProjectMembersController,
      Paginated<ProjectMember>,
      MemberListRef
    >(ProjectMembersController.new);
