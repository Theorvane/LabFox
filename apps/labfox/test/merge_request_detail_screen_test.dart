import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';
import 'package:labfox/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubMR extends MergeRequestController {
  _StubMR(this._value);
  final AsyncValue<MergeRequest> _value;

  @override
  Future<MergeRequest> build(MergeRequestRef arg) {
    return _value.when(
      data: (v) => Future.value(v),
      loading: () => Completer<MergeRequest>().future,
      error: (e, s) => Future.error(e, s),
    );
  }
}

class _StubTodoAction extends MrActionsController {
  bool called = false;

  @override
  Future<void> build(MergeRequestRef arg) async {}

  @override
  Future<bool> createTodo() async {
    called = true;
    return true;
  }
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<MergeRequest> value, {
  _StubTodoAction? todoAction,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mergeRequestControllerProvider.overrideWith(() => _StubMR(value)),
        if (todoAction != null)
          mrActionsControllerProvider.overrideWith(() => todoAction),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MergeRequestDetailScreen(projectId: 1, iid: 142),
      ),
    ),
  );
  await tester.pump();
}

MergeRequest _mr({String state = 'opened', List<Label> labels = const []}) =>
    MergeRequest(
      id: 55123,
      iid: 142,
      title: 'Add OAuth authentication',
      state: state,
      sourceBranch: 'feature/oauth',
      targetBranch: 'develop',
      description: 'Adds the OAuth flow.',
      webUrl: 'https://gitlab.com/acme/backend/-/merge_requests/142',
      labels: labels,
    );

void main() {
  testWidgets('renders branches, state, labels, and description', (
    tester,
  ) async {
    await _pump(
      tester,
      AsyncData(
        _mr(
          labels: const [Label(name: 'backend', color: '#0e8a16')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add OAuth authentication'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    // '!142' appears in the app bar and the header.
    expect(find.textContaining('!142'), findsWidgets);
    // The header eyebrow shows the repo path with the iid.
    expect(find.text('acme/backend !142'), findsOneWidget);
    // Source and target branches render in the branch chip.
    expect(find.text('feature/oauth'), findsOneWidget);
    expect(find.text('develop'), findsOneWidget);
    expect(find.byType(GitLabLabel), findsOneWidget);
    expect(find.byType(MarkdownViewer), findsOneWidget);
  });

  testWidgets('a merged MR shows the Merged state, not closed', (tester) async {
    await _pump(tester, AsyncData(_mr(state: 'merged')));
    await tester.pumpAndSettle();

    expect(find.text('Merged'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);
  });

  testWidgets('adds a merge request to the current user to-do list', (
    tester,
  ) async {
    final action = _StubTodoAction();
    await _pump(tester, AsyncData(_mr(state: 'merged')), todoAction: action);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to To-Do'));
    await tester.pumpAndSettle();

    expect(action.called, isTrue);
    expect(find.text('Added to your To-Do list.'), findsOneWidget);
  });
}
