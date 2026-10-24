import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/ui/ci_visual.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/pipeline_schedule_history_controller.dart';
import '../controllers/pipeline_schedules_controller.dart';

/// Inline history errors do not hide the schedule metadata or run-now action.
class PipelineScheduleHistory extends ConsumerStatefulWidget {
  const PipelineScheduleHistory({required this.scheduleRef, super.key});
  final PipelineScheduleRef scheduleRef;

  @override
  ConsumerState<PipelineScheduleHistory> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<PipelineScheduleHistory> {
  bool _busy = false;
  bool _pageFailed = false;
  int _generation = 0;

  Future<void> _loadMore() async {
    if (_busy) return;
    final generation = _generation;
    setState(() {
      _busy = true;
      _pageFailed = false;
    });
    try {
      await ref
          .read(
            pipelineScheduleHistoryControllerProvider(
              widget.scheduleRef,
            ).notifier,
          )
          .loadMore();
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _pageFailed = true);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = pipelineScheduleHistoryControllerProvider(
      widget.scheduleRef,
    );
    ref.listen<AsyncValue<Paginated<Pipeline>>>(provider, (_, next) {
      if (next.isLoading) {
        _generation++;
        _busy = false;
        _pageFailed = false;
      }
    });
    final history = ref.watch(provider);
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.pipelineScheduleHistoryTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: LabFoxSpacing.md),
            history.when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Column(
                children: [
                  Text(l10n.pipelineScheduleHistoryError),
                  TextButton(
                    onPressed: () => ref.invalidate(provider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
              data: (page) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (page.items.isEmpty)
                    Text(l10n.pipelineScheduleHistoryEmpty),
                  for (final pipeline in page.items)
                    _HistoryTile(
                      pipeline: pipeline,
                      projectId: widget.scheduleRef.projectId,
                    ),
                  if (_pageFailed) Text(l10n.pipelineScheduleHistoryError),
                  if (page.nextPage != null)
                    OutlinedButton(
                      onPressed: _busy ? null : _loadMore,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _pageFailed
                                  ? l10n.retry
                                  : l10n.pipelineSchedulesLoadMore,
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.pipeline, required this.projectId});
  final Pipeline pipeline;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, colors) = ciVisual(
      pipeline.ciStatus,
      LabFoxStatusColors.of(context),
    );
    final createdAt = pipeline.createdAt;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.foreground),
      title: Text(l10n.pipelineSchedulePipelineNumber(pipeline.id)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pipeline.status),
          if (pipeline.ref != null) Text(pipeline.ref!),
          if (createdAt != null)
            Text(
              DateFormat.yMMMd(
                Localizations.localeOf(context).toString(),
              ).add_jm().format(createdAt.toLocal()),
            ),
        ],
      ),
      trailing: const Icon(LabFoxIcons.chevron),
      onTap: () => context.push(Routes.pipeline(projectId, pipeline.id)),
    );
  }
}
