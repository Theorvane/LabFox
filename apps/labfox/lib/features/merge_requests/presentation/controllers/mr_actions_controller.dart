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
      final repo = await ref.read(mrActionsRepositoryProvider.future);
      if (repo == null) {
        return null;
      }
      return repo.approvals(projectId: arg.projectId, iid: arg.iid);
    });

/// Runs approve / unapprove / merge, then refreshes the MR and its approvals so
/// the screen shows the server's state — never a locally fabricated one.
class MrActionsController extends FamilyAsyncNotifier<void, MergeRequestRef> {
  bool _running = false;
  int _generation = 0;
  Completer<void>? _sessionEnded;

  MrActionsRepository? _repository;
  bool _hasRepository = false;

  @override
  Future<void> build(MergeRequestRef arg) async {
    _endSession();
    _running = false;
    _sessionEnded = Completer<void>();
    _repository = null;
    _hasRepository = false;
    ref.onDispose(_endSession);
    ref.listen(mrActionsRepositoryProvider, (previous, next) {
      final changed =
          next.hasValue &&
          _hasRepository &&
          !identical(_repository, next.valueOrNull);
      final reloading =
          next.isLoading && previous != null && !previous.isLoading;
      if (changed || reloading) {
        _endSession();
        _sessionEnded = Completer<void>();
        _running = false;
        state = const AsyncData(null);
      }
      if (next.hasValue) {
        _repository = next.valueOrNull;
        _hasRepository = true;
      }
    }, fireImmediately: true);
  }

  void _endSession() {
    _generation++;
    final ended = _sessionEnded;
    if (ended != null && !ended.isCompleted) ended.complete();
  }

  Future<void> _refresh() async {
    ref.invalidate(mergeRequestControllerProvider(arg));
    ref.invalidate(mrApprovalsProvider(arg));
  }

  Future<void> approve() => _run(
    (repo) => repo.approve(projectId: arg.projectId, iid: arg.iid),
    onSuccess: () => _track('mr_approved'),
  );

  Future<void> unapprove() => _run(
    (repo) => repo.unapprove(projectId: arg.projectId, iid: arg.iid),
    onSuccess: () => _track('mr_unapproved'),
  );

  Future<void> merge({bool squash = false}) => _run((repo) async {
    await repo.merge(projectId: arg.projectId, iid: arg.iid, squash: squash);
  }, onSuccess: () => _track('mr_merged', {'squash': squash}));

  Future<void> setOpen(bool open) => _run((repo) async {
    await repo.setOpen(projectId: arg.projectId, iid: arg.iid, open: open);
  }, onSuccess: () => _track(open ? 'mr_reopened' : 'mr_closed'));

  Future<void> setDraft({required bool draft, required String title}) =>
      _run((repo) async {
        await repo.setDraft(
          projectId: arg.projectId,
          iid: arg.iid,
          draft: draft,
          title: title,
        );
      }, onSuccess: () => _track('mr_draft_changed', {'draft': draft}));

  Future<void> rebase() => _run(
    (repo) => repo.rebase(projectId: arg.projectId, iid: arg.iid),
    onSuccess: () => _track('mr_rebased'),
  );

  Future<void> setSubscription(bool subscribed) => _run((repo) async {
    await repo.setSubscription(
      projectId: arg.projectId,
      iid: arg.iid,
      subscribed: subscribed,
    );
  });

  /// Returns false for an existing to-do, or null for a cancelled command.
  Future<bool?> createTodo() async {
    var created = false;
    final completed = await _run(
      (repo) async {
        created =
            await repo.createTodo(projectId: arg.projectId, iid: arg.iid) !=
            null;
      },
      onSuccess: () {
        if (created) ref.invalidate(inboxControllerProvider);
      },
    );
    return completed ? created : null;
  }

  /// Names the action only. No project, iid, title, or branch ever leaves the
  /// device (`PRIVACY.md`).
  void _track(String name, [Map<String, Object?>? properties]) {
    unawaited(ref.read(analyticsProvider).track(name, properties));
  }

  /// Sets a loading state around the action so the UI can disable buttons, runs
  /// it, refreshes, and rethrows a domain exception for the caller to surface.
  Future<bool> _run(
    Future<void> Function(MrActionsRepository repo) action, {
    void Function()? onSuccess,
  }) async {
    if (_running) return false;
    final generation = _generation;
    final ended = _sessionEnded!.future;
    _running = true;
    state = const AsyncLoading();
    try {
      // A replaced provider future may never complete. End its waiting command
      // when the session changes without dispatching or replaying a write.
      final repo = await Future.any<MrActionsRepository?>([
        ref.read(mrActionsRepositoryProvider.future),
        ended.then((_) => null),
      ]);
      if (generation != _generation) return false;
      if (repo == null) throw StateError('No authenticated account');
      await action(repo);
      if (generation != _generation) return false;
      await _refresh();
      if (generation != _generation) return false;
      onSuccess?.call();
      state = const AsyncData(null);
      return true;
    } catch (error, stack) {
      if (generation != _generation) return false;
      state = AsyncError(error, stack);
      rethrow;
    } finally {
      if (generation == _generation) _running = false;
    }
  }
}

final mrActionsControllerProvider =
    AsyncNotifierProvider.family<MrActionsController, void, MergeRequestRef>(
      MrActionsController.new,
    );
