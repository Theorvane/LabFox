import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/milestones_controller.dart';

/// A project milestone, restorable from its global GitLab ID.
class MilestoneDetailScreen extends ConsumerWidget {
  const MilestoneDetailScreen({
    required this.projectId,
    required this.milestoneId,
    super.key,
  }) : groupId = null;

  const MilestoneDetailScreen.group({
    required this.groupId,
    required this.milestoneId,
    super.key,
  }) : projectId = null;

  final int? projectId;
  final int? groupId;
  final int milestoneId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MilestoneRef? projectKey,
    GroupMilestoneRef? groupKey,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.milestoneDeleteConfirmTitle),
        content: Text(l10n.milestoneDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.milestoneDelete),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    try {
      if (projectKey != null) {
        await ref
            .read(milestoneDeleteControllerProvider(projectKey).notifier)
            .delete();
      } else {
        await ref
            .read(groupMilestoneDeleteControllerProvider(groupKey!).notifier)
            .delete();
      }
      if (!context.mounted) return;
      context.go(
        projectKey != null
            ? Routes.milestones(projectKey.projectId)
            : Routes.groupMilestones(groupKey!.groupId),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.milestoneDeleteError)));
    }
  }

  Future<void> _changeState(
    BuildContext context,
    WidgetRef ref,
    MilestoneRef key, {
    required bool close,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (close) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.milestoneCloseConfirmTitle),
          content: Text(l10n.milestoneCloseConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.milestoneClose),
            ),
          ],
        ),
      );
      if (!context.mounted || confirmed != true) return;
    }
    try {
      await ref
          .read(milestoneStateControllerProvider(key).notifier)
          .change(close: close);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.milestoneStateError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projectKey = projectId == null
        ? null
        : MilestoneRef(projectId: projectId!, milestoneId: milestoneId);
    final groupKey = groupId == null
        ? null
        : GroupMilestoneRef(groupId: groupId!, milestoneId: milestoneId);
    final milestone = projectKey == null
        ? ref.watch(groupMilestoneDetailProvider(groupKey!))
        : ref.watch(milestoneDetailProvider(projectKey));
    final changing =
        projectKey != null &&
        ref.watch(milestoneStateControllerProvider(projectKey)).isLoading;
    final deleting = projectKey != null
        ? ref.watch(milestoneDeleteControllerProvider(projectKey)).isLoading
        : ref
              .watch(groupMilestoneDeleteControllerProvider(groupKey!))
              .isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(milestone.valueOrNull?.title ?? l10n.milestonesTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(
                  groupId == null
                      ? Routes.milestones(projectId!)
                      : Routes.groupMilestones(groupId!),
                ),
        ),
        actions: [
          if (milestone.valueOrNull != null)
            IconButton(
              tooltip: l10n.milestoneEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => _EditMilestoneDialog(
                  projectKey: projectKey,
                  groupKey: groupKey,
                  milestone: milestone.valueOrNull!,
                ),
              ),
            ),
          if (projectKey != null &&
              (milestone.valueOrNull?.state == 'active' ||
                  milestone.valueOrNull?.state == 'closed'))
            IconButton(
              tooltip: milestone.valueOrNull!.state == 'closed'
                  ? l10n.milestoneReactivate
                  : l10n.milestoneClose,
              icon: Icon(
                milestone.valueOrNull!.state == 'closed'
                    ? Icons.restart_alt
                    : Icons.task_alt_outlined,
              ),
              onPressed: changing
                  ? null
                  : () => _changeState(
                      context,
                      ref,
                      projectKey,
                      close: milestone.valueOrNull!.state != 'closed',
                    ),
            ),
          if (milestone.valueOrNull != null)
            IconButton(
              tooltip: l10n.milestoneDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: deleting || changing
                  ? null
                  : () => _delete(context, ref, projectKey, groupKey),
            ),
        ],
      ),
      body: milestone.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.milestoneDetailError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => projectKey == null
                    ? ref.invalidate(groupMilestoneDetailProvider(groupKey!))
                    : ref.invalidate(milestoneDetailProvider(projectKey)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => projectKey == null
              ? ref.refresh(groupMilestoneDetailProvider(groupKey!).future)
              : ref.refresh(milestoneDetailProvider(projectKey).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final metadata = _Metadata(milestone: data);
              final description = _Description(milestone: data);
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 260, child: metadata),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: description),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  metadata,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  description,
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

