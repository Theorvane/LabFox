import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/milestones_controller.dart';

/// Active and closed project milestones.
class MilestonesScreen extends ConsumerStatefulWidget {
  const MilestonesScreen({required this.projectId, super.key}) : groupId = null;

  const MilestonesScreen.group({required this.groupId, super.key})
    : projectId = null;

  final int? projectId;
  final int? groupId;

  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen> {
  String _state = 'active';

  Future<void> _openCreate({int? projectId, int? groupId}) async {
    final created = await showDialog<GitLabMilestone>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateMilestoneDialog(
        projectId: projectId,
        groupId: groupId,
        listState: _state,
      ),
    );
    if (created != null && mounted) {
      unawaited(
        context.push(
          projectId == null
              ? Routes.groupMilestone(groupId!, created.id)
              : Routes.milestone(projectId, created.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projectId = widget.projectId;
    final groupId = widget.groupId;
    final projectKey = projectId == null
        ? null
        : MilestoneListRef(projectId: projectId, state: _state);
    final groupKey = groupId == null
        ? null
        : GroupMilestoneListRef(groupId: groupId, state: _state);
    final milestones = projectKey == null
        ? ref.watch(groupMilestoneListControllerProvider(groupKey!))
        : ref.watch(milestoneListControllerProvider(projectKey));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.milestonesTitle),
        actions: [
          if (projectId != null || groupId != null)
            TextButton.icon(
              onPressed: () =>
                  _openCreate(projectId: projectId, groupId: groupId),
              icon: const Icon(Icons.add),
              label: Text(l10n.milestoneNew),
            ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(
                  groupId == null
                      ? Routes.projectOverview(projectId!)
                      : Routes.group(groupId),
                ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'active',
                  label: Text(l10n.milestonesActive),
                ),
                ButtonSegment(
                  value: 'closed',
                  label: Text(l10n.milestonesClosed),
                ),
              ],
              selected: {_state},
              onSelectionChanged: (value) =>
                  setState(() => _state = value.single),
            ),
          ),
          Expanded(
            child: milestones.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.milestonesError),
                    const SizedBox(height: LabFoxSpacing.md),
                    FilledButton(
                      onPressed: () => projectKey == null
                          ? ref.invalidate(
                              groupMilestoneListControllerProvider(groupKey!),
                            )
                          : ref.invalidate(
                              milestoneListControllerProvider(projectKey),
                            ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(child: Text(l10n.milestonesEmpty))
                  : RefreshIndicator(
                      onRefresh: () => projectKey == null
                          ? ref.refresh(
                              groupMilestoneListControllerProvider(
                                groupKey!,
                              ).future,
                            )
                          : ref.refresh(
                              milestoneListControllerProvider(
                                projectKey,
                              ).future,
                            ),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Padding(
                                padding: const EdgeInsets.all(LabFoxSpacing.md),
                                child: Card.outlined(
                                  margin: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      for (final milestone in page.items)
                                        ListTile(
                                          leading: const Icon(
                                            LabFoxIcons.milestone,
                                          ),
                                          title: Text(milestone.title),
                                          subtitle: milestone.dueDate == null
                                              ? null
                                              : Text(
                                                  DateFormat.yMMMd(
                                                    Localizations.localeOf(
                                                      context,
                                                    ).toString(),
                                                  ).format(milestone.dueDate!),
                                                ),
                                          trailing: const Icon(
                                            LabFoxIcons.chevron,
                                          ),
                                          onTap: () => context.push(
                                            groupId == null
                                                ? Routes.milestone(
                                                    projectId!,
                                                    milestone.id,
                                                  )
                                                : Routes.groupMilestone(
                                                    groupId,
                                                    milestone.id,
                                                  ),
                                          ),
                                        ),
                                      if (page.hasMore)
                                        TextButton(
                                          onPressed: () => projectKey == null
                                              ? ref
                                                    .read(
                                                      groupMilestoneListControllerProvider(
                                                        groupKey!,
                                                      ).notifier,
                                                    )
                                                    .loadMore()
                                              : ref
                                                    .read(
                                                      milestoneListControllerProvider(
                                                        projectKey,
                                                      ).notifier,
                                                    )
                                                    .loadMore(),
                                          child: Text(l10n.milestoneLoadMore),
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
        ],
      ),
    );
  }
}

class _CreateMilestoneDialog extends ConsumerStatefulWidget {
  const _CreateMilestoneDialog({
    this.projectId,
    this.groupId,
    required this.listState,
  }) : assert((projectId == null) != (groupId == null));

  final int? projectId;
  final int? groupId;
  final String listState;

  @override
  ConsumerState<_CreateMilestoneDialog> createState() =>
      _CreateMilestoneDialogState();
}

class _CreateMilestoneDialogState
    extends ConsumerState<_CreateMilestoneDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _busy = false;
  bool _invalidTitle = false;
  bool _invalidDates = false;
  bool _failed = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseDate({required bool start}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (start ? _startDate : _dueDate) ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() {
        if (start) {
          _startDate = selected;
        } else {
          _dueDate = selected;
        }
        _invalidDates = false;
      });
    }
  }

  Future<void> _create() async {
    final title = _title.text.trim();
    if (title.isEmpty ||
        (_startDate != null &&
            _dueDate != null &&
            _startDate!.isAfter(_dueDate!))) {
      setState(() {
        _invalidTitle = title.isEmpty;
        _invalidDates =
            _startDate != null &&
            _dueDate != null &&
            _startDate!.isAfter(_dueDate!);
        _failed = false;
      });
      return;
    }
    setState(() {
      _busy = true;
      _invalidTitle = false;
      _invalidDates = false;
      _failed = false;
    });
    try {
      final created = widget.projectId == null
          ? await ref
                .read(
                  groupMilestoneListControllerProvider(
                    GroupMilestoneListRef(
                      groupId: widget.groupId!,
                      state: widget.listState,
                    ),
                  ).notifier,
                )
                .create(
                  title: title,
                  description: _description.text.trim(),
                  startDate: _startDate,
                  dueDate: _dueDate,
                )
          : await ref
                .read(
                  milestoneListControllerProvider(
                    MilestoneListRef(
                      projectId: widget.projectId!,
                      state: widget.listState,
                    ),
                  ).notifier,
                )
                .create(
                  title: title,
                  description: _description.text.trim(),
                  startDate: _startDate,
                  dueDate: _dueDate,
                );
      if (mounted) Navigator.of(context).pop(created);
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } on ArgumentError {
      if (mounted) setState(() => _invalidDates = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );
    Widget dateField(String label, DateTime? date, {required bool start}) =>
        Row(
          children: [
            Expanded(child: Text(label)),
            Flexible(
              child: OutlinedButton(
                onPressed: _busy ? null : () => _chooseDate(start: start),
                child: Text(
                  date == null
                      ? l10n.milestoneChooseDate
                      : dateFormat.format(date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (date != null)
              IconButton(
                tooltip: l10n.milestoneClearDate,
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        if (start) {
                          _startDate = null;
                        } else {
                          _dueDate = null;
                        }
                        _invalidDates = false;
                      }),
                icon: const Icon(Icons.clear),
              ),
          ],
        );
    return AlertDialog(
      title: Text(l10n.milestoneNew),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.milestoneTitleField),
            ),
            const SizedBox(height: LabFoxSpacing.md),
            TextField(
              controller: _description,
              enabled: !_busy,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.milestoneDescriptionField,
              ),
            ),
            const SizedBox(height: LabFoxSpacing.md),
            dateField(l10n.milestoneStartDate, _startDate, start: true),
            dateField(l10n.milestoneDueDate, _dueDate, start: false),
            if (_invalidTitle) Text(l10n.milestoneTitleRequired),
            if (_invalidDates) Text(l10n.milestoneDateOrderError),
            if (_failed) Text(l10n.milestoneCreateError),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: Text(l10n.milestoneCreate),
        ),
      ],
    );
  }
}
