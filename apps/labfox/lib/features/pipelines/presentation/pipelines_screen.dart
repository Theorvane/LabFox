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

  Future<void> _editRef() async {
    final projectId = widget.projectId;
    final choice = await showDialog<({String? value})>(
      context: context,
      builder: (context) => _PipelineRefFilterDialog(
        initialValue: ref.read(pipelineRefFilterProvider(projectId)),
      ),
    );
    if (!mounted || widget.projectId != projectId || choice == null) return;
    ref.read(pipelineRefFilterProvider(projectId).notifier).state =
        choice.value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projectId = widget.projectId;
    final status = ref.watch(pipelineStatusFilterProvider(projectId));
    final pipelineRef = ref.watch(pipelineRefFilterProvider(projectId));
    final source = ref.watch(pipelineSourceFilterProvider(projectId));
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
              child: Row(
                children: [
                  // A record keeps the All option distinct from menu cancellation.
                  FilterMenuChip<({PipelineStatusFilter? status})>(
                    selected: (status: status),
                    options: [
                      (status: null),
                      for (final value in PipelineStatusFilter.values)
                        (status: value),
                    ],
                    labelOf: (choice) => _statusLabel(l10n, choice.status),
                    onSelected: (choice) =>
                        ref
                            .read(
                              pipelineStatusFilterProvider(projectId).notifier,
                            )
                            .state = choice
                            .status,
                  ),
                  const SizedBox(width: LabFoxSpacing.sm),
                  Tooltip(
                    message: pipelineRef == null
                        ? l10n.pipelinesRefAll
                        : l10n.pipelinesRefSelected(pipelineRef),
                    child: OutlinedButton(
                      key: const ValueKey('pipeline-ref-filter'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          LabFoxSpacing.minTouchTarget,
                        ),
                      ),
                      onPressed: _editRef,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          pipelineRef == null
                              ? l10n.pipelinesRefAll
                              : l10n.pipelinesRefSelected(pipelineRef),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: LabFoxSpacing.sm),
                  FilterMenuChip<({PipelineSourceFilter? source})>(
                    key: const ValueKey('pipeline-source-filter'),
                    selected: (source: source),
                    options: [
                      (source: null),
                      for (final value in PipelineSourceFilter.values)
                        (source: value),
                    ],
                    labelOf: (choice) => _sourceLabel(l10n, choice.source),
                    onSelected: (choice) =>
                        ref
                            .read(
                              pipelineSourceFilterProvider(projectId).notifier,
                            )
                            .state = choice
                            .source,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (source == PipelineSourceFilter.parentPipeline)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LabFoxSpacing.md,
                vertical: LabFoxSpacing.sm,
              ),
              child: Text(
                l10n.pipelinesChildHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: pipelines.when(
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
                        onPressed: () => ref.invalidate(
                          pipelinesControllerProvider(projectId),
                        ),
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
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (items.isEmpty && index == 0) {
                        return EmptyState(
                          icon: LabFoxIcons.pipeline,
                          title:
                              status == null &&
                                  pipelineRef == null &&
                                  source == null
                              ? l10n.pipelinesEmpty
                              : l10n.pipelinesFilteredEmpty,
                        );
                      }
                      if (index == rowCount) {
                        return Padding(
                          padding: const EdgeInsets.all(LabFoxSpacing.md),
                          child: Column(
                            children: [
                              if (_pageFailed)
                                Text(l10n.pipelinesLoadMoreError),
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
                        onTap: () => context.push(
                          Routes.pipeline(projectId, items[index].id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
        if (pipeline.sourceLabel != null)
          MetaText(
            pipeline.source == 'parent_pipeline'
                ? l10n.pipelinesSourceChild
                : pipeline.sourceLabel!,
          ),
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

/// Owns draft input until the user explicitly applies or clears the filter.
class _PipelineRefFilterDialog extends StatefulWidget {
  const _PipelineRefFilterDialog({required this.initialValue});
  final String? initialValue;
  @override
  State<_PipelineRefFilterDialog> createState() =>
      _PipelineRefFilterDialogState();
}

class _PipelineRefFilterDialogState extends State<_PipelineRefFilterDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final text = _controller.text;
    // Preserve the exact ref; only an empty input removes the filter.
    Navigator.of(context).pop((value: text.isEmpty ? null : text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.pipelinesRefTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: l10n.pipelinesRefTitle,
          helperText: l10n.pipelinesRefHint,
          helperMaxLines: 3,
        ),
        onSubmitted: (_) => _apply(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop((value: null)),
          child: Text(l10n.pipelinesRefClear),
        ),
        FilledButton(onPressed: _apply, child: Text(l10n.pipelinesRefApply)),
      ],
    );
  }
}

String _sourceLabel(AppLocalizations l10n, PipelineSourceFilter? source) =>
    switch (source) {
      null => l10n.pipelinesSourceAll,
      PipelineSourceFilter.push => l10n.pipelinesSourcePush,
      PipelineSourceFilter.web => l10n.pipelinesSourceWeb,
      PipelineSourceFilter.api => l10n.pipelinesSourceApi,
      PipelineSourceFilter.schedule => l10n.pipelinesSourceSchedule,
      PipelineSourceFilter.trigger => l10n.pipelinesSourceTrigger,
      PipelineSourceFilter.pipeline => l10n.pipelinesSourcePipeline,
      PipelineSourceFilter.mergeRequestEvent =>
        l10n.pipelinesSourceMergeRequest,
      PipelineSourceFilter.parentPipeline => l10n.pipelinesSourceChild,
    };
