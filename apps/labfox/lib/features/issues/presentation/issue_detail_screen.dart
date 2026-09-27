import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/share_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import '../../comments/presentation/widgets/comment_thread.dart';
import '../../members/presentation/controllers/members_controller.dart';
import '../../milestones/presentation/controllers/milestones_controller.dart';
import '../../project_labels/presentation/controllers/project_labels_controller.dart';
import 'controllers/issues_controllers.dart';
import 'widgets/linked_issues_section.dart';

/// One issue: title, state, author, labels, the rendered description, and its
/// comment thread. The overflow menu edits, closes, or reopens the issue.
class IssueDetailScreen extends ConsumerWidget {
  const IssueDetailScreen({
    required this.projectId,
    required this.iid,
    super.key,
  });

  final int projectId;
  final int iid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final issueRef = IssueRef(projectId: projectId, iid: iid);
    final issue = ref.watch(issueControllerProvider(issueRef));

    return Scaffold(
      appBar: AppBar(
        title: Text('#$iid'),
        actions: [
          ShareLinkButton(url: issue.valueOrNull?.webUrl),
          if (issue.valueOrNull case final data?)
            PopupMenuButton<_IssueAction>(
              onSelected: (action) {
                if (action == _IssueAction.edit) {
                  showDialog<void>(
                    context: context,
                    builder: (_) =>
                        _EditIssueDialog(issue: data, issueRef: issueRef),
                  );
                } else if (action == _IssueAction.editLabels) {
                  showDialog<void>(
                    context: context,
                    builder: (_) =>
                        _EditIssueLabelsDialog(issue: data, issueRef: issueRef),
                  );
                } else if (action == _IssueAction.editDueDate) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _EditIssueDueDateDialog(
                      issue: data,
                      issueRef: issueRef,
                    ),
                  );
                } else if (action == _IssueAction.editMilestone) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _EditIssueMilestoneDialog(
                      issue: data,
                      issueRef: issueRef,
                    ),
                  );
                } else if (action == _IssueAction.editAssignees) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _EditIssueAssigneesDialog(
                      issue: data,
                      issueRef: issueRef,
                    ),
                  );
                } else if (action == _IssueAction.subscribe ||
                    action == _IssueAction.unsubscribe) {
                  _setSubscription(
                    context,
                    ref,
                    issueRef,
                    action == _IssueAction.subscribe,
                  );
                } else if (action == _IssueAction.addTodo) {
                  _createTodo(context, ref, issueRef);
                } else {
                  _setOpen(
                    context,
                    ref,
                    issueRef,
                    action == _IssueAction.reopen,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _IssueAction.addTodo,
                  child: Text(l10n.issueAddTodo),
                ),
                if (data.subscribed case final subscribed?)
                  PopupMenuItem(
                    value: subscribed
                        ? _IssueAction.unsubscribe
                        : _IssueAction.subscribe,
                    child: Text(
                      subscribed ? l10n.issueUnsubscribe : l10n.issueSubscribe,
                    ),
                  ),
                PopupMenuItem(
                  value: _IssueAction.edit,
                  child: Text(l10n.issueEdit),
                ),
                PopupMenuItem(
                  value: _IssueAction.editLabels,
                  child: Text(l10n.issueEditLabels),
                ),
                PopupMenuItem(
                  value: _IssueAction.editDueDate,
                  child: Text(l10n.issueEditDueDate),
                ),
                PopupMenuItem(
                  value: _IssueAction.editMilestone,
                  child: Text(l10n.issueEditMilestone),
                ),
                PopupMenuItem(
                  value: _IssueAction.editAssignees,
                  child: Text(l10n.issueEditAssignees),
                ),
                PopupMenuItem(
                  value: data.isOpen ? _IssueAction.close : _IssueAction.reopen,
                  child: Text(data.isOpen ? l10n.issueClose : l10n.issueReopen),
                ),
              ],
            ),
        ],
      ),
      body: issue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.issueError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(issueControllerProvider(issueRef)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.md),
          children: [
            _IssueHeader(issue: data),
            if (data.dueDate case final dueDate?) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: LabFoxSpacing.sm),
                  Text(
                    l10n.issueDueDateValue(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(dueDate),
                    ),
                  ),
                ],
              ),
            ],
            if (data.labels.isNotEmpty) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Wrap(
                spacing: LabFoxSpacing.sm,
                runSpacing: LabFoxSpacing.sm,
                children: [
                  for (final label in data.labels)
                    GitLabLabel(name: label.name, color: label.color),
                ],
              ),
            ],
            if (data.milestone case final milestone?) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Row(
                children: [
                  const Icon(LabFoxIcons.milestone, size: 18),
                  const SizedBox(width: LabFoxSpacing.sm),
                  Flexible(child: Text(milestone.title)),
                ],
              ),
            ],
            if (data.assignees.isNotEmpty) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Text(l10n.issueAssignees),
              Wrap(
                spacing: LabFoxSpacing.sm,
                children: [
                  for (final user in data.assignees)
                    Chip(label: Text(user.name)),
                ],
              ),
            ],
            const Divider(height: LabFoxSpacing.xl),
            if (data.description != null && data.description!.trim().isNotEmpty)
              MarkdownViewer(data: data.description!)
            else
              Text(
                l10n.issueNoDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: LabFoxSpacing.xl),
            LinkedIssuesSection(projectId: projectId, iid: iid),
            CommentThread(
              type: NoteableType.issue,
              projectId: projectId,
              iid: iid,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setOpen(
    BuildContext context,
    WidgetRef ref,
    IssueRef issueRef,
    bool open,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(issueControllerProvider(issueRef).notifier).setOpen(open);
    } on GitLabException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.issueStateError)));
      }
    }
  }

  Future<void> _setSubscription(
    BuildContext context,
    WidgetRef ref,
    IssueRef issueRef,
    bool subscribed,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(issueControllerProvider(issueRef).notifier)
          .setSubscription(subscribed);
    } on GitLabException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.issueSubscriptionError)));
      }
    }
  }

  Future<void> _createTodo(
    BuildContext context,
    WidgetRef ref,
    IssueRef issueRef,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final created = await ref
          .read(issueControllerProvider(issueRef).notifier)
          .createTodo();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(created ? l10n.issueTodoAdded : l10n.issueTodoExists),
          ),
        );
      }
    } on GitLabException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.issueTodoError)));
      }
    }
  }
}

