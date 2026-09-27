import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../core/ui/share_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import '../../comments/presentation/widgets/comment_thread.dart';
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
                  value: _IssueAction.edit,
                  child: Text(l10n.issueEdit),
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
}

enum _IssueAction { edit, close, reopen }

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
