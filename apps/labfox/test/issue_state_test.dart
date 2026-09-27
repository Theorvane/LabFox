import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/issues/data/issues_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/issue_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _FakeRepo extends IssuesRepository {
  _FakeRepo(this._issue)
    : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  Issue _issue;
  bool? lastOpen;
  String? lastTitle;
  String? lastDescription;

  @override
  Future<Issue> get({required int projectId, required int iid}) async => _issue;

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
}

void main() {
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
}
