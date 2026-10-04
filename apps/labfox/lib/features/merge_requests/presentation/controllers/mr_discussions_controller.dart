import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../comments/data/comments_repository.dart';
import '../../../comments/data/discussion_resolution.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import 'merge_requests_controllers.dart';
import 'mr_review_snapshot_controller.dart';

/// Reads grouped conversations and writes notes and replies in one session.
class MrDiscussionsController
    extends FamilyAsyncNotifier<Paginated<Discussion>, MergeRequestRef> {
  int _generation = 0;
  bool _loadingMore = false;
  bool _posting = false;
  Completer<void>? _ended;

  void _endSession() {
    _generation++;
    final ended = _ended;
    if (ended != null && !ended.isCompleted) ended.complete();
  }

  @override
  Future<Paginated<Discussion>> build(MergeRequestRef arg) async {
    _endSession();
    _ended = Completer<void>();
    _loadingMore = false;
    _posting = false;
    ref.onDispose(_endSession);
    final repo = await ref.watch(commentsRepositoryProvider.future);
    if (repo == null) {
      throw const GitLabAuthException('No authenticated account.');
    }
    return repo.discussions(projectId: arg.projectId, iid: arg.iid);
  }

  Future<CommentsRepository?> _repository() {
    final ended = _ended!.future;
    return Future.any([
      ref.read(commentsRepositoryProvider.future),
      ended.then((_) => null),
    ]);
  }

  Future<void> loadMore() async {
    if (_loadingMore || _posting || state.isLoading) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    final generation = _generation;
    _loadingMore = true;
    try {
      final repo = await _repository();
      if (generation != _generation) return;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      final next = await repo.discussions(
        projectId: arg.projectId,
        iid: arg.iid,
        page: page,
      );
      if (generation != _generation) return;
      final items = {for (final group in current.items) group.id: group};
      for (final group in next.items) {
        items[group.id] = group;
      }
      state = AsyncData(
        Paginated(
          items: List<Discussion>.unmodifiable(items.values),
          nextPage: next.nextPage,
          total: next.total ?? current.total,
          totalPages: next.totalPages ?? current.totalPages,
        ),
      );
    } catch (_) {
      if (generation == _generation) rethrow;
    } finally {
      if (generation == _generation) _loadingMore = false;
    }
  }

  /// Returns false when cancelled or already posting; drafts remain untouched.
  Future<bool> post(String body) => _post(body);

  Future<bool> reply({required String discussionId, required String body}) {
    final groups = state.valueOrNull?.items;
    if (groups == null ||
        !groups.any(
          (group) =>
              group.id == discussionId &&
              group.notes.any((note) => !note.isSystem),
        )) {
      return Future.value(false);
    }
    return _post(body, discussionId: discussionId);
  }

  bool _currentPosition(DiffNotePosition position) {
    final snapshot = ref.read(mrReviewSnapshotControllerProvider(arg));
    return !snapshot.isLoading &&
        !snapshot.hasError &&
        (snapshot.valueOrNull?.containsPosition(position) ?? false);
  }

  Future<bool> createPositioned({
    required String body,
    required DiffNotePosition position,
  }) {
    if (!_currentPosition(position)) return Future.value(false);
    return _post(body, position: position);
  }

  Future<bool> setResolved({
    required String discussionId,
    required bool resolved,
  }) {
    final groups = state.valueOrNull?.items;
    if (groups == null ||
        !groups.any(
          (group) =>
              group.id == discussionId &&
              group.notes.any((note) => !note.isSystem) &&
              discussionResolution(group) == !resolved,
        )) {
      return Future.value(false);
    }
    return _post('', discussionId: discussionId, resolved: resolved);
  }

  Future<bool> _post(
    String body, {
    String? discussionId,
    bool? resolved,
    DiffNotePosition? position,
  }) async {
    if (_posting ||
        state.isLoading ||
        state.hasError ||
        (resolved == null && body.trim().isEmpty)) {
      return false;
    }
    final generation = _generation;
    _posting = true;
    // A successful write reloads page one, superseding any in-flight pagination.
    try {
      final repo = await _repository();
      if (generation != _generation) return false;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      if (position != null && !_currentPosition(position)) return false;
      if (position != null) {
        await repo.createPositionedDiscussion(
          projectId: arg.projectId,
          iid: arg.iid,
          body: body,
          position: position,
        );
      } else if (resolved != null) {
        await repo.setDiscussionResolved(
          projectId: arg.projectId,
          iid: arg.iid,
          discussionId: discussionId!,
          resolved: resolved,
        );
      } else if (discussionId == null) {
        await repo.post(
          type: NoteableType.mergeRequest,
          projectId: arg.projectId,
          iid: arg.iid,
          body: body.trim(),
        );
      } else {
        await repo.replyToDiscussion(
          projectId: arg.projectId,
          iid: arg.iid,
          discussionId: discussionId,
          body: body,
        );
      }
      if (generation != _generation) return false;
      if (resolved == null) {
        unawaited(
          ref.read(analyticsProvider).track('comment_posted', {
            'target': 'merge_request',
          }),
        );
      } else {
        ref.invalidate(mergeRequestControllerProvider(arg));
      }
      ref.invalidateSelf();
      return true;
    } catch (_) {
      if (generation != _generation) return false;
      rethrow;
    } finally {
      if (generation == _generation) _posting = false;
    }
  }
}

final mrDiscussionsControllerProvider =
    AsyncNotifierProvider.family<
      MrDiscussionsController,
      Paginated<Discussion>,
      MergeRequestRef
    >(MrDiscussionsController.new);
