import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/issues/data/issues_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/issue_detail_screen.dart';
import 'package:labfox/features/members/presentation/controllers/members_controller.dart';
import 'package:labfox/features/milestones/presentation/controllers/milestones_controller.dart';
import 'package:labfox/features/project_labels/presentation/controllers/project_labels_controller.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FakeRepo extends IssuesRepository {
  _FakeRepo(this._issue)
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  Issue _issue;
  bool? lastOpen;
  String? lastTitle;
  String? lastDescription;
  bool? lastSubscription;
  int? lastTodoIid;
  List<String>? lastLabels;
  String? lastDueDate;
  bool rejectDueDate = false;
  int? lastMilestoneId;
  bool rejectMilestone = false;
  bool rejectLabels = false;
  List<int>? lastAssigneeIds;
  bool rejectAssignees = false;
  Issue? detailedAfterLabelUpdate;
  int getCount = 0;
  bool todoAlreadyExists = false;

  @override
  Future<Issue> get({required int projectId, required int iid}) async {
    getCount++;
    return detailedAfterLabelUpdate ?? _issue;
  }

  @override
  Future<Issue> setOpen({
    required int projectId,
    required int iid,
    required bool open,
  }) async {
    lastOpen = open;
    _issue = _issue.copyWith(state: open ? 'opened' : 'closed');
    return _issue;
  }

  @override
  Future<Issue> update({
    required int projectId,
    required int iid,
    required String title,
    required String description,
  }) async {
    lastTitle = title;
    lastDescription = description;
    _issue = _issue.copyWith(title: title, description: description);
    return _issue;
  }

  @override
  Future<Issue?> setSubscription({
    required int projectId,
    required int iid,
    required bool subscribed,
  }) async {
    lastSubscription = subscribed;
    return null;
  }

  @override
  Future<Issue> updateDueDate({
    required int projectId,
    required int iid,
    required String dueDate,
  }) async {
    if (rejectDueDate) throw const GitLabForbiddenException('Forbidden');
    lastDueDate = dueDate;
    _issue = _issue.copyWith(
      dueDate: dueDate.isEmpty ? null : DateTime.parse(dueDate),
    );
    return _issue;
  }

  @override
  Future<Issue> updateMilestone({
    required int projectId,
    required int iid,
    required int milestoneId,
  }) async {
    if (rejectMilestone) throw const GitLabForbiddenException('Forbidden');
    lastMilestoneId = milestoneId;
    _issue = _issue.copyWith(
      milestone: milestoneId == 0
          ? null
          : GitLabMilestone(
              id: milestoneId,
              iid: 2,
              title: 'Group release',
              state: 'active',
            ),
    );
    return _issue;
  }

  @override
  Future<Issue> updateAssignees({
    required int projectId,
    required int iid,
    required List<int> assigneeIds,
  }) async {
    if (rejectAssignees) throw const GitLabForbiddenException('Forbidden');
    lastAssigneeIds = assigneeIds;
    _issue = _issue.copyWith(
      assignees: [
        for (final id in assigneeIds)
          User(id: id, username: 'user$id', name: 'User $id'),
      ],
    );
    return _issue;
  }

  @override
  Future<Todo?> createTodo({required int projectId, required int iid}) async {
    lastTodoIid = iid;
    return todoAlreadyExists ? null : const Todo(id: 112, state: 'pending');
  }

  @override
  Future<Issue> updateLabels({
    required int projectId,
    required int iid,
    required List<String> labels,
  }) async {
    if (rejectLabels) throw const GitLabForbiddenException('Forbidden');
    lastLabels = labels;
    _issue = _issue.copyWith(
      labels: labels.map((name) => Label(name: name)).toList(),
    );
    return _issue;
  }
}

class _StubLabels extends ProjectLabelsController {
  @override
  Future<List<ProjectLabel>> build(int projectId) async => const [
    ProjectLabel(id: 1, name: 'bug', color: '#ff0000'),
    ProjectLabel(id: 2, name: 'review', color: '#00ff00'),
  ];
}

class _EmptyLabels extends ProjectLabelsController {
  @override
  Future<List<ProjectLabel>> build(int projectId) async => const [];
}

