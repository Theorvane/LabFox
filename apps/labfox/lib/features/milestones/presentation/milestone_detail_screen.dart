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
          if (projectKey != null && milestone.valueOrNull != null)
            IconButton(
              tooltip: l10n.milestoneEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => _EditMilestoneDialog(
                  keyRef: projectKey,
                  milestone: milestone.valueOrNull!,
                ),
              ),
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
  const _EditMilestoneDialog({required this.keyRef, required this.milestone});

  final MilestoneRef keyRef;
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
      await ref
          .read(milestoneEditControllerProvider(widget.keyRef).notifier)
          .save(
            title: _title.text,
            description: _description.text,
            startDate: _startDate,
            dueDate: _dueDate,
          );
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
              TextButton.icon(
                onPressed: _saving ? null : () => _selectDate(start: true),
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
              TextButton.icon(
                onPressed: _saving ? null : () => _selectDate(start: false),
                icon: const Icon(Icons.event_outlined),
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.milestoneDueDate),
                    if (_dueDate != null) Text(dateFormat.format(_dueDate!)),
                  ],
                ),
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
