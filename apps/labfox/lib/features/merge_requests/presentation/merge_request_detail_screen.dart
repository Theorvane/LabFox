import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/share_link_button.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import '../../comments/presentation/widgets/comment_thread.dart';
import 'controllers/merge_requests_controllers.dart';
import 'controllers/mr_actions_controller.dart';
import 'widgets/mr_actions.dart';

/// One merge request: an identity header, the description and discussion, with
/// the approve / merge actions pinned to a sticky bar so they never scroll away.
class MergeRequestDetailScreen extends ConsumerWidget {
  const MergeRequestDetailScreen({
    required this.projectId,
    required this.iid,
    super.key,
  });

  final int projectId;
  final int iid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mrRef = MergeRequestRef(projectId: projectId, iid: iid);
    final mr = ref.watch(mergeRequestControllerProvider(mrRef));
    final open = mr.valueOrNull?.isOpen ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('!$iid'),
        actions: [
          ShareLinkButton(url: mr.valueOrNull?.webUrl),
          if (mr.valueOrNull case final data?) _MrMenu(mr: data, mrRef: mrRef),
        ],
      ),
      bottomNavigationBar: open
          ? _ActionBar(mr: mr.value!, projectId: projectId)
          : null,
      body: mr.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.mergeRequestError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(mergeRequestControllerProvider(mrRef)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.md),
          children: [
            _Header(mr: data),
            const SizedBox(height: LabFoxSpacing.md),
            _BranchChip(source: data.sourceBranch, target: data.targetBranch),
            const SizedBox(height: LabFoxSpacing.md),
            OutlinedButton.icon(
              onPressed: () =>
                  context.push(Routes.mergeRequestChanges(projectId, iid)),
              icon: const Icon(LabFoxIcons.diff, size: 18),
              label: Text(l10n.mrViewChanges),
            ),
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
                l10n.mergeRequestNoDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: LabFoxSpacing.xl),
            CommentThread(
              type: NoteableType.mergeRequest,
              projectId: projectId,
              iid: iid,
            ),
          ],
        ),
      ),
    );
  }
}

enum _MrAction {
  close,
  reopen,
  rebase,
  toggleDraft,
  subscribe,
  unsubscribe,
  addTodo,
}

/// The overflow menu on a merge request: close/reopen, rebase, and toggle draft
/// — the state edits GitLab exposes, offered by the MR's current state.
class _MrMenu extends ConsumerWidget {
  const _MrMenu({required this.mr, required this.mrRef});

  final MergeRequest mr;
  final MergeRequestRef mrRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = <PopupMenuEntry<_MrAction>>[
      PopupMenuItem(value: _MrAction.addTodo, child: Text(l10n.mrAddTodo)),
      if (mr.subscribed case final subscribed?)
        PopupMenuItem(
          value: subscribed ? _MrAction.unsubscribe : _MrAction.subscribe,
          child: Text(subscribed ? l10n.mrUnsubscribe : l10n.mrSubscribe),
        ),
      if (mr.isOpen) ...[
        PopupMenuItem(
          value: _MrAction.toggleDraft,
          child: Text(mr.isDraft ? l10n.mrMarkReady : l10n.mrMarkDraft),
        ),
        PopupMenuItem(value: _MrAction.rebase, child: Text(l10n.mrRebase)),
        PopupMenuItem(value: _MrAction.close, child: Text(l10n.mrClose)),
      ] else if (mr.isClosed)
        PopupMenuItem(value: _MrAction.reopen, child: Text(l10n.mrReopen)),
    ];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<_MrAction>(
      onSelected: (action) => _run(context, ref, action),
      itemBuilder: (context) => items,
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    _MrAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(mrActionsControllerProvider(mrRef).notifier);
    try {
      switch (action) {
        case _MrAction.close:
          await notifier.setOpen(false);
        case _MrAction.reopen:
          await notifier.setOpen(true);
        case _MrAction.rebase:
          await notifier.rebase();
        case _MrAction.toggleDraft:
          await notifier.setDraft(draft: !mr.isDraft, title: mr.title);
        case _MrAction.subscribe:
          await notifier.setSubscription(true);
        case _MrAction.unsubscribe:
          await notifier.setSubscription(false);
        case _MrAction.addTodo:
          final created = await notifier.createTodo();
          if (created == null) return;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(created ? l10n.mrTodoAdded : l10n.mrTodoExists),
              ),
            );
          }
      }
    } on GitLabException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == _MrAction.subscribe || action == _MrAction.unsubscribe
                  ? l10n.mrSubscriptionError
                  : action == _MrAction.addTodo
                  ? l10n.mrTodoError
                  : l10n.mrActionError,
            ),
          ),
        );
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mr});

  final MergeRequest mr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final (colors, label, icon) = _status(mr, status, l10n);

    final path = repoPathFromWebUrl(mr.webUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetaText(path == null ? '!${mr.iid}' : '$path !${mr.iid}'),
        const SizedBox(height: LabFoxSpacing.xs),
        Text(
          mr.title,
          style: theme.textTheme.titleLarge?.copyWith(height: 1.2),
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        Wrap(
          spacing: LabFoxSpacing.sm,
          runSpacing: LabFoxSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusPill(label: label, colors: colors, icon: icon, filled: true),
            if (mr.author != null) ...[
              UserAvatar(user: mr.author!),
              MetaText(mr.author!.username),
            ],
          ],
        ),
      ],
    );
  }

  static (StatusColor, String, IconData) _status(
    MergeRequest mr,
    LabFoxStatusColors s,
    AppLocalizations l10n,
  ) {
    if (mr.isDraft) {
      return (s.pending, l10n.mrDraft, LabFoxIcons.mergeRequest);
    }
    if (mr.isMerged) {
      return (s.merged, l10n.mrStateMerged, LabFoxIcons.merged);
    }
    if (mr.isClosed) {
      return (s.closed, l10n.mrStateClosed, LabFoxIcons.close);
    }
    return (s.open, l10n.mrStateOpen, LabFoxIcons.mergeRequest);
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip({required this.source, required this.target});

  final String source;
  final String target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: theme.colorScheme.onSurfaceVariant,
    );
    Widget chip(String name) => Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LabFoxSpacing.sm + 2,
          vertical: LabFoxSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(LabFoxRadius.sm),
        ),
        child: Text(name, style: mono, overflow: TextOverflow.ellipsis),
      ),
    );

    // Source and target each get their own chip, the arrow between them —
    // the two-chip shape a pull/merge request header conventionally uses.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip(source),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.sm),
          child: Icon(
            Icons.arrow_forward,
            size: LabFoxIconSize.xs,
            color: theme.colorScheme.primary,
          ),
        ),
        chip(target),
      ],
    );
  }
}

/// The approve / merge controls, pinned above the safe area with a divider.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.mr, required this.projectId});

  final MergeRequest mr;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LabFoxSpacing.md,
            LabFoxSpacing.sm,
            LabFoxSpacing.md,
            LabFoxSpacing.sm,
          ),
          child: MrActions(mr: mr, projectId: projectId),
        ),
      ),
    );
  }
}