class _StubMilestones extends MilestoneListController {
  @override
  Future<Paginated<GitLabMilestone>> build(MilestoneListRef arg) async {
    expect(arg.includeAncestors, isTrue);
    expect(arg.state, 'active');
    return const Paginated(
      items: [
        GitLabMilestone(
          id: 17,
          iid: 2,
          title: 'Project release',
          state: 'active',
        ),
      ],
      nextPage: 2,
    );
  }

  @override
  Future<void> loadMore() async {
    state = const AsyncData(
      Paginated(
        items: [
          GitLabMilestone(
            id: 17,
            iid: 2,
            title: 'Project release',
            state: 'active',
          ),
          GitLabMilestone(
            id: 31,
            iid: 3,
            title: 'Group release',
            state: 'active',
          ),
        ],
      ),
    );
  }
}

class _StubMembers extends ProjectMembersController {
  @override
  Future<Paginated<ProjectMember>> build(MemberListRef arg) async {
    if (arg.query == 'bob') {
      return const Paginated(
        items: [
          ProjectMember(id: 2, username: 'bob', name: 'Bob', accessLevel: 30),
        ],
      );
    }
    return const Paginated(
      items: [
        ProjectMember(id: 1, username: 'alice', name: 'Alice', accessLevel: 30),
      ],
      nextPage: 2,
    );
  }

  @override
  Future<void> loadMore() async {
    state = const AsyncData(
      Paginated(
        items: [
          ProjectMember(
            id: 1,
            username: 'alice',
            name: 'Alice',
            accessLevel: 30,
          ),
          ProjectMember(id: 2, username: 'bob', name: 'Bob', accessLevel: 30),
        ],
      ),
    );
  }
}

