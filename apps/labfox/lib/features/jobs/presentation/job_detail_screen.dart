import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../core/ui/ci_visual.dart';
import '../../../core/ui/share_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/job_actions_controller.dart';
import 'controllers/job_controllers.dart';

/// One job: its status header and its log with ANSI colours.
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({
    required this.projectId,
    required this.jobId,
    super.key,
  });

  final int projectId;
  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobRef = JobRef(projectId: projectId, jobId: jobId);
    final detail = ref.watch(jobDetailProvider(jobRef));
    final trace = ref.watch(jobTraceProvider(jobRef));

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.valueOrNull?.name ?? l10n.jobTitle),
        actions: [
          ShareLinkButton(url: detail.valueOrNull?.webUrl),
          IconButton(
            icon: const Icon(LabFoxIcons.refresh),
            tooltip: l10n.jobRefresh,
            onPressed: () {
              ref.invalidate(jobDetailProvider(jobRef));
              ref.invalidate(jobTraceProvider(jobRef));
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: detail.when(
              loading: () => const SizedBox(
                height: 20,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(l10n.jobError),
              data: (job) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _JobHeader(job: job),
                  _JobActionBar(projectId: projectId, jobId: jobId, job: job),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: trace.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.jobLogError)),
              data: (text) {
                if (text.trim().isEmpty) {
                  return Center(child: Text(l10n.jobLogEmpty));
                }
                // The log is the last thing on screen; keep its tail above the
                // system gesture area.
                return SafeArea(
                  top: false,
                  child: SingleChildScrollView(child: AnsiLogView(trace: text)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The status header of a job: a CI glyph, the job name, a status pill and the
/// stage and run duration, matching the pipeline detail header.
class _JobHeader extends StatelessWidget {
  const _JobHeader({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = LabFoxStatusColors.of(context);
    final (icon, colors) = ciVisual(job.ciStatus, status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: LabFoxIconSize.lg, color: colors.foreground),
        ),
        const SizedBox(width: LabFoxSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: LabFoxSpacing.xs),
              DefaultTextStyle.merge(
                style: theme.textTheme.bodySmall!,
                child: Wrap(
                  spacing: LabFoxSpacing.sm,
                  runSpacing: LabFoxSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusPill(
                      label: ciLabel(job.status),
                      colors: colors,
                      dot: true,
                    ),
                    if (job.stage != null) MetaText(job.stage!),
                    if (_duration(job) case final d?) MetaText(d),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A short run duration like `1m 20s`, or null when the job has not both
  /// started and finished.
  static String? _duration(Job job) {
    final start = job.startedAt;
    final end = job.finishedAt;
    if (start == null || end == null) {
      return null;
    }
    final seconds = end.difference(start).inSeconds;
    if (seconds < 0) {
      return null;
    }
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return rest == 0 ? '${minutes}m' : '${minutes}m ${rest}s';
  }
}

class _JobActionBar extends ConsumerWidget {
  const _JobActionBar({
    required this.projectId,
    required this.jobId,
    required this.job,
  });

  final int projectId;
  final int jobId;
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobRef = JobRef(projectId: projectId, jobId: jobId);
    final busy = ref.watch(jobActionsControllerProvider(jobRef)).isLoading;
    final notifier = ref.read(jobActionsControllerProvider(jobRef).notifier);

    final buttons = <Widget>[
      if (job.canRetry)
        _ActionButton(
          icon: LabFoxIcons.refresh,
          label: l10n.jobActionRetry,
          busy: busy,
          run: notifier.retry,
        ),
      if (job.canCancel)
        _ActionButton(
          icon: Icons.stop_circle_outlined,
          label: l10n.jobActionCancel,
          busy: busy,
          run: notifier.cancel,
        ),
      if (job.canPlay)
        _ActionButton(
          icon: Icons.play_arrow,
          label: l10n.jobActionRun,
          busy: busy,
          run: notifier.play,
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
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.busy,
    required this.run,
  });

  final IconData icon;
  final String label;
  final bool busy;
  final Future<void> Function() run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: busy ? null : () => _run(context, l10n),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Future<void> _run(BuildContext context, AppLocalizations l10n) async {
    try {
      await run();
    } on GitLabException catch (error) {
      if (context.mounted) {
        final message = switch (error) {
          GitLabForbiddenException() ||
          GitLabAuthException() => l10n.jobActionForbidden,
          GitLabConflictException() => l10n.jobActionInvalid,
          _ => l10n.jobActionError,
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}