enum _IssueAction {
  edit,
  editLabels,
  editDueDate,
  editMilestone,
  editAssignees,
  close,
  reopen,
  subscribe,
  unsubscribe,
  addTodo,
}

class _EditIssueMilestoneDialog extends ConsumerStatefulWidget {
  const _EditIssueMilestoneDialog({
    required this.issue,
    required this.issueRef,
  });

  final Issue issue;
  final IssueRef issueRef;

  @override
  ConsumerState<_EditIssueMilestoneDialog> createState() =>
      _EditIssueMilestoneDialogState();
}

class _EditIssueMilestoneDialogState
    extends ConsumerState<_EditIssueMilestoneDialog> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _select(int milestoneId) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(issueControllerProvider(widget.issueRef).notifier)
          .updateMilestone(milestoneId);
      if (mounted) Navigator.of(context).pop();
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listRef = MilestoneListRef(
      projectId: widget.issueRef.projectId,
      state: 'active',
      includeAncestors: true,
    );
    final milestones = ref.watch(milestoneListControllerProvider(listRef));
    final available = milestones.valueOrNull?.items ?? <GitLabMilestone>[];
    final selected = widget.issue.milestone;
    final includesSelected = available.any((item) => item.id == selected?.id);
    return AlertDialog(
      title: Text(l10n.issueEditMilestone),
      content: SizedBox(
        width: 480,
        height: MediaQuery.sizeOf(context).height * 0.45,
        child: ListView(
          children: [
            ListTile(
              title: Text(l10n.issueNoMilestone),
              selected: selected == null,
              onTap: _busy ? null : () => _select(0),
            ),
            if (selected != null && !includesSelected)
              ListTile(
                title: Text(selected.title),
                selected: true,
                onTap: _busy ? null : () => _select(selected.id),
              ),
            if (milestones.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (milestones.hasError)
              Column(
                children: [
                  Text(l10n.issueMilestonesLoadError),
                  TextButton(
                    onPressed: () => ref.invalidate(
                      milestoneListControllerProvider(listRef),
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              )
            else ...[
              if (available.isEmpty && selected == null)
                Text(l10n.milestonesEmpty),
              for (final milestone in available)
                ListTile(
                  title: Text(milestone.title),
                  selected: milestone.id == selected?.id,
                  onTap: _busy ? null : () => _select(milestone.id),
                ),
              if (milestones.valueOrNull?.nextPage != null)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => ref
                            .read(
                              milestoneListControllerProvider(listRef).notifier,
                            )
                            .loadMore(),
                  child: Text(l10n.milestoneLoadMore),
                ),
            ],
            if (_failed) Text(l10n.issueMilestoneSaveError),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _EditIssueLabelsDialog extends ConsumerStatefulWidget {
  const _EditIssueLabelsDialog({required this.issue, required this.issueRef});

  final Issue issue;
  final IssueRef issueRef;

  @override
  ConsumerState<_EditIssueLabelsDialog> createState() =>
      _EditIssueLabelsDialogState();
}

class _EditIssueLabelsDialogState
    extends ConsumerState<_EditIssueLabelsDialog> {
  late final Set<String> _selected = {
    for (final label in widget.issue.labels) label.name,
  };
  bool _busy = false;
  bool _failed = false;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(issueControllerProvider(widget.issueRef).notifier)
          .updateLabels(_selected.toList());
      if (mounted) Navigator.of(context).pop();
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = ref.watch(
      projectLabelsControllerProvider(widget.issueRef.projectId),
    );
    return AlertDialog(
      title: Text(l10n.issueEditLabels),
      content: SizedBox(
        width: 480,
        height: MediaQuery.sizeOf(context).height * 0.45,
        child: Column(
          children: [
            Expanded(
              child: labels.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.issueLabelsLoadError),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          projectLabelsControllerProvider(
                            widget.issueRef.projectId,
                          ),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                data: (available) {
                  final names = <String>{
                    for (final label in available) label.name,
                    for (final label in widget.issue.labels) label.name,
                  }.toList();
                  if (names.isEmpty) {
                    return Center(child: Text(l10n.issueLabelsEmpty));
                  }
                  return ListView.builder(
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      final name = names[index];
                      return CheckboxListTile(
                        title: Text(name),
                        value: _selected.contains(name),
                        onChanged: _busy
                            ? null
                            : (checked) => setState(() {
                                if (checked == true) {
                                  _selected.add(name);
                                } else {
                                  _selected.remove(name);
                                }
                              }),
                      );
                    },
                  );
                },
              ),
            ),
            if (_failed) Text(l10n.issueLabelsSaveError),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy || !labels.hasValue ? null : _save,
          child: Text(l10n.issueSaveLabels),
        ),
      ],
    );
  }
}

class _EditIssueAssigneesDialog extends ConsumerStatefulWidget {
  const _EditIssueAssigneesDialog({
    required this.issue,
    required this.issueRef,
  });

  final Issue issue;
  final IssueRef issueRef;

  @override
  ConsumerState<_EditIssueAssigneesDialog> createState() =>
      _EditIssueAssigneesDialogState();
}

class _EditIssueAssigneesDialogState
    extends ConsumerState<_EditIssueAssigneesDialog> {
  late final Set<int> _selected = {
    for (final user in widget.issue.assignees) user.id,
  };
  String _query = '';
  bool _busy = false;
  bool _failed = false;

  void _toggle(int id, bool selected) => setState(() {
    if (selected) {
      _selected.add(id);
    } else {
      _selected.remove(id);
    }
  });

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(issueControllerProvider(widget.issueRef).notifier)
          .updateAssignees(_selected.toList());
      if (mounted) Navigator.of(context).pop();
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final memberRef = MemberListRef(
      projectId: widget.issueRef.projectId,
      query: _query,
    );
    final members = ref.watch(projectMembersControllerProvider(memberRef));
    final available = members.valueOrNull?.items ?? <ProjectMember>[];
    final listedIds = available.map((member) => member.id).toSet();
    return AlertDialog(
      title: Text(l10n.issueEditAssignees),
      content: SizedBox(
        width: 480,
        height: 400,
        child: Column(
          children: [
            TextField(
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.projectMembersSearch),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final user in widget.issue.assignees)
                    if (!listedIds.contains(user.id))
                      CheckboxListTile(
                        title: Text(user.name),
                        subtitle: Text(user.username),
                        value: _selected.contains(user.id),
                        onChanged: _busy
                            ? null
                            : (value) => _toggle(user.id, value ?? false),
                      ),
                  if (members.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (members.hasError)
                    Column(
                      children: [
                        Text(l10n.projectMembersError),
                        TextButton(
                          onPressed: () => ref.invalidate(
                            projectMembersControllerProvider(memberRef),
                          ),
                          child: Text(l10n.retry),
                        ),
                      ],
                    )
                  else ...[
                    if (available.isEmpty && widget.issue.assignees.isEmpty)
                      Text(l10n.projectMembersEmpty),
                    for (final member in available)
                      if (member.state == null || member.state == 'active')
                        CheckboxListTile(
                          title: Text(member.name),
                          subtitle: Text(member.username),
                          value: _selected.contains(member.id),
                          onChanged: _busy
                              ? null
                              : (value) => _toggle(member.id, value ?? false),
                        ),
                    if (members.valueOrNull?.nextPage != null)
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => ref
                                  .read(
                                    projectMembersControllerProvider(
                                      memberRef,
                                    ).notifier,
                                  )
                                  .loadMore(),
                        child: Text(l10n.projectMembersLoadMore),
                      ),
                  ],
                ],
              ),
            ),
            if (_failed) Text(l10n.issueAssigneesSaveError),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(l10n.issueSaveAssignees),
        ),
      ],
    );
  }
}

