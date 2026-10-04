import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/entitlement/paywall.dart';
import '../../../core/ui/ci_visual.dart';
import '../../../core/ui/share_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipelines_controllers.dart';
import 'downstream_pipelines_section.dart';
import 'upstream_pipeline_section.dart';

/// One pipeline: its status header and jobs grouped by stage.
class PipelineDetailScreen extends ConsumerWidget {
  const PipelineDetailScreen({
    required this.projectId,
    required this.pipelineId,
    super.key,
  });

  final int projectId;
  final int pipelineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pipelineRef = PipelineRef(
      projectId: projectId,
      pipelineId: pipelineId,
    );
    final status = ref.watch(pipelineJobStatusFilterProvider(pipelineRef));
    final detail = ref.watch(pipelineDetailProvider(pipelineRef));
    final jobs = ref.watch(pipelineJobsControllerProvider(pipelineRef));

    return Scaffold(
      appBar: AppBar(
        title: Text('#$pipelineId'),
        actions: [ShareLinkButton(url: detail.valueOrNull?.webUrl)],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pipelineDetailProvider(pipelineRef));
          ref.invalidate(pipelineJobsControllerProvider(pipelineRef));
          ref.invalidate(pipelineTriggerJobsControllerProvider(pipelineRef));
          ref.invalidate(pipelineUpstreamProvider(pipelineRef));
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.md),
          children: [
            detail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: Text(l10n.pipelineError),
              ),
              data: (p) =>
                  _PipelineHeader(pipelineRef: pipelineRef, pipeline: p),
            ),
            const Divider(height: LabFoxSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
              child: Wrap(
                spacing: LabFoxSpacing.sm,
                runSpacing: LabFoxSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.pipelineJobsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  // The record distinguishes clearing from dismissing the menu.
                  FilterMenuChip<({PipelineJobStatusFilter? status})>(
                    key: const ValueKey('pipeline-job-status-filter'),
                    selected: (status: status),
                    options: [
                      (status: null),
                      for (final value in PipelineJobStatusFilter.values)
                        (status: value),
                    ],
                    labelOf: (choice) => _jobStatusLabel(l10n, choice.status),
                    onSelected: (choice) =>
                        ref
                                .read(
                                  pipelineJobStatusFilterProvider(
                                    pipelineRef,
                                  ).notifier,
                                )
                                .state =
                            choice.status,
                  ),
                ],
              ),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            jobs.when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.pipelineJobsError),
                    TextButton(
                      onPressed: () => ref.invalidate(
                        pipelineJobsControllerProvider(pipelineRef),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (all) {
                if (all.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LabFoxSpacing.md,
                    ),
                    child: Text(
                      status == null
                          ? l10n.pipelineNoJobs
                          : l10n.pipelineJobsFilteredEmpty,
                    ),
                  );
                }
                final byStage = groupJobsByStage(all);
                return _PipelineStageFlow(
                  projectId: projectId,
                  stages: byStage,
                );
              },
            ),
            const Divider(height: LabFoxSpacing.xl),
            DownstreamPipelinesSection(pipelineRef: pipelineRef),
            const Divider(height: LabFoxSpacing.xl),
            UpstreamPipelineSection(pipelineRef: pipelineRef),
          ],
        ),
      ),
    );
  }
}

/// The status header of a pipeline: a large CI glyph, the branch it ran on,
/// a status pill and identifying metadata, with the retry/cancel actions below.
class _PipelineHeader extends StatelessWidget {
  const _PipelineHeader({required this.pipelineRef, required this.pipeline});

  final PipelineRef pipelineRef;
  final Pipeline pipeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = LabFoxStatusColors.of(context);
    final (icon, colors) = ciVisual(pipeline.ciStatus, status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  icon,
                  size: LabFoxIconSize.lg,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(width: LabFoxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pipeline.ref ??
                          AppLocalizations.of(
                            context,
                          ).pipelineSchedulePipelineNumber(pipeline.id),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: LabFoxSpacing.xs),
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodySmall!,
                      child: Wrap(
                        spacing: LabFoxSpacing.sm,
                        runSpacing: LabFoxSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusPill(
                            label: ciLabel(pipeline.status),
                            colors: colors,
                            dot: true,
                          ),
                          MetaText('#${pipeline.id}'),
                          if (pipeline.shortSha != null)
                            MetaText(pipeline.shortSha!),
                          if (pipeline.createdAt != null)
                            MetaText(
                              DateFormat.yMMMd().add_jm().format(
                                pipeline.createdAt!.toLocal(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _PipelineActions(pipelineRef: pipelineRef, pipeline: pipeline),
        ],
      ),
    );
  }
}

/// A connected, top-to-bottom stage flow that keeps execution order visible on
/// a narrow screen without requiring a horizontally scrolling graph.
class _PipelineStageFlow extends StatelessWidget {
  const _PipelineStageFlow({required this.projectId, required this.stages});

