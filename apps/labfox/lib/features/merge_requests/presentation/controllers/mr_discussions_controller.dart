import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../../comments/data/comments_repository.dart';
import '../../../comments/data/discussion_resolution.dart';
import '../../../comments/data/suggestion_application.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import '../../../diff/presentation/controllers/diff_controllers.dart';
import '../../data/merge_requests_repository.dart';
import '../../data/mr_draft_notes_repository.dart';
import 'merge_requests_controllers.dart';
import 'mr_draft_notes_provider.dart';
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

  Account? _pendingAccount;
  bool _pendingNeedsInspection = false;
  bool _pendingPublicationNeedsInspection = false;
  bool _pendingReviewerStateNeedsInspection = false;
  Future<void>? _pendingWriteSettled;

  void _syncPendingSession() {
    final account = ref.read(currentAccountProvider);
    // Replacing a client/wrapper for the same account cannot prove that a
    // dispatched write failed. Preserve its inspection gate and settled future.
    if (account != _pendingAccount) {
      _pendingNeedsInspection = false;
      _pendingPublicationNeedsInspection = false;
      _pendingReviewerStateNeedsInspection = false;
      _pendingWriteSettled = null;
      _pendingAccount = account;
    }
  }

  /// A refresh or repository wrapper replacement cannot authorize replay.
  bool get pendingSaveNeedsInspection {
    _syncPendingSession();
    return _pendingNeedsInspection || _pendingPublicationNeedsInspection;
  }

  bool get pendingPublicationNeedsInspection {
    _syncPendingSession();
    return _pendingPublicationNeedsInspection;
  }

  MrPendingReviewPublication _publicationSnapshot(
    MrDraftNotesRepository repository,
    MergeRequest detail,
    List<MergeRequestDraftNote> items, {
    int? draftNoteId,
    bool reviewerStateAvailable = false,
    MergeRequestReviewer? reviewer,
  }) => MrPendingReviewPublication._(
    reviewerStateAvailable: reviewerStateAvailable,
    reviewer: reviewer,
    items: items,
    draftNoteId: draftNoteId,
    account: ref.read(currentAccountProvider)!,
    client: ref.read(gitLabClientProvider).value!,
    drafts: repository,
    details: ref.read(mergeRequestsRepositoryProvider).value!,
    comments: ref.read(commentsRepositoryProvider).value!,
    resource: arg,
    mergeRequestId: detail.id,
  );

  bool _currentPublication(MrPendingReviewPublication snapshot) =>
      snapshot._resource == arg &&
      snapshot._account == ref.read(currentAccountProvider) &&
      identical(snapshot._client, ref.read(gitLabClientProvider).valueOrNull) &&
      identical(
        snapshot._drafts,
        ref.read(mrDraftNotesRepositoryProvider).valueOrNull,
      ) &&
      identical(
        snapshot._details,
        ref.read(mergeRequestsRepositoryProvider).valueOrNull,
      ) &&
      identical(
        snapshot._comments,
        ref.read(commentsRepositoryProvider).valueOrNull,
      );

  Future<MergeRequestReviewer?> _readCurrentReviewer(
    MrDraftNotesRepository repository,
    bool Function() current,
    _PendingReviewWait wait,
  ) async {
    final ids = <int>{};
    MergeRequestReviewer? own;
    int? page = 1;
    while (page != null) {
      if (!current()) throw const _PendingReviewCancelled();
      final result = await wait(
        repository.reviewers(
          projectId: arg.projectId,
          iid: arg.iid,
          page: page,
        ),
      );
      if (!current()) throw const _PendingReviewCancelled();
      if (result.nextPage != null && result.nextPage! <= page) {
        throw const GitLabServerException('Invalid reviewers pagination.');
      }
      for (final reviewer in result.items) {
        if (reviewer.user.id < 1 ||
            reviewer.state.trim().isEmpty ||
            !ids.add(reviewer.user.id)) {
          throw const GitLabServerException('Invalid reviewers identity.');
        }
        if (reviewer.user.id == repository.authorId) own = reviewer;
      }
      page = result.nextPage;
    }
    await wait(Future<void>.value());
    if (!current()) throw const _PendingReviewCancelled();
    return own;
  }

  /// Preparation reads every private page and never clears uncertainty.
  Future<MrPendingReviewPublication?> preparePendingReviewPublication({
    bool includeReviewerState = false,
    bool Function()? isCurrent,
  }) {
    if (pendingSaveNeedsInspection) return Future.value(null);
    return _pendingReview((repository, detail, current, wait) async {
      final items = await _readPendingNotes(repository, detail, current, wait);
      MergeRequestReviewer? reviewer;
      var available = false;
      if (includeReviewerState) {
        try {
          reviewer = await _readCurrentReviewer(repository, current, wait);
          available = true;
        } on GitLabException {
          // Older or restricted instances can still publish notes and a summary.
        }
      }
      await wait(Future<void>.value());
      if (!current()) throw const _PendingReviewCancelled();
      return _publicationSnapshot(
        repository,
        detail,
        items,
        reviewerStateAvailable: available,
        reviewer: reviewer,
      );
    }, isCurrent: isCurrent);
  }

  /// Confirms the selected saved DTO against every current private page.
  Future<MrPendingReviewPublication?> preparePendingNotePublication(
    MergeRequestDraftNote draft, {
    bool Function()? isCurrent,
  }) {
    if (pendingSaveNeedsInspection) return Future.value(null);
    return _pendingReview((repository, detail, current, wait) async {
      await _confirmPendingTarget(repository, detail, draft, current, wait);
      return _publicationSnapshot(repository, detail, [
        draft,
      ], draftNoteId: draft.id);
    }, isCurrent: isCurrent);
  }

  /// Publishes only the bound saved identity after a fresh exact comparison.
  /// Another client can still change that identity after the preflight read.
  Future<bool> publishPendingNote(
    MrPendingReviewPublication snapshot, {
    bool Function()? isCurrent,
  }) async {
    if (pendingSaveNeedsInspection ||
        snapshot._draftNoteId == null ||
        snapshot.items.length != 1 ||
        snapshot.items.single.id != snapshot._draftNoteId ||
        !_currentPublication(snapshot)) {
      return false;
    }
    final published =
        await _pendingReview((repository, detail, current, wait) async {
          if (detail.id != snapshot._mergeRequestId ||
              !_currentPublication(snapshot)) {
            throw const GitLabConflictException(
              'The selected private review target changed.',
            );
          }
          await _confirmPendingTarget(
            repository,
            detail,
            snapshot.items.single,
            current,
            wait,
          );
          _pendingPublicationNeedsInspection = true;
          _pendingNeedsInspection = true;
          final write = repository.publishNote(
            projectId: arg.projectId,
            iid: arg.iid,
            mergeRequestId: detail.id,
            draft: snapshot.items.single,
          );
          _pendingWriteSettled = write.then<void>(
            (_) {},
            onError: (Object _, StackTrace _) {},
          );
          await wait(write);
          if (!current()) throw const _PendingReviewCancelled();
          _pendingPublicationNeedsInspection = false;
          _pendingNeedsInspection = false;
          _pendingWriteSettled = null;
          ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
          return true;
        }, isCurrent: isCurrent) ??
        false;
    await Future<void>.value();
    if (published &&
        (!_currentPublication(snapshot) || isCurrent?.call() == false)) {
      return false;
    }
    if (published) {
      ref.invalidate(mergeRequestControllerProvider(arg));
      ref.invalidateSelf();
    }
    return published;
  }

  /// An unchanged complete snapshot authorizes one account-scoped bulk POST.
  /// This is a preflight comparison, not a conditional server-side transaction.
  Future<bool> publishPendingReview(
    MrPendingReviewPublication snapshot, {
    String? summaryNote,
    ReviewerSubmissionState? reviewerState,
    bool Function()? isCurrent,
  }) async {
    if (summaryNote != null && summaryNote.trim().isEmpty) return false;
    if (pendingSaveNeedsInspection ||
        snapshot._draftNoteId != null ||
        (snapshot.items.isEmpty &&
            summaryNote == null &&
            reviewerState == null) ||
        (reviewerState != null && !snapshot.reviewerStateAvailable) ||
        !_currentPublication(snapshot)) {
      return false;
    }
    final published =
        await _pendingReview((repository, detail, current, wait) async {
          final items = await _readPendingNotes(
            repository,
            detail,
            current,
            wait,
          );
          final byId = {for (final item in items) item.id: item};
          if (detail.id != snapshot._mergeRequestId ||
              !_currentPublication(snapshot) ||
              items.length != snapshot.items.length ||
              !snapshot.items.every((item) => byId[item.id] == item)) {
            throw const GitLabConflictException(
              'The pending review changed. Inspect it before publishing.',
            );
          }
          if (reviewerState != null) {
            final reviewer = await _readCurrentReviewer(
              repository,
              current,
              wait,
            );
            if (reviewer != snapshot.reviewer ||
                (reviewerState == ReviewerSubmissionState.reviewed &&
                    reviewer?.state == 'approved')) {
              throw const GitLabConflictException(
                'The reviewer state changed or cannot be replaced. Inspect before submitting.',
              );
            }
          }
          await wait(Future<void>.value());
          if (!current()) throw const _PendingReviewCancelled();
          _pendingPublicationNeedsInspection = true;
          _pendingNeedsInspection = true;
          _pendingReviewerStateNeedsInspection = reviewerState != null;
          final write = repository.publish(
            projectId: arg.projectId,
            iid: arg.iid,
            mergeRequestId: detail.id,
            summaryNote: summaryNote,
            reviewerState: reviewerState,
          );
          _pendingWriteSettled = write.then<void>(
            (_) {},
            onError: (Object _, StackTrace _) {},
          );
          await wait(write);
          if (reviewerState != null) {
            final reviewer = await _readCurrentReviewer(
              repository,
              current,
              wait,
            );
            if (reviewer?.state != reviewerState.value) {
              throw const GitLabServerException(
                'Review submission state was not confirmed. Inspect before retrying.',
              );
            }
          }
          await wait(Future<void>.value());
          if (!current()) throw const _PendingReviewCancelled();
          _pendingPublicationNeedsInspection = false;
          _pendingReviewerStateNeedsInspection = false;
          _pendingNeedsInspection = false;
          _pendingWriteSettled = null;
          ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
          return true;
        }, isCurrent: isCurrent) ??
        false;
    await Future<void>.value();
    // A queued account/repository change can occur after the action returns.
    if (published &&
        (!_currentPublication(snapshot) || isCurrent?.call() == false)) {
      return false;
    }
    if (published) {
      ref.invalidate(mergeRequestControllerProvider(arg));
      ref.invalidateSelf();
    }
    return published;
  }

  /// Recovery stages both private notes and all current public discussions.
  /// Their text or absence cannot identify which uncertain attempt succeeded.
  Future<MrPendingReviewPublicationInspection?>
  inspectPendingReviewPublication({
    bool includeReviewerState = false,
    bool Function()? isCurrent,
  }) => _pendingReview((repository, detail, current, wait) async {
    final unsettled = _pendingWriteSettled;
    if (unsettled != null) await wait(unsettled);
    final items = await _readPendingNotes(repository, detail, current, wait);
    final comments = ref.read(commentsRepositoryProvider).value!;
    final groups = <Discussion>[];
    final ids = <String>{};
    final noteIds = <int>{};
    int? page = 1;
    while (page != null) {
      if (!current()) throw const _PendingReviewCancelled();
      final result = await wait(
        comments.discussions(
          projectId: arg.projectId,
          iid: arg.iid,
          page: page,
        ),
      );
      if (!current()) throw const _PendingReviewCancelled();
      if ((result.nextPage != null && result.nextPage! <= page) ||
          result.items.any(
            (group) =>
                group.id.trim().isEmpty ||
                !ids.add(group.id) ||
                group.notes.any((note) => note.id < 1 || !noteIds.add(note.id)),
          )) {
        throw const GitLabServerException('Invalid public review inspection.');
      }
      groups.addAll(result.items);
      page = result.nextPage;
    }
    MergeRequestReviewer? reviewer;
    var available = false;
    if (includeReviewerState || _pendingReviewerStateNeedsInspection) {
      try {
        reviewer = await _readCurrentReviewer(repository, current, wait);
        available = true;
      } on GitLabException {
        if (_pendingReviewerStateNeedsInspection) rethrow;
      }
    }
    await wait(Future<void>.value());
    if (!current()) throw const _PendingReviewCancelled();
    final inspection = MrPendingReviewPublicationInspection._(
      _publicationSnapshot(
        repository,
        detail,
        items,
        reviewerStateAvailable: available,
        reviewer: reviewer,
      ),
      groups,
    );
    _pendingNeedsInspection = false;
    _pendingPublicationNeedsInspection = false;
    _pendingReviewerStateNeedsInspection = false;
    _pendingWriteSettled = null;
    ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
    state = AsyncData(Paginated(items: inspection.publicDiscussions));
    return inspection;
  }, isCurrent: isCurrent);

  /// Only existing public discussion groups accept this private reply flow.
  static bool canSavePendingReply(Discussion target) =>
      _validReplyContext(target) &&
      !target.individualNote &&
      !target.notes.first.isSystem;

  static bool _validReplyContext(Discussion target) {
    final ids = <int>{};
    return target.id.trim().isNotEmpty &&
        target.notes.isNotEmpty &&
        target.notes.every((note) => note.id > 0 && ids.add(note.id));
  }

  bool _currentReplyTarget(Discussion target) =>
      !state.isLoading &&
      !state.hasError &&
      state.valueOrNull?.items.where((group) => group.id == target.id).length ==
          1 &&
      state.valueOrNull!.items.any((group) => group == target);

  /// Re-reads the captured public context before one private non-resolving save.
  Future<MergeRequestDraftNote?> savePendingReply(
    Discussion target,
    String note, {
    bool Function()? isCurrent,
  }) {
    if (note.trim().isEmpty ||
        pendingSaveNeedsInspection ||
        !canSavePendingReply(target) ||
        !_currentReplyTarget(target)) {
      return Future.value(null);
    }
    return _pendingReview((repository, detail, current, wait) async {
      final comments = await wait(ref.read(commentsRepositoryProvider.future));
      if (!current()) throw const _PendingReviewCancelled();
      final fresh = await wait(
        comments!.discussion(
          projectId: arg.projectId,
          iid: arg.iid,
          discussionId: target.id,
        ),
      );
      if (!current()) throw const _PendingReviewCancelled();
      if (fresh != target ||
          !canSavePendingReply(fresh) ||
          !_currentReplyTarget(target)) {
        throw const GitLabConflictException('The selected discussion changed.');
      }
      await wait(Future<void>.value());
      if (!current()) throw const _PendingReviewCancelled();
      if (!_currentReplyTarget(target)) {
        throw const GitLabConflictException('The selected discussion changed.');
      }
      _pendingNeedsInspection = true;
      final write = repository.createReply(
        projectId: arg.projectId,
        iid: arg.iid,
        mergeRequestId: detail.id,
        discussionId: target.id,
        note: note,
      );
      _pendingWriteSettled = write.then<void>(
        (_) {},
        onError: (Object _, StackTrace _) {},
      );
      final saved = await wait(write);
      if (!current()) throw const _PendingReviewCancelled();
      if (saved.id < 1 ||
          saved.authorId != repository.authorId ||
          saved.mergeRequestId != detail.id ||
          saved.note != note ||
          saved.discussionId != target.id ||
          saved.resolveDiscussion != false ||
          saved.commitId != null ||
          saved.lineCode != null ||
          !_confirmedPosition(null, saved.position)) {
        throw const GitLabServerException('Unconfirmed private reply save.');
      }
      await wait(Future<void>.value());
      if (!current()) throw const _PendingReviewCancelled();
      _pendingNeedsInspection = false;
      _pendingWriteSettled = null;
      ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
      return saved;
    }, isCurrent: isCurrent);
  }

  /// Stages complete private notes and the original public target together.
  /// A missing target stays missing; scoped reads cannot recover publication.
  Future<MrPendingReplyInspection?> inspectPendingReply(
    Discussion original, {
    bool Function()? isCurrent,
  }) {
    if (original.id.trim().isEmpty) return Future.value(null);
    return _pendingReview((repository, detail, current, wait) async {
      final unsettled = _pendingWriteSettled;
      if (unsettled != null) await wait(unsettled);
      final notes = await _readPendingNotes(repository, detail, current, wait);
      final comments = await wait(ref.read(commentsRepositoryProvider.future));
      if (!current()) throw const _PendingReviewCancelled();
      Discussion? target;
      try {
        final fresh = await wait(
          comments!.discussion(
            projectId: arg.projectId,
            iid: arg.iid,
            discussionId: original.id,
          ),
        );
        if (fresh.id != original.id || !_validReplyContext(fresh)) {
          throw const GitLabServerException('Invalid private reply context.');
        }
        target = fresh;
      } on GitLabNotFoundException {
        target = null;
      }
      await wait(Future<void>.value());
      if (!current()) throw const _PendingReviewCancelled();
      final inspection = MrPendingReplyInspection(notes, target);
      if (!_pendingPublicationNeedsInspection) {
        final page = state.valueOrNull!;
        // Preserve other groups and pagination while replacing only this target.
        state = AsyncData(
          Paginated(
            items: List<Discussion>.unmodifiable([
              for (final group in page.items)
                if (group.id != original.id) group else ?target,
            ]),
            nextPage: page.nextPage,
            total: page.total,
            totalPages: page.totalPages,
          ),
        );
        _pendingNeedsInspection = false;
        _pendingWriteSettled = null;
        ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
      }
      return inspection;
    }, isCurrent: isCurrent);
  }

  /// Saves one unpublished note; a text position requires a fresh diff check.
  Future<MergeRequestDraftNote?> savePendingNote(
    String note, {
    DiffNotePosition? position,
    bool Function()? isCurrent,
  }) {
    if (note.trim().isEmpty || pendingSaveNeedsInspection) {
      return Future.value(null);
    }
    MrReviewSelection? selection;
    if (position != null) {
      final displayed = ref.read(mrReviewSnapshotControllerProvider(arg));
      if (displayed.isLoading || displayed.hasError || !displayed.hasValue) {
        return Future.value(null);
      }
      if (!validTextDiscussionPosition(position)) return Future.value(null);
      selection = MrReviewSelection.capture(displayed.value!, position);
      if (selection == null) return Future.value(null);
    }
    return _pendingReview(
      (repository, detail, current, wait) async {
        await wait(Future<void>.value());
        if (!current()) throw const _PendingReviewCancelled();
        _pendingNeedsInspection = true;
        final write = repository.create(
          projectId: arg.projectId,
          iid: arg.iid,
          mergeRequestId: detail.id,
          note: note,
          position: position,
        );
        // A cancelled view does not cancel a dispatched server request. Recovery
        // waits for this actual write to settle before inspecting server notes.
        _pendingWriteSettled = write.then<void>(
          (_) {},
          onError: (Object _, StackTrace _) {},
        );
        final saved = await wait(write);
        if (!current()) throw const _PendingReviewCancelled();
        if (saved.id < 1 ||
            saved.authorId != repository.authorId ||
            saved.mergeRequestId != detail.id ||
            saved.note != note ||
            saved.resolveDiscussion == true ||
            saved.discussionId != null ||
            saved.commitId != null ||
            !_confirmedPosition(position, saved.position)) {
          throw const GitLabServerException('Unconfirmed private review save.');
        }
        await wait(Future<void>.value());
        if (!current()) throw const _PendingReviewCancelled();
        _pendingNeedsInspection = false;
        _pendingWriteSettled = null;
        ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
        return saved;
      },
      isCurrent: isCurrent,
      selection: selection,
    );
  }

  bool _confirmedPosition(DiffNotePosition? sent, DiffNotePosition? saved) {
    if (sent == null) {
      return saved == null ||
          ((saved.positionType == null || saved.positionType == 'text') &&
              [
                saved.baseSha,
                saved.startSha,
                saved.headSha,
                saved.oldPath,
                saved.newPath,
                saved.oldLine,
                saved.newLine,
                saved.lineRange,
                saved.width,
                saved.height,
                saved.x,
                saved.y,
              ].every((field) => field == null));
    }
    if (saved == null) return false;
    bool endpoint(DiffNoteRangeEndpoint? a, DiffNoteRangeEndpoint? b) =>
        a != null &&
        b != null &&
        a.lineCode == b.lineCode &&
        a.type == b.type &&
        (b.oldLine == null || b.oldLine == a.oldLine) &&
        (b.newLine == null || b.newLine == a.newLine);
    final range = sent.lineRange;
    final returned = saved.lineRange;
    return validTextDiscussionPosition(saved) &&
        sent.copyWith(lineRange: null) == saved.copyWith(lineRange: null) &&
        (range == null
            ? returned == null
            : returned != null &&
                  endpoint(range.start, returned.start) &&
                  endpoint(range.end, returned.end));
  }

  /// Returns a complete staged list for explicit user inspection, never a replay.
  /// Identical text does not identify an uncertain create attempt.
  Future<List<MergeRequestDraftNote>?> inspectPendingNotes({
    bool Function()? isCurrent,
  }) => _pendingReview((repository, detail, current, wait) async {
    final unsettled = _pendingWriteSettled;
    if (unsettled != null) await wait(unsettled);
    final notes = await _readPendingNotes(repository, detail, current, wait);
    await wait(Future<void>.value());
    if (!current()) throw const _PendingReviewCancelled();
    if (!_pendingPublicationNeedsInspection) {
      _pendingNeedsInspection = false;
      _pendingWriteSettled = null;
    }
    return List<MergeRequestDraftNote>.unmodifiable(notes);
  }, isCurrent: isCurrent);

  /// Selected body and original metadata must still match fresh private state.
  Future<MergeRequestDraftNote?> updatePendingNote(
    MergeRequestDraftNote draft,
    String note, {
    bool Function()? isCurrent,
  }) {
    if (note.trim().isEmpty ||
        !MrDraftNotesRepository.canUpdate(draft) ||
        pendingSaveNeedsInspection) {
      return Future.value(null);
    }
    return _pendingReview((repository, detail, current, wait) async {
      await _confirmPendingTarget(repository, detail, draft, current, wait);
      if (!current()) throw const _PendingReviewCancelled();
      _pendingNeedsInspection = true;
      final write = repository.update(
        projectId: arg.projectId,
        iid: arg.iid,
        mergeRequestId: detail.id,
        draft: draft,
        note: note,
      );
      _pendingWriteSettled = write.then<void>(
        (_) {},
        onError: (Object _, StackTrace _) {},
      );
      final saved = await wait(write);
      if (!current()) throw const _PendingReviewCancelled();
      if (saved.id != draft.id ||
          saved.authorId != repository.authorId ||
          saved.mergeRequestId != detail.id ||
          saved.note != note) {
        throw const GitLabServerException('Unconfirmed private review update.');
      }
      _pendingNeedsInspection = false;
      _pendingWriteSettled = null;
      ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
      return saved;
    }, isCurrent: isCurrent);
  }

  /// Deletion is explicit and never treats a missing draft as success.
  Future<bool> deletePendingNote(
    MergeRequestDraftNote draft, {
    bool Function()? isCurrent,
  }) async {
    if (pendingSaveNeedsInspection) return false;
    return await _pendingReview((repository, detail, current, wait) async {
          await _confirmPendingTarget(repository, detail, draft, current, wait);
          if (!current()) throw const _PendingReviewCancelled();
          _pendingNeedsInspection = true;
          final write = repository.delete(
            projectId: arg.projectId,
            iid: arg.iid,
            mergeRequestId: detail.id,
            draft: draft,
          );
          _pendingWriteSettled = write.then<void>(
            (_) {},
            onError: (Object _, StackTrace _) {},
          );
          await wait(write);
          if (!current()) throw const _PendingReviewCancelled();
          _pendingNeedsInspection = false;
          _pendingWriteSettled = null;
          ref.read(mrDraftNotesRevisionProvider(arg).notifier).state++;
          return true;
        }, isCurrent: isCurrent) ??
        false;
  }

  Future<void> _confirmPendingTarget(
    MrDraftNotesRepository repository,
    MergeRequest detail,
    MergeRequestDraftNote selected,
    bool Function() current,
    _PendingReviewWait wait,
  ) async {
    if (selected.id < 1 ||
        selected.authorId != repository.authorId ||
        selected.mergeRequestId != detail.id) {
      throw ArgumentError('A current owned private review target is required.');
    }
    final notes = await _readPendingNotes(repository, detail, current, wait);
    final matches = notes.where((draft) => draft.id == selected.id);
    if (matches.length != 1 || matches.single != selected) {
      throw const GitLabConflictException(
        'The selected private review note changed.',
      );
    }
    // Let session cancellation queued during comparison settle before dispatch.
    await wait(Future<void>.value());
    if (!current()) throw const _PendingReviewCancelled();
  }

  Future<List<MergeRequestDraftNote>> _readPendingNotes(
    MrDraftNotesRepository repository,
    MergeRequest detail,
    bool Function() current,
    _PendingReviewWait wait,
  ) async {
    final notes = <MergeRequestDraftNote>[];
    final ids = <int>{};
    int? page = 1;
    while (page != null) {
      if (!current()) throw const _PendingReviewCancelled();
      final result = await wait(
        repository.list(projectId: arg.projectId, iid: arg.iid, page: page),
      );
      if (!current()) throw const _PendingReviewCancelled();
      if ((result.nextPage != null && result.nextPage! <= page) ||
          result.items.any(
            (draft) =>
                draft.id < 1 ||
                draft.authorId != repository.authorId ||
                draft.mergeRequestId != detail.id ||
                !ids.add(draft.id),
          )) {
        throw const GitLabServerException('Invalid private review inspection.');
      }
      notes.addAll(result.items);
      page = result.nextPage;
    }
    return List<MergeRequestDraftNote>.unmodifiable(notes);
  }

  /// Shares the existing discussion write/pagination reservation during fresh
  /// identity reads, private saves and complete read-only recovery.
  Future<T?> _pendingReview<T>(
    Future<T> Function(
      MrDraftNotesRepository,
      MergeRequest,
      bool Function(),
      _PendingReviewWait,
    )
    action, {
    bool Function()? isCurrent,
    MrReviewSelection? selection,
  }) async {
    if (_posting ||
        _loadingMore ||
        state.isLoading ||
        state.hasError ||
        isCurrent?.call() == false) {
      return null;
    }
    if (arg.projectId < 1 || arg.iid < 1) {
      throw ArgumentError('Invalid MR route.');
    }
    final account = ref.read(currentAccountProvider);
    if (account == null || account.user.id < 1) {
      throw const GitLabAuthException(
        'No authenticated private review session.',
      );
    }
    final generation = _generation;
    _posting = true;
    final ended = Completer<void>();
    final subscriptions = <ProviderSubscription<Object?>>[];
    bool Function()? sessionCurrent;
    try {
      final clientFuture = ref.read(gitLabClientProvider.future);
      final draftFuture = ref.read(mrDraftNotesRepositoryProvider.future);
      final commentsFuture = ref.read(commentsRepositoryProvider.future);
      final sourceFuture = ref.read(mergeRequestsRepositoryProvider.future);
      final diffFuture = selection == null
          ? null
          : ref.read(diffRepositoryProvider.future);
      final reviewProvider = mrReviewSnapshotControllerProvider(arg);
      Future<MrReviewSnapshot>? reviewFuture = selection == null
          ? null
          : ref.read(reviewProvider.future);
      Object? reviewSession = selection == null
          ? null
          : ref.read(reviewProvider.notifier).session;
      Future<MergeRequest>? detailFuture;
      bool current() =>
          generation == _generation &&
          isCurrent?.call() != false &&
          ref.read(currentAccountProvider) == account &&
          identical(ref.read(gitLabClientProvider.future), clientFuture) &&
          identical(
            ref.read(mrDraftNotesRepositoryProvider.future),
            draftFuture,
          ) &&
          identical(
            ref.read(commentsRepositoryProvider.future),
            commentsFuture,
          ) &&
          identical(
            ref.read(mergeRequestsRepositoryProvider.future),
            sourceFuture,
          ) &&
          (diffFuture == null ||
              identical(ref.read(diffRepositoryProvider.future), diffFuture)) &&
          (reviewSession == null ||
              identical(
                ref.read(reviewProvider.notifier).session,
                reviewSession,
              )) &&
          (reviewFuture == null ||
              identical(ref.read(reviewProvider.future), reviewFuture)) &&
          (detailFuture == null ||
              identical(
                ref.read(mergeRequestControllerProvider(arg).future),
                detailFuture,
              ));
      sessionCurrent = current;
      void check() {
        if (!current() && !ended.isCompleted) ended.complete();
      }

      subscriptions.add(ref.listen(currentAccountProvider, (_, _) => check()));
      subscriptions.add(ref.listen(gitLabClientProvider, (_, _) => check()));
      subscriptions.add(
        ref.listen(mrDraftNotesRepositoryProvider, (_, _) => check()),
      );
      subscriptions.add(
        ref.listen(commentsRepositoryProvider, (_, _) => check()),
      );
      subscriptions.add(
        ref.listen(mergeRequestsRepositoryProvider, (_, _) => check()),
      );

      if (selection != null) {
        subscriptions.add(
          ref.listen(diffRepositoryProvider, (_, _) => check()),
        );
        subscriptions.add(ref.listen(reviewProvider, (_, _) => check()));
      }

      // Bridge session cancellation once per command. Individual reads use the
      // local signal, which is completed in finally to release their handlers.
      unawaited(
        _ended!.future.then((_) {
          if (!ended.isCompleted) ended.complete();
        }),
      );
      Future<R> wait<R>(Future<R> future) => Future.any([
        future,
        ended.future.then<R>((_) => throw const _PendingReviewCancelled()),
      ]);
      // Attach error handlers to every started read immediately, including
      // reads that fail while another repository remains unresolved.
      final values = await wait(
        Future.wait<Object?>([
          clientFuture,
          draftFuture,
          sourceFuture,
          commentsFuture,
          ?diffFuture,
        ], eagerError: true),
      );
      final client = values[0] as GitLabClient?;
      final repository = values[1] as MrDraftNotesRepository?;
      final source = values[2];
      final comments = values[3];

      if (!current()) return null;
      if (client == null ||
          source == null ||
          comments == null ||
          (selection != null && values[4] == null) ||
          repository == null ||
          repository.authorId != account.user.id) {
        throw const GitLabAuthException('Invalid private review session.');
      }
      if (ref.exists(mergeRequestControllerProvider(arg))) {
        ref.invalidate(mergeRequestControllerProvider(arg));
      }
      final freshDetail = ref.read(mergeRequestControllerProvider(arg).future);
      detailFuture = freshDetail;
      subscriptions.add(
        ref.listen(mergeRequestControllerProvider(arg), (_, _) => check()),
      );
      final detail = await wait(freshDetail);
      if (!current()) return null;
      if (detail.id < 1 ||
          detail.iid != arg.iid ||
          (detail.projectId != null && detail.projectId != arg.projectId)) {
        throw const GitLabServerException(
          'Invalid private review detail identity.',
        );
      }
      if (selection != null) {
        // Suspend only our snapshot identity guard while starting this explicit
        // fresh read; subsequent external refreshes still cancel the command.
        reviewFuture = null;
        reviewSession = null;
        ref.invalidate(reviewProvider);
        final freshReview = ref.read(reviewProvider.future);
        reviewFuture = freshReview;
        reviewSession = ref.read(reviewProvider.notifier).session;
        final snapshot = await wait(freshReview);
        if (!current()) return null;
        if (!selection.matches(snapshot)) {
          throw const GitLabConflictException('The selected diff changed.');
        }
      }
      _syncPendingSession();
      return await action(repository, detail, current, wait);
    } on _PendingReviewCancelled {
      return null;
    } catch (_) {
      if (generation != _generation || isCurrent?.call() == false) return null;
      // Repository/account replacements are also observed by the cancellation
      // subscriptions. Ignore their failures rather than showing old-session UI.
      if (ended.isCompleted || sessionCurrent?.call() == false) return null;
      rethrow;
    } finally {
      if (!ended.isCompleted) ended.complete();
      for (final subscription in subscriptions) {
        subscription.close();
      }
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

/// Private cancellation does not expose a server payload or trigger retry.
class _PendingReviewCancelled implements Exception {
  const _PendingReviewCancelled();
}

typedef _PendingReviewWait = Future<T> Function<T>(Future<T> future);

/// Immutable confirmation data bound to the account, repositories and MR.
class MrPendingReviewPublication {
  MrPendingReviewPublication._({
    this.reviewerStateAvailable = false,
    this.reviewer,
    required List<MergeRequestDraftNote> items,
    int? draftNoteId,
    required Account account,
    required GitLabClient client,
    required MrDraftNotesRepository drafts,
    required MergeRequestsRepository details,
    required CommentsRepository comments,
    required MergeRequestRef resource,
    required int mergeRequestId,
  }) : items = List.unmodifiable(items),
       _draftNoteId = draftNoteId,
       _account = account,
       _client = client,
       _drafts = drafts,
       _details = details,
       _comments = comments,
       _resource = resource,
       _mergeRequestId = mergeRequestId;

  /// Derives a selected confirmation from a complete recovery inspection.
  /// Callers must show it again and obtain fresh consent before publication.
  MrPendingReviewPublication? forNote(int draftNoteId) {
    final matches = items.where((item) => item.id == draftNoteId);
    if (draftNoteId < 1 || matches.length != 1) return null;
    return MrPendingReviewPublication._(
      items: [matches.single],
      draftNoteId: draftNoteId,
      reviewerStateAvailable: reviewerStateAvailable,
      reviewer: reviewer,
      account: _account,
      client: _client,
      drafts: _drafts,
      details: _details,
      comments: _comments,
      resource: _resource,
      mergeRequestId: _mergeRequestId,
    );
  }

  final bool reviewerStateAvailable;
  final MergeRequestReviewer? reviewer;
  final int? _draftNoteId;
  final List<MergeRequestDraftNote> items;
  final Account _account;
  final GitLabClient _client;
  final MrDraftNotesRepository _drafts;
  final MergeRequestsRepository _details;
  final CommentsRepository _comments;
  final MergeRequestRef _resource;
  final int _mergeRequestId;
}

class MrPendingReviewPublicationInspection {
  MrPendingReviewPublicationInspection._(this.pending, List<Discussion> groups)
    : publicDiscussions = List.unmodifiable(groups);
  final MrPendingReviewPublication pending;
  final List<Discussion> publicDiscussions;
}

class MrPendingReplyInspection {
  MrPendingReplyInspection(List<MergeRequestDraftNote> notes, this.target)
    : notes = List.unmodifiable(notes);
  final List<MergeRequestDraftNote> notes;
  final Discussion? target;
}
