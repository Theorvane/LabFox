import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../../inbox/presentation/controllers/inbox_controllers.dart';
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

  /// Saves label membership and refreshes detail and list consumers.
  Future<void> updateLabels(List<String> labels) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final updated = await repo.updateLabels(
      projectId: arg.projectId,
      iid: arg.iid,
      labels: labels,
    );
    // Update responses can contain bare label names. Reload the detailed
    // resource so its color metadata remains visible on the detail screen.
    Issue detailed;
    try {
      detailed = await repo.get(projectId: arg.projectId, iid: arg.iid);
    } on GitLabException {
      // The write succeeded; keep its response if the follow-up read fails.
      detailed = updated;
    }
    state = AsyncData(detailed);
    ref.invalidate(issuesControllerProvider);
    ref.invalidate(myIssuesControllerProvider);
  }

  /// Updates the date and refreshes issue lists that show due-date metadata.
  Future<void> updateDueDate(String dueDate) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final updated = await repo.updateDueDate(
      projectId: arg.projectId,
      iid: arg.iid,
      dueDate: dueDate,
    );
    state = AsyncData(updated);
    ref.invalidate(issuesControllerProvider);
    ref.invalidate(myIssuesControllerProvider);
  }

  /// Assigns or clears a milestone and refreshes issue lists.
  Future<void> updateMilestone(int milestoneId) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) throw StateError('No authenticated account');
    final updated = await repo.updateMilestone(
      projectId: arg.projectId,
      iid: arg.iid,
      milestoneId: milestoneId,
    );
    state = AsyncData(updated);
    ref.invalidate(issuesControllerProvider);
    ref.invalidate(myIssuesControllerProvider);
  }

  /// Updates confidentiality and refreshes lists that may change visibility.
  Future<void> setConfidential(bool confidential) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) throw StateError('No authenticated account');
    final updated = await repo.setConfidential(
      projectId: arg.projectId,
      iid: arg.iid,
      confidential: confidential,
    );
    state = AsyncData(updated.copyWith(confidential: confidential));
    ref.invalidate(issuesControllerProvider);
    ref.invalidate(myIssuesControllerProvider);
  }

  /// Changes discussion access and updates detail and issue-list consumers.
  Future<void> setDiscussionLocked(bool locked) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) throw StateError('No authenticated account');
    final updated = await repo.setDiscussionLocked(
      projectId: arg.projectId,
      iid: arg.iid,
      locked: locked,
    );
    state = AsyncData(updated.copyWith(discussionLocked: locked));
    ref.invalidate(issuesControllerProvider);
    ref.invalidate(myIssuesControllerProvider);
  }

  /// Replaces the issue assignees and refreshes affected lists.
  Future<void> updateAssignees(List<int> assigneeIds) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) throw StateError('No authenticated account');
    final updated = await repo.updateAssignees(
      projectId: arg.projectId,
      iid: arg.iid,
      assigneeIds: assigneeIds,
    );
    state = AsyncData(updated);
    ref.invalidate(issuesControllerProvider);
    ref.invalidate(myIssuesControllerProvider);
  }

  /// Applies the server response or the known target state for an idempotent
  /// 304 response, without treating an absent subscription field as false.
  Future<void> setSubscription(bool subscribed) async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final updated = await repo.setSubscription(
      projectId: arg.projectId,
      iid: arg.iid,
      subscribed: subscribed,
    );
    final current = state.valueOrNull;
    if (updated != null) {
      state = AsyncData(updated.copyWith(subscribed: subscribed));
    } else if (current != null) {
      state = AsyncData(current.copyWith(subscribed: subscribed));
    } else {
      state = AsyncData(await repo.get(projectId: arg.projectId, iid: arg.iid));
    }
  }

  /// Returns true when a new to-do item was created; false for GitLab's 304
  /// response when the issue is already in the current user's inbox.
  Future<bool> createTodo() async {
    final repo = await ref.read(issuesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    final todo = await repo.createTodo(projectId: arg.projectId, iid: arg.iid);
    if (todo == null) return false;
    ref.invalidate(inboxControllerProvider);
    return true;
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