void main() {
  test('updateAssignees refreshes issue detail state', () async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'x', state: 'opened'),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    await container.read(issueControllerProvider(ref).notifier).updateAssignees(
      [1, 2],
    );

    expect(repo.lastAssigneeIds, [1, 2]);
    expect(
      container
          .read(issueControllerProvider(ref))
          .value!
          .assignees
          .map((user) => user.id),
      [1, 2],
    );
  });

  test('updateMilestone refreshes issue detail state', () async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'x', state: 'opened'),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    await container
        .read(issueControllerProvider(ref).notifier)
        .updateMilestone(31);

    expect(repo.lastMilestoneId, 31);
    expect(
      container.read(issueControllerProvider(ref)).value!.milestone?.id,
      31,
    );
  });

  test('updateLabels refreshes issue detail state', () async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'x', state: 'opened'),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    await container.read(issueControllerProvider(ref).notifier).updateLabels([
      'bug',
      'review',
    ]);

    expect(repo.lastLabels, ['bug', 'review']);
    expect(
      container
          .read(issueControllerProvider(ref))
          .value!
          .labels
          .map((label) => label.name),
      ['bug', 'review'],
    );
  });

  test('updateLabels reloads detailed label colors', () async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'x', state: 'opened'),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);
    repo.detailedAfterLabelUpdate = const Issue(
      id: 1,
      iid: 5,
      title: 'x',
      state: 'opened',
      labels: [Label(name: 'bug', color: '#ff0000')],
    );

    await container.read(issueControllerProvider(ref).notifier).updateLabels([
      'bug',
    ]);

    expect(repo.getCount, 2);
    expect(
      container.read(issueControllerProvider(ref)).value!.labels.single.color,
      '#ff0000',
    );
  });

  test('updating due date refreshes issue detail state', () async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'x', state: 'opened'),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    await container
        .read(issueControllerProvider(ref).notifier)
        .updateDueDate('2026-10-15');

    expect(repo.lastDueDate, '2026-10-15');
    expect(
      container.read(issueControllerProvider(ref)).value!.dueDate,
      DateTime(2026, 10, 15),
    );
  });

  test('setOpen closes the issue via the repository', () async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'x', state: 'opened'),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    await container.read(issueControllerProvider(ref).notifier).setOpen(false);

    expect(repo.lastOpen, isFalse);
    expect(container.read(issueControllerProvider(ref)).value!.isOpen, isFalse);
  });

  test('update reflects the saved title and cleared description', () async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'Old',
        description: 'Body',
        state: 'opened',
      ),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    await container
        .read(issueControllerProvider(ref).notifier)
        .updateDetails(title: 'New', description: '');

    expect(repo.lastTitle, 'New');
    expect(repo.lastDescription, '');
    expect(container.read(issueControllerProvider(ref)).value!.title, 'New');
  });

  test('setSubscription handles an idempotent response', () async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'x',
        state: 'opened',
        subscribed: false,
      ),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    await container
        .read(issueControllerProvider(ref).notifier)
        .setSubscription(true);

    expect(repo.lastSubscription, isTrue);
    expect(
      container.read(issueControllerProvider(ref)).value!.subscribed,
      isTrue,
    );
  });

  test('createTodo returns whether a new item was added', () async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'x', state: 'opened'),
    );
    final container = ProviderContainer(
      overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
    );
    addTearDown(container.dispose);
    const ref = IssueRef(projectId: 7, iid: 5);
    await container.read(issueControllerProvider(ref).future);

    expect(
      await container.read(issueControllerProvider(ref).notifier).createTodo(),
      isTrue,
    );
    expect(repo.lastTodoIid, 5);

    repo.todoAlreadyExists = true;
    expect(
      await container.read(issueControllerProvider(ref).notifier).createTodo(),
      isFalse,
    );
  });

  testWidgets('the detail menu offers Close for an open issue', (tester) async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'Bug', state: 'opened'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    expect(find.text('Close issue'), findsOneWidget);
  });

  testWidgets('edits an issue and clears its description', (tester) async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'Old title',
        description: 'Old body',
        state: 'opened',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit issue'));
    await tester.pumpAndSettle();

    expect(find.text('Old title'), findsWidgets);
    await tester.enterText(find.byType(TextFormField).first, 'New title');
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(repo.lastTitle, 'New title');
    expect(repo.lastDescription, '');
    expect(find.text('New title'), findsOneWidget);
    expect(find.text('No description provided.'), findsOneWidget);
  });

  testWidgets('selects existing project labels for an issue', (tester) async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        labels: [Label(name: 'bug')],
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          projectLabelsControllerProvider.overrideWith(_StubLabels.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save labels'));
    await tester.pumpAndSettle();

    expect(repo.lastLabels, ['bug', 'review']);
    expect(find.text('review'), findsOneWidget);
  });

  testWidgets('clears every issue label', (tester) async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        labels: [Label(name: 'bug')],
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          projectLabelsControllerProvider.overrideWith(_StubLabels.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'bug'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save labels'));
    await tester.pumpAndSettle();

    expect(repo.lastLabels, isEmpty);
    expect(find.text('bug'), findsNothing);
  });

  testWidgets('shows an empty picker when no labels are available', (
    tester,
  ) async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'Bug', state: 'opened'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          projectLabelsControllerProvider.overrideWith(_EmptyLabels.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await tester.pumpAndSettle();

    expect(find.text('No labels available'), findsOneWidget);
  });

  testWidgets('keeps label selection open on permission denial', (
    tester,
  ) async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'Bug', state: 'opened'),
    )..rejectLabels = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          projectLabelsControllerProvider.overrideWith(_StubLabels.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save labels'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not update labels. Please try again.'),
      findsOneWidget,
    );
    expect(repo.lastLabels, isNull);
  });

  testWidgets(
    'adds an assignee while preserving one absent from member search',
    (tester) async {
      final repo = _FakeRepo(
        const Issue(
          id: 1,
          iid: 5,
          title: 'Bug',
          state: 'opened',
          assignees: [User(id: 99, username: 'former', name: 'Former')],
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            issuesRepositoryProvider.overrideWith((ref) async => repo),
            projectMembersControllerProvider.overrideWith(_StubMembers.new),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: IssueDetailScreen(projectId: 7, iid: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit assignees'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Alice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save assignees'));
      await tester.pumpAndSettle();

      expect(repo.lastAssigneeIds, [99, 1]);
    },
  );

  testWidgets('loads more members and clears all assignees', (tester) async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        assignees: [User(id: 1, username: 'alice', name: 'Alice')],
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          projectMembersControllerProvider.overrideWith(_StubMembers.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit assignees'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsOneWidget);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Alice'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'bob');
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsOneWidget);
    await tester.tap(find.text('Save assignees'));
    await tester.pumpAndSettle();

    expect(repo.lastAssigneeIds, isEmpty);
  });

  testWidgets('keeps assignee picker open on permission denial', (
    tester,
  ) async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'Bug', state: 'opened'),
    )..rejectAssignees = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          projectMembersControllerProvider.overrideWith(_StubMembers.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit assignees'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save assignees'));
    await tester.pumpAndSettle();

    expect(find.text('Edit assignees'), findsOneWidget);
    expect(find.textContaining('Could not update assignees'), findsOneWidget);
  });

  testWidgets('selects a paginated ancestor milestone', (tester) async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'Bug', state: 'opened'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          milestoneListControllerProvider.overrideWith(_StubMilestones.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Group release'));
    await tester.pumpAndSettle();

    expect(repo.lastMilestoneId, 31);
    expect(find.text('Group release'), findsOneWidget);
  });

  testWidgets('clears a closed milestone absent from active list', (
    tester,
  ) async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        milestone: GitLabMilestone(
          id: 99,
          iid: 4,
          title: 'Old release',
          state: 'closed',
        ),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          milestoneListControllerProvider.overrideWith(_StubMilestones.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit milestone'));
    await tester.pumpAndSettle();
    expect(find.text('Old release'), findsWidgets);
    await tester.tap(find.text('No milestone'));
    await tester.pumpAndSettle();

    expect(repo.lastMilestoneId, 0);
    expect(find.text('Old release'), findsNothing);
  });

  testWidgets('keeps milestone selection open on permission denial', (
    tester,
  ) async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'Bug', state: 'opened'),
    )..rejectMilestone = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          issuesRepositoryProvider.overrideWith((ref) async => repo),
          milestoneListControllerProvider.overrideWith(_StubMilestones.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project release'));
    await tester.pumpAndSettle();

    expect(repo.lastMilestoneId, isNull);
    expect(find.text('Edit milestone'), findsOneWidget);
    expect(
      find.textContaining('Could not update the milestone'),
      findsOneWidget,
    );
  });

  testWidgets('clears an existing issue due date', (tester) async {
    final repo = _FakeRepo(
      Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        dueDate: DateTime(2026, 10, 15),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear due date'));
    await tester.pumpAndSettle();

    expect(repo.lastDueDate, '');
    expect(find.text('Oct 15, 2026'), findsNothing);
  });

  testWidgets('selects a new due date from the date picker', (tester) async {
    final repo = _FakeRepo(
      Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        dueDate: DateTime(2026, 10, 15),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(repo.lastDueDate, '2026-10-20');
    expect(find.textContaining('Due date:'), findsOneWidget);
  });

  testWidgets('keeps the due-date dialog open on permission denial', (
    tester,
  ) async {
    final repo = _FakeRepo(
      Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        dueDate: DateTime(2026, 10, 15),
      ),
    )..rejectDueDate = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear due date'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not update the due date. Please try again.'),
      findsOneWidget,
    );
    expect(repo.lastDueDate, isNull);
  });

  testWidgets('subscribes to issue notifications from the detail menu', (
    tester,
  ) async {
    final repo = _FakeRepo(
      const Issue(
        id: 1,
        iid: 5,
        title: 'Bug',
        state: 'opened',
        subscribed: false,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subscribe to notifications'));
    await tester.pumpAndSettle();

    expect(repo.lastSubscription, isTrue);
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unsubscribe from notifications'), findsOneWidget);
  });

  testWidgets('adds the issue to the current user to-do list', (tester) async {
    final repo = _FakeRepo(
      const Issue(id: 1, iid: 5, title: 'Bug', state: 'opened'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [issuesRepositoryProvider.overrideWith((ref) async => repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IssueDetailScreen(projectId: 7, iid: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to To-Do'));
    await tester.pumpAndSettle();

    expect(repo.lastTodoIid, 5);
    expect(find.text('Added to your To-Do list.'), findsOneWidget);
  });
}