class _EditMilestoneDialog extends ConsumerStatefulWidget {
  const _EditMilestoneDialog({
    required this.projectKey,
    required this.groupKey,
    required this.milestone,
  }) : assert((projectKey == null) != (groupKey == null));

  final MilestoneRef? projectKey;
  final GroupMilestoneRef? groupKey;
  final GitLabMilestone milestone;

  @override
  ConsumerState<_EditMilestoneDialog> createState() =>
      _EditMilestoneDialogState();
}

class _EditMilestoneDialogState extends ConsumerState<_EditMilestoneDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.milestone.title);
    _description = TextEditingController(text: widget.milestone.description);
    _startDate = widget.milestone.startDate;
    _dueDate = widget.milestone.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool start}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (start ? _startDate : _dueDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: AppLocalizations.of(context).milestoneChooseDate,
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (start) {
        _startDate = selected;
      } else {
        _dueDate = selected;
      }
      _error = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      setState(() => _error = l10n.milestoneTitleRequired);
      return;
    }
    if (_startDate != null &&
        _dueDate != null &&
        _startDate!.isAfter(_dueDate!)) {
      setState(() => _error = l10n.milestoneDateOrderError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.projectKey != null) {
        await ref
            .read(milestoneEditControllerProvider(widget.projectKey!).notifier)
            .save(
              title: _title.text,
              description: _description.text,
              startDate: _startDate,
              dueDate: _dueDate,
              clearStartDate:
                  widget.milestone.startDate != null && _startDate == null,
              clearDueDate:
                  widget.milestone.dueDate != null && _dueDate == null,
            );
      } else {
        await ref
            .read(
              groupMilestoneEditControllerProvider(widget.groupKey!).notifier,
            )
            .save(
              title: _title.text,
              description: _description.text,
              startDate: _startDate,
              dueDate: _dueDate,
              clearStartDate:
                  widget.milestone.startDate != null && _startDate == null,
              clearDueDate:
                  widget.milestone.dueDate != null && _dueDate == null,
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.milestoneUpdateError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );
    return AlertDialog(
      title: Text(l10n.milestoneEdit),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: l10n.milestoneTitleField,
                ),
              ),
              const SizedBox(height: LabFoxSpacing.sm),
              TextField(
                controller: _description,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: l10n.milestoneDescriptionField,
                ),
              ),
              const SizedBox(height: LabFoxSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _selectDate(start: true),
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.milestoneStartDate),
                          if (_startDate != null)
                            Text(dateFormat.format(_startDate!)),
                        ],
                      ),
                    ),
                  ),
                  if (_startDate != null)
                    IconButton(
                      tooltip: l10n.milestoneClearStartDate,
                      onPressed: _saving
                          ? null
                          : () => setState(() {
                              _startDate = null;
                              _error = null;
                            }),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _selectDate(start: false),
                      icon: const Icon(Icons.event_outlined),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.milestoneDueDate),
                          if (_dueDate != null)
                            Text(dateFormat.format(_dueDate!)),
                        ],
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      tooltip: l10n.milestoneClearDueDate,
                      onPressed: _saving
                          ? null
                          : () => setState(() {
                              _dueDate = null;
                              _error = null;
                            }),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(l10n.milestoneSaveChanges),
        ),
      ],
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.milestone});
  final GitLabMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              milestone.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            Chip(
              label: Text(
                milestone.state == 'closed'
                    ? l10n.milestonesClosed
                    : l10n.milestonesActive,
              ),
            ),
            if (milestone.startDate != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Text(
                l10n.milestoneStartDate,
                style: LabFoxTextRoles.of(context).sectionHeader,
              ),
              Text(dateFormat.format(milestone.startDate!)),
            ],
            if (milestone.dueDate != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Text(
                l10n.milestoneDueDate,
                style: LabFoxTextRoles.of(context).sectionHeader,
              ),
              Text(dateFormat.format(milestone.dueDate!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.milestone});
  final GitLabMilestone milestone;

  @override
  Widget build(BuildContext context) =>
      milestone.description == null || milestone.description!.isEmpty
      ? const SizedBox.shrink()
      : Card.outlined(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: MarkdownViewer(data: milestone.description!),
          ),
        );
}
