import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../data/mr_draft_notes_repository.dart';
import 'merge_requests_controllers.dart';
import 'mr_draft_notes_provider.dart';

/// A route plus the authoritative global MR identity from the current detail.
class MrPendingReviewQuery {
  const MrPendingReviewQuery({
    required this.mergeRequest,
    required this.mergeRequestId,
    this.perPage = 20,
    this.requireCurrentDetail = false,
  });

  final MergeRequestRef mergeRequest;
  final int mergeRequestId;
  final int perPage;

  /// UI consumers recheck authoritative detail before every draft read.
  final bool requireCurrentDetail;

  @override
  bool operator ==(Object other) =>
      other is MrPendingReviewQuery &&
      other.mergeRequest == mergeRequest &&
      other.mergeRequestId == mergeRequestId &&
      other.perPage == perPage &&
      other.requireCurrentDetail == requireCurrentDetail;

  @override
  int get hashCode =>
      Object.hash(mergeRequest, mergeRequestId, perPage, requireCurrentDetail);
}

/// Loaded private rows are a partial list until the server cursor ends.
/// Totals are optional server metadata, never a basis for publication eligibility.
class MrPendingReviewDrafts {
  MrPendingReviewDrafts._({
    required List<MergeRequestDraftNote> items,
    required Account? account,
    required MrDraftNotesRepository? repository,
    this.nextPage,
    this.total,
    this.totalPages,
    this.isLoadingMore = false,
  }) : items = List.unmodifiable(items),
       _account = account,
       _repository = repository;

  final List<MergeRequestDraftNote> items;
  final int? nextPage;
  final int? total;
  final int? totalPages;
  final bool isLoadingMore;
  final Account? _account;
  final MrDraftNotesRepository? _repository;

  bool get isComplete => nextPage == null;

  MrPendingReviewDrafts _loading() => MrPendingReviewDrafts._(
    items: items,
    account: _account,
    repository: _repository,
    nextPage: nextPage,
    total: total,
    totalPages: totalPages,
    isLoadingMore: true,
  );
}

