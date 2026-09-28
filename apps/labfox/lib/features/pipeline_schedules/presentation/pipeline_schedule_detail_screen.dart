import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipeline_schedules_controller.dart';
import 'widgets/pipeline_schedule_delete_dialog.dart';

/// A restorable pipeline schedule detail with an explicit run-now action.
class PipelineScheduleDetailScreen extends ConsumerWidget {
  const PipelineScheduleDetailScreen({
    required this.projectId,
    required this.scheduleId,
    super.key,
  });

  final int projectId;
  final int scheduleId;

  Future<void> _delete(
    BuildContext context,
    PipelineScheduleRef key,
    String description,
  ) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => PipelineScheduleDeleteDialog(
        scheduleRef: key,
        description: description,
      ),
    );
    if (context.mounted && deleted == true) {
      context.go(Routes.pipelineSchedules(projectId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = PipelineScheduleRef(
      projectId: projectId,
      scheduleId: scheduleId,
    );
    final schedule = ref.watch(pipelineScheduleDetailProvider(key));
    final action = ref.watch(pipelineScheduleActionControllerProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          schedule.valueOrNull?.description ?? l10n.pipelineSchedulesTitle,
        ),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.pipelineSchedules(projectId)),
        ),
      ),
      body: schedule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.pipelineScheduleDetailError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(pipelineScheduleDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(pipelineScheduleDetailProvider(key).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final summary = _ScheduleSummary(schedule: data);
              final related = _ScheduleRelated(
                schedule: data,
                projectId: projectId,
                actionBusy: action.isLoading,
                onDelete: () => _delete(context, key, data.description),
                onPlay: () async {
                  try {
                    await ref
                        .read(
                          pipelineScheduleActionControllerProvider(
                            key,
                          ).notifier,
                        )
                        .play();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.pipelineScheduleRunSuccess),
                        ),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.pipelineScheduleRunError)),
                      );
                    }
                  }
                },
              );
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: constraints.maxWidth >= LabFoxBreakpoints.tablet
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 320, child: summary),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: related),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  summary,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  related,
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScheduleSummary extends StatelessWidget {
  const _ScheduleSummary({required this.schedule});
  final PipelineSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final next = schedule.nextRunAt;
    final nextLabel = next == null
        ? null
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).add_jm().format(next.toLocal());
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.description,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            Chip(
              label: Text(
                schedule.active
                    ? l10n.pipelineSchedulesActive
                    : l10n.pipelineSchedulesInactive,
              ),
            ),
            ListTile(
              title: Text(l10n.pipelineScheduleRef),
              subtitle: Text(schedule.ref),
            ),
            ListTile(
              title: Text(l10n.pipelineScheduleCron),
              subtitle: Text(schedule.cron),
            ),
            if (schedule.cronTimezone != null)
              ListTile(
                title: Text(l10n.pipelineScheduleTimezone),
                subtitle: Text(schedule.cronTimezone!),
              ),
            if (nextLabel != null)
              ListTile(
                title: Text(l10n.pipelineScheduleNextRunLabel),
                subtitle: Text(nextLabel),
              ),
            if (schedule.owner?.name != null)
              ListTile(
                title: Text(l10n.pipelineScheduleOwner),
                subtitle: Text(schedule.owner!.name!),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRelated extends StatelessWidget {
  const _ScheduleRelated({
    required this.schedule,
    required this.projectId,
    required this.actionBusy,
    required this.onPlay,
    required this.onDelete,
  });
  final PipelineSchedule schedule;
  final int projectId;
  final bool actionBusy;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pipeline = schedule.lastPipeline;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: actionBusy ? null : onPlay,
              icon: const Icon(LabFoxIcons.pipeline),
              label: Text(l10n.pipelineScheduleRunNow),
            ),
            const SizedBox(height: LabFoxSpacing.md),
            OutlinedButton.icon(
              onPressed: actionBusy ? null : onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.pipelineScheduleDelete),
            ),
            if (pipeline != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Text(
                l10n.pipelineScheduleLastPipeline,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ListTile(
                title: Text(l10n.pipelineSchedulePipelineNumber(pipeline.id)),
                subtitle: pipeline.status == null
                    ? null
                    : Text(pipeline.status!),
                onTap: () =>
                    context.push(Routes.pipeline(projectId, pipeline.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