class _EditIssueDueDateDialog extends ConsumerStatefulWidget {
  const _EditIssueDueDateDialog({required this.issue, required this.issueRef});

  final Issue issue;
  final IssueRef issueRef;

  @override
  ConsumerState<_EditIssueDueDateDialog> createState() =>
      _EditIssueDueDateDialogState();
}

class _EditIssueDueDateDialogState
    extends ConsumerState<_EditIssueDueDateDialog> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _update(DateTime? date) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(issueControllerProvider(widget.issueRef).notifier)
          .updateDueDate(
            date == null ? '' : DateFormat('yyyy-MM-dd').format(date),
          );
      if (mounted) Navigator.of(context).pop();
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: widget.issue.dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) await _update(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.issueEditDueDate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.issue.dueDate case final dueDate?)
            Text(MaterialLocalizations.of(context).formatMediumDate(dueDate)),
          if (_failed) Text(l10n.issueDueDateError),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        if (widget.issue.dueDate != null)
          TextButton(
            onPressed: _busy ? null : () => _update(null),
            child: Text(l10n.issueClearDueDate),
          ),
        FilledButton(
          onPressed: _busy ? null : _pickDate,
          child: Text(l10n.issueSelectDueDate),
        ),
      ],
    );
  }
}

class _EditIssueDialog extends ConsumerStatefulWidget {
  const _EditIssueDialog({required this.issue, required this.issueRef});

