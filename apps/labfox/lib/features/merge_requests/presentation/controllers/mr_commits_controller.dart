import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../data/merge_requests_repository.dart';
import 'merge_requests_controllers.dart';

/// Establishes the authoritative global MR identity from an identifier-only route.
class MrCommitOriginController
    extends AutoDisposeFamilyAsyncNotifier<MergeRequest?, MergeRequestRef> {
  @override
  Future<MergeRequest?> build(MergeRequestRef arg) async {
    if (arg.projectId < 1 || arg.iid < 1) {
      throw ArgumentError('Invalid MR route.');
    }
    var active = true;
    ref.onDispose(() => active = false);
    final account = ref.watch(currentAccountProvider);
    if (account == null) return null;
    final source = ref.watch(mergeRequestsRepositoryProvider.future);
    bool current() =>
        active &&
        ref.read(currentAccountProvider) == account &&
        identical(ref.read(mergeRequestsRepositoryProvider.future), source);
    try {
      final repo = await source;
      if (!current()) return null;
      if (repo == null || account.user.id < 1) {
        throw const GitLabAuthException(
          'No authenticated commit review session.',
        );
      }
      final detail = await repo.get(projectId: arg.projectId, iid: arg.iid);
      if (!current()) return null;
      if (detail.id < 1 ||
          detail.iid != arg.iid ||
          detail.targetProjectId != arg.projectId ||
          (detail.projectId != null && detail.projectId != arg.projectId)) {
        throw const GitLabServerException('Invalid commit review identity.');
      }
      return detail;
    } catch (_) {
      if (!current()) return null;
      rethrow;
    }
  }
}

final mrCommitOriginControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MrCommitOriginController, MergeRequest?, MergeRequestRef>(
      MrCommitOriginController.new,
    );

/// Browses every advertised membership page without exposing partial stale lists.
class MrCommitsController
    extends AutoDisposeFamilyAsyncNotifier<List<Commit>?, MergeRequestRef> {
  @override
  Future<List<Commit>?> build(MergeRequestRef arg) async {
    var active = true;
    ref.onDispose(() => active = false);
    final account = ref.watch(currentAccountProvider);
    if (account == null) return null;
    final origin = ref.watch(mrCommitOriginControllerProvider(arg).future);
    final source = ref.watch(mergeRequestsRepositoryProvider.future);
    bool current() =>
        active &&
        ref.read(currentAccountProvider) == account &&
        identical(ref.read(mergeRequestsRepositoryProvider.future), source) &&
        identical(
          ref.read(mrCommitOriginControllerProvider(arg).future),
          origin,
        );
    try {
      // Observe both started futures immediately, even if one fails first.
      final values = await Future.wait<Object?>([
        origin,
        source,
      ], eagerError: true);
      if (!current() || values[0] == null) return null;
      final repo = values[1] as MergeRequestsRepository?;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated commit browser.');
      }
      final commits = await repo.commits(
        projectId: arg.projectId,
        iid: arg.iid,
        isCurrent: current,
      );
      if (!current() || commits == null) return null;
      return List<Commit>.unmodifiable(commits);
    } catch (_) {
      if (!current()) return null;
      rethrow;
    }
  }
}

final mrCommitsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MrCommitsController, List<Commit>?, MergeRequestRef>(
      MrCommitsController.new,
    );
