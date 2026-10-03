import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/inbox_controllers.dart';

/// The current user's to-do inbox — the entry point of the core flow.
///
/// A state filter switches between pending items and the read-only history of
/// items already marked done.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  TodoState _state = TodoState.pending;
  TodoType? _type;
  TodoAction? _action;

  bool get _pending => _state == TodoState.pending;

  InboxQuery get _query =>
      InboxQuery(state: _state, type: _type, action: _action);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todos = ref.watch(inboxControllerProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inboxTitle),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
        ),
        actions: [
          if (_pending && (todos.valueOrNull?.isNotEmpty ?? false))
            IconButton(
              icon: const Icon(LabFoxIcons.doneAll),
              tooltip: l10n.inboxMarkAllDone,
              onPressed: () => _markAllDone(context),
            ),
        ],
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
                  FilterMenuChip<TodoState>(
                    selected: _state,
                    options: const [TodoState.pending, TodoState.done],
                    labelOf: (state) => state == TodoState.pending
                        ? l10n.inboxFilterPending
                        : l10n.inboxFilterDone,
                    onSelected: (state) => setState(() => _state = state),
                  ),
                  const SizedBox(width: LabFoxSpacing.sm),
                  FilterMenuChip<TodoType?>(
                    selected: _type,
                    options: const [
                      null,
                      TodoType.issue,
                      TodoType.mergeRequest,
                    ],
                    labelOf: (type) => switch (type) {
                      null => l10n.inboxFilterAllTypes,
                      TodoType.issue => l10n.inboxTypeIssues,
                      TodoType.mergeRequest => l10n.inboxTypeMergeRequests,
                    },
                    onSelected: (type) => setState(() => _type = type),
                  ),
                  const SizedBox(width: LabFoxSpacing.sm),
                  FilterMenuChip<TodoAction?>(
                    selected: _action,
                    options: const [
                      null,
                      TodoAction.assigned,
                      TodoAction.mentioned,
                      TodoAction.approvalRequired,
                      TodoAction.buildFailed,
                      TodoAction.marked,
                      TodoAction.unmergeable,
                      TodoAction.directlyAddressed,
                    ],
                    labelOf: (action) => switch (action) {
                      null => l10n.inboxFilterAllReasons,
                      TodoAction.assigned => l10n.inboxActionAssigned,
                      TodoAction.mentioned => l10n.inboxActionMentioned,
                      TodoAction.approvalRequired =>
                        l10n.inboxActionApprovalRequired,
                      TodoAction.buildFailed => l10n.inboxActionBuildFailed,
                      TodoAction.marked => l10n.inboxActionMarked,
                      TodoAction.unmergeable => l10n.inboxActionUnmergeable,
                      TodoAction.directlyAddressed =>
                        l10n.inboxActionDirectlyAddressed,
                    },
                    onSelected: (action) => setState(() => _action = action),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(inboxControllerProvider(_query).future),
        child: todos.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: l10n.inboxError,
            onRetry: () => ref.invalidate(inboxControllerProvider(_query)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _EmptyState(
                message: _pending ? l10n.inboxEmpty : l10n.inboxDoneEmpty,
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final todo = items[index];
                final tile = _TodoTile(
                  todo: todo,
                  onTap: () => _openTarget(context, todo),
                  onMarkDone: _pending
                      ? () => _markDone(context, todo.id)
                      : null,
                );
                if (!_pending) {
                  return tile;
                }
                return Dismissible(
                  key: ValueKey(todo.id),
                  direction: DismissDirection.endToStart,
                  background: const _DismissBackground(),
                  onDismissed: (_) => _markDone(context, todo.id),
                  child: tile,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openTarget(BuildContext context, Todo todo) {
    final projectId = todo.project?.id;
    final iid = todo.target?.iid;
    if (projectId == null || iid == null) {
      return;
    }
    switch (todo.targetType) {
      case 'Issue':
        context.push(Routes.issue(projectId, iid));
      case 'MergeRequest':
        context.push(Routes.mergeRequest(projectId, iid));
    }
  }

  Future<void> _markDone(BuildContext context, int id) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(inboxControllerProvider(_query).notifier).markDone(id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.inboxMarkDoneError)));
    }
  }

  Future<void> _markAllDone(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(inboxControllerProvider(_query).notifier).markAllDone();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.inboxMarkDoneError)));
    }
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.todo,
    required this.onTap,
    required this.onMarkDone,
  });

  final Todo todo;
  final VoidCallback onTap;

  /// Clears the item; null on the read-only done view, which hides the button.
  final VoidCallback? onMarkDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final colors = _reasonColors(todo.actionName, status);
    final canOpen =
        todo.project?.id != null &&
        todo.target?.iid != null &&
        (todo.targetType == 'Issue' || todo.targetType == 'MergeRequest');

    return WorkTile(
      icon: _iconFor(todo.targetType),
      iconColor: colors.foreground,
      contextLabel: todo.project?.pathWithNamespace,
      title: todo.title,
      metadata: [
        StatusPill(label: _actionLabel(l10n, todo.actionName), colors: colors),
        if (todo.target?.iid != null) MetaText(_targetNumber(todo)),
        if (todo.createdAt != null) MetaText(timeAgo(todo.createdAt!)),
      ],
      trailing: onMarkDone == null
          ? null
          : IconButton(
              icon: const Icon(LabFoxIcons.check),
              tooltip: l10n.inboxMarkDone,
              onPressed: onMarkDone,
            ),
      onTap: canOpen ? onTap : null,
    );
  }

  /// The target's user-facing number; project context has its own hierarchy.
  static String _targetNumber(Todo todo) {
    final iid = todo.target!.iid!;
    final sigil = todo.targetType == 'MergeRequest' ? '!' : '#';
    return '$sigil$iid';
  }

  /// The reason's colour: failures read red, an approval request blue, a
  /// mention violet, everything else (assigned, added) green.
  static StatusColor _reasonColors(String action, LabFoxStatusColors s) {
    return switch (action) {
      'build_failed' || 'unmergeable' => s.closed,
      'approval_required' => s.running,
      'mentioned' || 'directly_addressed' => s.merged,
      _ => s.open,
    };
  }

  static IconData _iconFor(String? targetType) {
    switch (targetType) {
      case 'Issue':
        return LabFoxIcons.issueOpen;
      case 'MergeRequest':
        return LabFoxIcons.mergeRequest;
      case 'Commit':
        return LabFoxIcons.commit;
      default:
        return LabFoxIcons.notification;
    }
  }

  static String _actionLabel(AppLocalizations l10n, String action) {
    switch (action) {
      case 'assigned':
        return l10n.inboxActionAssigned;
      case 'mentioned':
        return l10n.inboxActionMentioned;
      case 'build_failed':
        return l10n.inboxActionBuildFailed;
      case 'marked':
        return l10n.inboxActionMarked;
      case 'approval_required':
        return l10n.inboxActionApprovalRequired;
      case 'unmergeable':
        return l10n.inboxActionUnmergeable;
      case 'directly_addressed':
        return l10n.inboxActionDirectlyAddressed;
      default:
        return l10n.inboxActionMentioned;
    }
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.lg),
      child: Icon(
        LabFoxIcons.check,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A single tile keeps the pull-to-refresh gesture available even when the
    // list is empty.
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: LabFoxSpacing.xxl * 2),
          child: Column(
            children: [
              Icon(
                LabFoxIcons.doneAll,
                size: LabFoxIconSize.xl,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: LabFoxSpacing.md),
              Text(message, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(LabFoxSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: LabFoxSpacing.xxl + LabFoxSpacing.lg),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ),
        ),
      ],
    );
  }
}
