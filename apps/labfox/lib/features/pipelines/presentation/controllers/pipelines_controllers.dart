import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/pipelines_repository.dart';

final pipelinesRepositoryProvider = FutureProvider<PipelinesRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : PipelinesRepository(client);
});

/// The selected server-side filter, scoped to one project.
final pipelineStatusFilterProvider =
    StateProvider.family<PipelineStatusFilter?, int>((ref, projectId) => null);

/// The exact branch or tag filter, scoped to one project.
final pipelineRefFilterProvider = StateProvider.family<String?, int>(
  (ref, projectId) => null,
);

/// The selected source, including explicit child discovery, scoped to one project.
final pipelineSourceFilterProvider =
    StateProvider.family<PipelineSourceFilter?, int>((ref, projectId) => null);

/// Lists a project's pipelines.
class PipelinesController
    extends FamilyAsyncNotifier<Paginated<Pipeline>, int> {
  bool _loadingMore = false;
  int _generation = 0;

  @override
  Future<Paginated<Pipeline>> build(int projectId) async {
    _generation++;
    _loadingMore = false;
    final status = ref.watch(pipelineStatusFilterProvider(projectId));
    final pipelineRef = ref.watch(pipelineRefFilterProvider(projectId));
    final source = ref.watch(pipelineSourceFilterProvider(projectId));
    final repo = await ref.watch(pipelinesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.list(
      projectId,
      status: status,
      ref: pipelineRef,
      source: source,
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore || state.isLoading) return;
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (current == null || page == null) return;
    final generation = _generation;
    final status = ref.read(pipelineStatusFilterProvider(arg));
    final pipelineRef = ref.read(pipelineRefFilterProvider(arg));
    final source = ref.read(pipelineSourceFilterProvider(arg));
    _loadingMore = true;
    try {
      final repo = await ref.read(pipelinesRepositoryProvider.future);
      if (repo == null) throw StateError('No authenticated account');
      final next = await repo.list(
        arg,
        page: page,
        status: status,
        ref: pipelineRef,
        source: source,
      );
      if (generation != _generation) return;
      final items = {for (final item in current.items) item.id: item};
      for (final item in next.items) {
        items[item.id] = item;
      }
      state = AsyncData(
        Paginated(
          items: items.values.toList(growable: false),
          nextPage: next.nextPage,
          total: next.total,
          totalPages: next.totalPages,
        ),
      );
    } finally {
      // Failure retains rows and the server cursor for the next attempt.
      if (generation == _generation) _loadingMore = false;
    }
  }
}

final pipelinesControllerProvider =
    AsyncNotifierProvider.family<PipelinesController, Paginated<Pipeline>, int>(
      PipelinesController.new,
    );

/// Identifies one pipeline.
class PipelineRef {
  const PipelineRef({required this.projectId, required this.pipelineId});

  final int projectId;
  final int pipelineId;

  @override
  bool operator ==(Object other) =>
      other is PipelineRef &&
      other.projectId == projectId &&
      other.pipelineId == pipelineId;

  @override
  int get hashCode => Object.hash(projectId, pipelineId);
}

/// The jobs of a pipeline, grouped by stage in first-seen order.
class PipelineJobsController
    extends FamilyAsyncNotifier<List<Job>, PipelineRef> {
  @override
  Future<List<Job>> build(PipelineRef arg) async {
    final repo = await ref.watch(pipelinesRepositoryProvider.future);
    if (repo == null) {
      throw StateError('No authenticated account');
    }
    return repo.jobs(projectId: arg.projectId, pipelineId: arg.pipelineId);
  }
}

final pipelineJobsControllerProvider =
    AsyncNotifierProvider.family<
      PipelineJobsController,
      List<Job>,
      PipelineRef
    >(PipelineJobsController.new);

/// A pipeline's own detail (status, ref, sha).
final pipelineDetailProvider = FutureProvider.family<Pipeline, PipelineRef>((
  ref,
  arg,
) async {
  final repo = await ref.watch(pipelinesRepositoryProvider.future);
  if (repo == null) {
    throw StateError('No authenticated account');
  }
  return repo.get(projectId: arg.projectId, pipelineId: arg.pipelineId);
});

/// Groups jobs by stage in pipeline execution order.
///
/// GitLab returns pipeline jobs by ID descending. Job IDs are allocated when
/// the pipeline is created, so reversing that API order restores the stage and
/// job sequence used to build the pipeline instead of presenting it backwards.
Map<String, List<Job>> groupJobsByStage(List<Job> jobs) {
  final ordered = [...jobs]..sort((a, b) => a.id.compareTo(b.id));
  final groups = <String, List<Job>>{};
  for (final job in ordered) {
    groups.putIfAbsent(job.stage ?? '', () => []).add(job);
  }
  return groups;
}

/// Runs retry / cancel, then refreshes the project list, pipeline and its jobs
/// so the new status comes from the server, not a local guess.
class PipelineActionsController extends FamilyAsyncNotifier<void, PipelineRef> {
  @override
  void build(PipelineRef arg) {}

  Future<void> retry() => _run(
    (repo) => repo.retry(projectId: arg.projectId, pipelineId: arg.pipelineId),
    'pipeline_retried',
  );

  Future<void> cancel() => _run(
    (repo) => repo.cancel(projectId: arg.projectId, pipelineId: arg.pipelineId),
    'pipeline_cancelled',
  );

  /// [event] names the action for analytics — the action only, never which
  /// project or pipeline it was (`PRIVACY.md`).
  Future<void> _run(
    Future<void> Function(PipelinesRepository repo) action,
    String event,
  ) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      final repo = await ref.read(pipelinesRepositoryProvider.future);
      if (repo == null) {
        throw StateError('No authenticated account');
      }
      await action(repo);
      ref.invalidate(pipelinesControllerProvider(arg.projectId));
      ref.invalidate(pipelineDetailProvider(arg));
      ref.invalidate(pipelineJobsControllerProvider(arg));
      unawaited(ref.read(analyticsProvider).track(event));
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final pipelineActionsControllerProvider =
    AsyncNotifierProvider.family<PipelineActionsController, void, PipelineRef>(
      PipelineActionsController.new,
    );
