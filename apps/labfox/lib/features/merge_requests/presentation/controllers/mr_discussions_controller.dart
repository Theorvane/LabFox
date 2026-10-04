import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../comments/data/comments_repository.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import 'merge_requests_controllers.dart';

/// Reads grouped conversations and posts top-level notes, bound to one session.
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
  Future<bool> post(String body) async {
    if (_posting || state.isLoading || state.hasError || body.trim().isEmpty) {
      return false;
    }
    final generation = _generation;
    _posting = true;
    // A successful post reloads page one, superseding any in-flight pagination.
    try {
      final repo = await _repository();
      if (generation != _generation) return false;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      await repo.post(
        type: NoteableType.mergeRequest,
        projectId: arg.projectId,
        iid: arg.iid,
        body: body.trim(),
      );
      if (generation != _generation) return false;
      unawaited(
        ref.read(analyticsProvider).track('comment_posted', {
          'target': 'merge_request',
        }),
      );
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
