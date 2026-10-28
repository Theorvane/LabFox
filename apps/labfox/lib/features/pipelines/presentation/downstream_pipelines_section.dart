import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/ci_visual.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipelines_controllers.dart';

/// Trigger relationships stay independent from the pipeline's regular jobs.
class DownstreamPipelinesSection extends ConsumerStatefulWidget {
  const DownstreamPipelinesSection({required this.pipelineRef, super.key});
  final PipelineRef pipelineRef;
  @override
  ConsumerState<DownstreamPipelinesSection> createState() =>
      _DownstreamPipelinesSectionState();
}

class _DownstreamPipelinesSectionState
    extends ConsumerState<DownstreamPipelinesSection> {
  bool _busy = false;
  bool _pageFailed = false;
  int _generation = 0;
  @override
  void didUpdateWidget(DownstreamPipelinesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pipelineRef != widget.pipelineRef) {
      _generation++;
      _busy = false;
      _pageFailed = false;
    }
  }

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
            pipelineTriggerJobsControllerProvider(widget.pipelineRef).notifier,
          )
          .loadMore();
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _pageFailed = true);
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = pipelineTriggerJobsControllerProvider(widget.pipelineRef);
    ref.listen<AsyncValue<Paginated<PipelineTriggerJob>>>(provider, (_, next) {
      if (next.isLoading) {
        _generation++;
        _busy = false;
        _pageFailed = false;
      }
    });
    final jobs = ref.watch(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
          child: Text(
            l10n.pipelineDownstreamTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        jobs.when(
          skipLoadingOnRefresh: false,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pipelineDownstreamError),
                TextButton(
                  onPressed: () => ref.invalidate(provider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (page) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (page.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LabFoxSpacing.md,
                  ),
                  child: Text(l10n.pipelineDownstreamEmpty),
                ),
              for (final job in page.items) _TriggerTile(job: job),
              if (page.nextPage != null)
                Padding(
                  padding: const EdgeInsets.all(LabFoxSpacing.md),
                  child: Column(
                    children: [
                      if (_pageFailed)
                        Text(l10n.pipelineDownstreamLoadMoreError),
                      OutlinedButton(
                        onPressed: _busy ? null : _loadMore,
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _pageFailed
                                    ? l10n.retry
                                    : l10n.pipelinesLoadMore,
                              ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TriggerTile extends StatelessWidget {
  const _TriggerTile({required this.job});
  final PipelineTriggerJob job;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final target = job.downstreamPipeline;
    VoidCallback? open;
    // A missing project must never be inferred from the parent or web URL.
    if (target != null &&
        target.projectId != null &&
        target.projectId! > 0 &&
        target.id > 0) {
      open = () => context.push(Routes.pipeline(target.projectId!, target.id));
    }
    final (icon, colors) = ciVisual(
      target?.ciStatus ?? job.ciStatus,
      LabFoxStatusColors.of(context),
    );
    return WorkTile(
      title: job.name,
      icon: icon,
      iconColor: colors.foreground,
      metadata: [
        StatusPill(
          label: ciLabel(target?.status ?? job.status),
          colors: colors,
          dot: true,
        ),
        if (open != null)
          MetaText(l10n.pipelineDownstreamTarget(target!.projectId!, target.id))
        else
          MetaText(l10n.pipelineDownstreamUnavailable),
        if (target?.ref case final branch?) MetaText(branch),
        if (job.stage case final stage?) MetaText(stage),
      ],
      trailing: open == null ? null : const Icon(LabFoxIcons.chevron),
      onTap: open,
    );
  }
}
