import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../../inbox/presentation/controllers/inbox_controllers.dart';
import '../../data/mr_actions_repository.dart';
import 'merge_requests_controllers.dart';

final mrActionsRepositoryProvider = FutureProvider<MrActionsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : MrActionsRepository(client);
});

/// The approval state for a merge request, or null when the instance does not
/// expose approvals.
final mrApprovalsProvider =
    FutureProvider.family<MergeRequestApprovals?, MergeRequestRef>((
      ref,
      arg,
    ) async {
      final repo = await ref.watch(mrActionsRepositoryProvider.future);
      if (repo == null) {
        return null;
      }
      return repo.approvals(projectId: arg.projectId, iid: arg.iid);
    });

/// Runs approve / unapprove / merge, then refreshes the MR and its approvals so
/// the screen shows the server's state — never a locally fabricated one.
class MrActionsController extends FamilyAsyncNotifier<void, MergeRequestRef> {
  bool _running = false;
  @override
  Future<void> build(MergeRequestRef arg) async {}

  Future<void> _refresh() async {
    ref.invalidate(mergeRequestControllerProvider(arg));
    ref.invalidate(mrApprovalsProvider(arg));
  }

  Future<void> approve() => _run((repo) async {
    await repo.approve(projectId: arg.projectId, iid: arg.iid);
    _track('mr_approved');
  });

  Future<void> unapprove() => _run((repo) async {
    await repo.unapprove(projectId: arg.projectId, iid: arg.iid);
    _track('mr_unapproved');
  });

  Future<void> merge({bool squash = false}) => _run((repo) async {
    await repo.merge(projectId: arg.projectId, iid: arg.iid, squash: squash);
    // Which merge method gets used decides whether the squash option is worth
    // keeping in the sheet.
    _track('mr_merged', {'squash': squash});
  });

  Future<void> setOpen(bool open) => _run((repo) async {
    await repo.setOpen(projectId: arg.projectId, iid: arg.iid, open: open);
    _track(open ? 'mr_reopened' : 'mr_closed');
  });

  Future<void> setDraft({required bool draft, required String title}) =>
      _run((repo) async {
        await repo.setDraft(
          projectId: arg.projectId,
          iid: arg.iid,
          draft: draft,
          title: title,
        );
        _track('mr_draft_changed', {'draft': draft});
      });

  Future<void> rebase() => _run((repo) async {
    await repo.rebase(projectId: arg.projectId, iid: arg.iid);
    _track('mr_rebased');
  });

  Future<void> setSubscription(bool subscribed) => _run((repo) async {
    await repo.setSubscription(
      projectId: arg.projectId,
      iid: arg.iid,
      subscribed: subscribed,
    );
  });

  /// Returns false when GitLab reports that a to-do already exists (304).
  Future<bool> createTodo() async {
    var created = false;
    await _run((repo) async {
      final todo = await repo.createTodo(
        projectId: arg.projectId,
        iid: arg.iid,
      );
      created = todo != null;
      if (created) ref.invalidate(inboxControllerProvider);
    });
    return created;
  }

  /// Names the action only. No project, iid, title, or branch ever leaves the
  /// device (`PRIVACY.md`).
  void _track(String name, [Map<String, Object?>? properties]) {
    unawaited(ref.read(analyticsProvider).track(name, properties));
  }

  /// Sets a loading state around the action so the UI can disable buttons, runs
  /// it, refreshes, and rethrows a domain exception for the caller to surface.
  Future<void> _run(
    Future<void> Function(MrActionsRepository repo) action,
  ) async {
    if (_running) return;
    // Reserve before awaiting the repository: the UI may not have rebuilt yet.
    _running = true;
    state = const AsyncLoading();
    try {
      final repo = await ref.read(mrActionsRepositoryProvider.future);
      if (repo == null) {
        throw StateError('No authenticated account');
      }
      await action(repo);
      await _refresh();
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    } finally {
      _running = false;
    }
  }
}

final mrActionsControllerProvider =
    AsyncNotifierProvider.family<MrActionsController, void, MergeRequestRef>(
      MrActionsController.new,
    );
