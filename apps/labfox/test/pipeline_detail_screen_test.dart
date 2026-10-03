import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';
import 'package:labfox/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:labfox/l10n/app_localizations.dart';

class _StubJobs extends PipelineJobsController {
  _StubJobs(this._value);
  final List<Job> _value;

  @override
  Future<List<Job>> build(PipelineRef arg) async => _value;
}

Future<void> _pump(
  WidgetTester tester, {
  required Pipeline pipeline,
  List<Job> jobs = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pipelineTriggerJobsControllerProvider.overrideWith(_NoTriggers.new),
        pipelineDetailProvider.overrideWith((ref, arg) async => pipeline),
        pipelineJobsControllerProvider.overrideWith(() => _StubJobs(jobs)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PipelineDetailScreen(projectId: 1, pipelineId: 944),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('header shows the ref, a status pill and the pipeline number', (
    tester,
  ) async {
    await _pump(
      tester,
      pipeline: const Pipeline(
        id: 944,
        status: 'failed',
        ref: 'main',
        sha: 'abcdef1234567890',
      ),
    );

    // The branch ref reads as the header title.
    expect(find.text('main'), findsOneWidget);
    // The status pill spells out the state.
    expect(find.text('Failed'), findsOneWidget);
    // The pipeline number appears (app bar and header meta).
    expect(find.textContaining('#944'), findsWidgets);
    // The short SHA is shown, not the full 40-char one.
    expect(find.text('abcdef12'), findsOneWidget);
  });

  testWidgets('jobs render grouped by stage with a status pill each', (
    tester,
  ) async {
    await _pump(
      tester,
      pipeline: const Pipeline(id: 944, status: 'running', ref: 'main'),
      jobs: const [
        Job(id: 1, name: 'compile', status: 'success', stage: 'build'),
        Job(id: 2, name: 'unit', status: 'running', stage: 'test'),
      ],
    );

    expect(find.text('compile'), findsOneWidget);
    expect(find.text('unit'), findsOneWidget);
    // Each job carries its own status pill.
    expect(find.text('Success'), findsOneWidget);
    // 'Running' appears on the pipeline header pill and the job pill.
    expect(find.text('Running'), findsWidgets);
    // Stage names head their groups.
    expect(find.text('build'), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
  });

  testWidgets('stage flow renders from earliest to latest at phone width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pump(
      tester,
      pipeline: const Pipeline(id: 944, status: 'running', ref: 'main'),
      jobs: const [
        Job(id: 30, name: 'release', status: 'created', stage: 'deploy'),
        Job(id: 20, name: 'unit', status: 'success', stage: 'test'),
        Job(id: 10, name: 'compile', status: 'success', stage: 'build'),
      ],
    );

    expect(
      tester.getTopLeft(find.text('build')).dy,
      lessThan(tester.getTopLeft(find.text('test')).dy),
    );
    expect(
      tester.getTopLeft(find.text('test')).dy,
      lessThan(tester.getTopLeft(find.text('deploy')).dy),
    );
    expect(find.byKey(const ValueKey('pipeline-stage-connector-0')), findsOne);
    expect(find.byKey(const ValueKey('pipeline-stage-connector-1')), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stage flow remains stable at desktop width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pump(
      tester,
      pipeline: const Pipeline(id: 944, status: 'success', ref: 'main'),
      jobs: const [
        Job(id: 20, name: 'unit', status: 'success', stage: 'test'),
        Job(id: 10, name: 'compile', status: 'success', stage: 'build'),
      ],
    );

    expect(find.text('build'), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
    expect(find.byKey(const ValueKey('pipeline-stage-connector-0')), findsOne);
    expect(tester.takeException(), isNull);
  });
}

class _NoTriggers extends PipelineTriggerJobsController {
  @override
  Future<Paginated<PipelineTriggerJob>> build(PipelineRef arg) async =>
      const Paginated(items: []);
}
