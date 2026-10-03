import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/analytics/analytics.dart';
import 'package:labfox/core/entitlement/entitlement.dart';
import 'package:labfox/core/entitlement/entitlement_providers.dart';
import 'package:labfox/core/entitlement/paywall.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';
import 'package:labfox/features/comments/presentation/controllers/comments_controller.dart';
import 'package:labfox/features/jobs/data/job_repository.dart';
import 'package:labfox/features/jobs/presentation/controllers/job_actions_controller.dart';
import 'package:labfox/features/jobs/presentation/controllers/job_controllers.dart';
import 'package:labfox/features/merge_requests/data/mr_actions_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';
import 'package:labfox/l10n/app_localizations.dart';

/// Records the event names and their properties instead of posting anywhere.
class _Recording implements Analytics {
  final List<(String, Map<String, Object?>)> events = [];

  List<String> get names => events.map((e) => e.$1).toList();

  @override
  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    events.add((name, properties ?? const {}));
  }
}

GitLabClient _client() =>
    GitLabClient(baseUrl: 'https://gitlab.com', token: 'glpat-xxxxxxxxxxxx');

const _mr = MergeRequest(
  id: 1,
  iid: 2,
  title: 'title',
  state: 'opened',
  sourceBranch: 'feature',
  targetBranch: 'main',
);

class _FakeMrActions extends MrActionsRepository {
  _FakeMrActions() : super(_client());

  @override
  Future<void> approve({required int projectId, required int iid}) async {}

  @override
  Future<void> unapprove({required int projectId, required int iid}) async {}

  @override
  Future<MergeRequest> merge({
    required int projectId,
    required int iid,
    bool squash = false,
  }) async => _mr;

  @override
  Future<MergeRequest> setOpen({
    required int projectId,
    required int iid,
    required bool open,
  }) async => _mr;

  @override
  Future<void> rebase({required int projectId, required int iid}) async {}

  @override
  Future<MergeRequestApprovals?> approvals({
    required int projectId,
    required int iid,
  }) async => null;
}

const _job = Job(id: 3, name: 'build', status: 'success');

class _FakeJobs extends JobRepository {
  _FakeJobs() : super(_client());

  @override
  Future<Job> retry({required int projectId, required int jobId}) async => _job;

  @override
  Future<Job> cancel({required int projectId, required int jobId}) async =>
      _job;

  @override
  Future<Job> play({required int projectId, required int jobId}) async => _job;
}

const _pipeline = Pipeline(id: 4, status: 'success');

class _FakePipelines extends PipelinesRepository {
  @override
  Future<Paginated<PipelineTriggerJob>> triggerJobs({
    required int projectId,
    required int pipelineId,
    int page = 1,
  }) async => const Paginated(items: []);
  _FakePipelines() : super(_client());

  @override
  Future<Pipeline> retry({
    required int projectId,
    required int pipelineId,
  }) async => _pipeline;

  @override
  Future<Pipeline> cancel({
    required int projectId,
    required int pipelineId,
  }) async => _pipeline;
}

class _FakeComments extends CommentsRepository {
  _FakeComments() : super(_client());

  @override
  Future<Note> post({
    required NoteableType type,
    required int projectId,
    required int iid,
    required String body,
  }) async => const Note(id: 1, body: 'x');

  @override
  Future<List<Note>> list({
    required NoteableType type,
    required int projectId,
    required int iid,
  }) async => const [];
}

ProviderContainer _container(_Recording analytics, List<Override> overrides) {
  final container = ProviderContainer(
    overrides: [analyticsProvider.overrideWithValue(analytics), ...overrides],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  const mrRef = MergeRequestRef(projectId: 1, iid: 2);
  const jobRef = JobRef(projectId: 1, jobId: 3);
  const pipelineRef = PipelineRef(projectId: 1, pipelineId: 4);

  test('approving and unapproving an MR are tracked apart', () async {
    final analytics = _Recording();
    final container = _container(analytics, [
      mrActionsRepositoryProvider.overrideWith((ref) async => _FakeMrActions()),
    ]);

    final notifier = container.read(
      mrActionsControllerProvider(mrRef).notifier,
    );
    await notifier.approve();
    await notifier.unapprove();

    expect(analytics.names, containsAll(['mr_approved', 'mr_unapproved']));
  });

  test('merging records whether it was squashed', () async {
    final analytics = _Recording();
    final container = _container(analytics, [
      mrActionsRepositoryProvider.overrideWith((ref) async => _FakeMrActions()),
    ]);

    await container
        .read(mrActionsControllerProvider(mrRef).notifier)
        .merge(squash: true);

    final merged = analytics.events.firstWhere((e) => e.$1 == 'mr_merged');
    expect(merged.$2['squash'], isTrue);
  });

  test('closing and reopening an MR are tracked apart', () async {
    final analytics = _Recording();
    final container = _container(analytics, [
      mrActionsRepositoryProvider.overrideWith((ref) async => _FakeMrActions()),
    ]);

    final notifier = container.read(
      mrActionsControllerProvider(mrRef).notifier,
    );
    await notifier.setOpen(false);
    await notifier.setOpen(true);
    await notifier.rebase();

    expect(
      analytics.names,
      containsAll(['mr_closed', 'mr_reopened', 'mr_rebased']),
    );
  });

  test('job actions are tracked, manual runs apart from retries', () async {
    final analytics = _Recording();
    final container = _container(analytics, [
      jobRepositoryProvider.overrideWith((ref) async => _FakeJobs()),
    ]);

    final notifier = container.read(
      jobActionsControllerProvider(jobRef).notifier,
    );
    await notifier.retry();
    await notifier.cancel();
    await notifier.play();

    expect(
      analytics.names,
      containsAll(['job_retried', 'job_cancelled', 'job_played']),
    );
  });

  test('pipeline actions are tracked', () async {
    final analytics = _Recording();
    final container = _container(analytics, [
      pipelinesRepositoryProvider.overrideWith((ref) async => _FakePipelines()),
    ]);

    final notifier = container.read(
      pipelineActionsControllerProvider(pipelineRef).notifier,
    );
    await notifier.retry();
    await notifier.cancel();

    expect(
      analytics.names,
      containsAll(['pipeline_retried', 'pipeline_cancelled']),
    );
  });

  test('a comment records what it was posted on, never its text', () async {
    final analytics = _Recording();
    final container = _container(analytics, [
      commentsRepositoryProvider.overrideWith((ref) async => _FakeComments()),
    ]);
    const ref = CommentsRef(
      type: NoteableType.mergeRequest,
      projectId: 1,
      iid: 2,
    );

    await container
        .read(commentsControllerProvider(ref).notifier)
        .post('looks good to me');

    final posted = analytics.events.firstWhere((e) => e.$1 == 'comment_posted');
    expect(posted.$2['target'], 'merge_request');
    expect(posted.$2.values.join(' '), isNot(contains('looks good')));
  });

  testWidgets('a paywall records which feature was reached for', (
    tester,
  ) async {
    final analytics = _Recording();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWithValue(analytics),
          freePlatformProvider.overrideWithValue(false),
          entitlementProvider.overrideWith(_FreeEntitlement.new),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => runSubscribed(
                  context,
                  ref,
                  feature: PaidFeature.pipelineActions,
                  action: () async {},
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final shown = analytics.events.firstWhere((e) => e.$1 == 'paywall_shown');
    expect(shown.$2['feature'], 'pipelineActions');
  });
}

class _FreeEntitlement extends EntitlementController {
  @override
  Entitlement build() => Entitlement.free;
}
