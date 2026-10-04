import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';
import 'package:labfox/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubActions extends PipelineActionsController {
  final List<String> ran = [];

  @override
  Future<void> build(PipelineRef arg) async {}

  @override
  Future<void> retry() async => ran.add('retry');

  @override
  Future<void> cancel() async => ran.add('cancel');
}

Future<_StubActions> _pump(
  WidgetTester tester, {
  required String status,
}) async {
  final stub = _StubActions();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineTriggerJobsControllerProvider.overrideWith(_NoTriggers.new),
        pipelineUpstreamProvider.overrideWith((ref, arg) async => null),
        pipelineDetailProvider.overrideWith(
          (ref, arg) async => Pipeline(id: 944, status: status, ref: 'main'),
        ),
        pipelineJobsControllerProvider.overrideWith(() => _NoJobs()),
        pipelineActionsControllerProvider.overrideWith(() => stub),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PipelineDetailScreen(projectId: 1, pipelineId: 944),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return stub;
}

class _NoJobs extends PipelineJobsController {
  @override
  Future<Paginated<Job>> build(PipelineRef arg) async =>
      const Paginated(items: []);
}

void main() {
  testWidgets('a failed pipeline shows Retry, not Cancel', (tester) async {
    await _pump(tester, status: 'failed');
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsNothing);
  });

  testWidgets('a running pipeline shows Cancel, not Retry', (tester) async {
    await _pump(tester, status: 'running');
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsNothing);
  });

  testWidgets('tapping Retry runs the action', (tester) async {
    final stub = await _pump(tester, status: 'failed');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(stub.ran, ['retry']);
  });
}

class _NoTriggers extends PipelineTriggerJobsController {
  @override
  Future<Paginated<PipelineTriggerJob>> build(PipelineRef arg) async =>
      const Paginated(items: []);
}
