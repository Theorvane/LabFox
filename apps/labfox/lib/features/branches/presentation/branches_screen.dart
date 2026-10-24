import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import '../../commits/presentation/controllers/history_controllers.dart';

/// A project's branches. Tapping one browses the repository on that branch.
class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = AppLocalizations.of(context);
    final branches = widgetRef.watch(branchesControllerProvider(projectId));
    final list = branches.valueOrNull;
    // The create dialog prefills its source ref with the default branch, so
    // the action stays disabled until the list has loaded — opening it during
    // loading would seed the field with nothing and never fill it in.
    final String? defaultBranch = (list == null || list.isEmpty)
        ? null
        : list.firstWhere((b) => b.isDefault, orElse: () => list.first).name;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.branchesTitle),
        actions: [
          IconButton(
            icon: const Icon(LabFoxIcons.private),
            tooltip: l10n.protectedBranchesTitle,
            onPressed: () => context.push(Routes.protectedBranches(projectId)),
          ),
          IconButton(
            icon: const Icon(LabFoxIcons.add),
            tooltip: l10n.newBranchButton,
            onPressed: defaultBranch == null
                ? null
                : () => _showCreateDialog(context, widgetRef, defaultBranch),
          ),
        ],
      ),
      body: branches.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.branchesError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () => widgetRef.invalidate(
                    branchesControllerProvider(projectId),
                  ),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: LabFoxIcons.branch,
              title: l10n.branchesEmpty,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                widgetRef.refresh(branchesControllerProvider(projectId).future),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _branchTile(context, l10n, items[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _branchTile(
    BuildContext context,
    AppLocalizations l10n,
    Branch branch,
  ) {
    final theme = Theme.of(context);
    return WorkTile(
      icon: LabFoxIcons.branch,
      title: branch.name,
      metadata: [
        if (branch.isDefault) MetaText(l10n.branchDefault),
        if (branch.isProtected)
          Icon(
            LabFoxIcons.private,
            size: LabFoxIconSize.xs,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
      trailing: const Icon(LabFoxIcons.chevron),
      onTap: () => context.push(Routes.repository(projectId, branch.name)),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    WidgetRef ref,
    String fromRef,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) =>
          _CreateBranchDialog(projectId: projectId, fromRef: fromRef),
    );
  }
}

/// A dialog to create a branch from a source ref. Closes on success and lets
/// the branches list reload; a failure keeps the dialog open with a message.
class _CreateBranchDialog extends ConsumerStatefulWidget {
  const _CreateBranchDialog({required this.projectId, required this.fromRef});

  final int projectId;
  final String fromRef;

  @override
  ConsumerState<_CreateBranchDialog> createState() =>
      _CreateBranchDialogState();
}

class _CreateBranchDialogState extends ConsumerState<_CreateBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late final _from = TextEditingController(text: widget.fromRef);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _from.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(branchesControllerProvider(widget.projectId).notifier)
          .create(name: _name.text.trim(), ref: _from.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on GitLabException {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.newBranchError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.newBranchTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              enabled: !_busy,
              autofocus: true,
              autocorrect: false,
              decoration: InputDecoration(labelText: l10n.newBranchNameLabel),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.newBranchNameRequired
                  : null,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            TextFormField(
              controller: _from,
              enabled: !_busy,
              autocorrect: false,
              decoration: InputDecoration(labelText: l10n.newBranchFromLabel),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.newBranchFromRequired
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(l10n.newBranchCreate),
        ),
      ],
    );
  }
}
