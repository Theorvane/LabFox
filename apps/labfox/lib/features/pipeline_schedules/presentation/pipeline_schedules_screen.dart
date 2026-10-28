import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipeline_schedules_controller.dart';
import 'widgets/pipeline_schedule_create_dialog.dart';

/// Project pipeline schedules with active-state filtering.
class PipelineSchedulesScreen extends ConsumerStatefulWidget {
  const PipelineSchedulesScreen({required this.projectId, super.key});
  final int projectId;

  @override
  ConsumerState<PipelineSchedulesScreen> createState() =>
      _PipelineSchedulesScreenState();
}

class _PipelineSchedulesScreenState
    extends ConsumerState<PipelineSchedulesScreen> {
  bool? _active;

  Future<void> _create() async {
    final scheduleId = await showDialog<int>(
      context: context,
      builder: (_) => PipelineScheduleCreateDialog(projectId: widget.projectId),
    );
    if (mounted && scheduleId != null) {
      await context.push(Routes.pipelineSchedule(widget.projectId, scheduleId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = PipelineScheduleListRef(
      projectId: widget.projectId,
      active: _active,
    );
    final schedules = ref.watch(pipelineScheduleListControllerProvider(key));
    final filters = <(bool?, String)>[
      (null, l10n.pipelineSchedulesAll),
      (true, l10n.pipelineSchedulesActive),
      (false, l10n.pipelineSchedulesInactive),
    ];
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.pipelineScheduleCreate,
            icon: const Icon(Icons.add),
            onPressed: _create,
          ),
        ],
        title: Text(l10n.pipelineSchedulesTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(widget.projectId)),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: Row(
                  children: [
                    for (final filter in filters) ...[
                      ChoiceChip(
                        label: Text(filter.$2),
                        selected: _active == filter.$1,
                        onSelected: (_) => setState(() => _active = filter.$1),
                      ),
                      const SizedBox(width: LabFoxSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: schedules.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.pipelineSchedulesError),
                    const SizedBox(height: LabFoxSpacing.md),
                    FilledButton(
                      onPressed: () => ref.invalidate(
                        pipelineScheduleListControllerProvider(key),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(child: Text(l10n.pipelineSchedulesEmpty))
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        pipelineScheduleListControllerProvider(key).future,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) => ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      constraints.maxWidth >=
                                          LabFoxBreakpoints.tablet
                                      ? 900
                                      : constraints.maxWidth,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    LabFoxSpacing.md,
                                  ),
                                  child: Card.outlined(
                                    margin: EdgeInsets.zero,
                                    child: Column(
                                      children: [
                                        for (final schedule in page.items)
                                          _ScheduleTile(
                                            projectId: widget.projectId,
                                            schedule: schedule,
                                          ),
                                        if (page.hasMore)
                                          TextButton(
                                            onPressed: () => ref
                                                .read(
                                                  pipelineScheduleListControllerProvider(
                                                    key,
                                                  ).notifier,
                                                )
                                                .loadMore(),
                                            child: Text(
                                              l10n.pipelineSchedulesLoadMore,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.projectId, required this.schedule});
  final int projectId;
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
    return ListTile(
      leading: const Icon(LabFoxIcons.pipeline),
      title: Text(schedule.description),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schedule.active
                ? l10n.pipelineSchedulesActive
                : l10n.pipelineSchedulesInactive,
          ),
          Text(schedule.ref),
          if (nextLabel != null) Text(l10n.pipelineScheduleNextRun(nextLabel)),
        ],
      ),
      trailing: const Icon(LabFoxIcons.chevron),
      onTap: () =>
          context.push(Routes.pipelineSchedule(projectId, schedule.id)),
    );
  }
}