  final int projectId;
  final Map<String, List<Job>> stages;

  @override
  Widget build(BuildContext context) {
    final entries = stages.entries.toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, entry) in entries.indexed)
          _Stage(
            projectId: projectId,
            stage: entry.key,
            jobs: entry.value,
            step: index + 1,
            hasPrevious: index > 0,
            hasNext: index < entries.length - 1,
          ),
      ],
    );
  }
}

/// One numbered stage in the connected flow. Each job remains a [WorkTile]
/// with its own CI glyph and status pill so status is never conveyed by the
/// connector alone.
class _Stage extends StatelessWidget {
  const _Stage({
    required this.projectId,
    required this.stage,
    required this.jobs,
    required this.step,
    required this.hasPrevious,
    required this.hasNext,
  });

  final int projectId;
  final String stage;
  final List<Job> jobs;
  final int step;
  final bool hasPrevious;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = LabFoxStatusColors.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: LabFoxSpacing.xl,
            child: Column(
              children: [
                if (hasPrevious)
                  SizedBox(
                    height: LabFoxSpacing.md,
                    child: VerticalDivider(
                      width: LabFoxSpacing.xs,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  )
                else
                  const SizedBox(height: LabFoxSpacing.md),
                Container(
                  width: LabFoxSpacing.lg,
                  height: LabFoxSpacing.lg,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text('$step', style: theme.textTheme.labelSmall),
                ),
                if (hasNext)
                  Expanded(
                    child: VerticalDivider(
                      key: ValueKey('pipeline-stage-connector-${step - 1}'),
                      width: LabFoxSpacing.xs,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: LabFoxSpacing.md,
                    right: LabFoxSpacing.md,
                    bottom: LabFoxSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          stage.isEmpty ? '—' : stage,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(width: LabFoxSpacing.sm),
                      Text(
                        '${jobs.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final job in jobs)
                  Builder(
                    builder: (context) {
                      final (icon, colors) = ciVisual(job.ciStatus, status);
                      return WorkTile(
                        icon: icon,
                        iconColor: colors.foreground,
                        title: job.name,
                        metadata: [
                          StatusPill(
                            label: ciLabel(job.status),
                            colors: colors,
                            dot: true,
                          ),
                        ],
                        trailing: const Icon(
                          LabFoxIcons.chevron,
                          size: LabFoxIconSize.sm,
                        ),
                        onTap: () =>
                            context.push(Routes.job(projectId, job.id)),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineActions extends ConsumerWidget {
  const _PipelineActions({required this.pipelineRef, required this.pipeline});

  final PipelineRef pipelineRef;
  final Pipeline pipeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref
        .watch(pipelineActionsControllerProvider(pipelineRef))
        .isLoading;
    final notifier = ref.read(
      pipelineActionsControllerProvider(pipelineRef).notifier,
    );

    final buttons = <Widget>[
      if (pipeline.canRetry)
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () => runSubscribed(
                  context,
                  ref,
                  feature: PaidFeature.pipelineActions,
                  action: () => _run(context, l10n, notifier.retry),
                ),
          icon: const Icon(LabFoxIcons.refresh, size: 18),
          label: Text(l10n.pipelineActionRetry),
        ),
      if (pipeline.canCancel)
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () => runSubscribed(
                  context,
                  ref,
                  feature: PaidFeature.pipelineActions,
                  action: () => _run(context, l10n, notifier.cancel),
                ),
          icon: const Icon(Icons.stop_circle_outlined, size: 18),
          label: Text(l10n.pipelineActionCancel),
        ),
    ];
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: LabFoxSpacing.sm),
      child: Wrap(spacing: LabFoxSpacing.sm, children: buttons),
    );
  }

  Future<void> _run(
    BuildContext context,
    AppLocalizations l10n,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on GitLabException catch (error) {
      if (context.mounted) {
        final message = switch (error) {
          GitLabForbiddenException() ||
          GitLabAuthException() => l10n.pipelineActionForbidden,
          GitLabConflictException() => l10n.pipelineActionInvalid,
          _ => l10n.pipelineActionError,
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}

String _jobStatusLabel(
  AppLocalizations l10n,
  PipelineJobStatusFilter? status,
) => switch (status) {
  null => l10n.pipelineJobsStatusAll,
  PipelineJobStatusFilter.created => l10n.pipelinesStatusCreated,
  PipelineJobStatusFilter.pending => l10n.pipelinesStatusPending,
  PipelineJobStatusFilter.running => l10n.pipelinesStatusRunning,
  PipelineJobStatusFilter.success => l10n.pipelinesStatusSuccess,
  PipelineJobStatusFilter.failed => l10n.pipelinesStatusFailed,
  PipelineJobStatusFilter.canceled => l10n.pipelinesStatusCanceled,
  PipelineJobStatusFilter.skipped => l10n.pipelinesStatusSkipped,
  PipelineJobStatusFilter.manual => l10n.pipelinesStatusManual,
};
