import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../comments/data/comments_repository.dart';
import '../../../comments/data/discussion_resolution.dart';
import '../../../comments/data/suggestion_application.dart';
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

  bool _currentSuggestion(
    String discussionId,
    Note note,
    Suggestion suggestion,
  ) {
    final groups = state.valueOrNull?.items;
    return !state.isLoading &&
        !state.hasError &&
        groups != null &&
        containsApplicableSuggestion(
          groups,
          discussionId: discussionId,
          note: note,
          suggestion: suggestion,
        );
  }

  /// Holds the same reservation as comments, replies and resolution writes.
  Future<bool> applySuggestion({
    required String discussionId,
    required Note note,
    required Suggestion suggestion,
    String? commitMessage,
    bool Function()? isCurrent,
  }) async {
    if (_posting ||
        _loadingMore ||
        !_currentSuggestion(discussionId, note, suggestion) ||
        isCurrent?.call() == false) {
      return false;
    }
    final generation = _generation;
    _posting = true;
    bool current() => generation == _generation && isCurrent?.call() != false;
    try {
      final repo = await _repository();
      if (!current()) return false;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      if (!_currentSuggestion(discussionId, note, suggestion)) return false;
      final fresh = await repo.discussion(
        projectId: arg.projectId,
        iid: arg.iid,
        discussionId: discussionId,
      );
      if (!current()) return false;
      if (!_currentSuggestion(discussionId, note, suggestion) ||
          !containsApplicableSuggestion(
            [fresh],
            discussionId: discussionId,
            note: note,
            suggestion: suggestion,
          )) {
        throw const GitLabConflictException(
          'Suggestion changed. Reload before applying.',
        );
      }
      final returned = await repo.applySuggestion(
        suggestionId: suggestion.id,
        commitMessage: commitMessage,
      );
      if (!current()) return false;
      if (!confirmsAppliedSuggestion(returned, suggestion)) {
        throw const GitLabServerException(
          'Unconfirmed suggestion application.',
        );
      }
      ref.invalidate(mergeRequestControllerProvider(arg));
      ref.invalidate(mrReviewSnapshotControllerProvider(arg));
      ref.invalidateSelf();
      return true;
    } catch (_) {
      if (!current()) return false;
      rethrow;
    } finally {
      if (generation == _generation) _posting = false;
    }
  }

  bool _currentSuggestions(List<SuggestionTarget> targets) =>
      !state.isLoading &&
      !state.hasError &&
      state.hasValue &&
      containsApplicableSuggestionTargets(state.value!.items, targets);

  /// Confirms all selected patches before one batch; never applies a subset.
  Future<bool> applySuggestions(
    List<SuggestionTarget> selection, {
    String? commitMessage,
    bool Function()? isCurrent,
  }) async {
    final targets = List<SuggestionTarget>.unmodifiable(selection);
    if (_posting ||
        _loadingMore ||
        !_currentSuggestions(targets) ||
        isCurrent?.call() == false) {
      return false;
    }
    final generation = _generation;
    _posting = true;
    bool current() => generation == _generation && isCurrent?.call() != false;
    try {
      final repo = await _repository();
      if (!current()) return false;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      if (!_currentSuggestions(targets)) return false;
      final fresh = await _readDiscussions(
        repo,
        targets.map((t) => t.discussionId).toSet().toList(),
        current,
      );
      if (!current() || fresh == null) return false;
      if (!_currentSuggestions(targets) ||
          !containsApplicableSuggestionTargets(fresh, targets)) {
        throw const GitLabConflictException(
          'Suggestions changed. Reload before applying.',
        );
      }
      final returned = await repo.applySuggestions(
        suggestionIds: targets.map((t) => t.suggestion.id).toList(),
        commitMessage: commitMessage,
      );
      if (!current()) return false;
      final byId = {for (final s in returned) s.id: s};
      if (returned.length != targets.length ||
          byId.length != targets.length ||
          !targets.every(
            (t) =>
                byId[t.suggestion.id] != null &&
                confirmsAppliedSuggestion(byId[t.suggestion.id]!, t.suggestion),
          )) {
        throw const GitLabServerException(
          'Unconfirmed suggestion batch application.',
        );
      }
      ref.invalidate(mergeRequestControllerProvider(arg));
      ref.invalidate(mrReviewSnapshotControllerProvider(arg));
      ref.invalidateSelf();
      return true;
    } catch (_) {
      if (!current()) return false;
      rethrow;
    } finally {
      if (generation == _generation) _posting = false;
    }
  }

  /// Explicit read-only recovery never retries an application automatically.
  Future<Discussion?> inspectDiscussion(
    String discussionId, {
    bool Function()? isCurrent,
  }) async =>
      (await inspectDiscussions([discussionId], isCurrent: isCurrent))?.single;

  /// Stages every selected thread before replacing any loaded cache entry.
  Future<List<Discussion>?> inspectDiscussions(
    List<String> discussionIds, {
    bool Function()? isCurrent,
  }) async {
    final ids = List<String>.unmodifiable(discussionIds);
    if (_posting ||
        _loadingMore ||
        isCurrent?.call() == false ||
        ids.isEmpty ||
        ids.toSet().length != ids.length) {
      return null;
    }
    final generation = _generation;
    _posting = true;
    bool current() => generation == _generation && isCurrent?.call() != false;
    try {
      final repo = await _repository();
      if (!current()) return null;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      final fresh = await _readDiscussions(repo, ids, current);
      if (!current() || fresh == null) return null;
      final page = state.valueOrNull;
      if (page != null && !state.isLoading && !state.hasError) {
        final byId = {for (final g in fresh) g.id: g};
        state = AsyncData(
          Paginated(
            items: List<Discussion>.unmodifiable(
              page.items.map((g) => byId[g.id] ?? g),
            ),
            nextPage: page.nextPage,
            total: page.total,
            totalPages: page.totalPages,
          ),
        );
      }
      return fresh;
    } catch (_) {
      if (!current()) return null;
      rethrow;
    } finally {
      if (generation == _generation) _posting = false;
    }
  }

  Future<List<Discussion>?> _readDiscussions(
    CommentsRepository repo,
    List<String> ids,
    bool Function() isCurrent,
  ) async {
    final result = <Discussion>[];
    for (final id in ids) {
      if (!isCurrent()) return null;
      final fresh = await repo.discussion(
        projectId: arg.projectId,
        iid: arg.iid,
        discussionId: id,
      );
      if (!isCurrent()) return null;
      if (fresh.id != id) {
        throw const GitLabServerException('Invalid discussion response.');
      }
      result.add(fresh);
    }
    return List<Discussion>.unmodifiable(result);
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
    final repositorySession = ref.read(commentsRepositoryProvider.future);
    // A successful write reloads page one, superseding any in-flight pagination.
    try {
      final repo = await _repository();
      final session = ref.read(commentsRepositoryProvider);
      if (generation != _generation ||
          session.isLoading ||
          session.hasError ||
          !identical(session.valueOrNull, repo)) {
        return false;
      }
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
      final completedSession = ref.read(commentsRepositoryProvider);
      if (generation != _generation ||
          completedSession.isLoading ||
          completedSession.hasError ||
          !identical(completedSession.valueOrNull, repo)) {
        return false;
      }
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
      if (generation != _generation ||
          !identical(
            ref.read(commentsRepositoryProvider.future),
            repositorySession,
          )) {
        return false;
      }
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
