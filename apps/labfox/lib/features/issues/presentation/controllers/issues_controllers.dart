import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/issues_repository.dart';

final issuesRepositoryProvider = FutureProvider<IssuesRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : IssuesRepository(client);
});

/// Identifies an issue list: which project, which state filter, and an
/// optional text search over title and description.
class IssuesQuery {
  const IssuesQuery({
    required this.projectId,
    this.state = IssueState.opened,
    this.search,
  });

  final int projectId;
  final IssueState state;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is IssuesQuery &&
      other.projectId == projectId &&
      other.state == state &&
      other.search == search;

  @override
  int get hashCode => Object.hash(projectId, state, search);
}

/// Lists issues for a query.
class IssuesController extends FamilyAsyncNotifier<List<Issue>, IssuesQuery> {
  @override
  Future<List<Issue>> build(IssuesQuery arg) async {
    final repo = await ref.watch(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(
      projectId: arg.projectId,
      state: arg.state,
      search: arg.search,
    );
  }
}

final issuesControllerProvider =
    AsyncNotifierProvider.family<IssuesController, List<Issue>, IssuesQuery>(
      IssuesController.new,
    );

/// Identifies one issue by its per-project iid.
class IssueRef {
  const IssueRef({required this.projectId, required this.iid});

  final int projectId;
  final int iid;

  @override
  bool operator ==(Object other) =>
      other is IssueRef && other.projectId == projectId && other.iid == iid;

  @override
  int get hashCode => Object.hash(projectId, iid);
}

/// Loads one issue's detail and toggles its open/closed state.
class IssueController extends FamilyAsyncNotifier<Issue, IssueRef> {
  @override
  Future<Issue> build(IssueRef arg) async {
    final repo = await ref.watch(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.get(projectId: arg.projectId, iid: arg.iid);
  }

  /// Closes or reopens the issue, reflects the returned state, and invalidates
  /// the project's issue lists so they pick up the change on return.
  Future<void> setOpen(bool open) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final updated = await repo.setOpen(
      projectId: arg.projectId,
      iid: arg.iid,
      open: open,
    );
    state = AsyncData(updated);
    ref.invalidate(issuesControllerProvider);
  }

  /// Saves editable fields and refreshes detail and list consumers.
  Future<void> updateDetails({
    required String title,
    required String description,
  }) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final updated = await repo.update(
      projectId: arg.projectId,
      iid: arg.iid,
      title: title,
      description: description,
    );
    state = AsyncData(updated);
    ref.invalidate(issuesControllerProvider);
    ref.invalidate(myIssuesControllerProvider);
  }
}

final issueControllerProvider =
    AsyncNotifierProvider.family<IssueController, Issue, IssueRef>(
      IssueController.new,
    );

/// Creates a new issue, then invalidates the open-issues list so it appears on
/// return. Exposes an [AsyncValue] so the form can show progress and errors.
class NewIssueController extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<Issue> submit({
    required int projectId,
    required String title,
    String? description,
  }) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    state = const AsyncLoading();
    try {
      final issue = await repo.create(
        projectId: projectId,
        title: title,
        description: description,
      );
      state = const AsyncData(null);
      unawaited(ref.read(analyticsProvider).track('issue_created'));
      ref.invalidate(issuesControllerProvider);
      return issue;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final newIssueControllerProvider =
    AutoDisposeAsyncNotifierProvider<NewIssueController, void>(
      NewIssueController.new,
    );

/// Identifies an account-level issue list: whose issues, in which state.
class MyIssuesQuery {
  const MyIssuesQuery({required this.scope, required this.state});

  final IssueScope scope;
  final IssueState state;

  @override
  bool operator ==(Object other) =>
      other is MyIssuesQuery && other.scope == scope && other.state == state;

  @override
  int get hashCode => Object.hash(scope, state);
}

/// The current user's issues across every project.
class MyIssuesController
    extends FamilyAsyncNotifier<List<Issue>, MyIssuesQuery> {
  @override
  Future<List<Issue>> build(MyIssuesQuery arg) async {
    final repo = await ref.watch(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.listMine(scope: arg.scope, state: arg.state);
  }
}

final myIssuesControllerProvider =
    AsyncNotifierProvider.family<
      MyIssuesController,
      List<Issue>,
      MyIssuesQuery
    >(MyIssuesController.new);