  final Issue issue;
  final IssueRef issueRef;

  @override
  ConsumerState<_EditIssueDialog> createState() => _EditIssueDialogState();
}

class _EditIssueDialogState extends ConsumerState<_EditIssueDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.issue.title);
  late final _description = TextEditingController(
    text: widget.issue.description ?? '',
  );
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(issueControllerProvider(widget.issueRef).notifier)
          .updateDetails(
            title: _title.text.trim(),
            description: _description.text,
          );
      if (mounted) Navigator.of(context).pop();
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.issueEdit),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: l10n.newIssueTitleLabel,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.newIssueTitleRequired
                      : null,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                TextFormField(
                  controller: _description,
                  enabled: !_busy,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.newIssueDescriptionLabel,
                  ),
                ),
                if (_failed) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l10n.issueEditError),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(l10n.issueSaveChanges),
        ),
      ],
    );
  }
}

class _IssueHeader extends StatelessWidget {
  const _IssueHeader({required this.issue});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final open = issue.isOpen;
    final colors = open ? status.open : status.closed;

    final path = repoPathFromWebUrl(issue.webUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetaText(path == null ? '#${issue.iid}' : '$path #${issue.iid}'),
        const SizedBox(height: LabFoxSpacing.xs),
        Text(
          issue.title,
          style: theme.textTheme.titleLarge?.copyWith(height: 1.2),
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        Wrap(
          spacing: LabFoxSpacing.sm,
          runSpacing: LabFoxSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusPill(
              label: open ? l10n.issueStateOpen : l10n.issueStateClosed,
              colors: colors,
              icon: open ? LabFoxIcons.issueOpen : LabFoxIcons.issueClosed,
              filled: true,
            ),
            if (issue.author != null) ...[
              UserAvatar(user: issue.author!),
              MetaText(issue.author!.username),
            ],
          ],
        ),
      ],
    );
  }
}