/// Reads only; refresh and pagination never create, publish or approve notes.
class MrPendingReviewController
    extends
        AutoDisposeFamilyAsyncNotifier<
          MrPendingReviewDrafts,
          MrPendingReviewQuery
        > {
  int _generation = 0;
  void _end() => _generation++;

  bool _current(
    int generation,
    Account? account,
    MrDraftNotesRepository? repository,
  ) {
    if (generation != _generation) return false;
    if (ref.read(currentAccountProvider) != account) return false;
    if (arg.requireCurrentDetail) {
      final detail = ref
          .read(mergeRequestControllerProvider(arg.mergeRequest))
          .unwrapPrevious();
      final source = ref.read(mergeRequestsRepositoryProvider);
      if (detail.isLoading ||
          detail.hasError ||
          !detail.hasValue ||
          source.isLoading ||
          source.hasError ||
          source.valueOrNull == null ||
          !_matchesDetail(detail.value!)) {
        return false;
      }
    }
    final session = ref.read(mrDraftNotesRepositoryProvider);
    return !session.isLoading &&
        !session.hasError &&
        identical(session.valueOrNull, repository);
  }

  bool _matchesDetail(MergeRequest detail) =>
      detail.id == arg.mergeRequestId &&
      detail.id > 0 &&
      detail.iid == arg.mergeRequest.iid &&
      (detail.projectId == null ||
          detail.projectId == arg.mergeRequest.projectId);

  @override
  Future<MrPendingReviewDrafts> build(MrPendingReviewQuery arg) async {
    _end();
    ref.onDispose(_end);
    final generation = _generation;
    if (arg.mergeRequest.projectId < 1 ||
        arg.mergeRequest.iid < 1 ||
        arg.mergeRequestId < 1 ||
        arg.perPage < 1 ||
        arg.perPage > 100) {
      throw ArgumentError('Invalid pending review query.');
    }
    final account = ref.watch(currentAccountProvider);
    if (account == null) {
      throw const GitLabAuthException('No authenticated draft note session.');
    }
    if (arg.requireCurrentDetail) {
      final source = ref.watch(mergeRequestsRepositoryProvider.future);
      final fresh = await ref.watch(
        mergeRequestControllerProvider(arg.mergeRequest).future,
      );
      final detailRepository = await source;
      if (generation != _generation) {
        return MrPendingReviewDrafts._(
          items: [],
          account: null,
          repository: null,
        );
      }
      if (detailRepository == null || !_matchesDetail(fresh)) {
        throw const GitLabServerException(
          'Invalid pending review detail identity.',
        );
      }
    }
    final repositorySession = ref.watch(mrDraftNotesRepositoryProvider.future);
    final repository = await repositorySession;
    if (!_current(generation, account, repository)) {
      // Riverpod discards superseded build outcomes; no private rows are returned.
      return MrPendingReviewDrafts._(
        items: [],
        account: null,
        repository: null,
      );
    }
    if (repository == null) {
      throw const GitLabAuthException('No authenticated draft note session.');
    }
    final page = await repository.list(
      projectId: arg.mergeRequest.projectId,
      iid: arg.mergeRequest.iid,
      perPage: arg.perPage,
    );
    if (!_current(generation, account, repository)) {
      return MrPendingReviewDrafts._(
        items: [],
        account: null,
        repository: null,
      );
    }
    return _combine(
      page,
      requestedPage: 1,
      repository: repository,
      account: account,
    );
  }

  MrPendingReviewDrafts _combine(
    Paginated<MergeRequestDraftNote> page, {
    required int requestedPage,
    required MrDraftNotesRepository repository,
    required Account account,
    MrPendingReviewDrafts? previous,
  }) {
    final ids = {
      for (final draft in previous?.items ?? <MergeRequestDraftNote>[])
        draft.id,
    };
    if ((page.nextPage != null && page.nextPage! <= requestedPage) ||
        page.items.any(
          (draft) =>
              draft.mergeRequestId != arg.mergeRequestId ||
              draft.authorId != account.user.id ||
              draft.authorId != repository.authorId ||
              !ids.add(draft.id),
        )) {
      throw const GitLabServerException('Invalid pending review draft page.');
    }
    return MrPendingReviewDrafts._(
      items: [...?previous?.items, ...page.items],
      account: account,
      repository: repository,
      nextPage: page.nextPage,
      total: page.total ?? previous?.total,
      totalPages: page.totalPages ?? previous?.totalPages,
    );
  }

  Future<bool> loadMore() async {
    if (state.isLoading || state.hasError) return false;
    final current = state.valueOrNull;
    final requestedPage = current?.nextPage;
    final repository = current?._repository;
    final account = current?._account;
    final generation = _generation;
    if (current == null ||
        current.isLoadingMore ||
        requestedPage == null ||
        repository == null ||
        account == null ||
        !_current(generation, account, repository)) {
      return false;
    }
    state = AsyncData(current._loading());
    try {
      final page = await repository.list(
        projectId: arg.mergeRequest.projectId,
        iid: arg.mergeRequest.iid,
        page: requestedPage,
        perPage: arg.perPage,
      );
      if (!_current(generation, account, repository)) return false;
      state = AsyncData(
        _combine(
          page,
          requestedPage: requestedPage,
          repository: repository,
          account: account,
          previous: current,
        ),
      );
      return true;
    } catch (error, stack) {
      if (!_current(generation, account, repository)) return false;
      // A failed private read cannot retain an earlier, now uncertain partial list.
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  /// Explicit read-only retry starts at page one and supersedes pending pages.
  void refresh() {
    _end();
    ref.invalidateSelf();
  }
}

final mrPendingReviewControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      MrPendingReviewController,
      MrPendingReviewDrafts,
      MrPendingReviewQuery
    >(MrPendingReviewController.new);

/// Presentation must watch this provider, excluding retained private data.
final mrPendingReviewProvider = Provider.autoDispose
    .family<AsyncValue<MrPendingReviewDrafts>, MrPendingReviewQuery>((
      ref,
      query,
    ) {
      final account = ref.watch(currentAccountProvider);
      final repository = ref.watch(mrDraftNotesRepositoryProvider);
      final value = ref
          .watch(mrPendingReviewControllerProvider(query))
          .unwrapPrevious();
      if (value.hasValue &&
          (account == null ||
              value.value!._account != account ||
              repository.isLoading ||
              repository.hasError ||
              !identical(repository.valueOrNull, value.value!._repository))) {
        return const AsyncLoading();
      }
      return value;
    });
