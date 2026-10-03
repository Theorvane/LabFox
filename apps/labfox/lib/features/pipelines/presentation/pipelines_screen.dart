import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/ui/ci_visual.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipelines_controllers.dart';

/// A project's pipelines, most recent first.
class PipelinesScreen extends ConsumerStatefulWidget {
  const PipelinesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<PipelinesScreen> createState() => _PipelinesScreenState();
}

class _PipelinesScreenState extends ConsumerState<PipelinesScreen> {
  bool _busy = false;
  bool _pageFailed = false;
  int _generation = 0;

  @override
  void didUpdateWidget(PipelinesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
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
          .read(pipelinesControllerProvider(widget.projectId).notifier)
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
    final projectId = widget.projectId;
    final status = ref.watch(pipelineStatusFilterProvider(projectId));
    final provider = pipelinesControllerProvider(projectId);
    ref.listen<AsyncValue<Paginated<Pipeline>>>(provider, (_, next) {
      if (next.isLoading) {
        _generation++;
        _busy = false;
        _pageFailed = false;
      }
    });
    final pipelines = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pipelinesTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: LabFoxSpacing.md,
                right: LabFoxSpacing.md,
                bottom: LabFoxSpacing.sm,
              ),
              // A record keeps the All option distinct from menu cancellation.
              child: FilterMenuChip<({PipelineStatusFilter? status})>(
                selected: (status: status),
                options: [
                  (status: null),
                  for (final value in PipelineStatusFilter.values)
                    (status: value),
                ],
                labelOf: (choice) => _statusLabel(l10n, choice.status),
                onSelected: (choice) =>
                    ref
                        .read(pipelineStatusFilterProvider(projectId).notifier)
                        .state = choice
                        .status,
              ),
            ),
          ),
        ),
      ),
      body: pipelines.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.pipelinesError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(pipelinesControllerProvider(projectId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        skipLoadingOnRefresh: false,
        data: (page) {
          final items = page.items;
          final rowCount = items.isEmpty ? 1 : items.length;
          return RefreshIndicator(
            onRefresh: () async {
              try {
                final refreshed = ref.refresh(provider.future);
                await refreshed;
              } catch (_) {
                // The provider owns the localized, retryable error state.
              }
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: rowCount + (page.nextPage == null ? 0 : 1),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (items.isEmpty && index == 0) {
                  return EmptyState(
                    icon: LabFoxIcons.pipeline,
                    title: status == null
                        ? l10n.pipelinesEmpty
                        : l10n.pipelinesFilteredEmpty,
                  );
                }
                if (index == rowCount) {
                  return Padding(
                    padding: const EdgeInsets.all(LabFoxSpacing.md),
                    child: Column(
                      children: [
                        if (_pageFailed) Text(l10n.pipelinesLoadMoreError),
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
                  );
                }
                return _PipelineTile(
                  pipeline: items[index],
                  onTap: () =>
                      context.push(Routes.pipeline(projectId, items[index].id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PipelineTile extends StatelessWidget {
  const _PipelineTile({required this.pipeline, required this.onTap});

  final Pipeline pipeline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final (icon, colors) = ciVisual(pipeline.ciStatus, status);

    return WorkTile(
      icon: icon,
      iconColor: colors.foreground,
      title: pipeline.ref ?? l10n.pipelineSchedulePipelineNumber(pipeline.id),
      metadata: [
        StatusPill(label: ciLabel(pipeline.status), colors: colors, dot: true),
        MetaText('#${pipeline.id}'),
        // Why it ran. Two pipelines on the same ref with the same status are
        // indistinguishable until you know one was scheduled and the other
        // came from a push; gitlab.com tags it for that reason, and it is
        // already in the list response.
        if (pipeline.sourceLabel != null) MetaText(pipeline.sourceLabel!),
        if (pipeline.sha != null) MetaText(_shortSha(pipeline.sha!)),
        if (pipeline.createdAt != null)
          MetaText(DateFormat.yMMMd().format(pipeline.createdAt!.toLocal())),
      ],
      trailing: const Icon(LabFoxIcons.chevron),
      onTap: onTap,
    );
  }

  static String _shortSha(String sha) =>
      sha.length <= 8 ? sha : sha.substring(0, 8);
}

String _statusLabel(AppLocalizations l10n, PipelineStatusFilter? status) =>
    switch (status) {
      null => l10n.pipelinesStatusAll,
      PipelineStatusFilter.created => l10n.pipelinesStatusCreated,
      PipelineStatusFilter.pending => l10n.pipelinesStatusPending,
      PipelineStatusFilter.running => l10n.pipelinesStatusRunning,
      PipelineStatusFilter.success => l10n.pipelinesStatusSuccess,
      PipelineStatusFilter.failed => l10n.pipelinesStatusFailed,
      PipelineStatusFilter.canceled => l10n.pipelinesStatusCanceled,
      PipelineStatusFilter.skipped => l10n.pipelinesStatusSkipped,
      PipelineStatusFilter.manual => l10n.pipelinesStatusManual,
    };
