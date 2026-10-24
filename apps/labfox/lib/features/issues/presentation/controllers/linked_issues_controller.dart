import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/issue_links_repository.dart';
import 'issues_controllers.dart';

final issueLinksRepositoryProvider = FutureProvider<IssueLinksRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : IssueLinksRepository(client);
});

class LinkedIssuesController
    extends FamilyAsyncNotifier<Paginated<IssueLink>, IssueRef> {
  bool _loadingMore = false;

  @override
  Future<Paginated<IssueLink>> build(IssueRef arg) async {
    final repository = await ref.watch(issueLinksRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(arg.projectId, issueIid: arg.iid);
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    _loadingMore = true;
    try {
      final repository = await ref.read(issueLinksRepositoryProvider.future);
      if (repository == null) throw StateError('No authenticated account');
      final next = await repository.list(
        arg.projectId,
        issueIid: arg.iid,
        page: page,
      );
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

final linkedIssuesControllerProvider =
    AsyncNotifierProvider.family<
      LinkedIssuesController,
      Paginated<IssueLink>,
      IssueRef
    >(LinkedIssuesController.new);
