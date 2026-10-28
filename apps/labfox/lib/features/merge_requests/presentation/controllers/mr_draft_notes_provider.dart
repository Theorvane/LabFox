import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/mr_draft_notes_repository.dart';
import 'merge_requests_controllers.dart';

/// The author identity and client are replaced together on account changes.
final mrDraftNotesRepositoryProvider =
    FutureProvider.autoDispose<MrDraftNotesRepository?>((ref) async {
      final account = ref.watch(currentAccountProvider);
      if (account == null) return null;
      var active = true;
      ref.onDispose(() => active = false);
      final client = await ref.watch(gitLabClientProvider.future);
      if (!active || client == null) return null;
      return MrDraftNotesRepository(client, authorId: account.user.id);
    });

/// A confirmed private save refreshes every reader variant for this route only.
final mrDraftNotesRevisionProvider = StateProvider.autoDispose
    .family<int, MergeRequestRef>((ref, resource) => 0);

/// An explicit page for a project/IID; the DTO's global MR ID is never routed.
class MrDraftNotesQuery {
  const MrDraftNotesQuery({
    required this.mergeRequest,
    this.page = 1,
    this.perPage = 20,
  });

  final MergeRequestRef mergeRequest;
  final int page;
  final int perPage;

  @override
  bool operator ==(Object other) =>
      other is MrDraftNotesQuery &&
      other.mergeRequest == mergeRequest &&
      other.page == page &&
      other.perPage == perPage;

  @override
  int get hashCode => Object.hash(mergeRequest, page, perPage);
}

/// Read-only future and explicit retry target for one requested page.
/// Presentation reads [mrDraftNotesPageProvider] to exclude retained private data.
/// Riverpod discards obsolete session completions, including their errors.
final mrDraftNotesReadProvider = FutureProvider.autoDispose
    .family<Paginated<MergeRequestDraftNote>, MrDraftNotesQuery>((
      ref,
      query,
    ) async {
      ref.watch(mrDraftNotesRevisionProvider(query.mergeRequest));
      var active = true;
      ref.onDispose(() => active = false);
      final repo = await ref.watch(mrDraftNotesRepositoryProvider.future);
      if (!active || repo == null) {
        throw const GitLabAuthException('No authenticated draft note session.');
      }
      return repo.list(
        projectId: query.mergeRequest.projectId,
        iid: query.mergeRequest.iid,
        page: query.page,
        perPage: query.perPage,
      );
    });

/// Hides retained data during loading/errors, including immediate account changes.
/// FutureProvider retains earlier values by default; private drafts cannot do so.
final mrDraftNotesPageProvider = Provider.autoDispose
    .family<AsyncValue<Paginated<MergeRequestDraftNote>>, MrDraftNotesQuery>(
      (ref, query) =>
          ref.watch(mrDraftNotesReadProvider(query)).unwrapPrevious(),
    );
