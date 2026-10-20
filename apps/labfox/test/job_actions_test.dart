import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/jobs/presentation/controllers/job_actions_controller.dart';
import 'package:labfox/features/jobs/presentation/controllers/job_controllers.dart';
import 'package:labfox/features/jobs/presentation/job_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubActions extends JobActionsController {
  _StubActions({this.rejectWith});
  final Object? rejectWith;
  final List<String> ran = [];

  @override
  Future<void> build(JobRef arg) async {}

  @override
  Future<void> retry() async => _do('retry');
  @override
  Future<void> cancel() async => _do('cancel');
  @override
  Future<void> play() async => _do('play');

  Future<void> _do(String action) async {
    ran.add(action);
    if (rejectWith != null) {
      throw rejectWith!;
    }
  }
}

Future<_StubActions> _pump(
  WidgetTester tester, {
  required Job job,
  Object? rejectWith,
}) async {
  final stub = _StubActions(rejectWith: rejectWith);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jobDetailProvider.overrideWith((ref, arg) async => job),
        jobTraceProvider.overrideWith((ref, arg) async => 'log'),
        jobActionsControllerProvider.overrideWith(() => stub),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JobDetailScreen(projectId: 1, jobId: 7001),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return stub;
}

void main() {
  testWidgets('a failed job shows Retry, not Cancel or Run', (tester) async {
    await _pump(
      tester,
      job: const Job(id: 1, name: 'x', status: 'failed'),
    );
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Run'), findsNothing);
  });

  testWidgets('a running job shows Cancel, not Retry', (tester) async {
    await _pump(
      tester,
      job: const Job(id: 1, name: 'x', status: 'running'),
    );
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsNothing);
  });

  testWidgets('a manual job shows Run', (tester) async {
    await _pump(
      tester,
      job: const Job(id: 1, name: 'deploy', status: 'manual'),
    );
    expect(find.widgetWithText(OutlinedButton, 'Run'), findsOneWidget);
  });

  testWidgets('tapping Retry runs the action', (tester) async {
    final stub = await _pump(
      tester,
      job: const Job(id: 1, name: 'x', status: 'failed'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(stub.ran, ['retry']);
  });

  testWidgets('a forbidden action shows a permission message', (tester) async {
    await _pump(
      tester,
      job: const Job(id: 1, name: 'x', status: 'failed'),
      rejectWith: const GitLabForbiddenException('no', statusCode: 403),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.textContaining('do not have permission'), findsOneWidget);
  });

  testWidgets('retrying a job is available without a subscription', (
    tester,
  ) async {
    final stub = await _pump(
      tester,
      job: const Job(id: 7001, name: 'test', status: 'failed'),
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(stub.ran, ['retry']);
    expect(find.textContaining('Retrying, cancelling'), findsNothing);
  });
}
