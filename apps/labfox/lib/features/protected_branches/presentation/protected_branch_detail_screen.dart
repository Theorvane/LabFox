import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_branches_controller.dart';
import 'widgets/protected_branch_force_push_dialog.dart';
import 'widgets/protected_branch_merge_role_dialog.dart';
import 'widgets/protected_branch_push_role_dialog.dart';
import 'widgets/protected_branch_unprotect_dialog.dart';

/// One rule, restorable from its project and branch name.
class ProtectedBranchDetailScreen extends ConsumerWidget {
  const ProtectedBranchDetailScreen({
    required this.projectId,
    required this.name,
    super.key,
  });

  final int projectId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = ProtectedBranchRef(projectId: projectId, name: name);
    final rule = ref.watch(protectedBranchDetailProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(rule.valueOrNull?.name ?? l10n.protectedBranchesTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.protectedBranches(projectId)),
        ),
      ),
      body: rule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.protectedBranchesError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(protectedBranchDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(protectedBranchDetailProvider(key).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final settings = _Settings(
                rule: data,
                onEditPushRole: editableProtectedBranchPushAccess(data) == null
                    ? null
                    : () async {
                        final changed = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ProtectedBranchPushRoleDialog(
                            target: key,
                            rule: data,
                          ),
                        );
                        if (changed == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.protectedBranchPushRoleSuccess,
                              ),
                            ),
                          );
                        }
                      },
                onEditMergeRole:
                    editableProtectedBranchMergeAccess(data) == null
                    ? null
                    : () async {
                        final changed = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ProtectedBranchMergeRoleDialog(
                            target: key,
                            rule: data,
                          ),
                        );
                        if (changed == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.protectedBranchMergeRoleSuccess,
                              ),
                            ),
                          );
                        }
                      },
                onEditForcePush: data.inherited == true
                    ? null
                    : () async {
                        final changed = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ProtectedBranchForcePushDialog(
                            target: key,
                            rule: data,
                          ),
                        );
                        if (changed == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.protectedBranchForcePushSuccess,
                              ),
                            ),
                          );
                        }
                      },
                onUnprotect: data.inherited == true
                    ? null
                    : () async {
                        final removed = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ProtectedBranchUnprotectDialog(
                            target: key,
                            rule: data,
                          ),
                        );
                        if (removed == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.protectedBranchUnprotectSuccess,
                              ),
                            ),
                          );
                          context.go(Routes.protectedBranches(projectId));
                        }
                      },
              );
              final access = Column(
                children: [
                  _AccessCard(
                    title: l10n.protectedBranchPushAccess,
                    entries: data.pushAccessLevels,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  _AccessCard(
                    title: l10n.protectedBranchMergeAccess,
                    entries: data.mergeAccessLevels,
                  ),
                ],
              );
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
                                  SizedBox(width: 300, child: settings),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: access),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  settings,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  access,
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

class _Settings extends StatelessWidget {
  const _Settings({
    required this.rule,
    required this.onEditForcePush,
    required this.onEditMergeRole,
    required this.onUnprotect,
    required this.onEditPushRole,
  });

  final ProtectedBranch rule;
  final VoidCallback? onEditForcePush;
  final VoidCallback? onEditMergeRole;
  final VoidCallback? onUnprotect;
  final VoidCallback? onEditPushRole;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rule.name, style: Theme.of(context).textTheme.titleLarge),
            if (rule.inherited == true) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.protectedBranchInherited),
            ],
            const SizedBox(height: LabFoxSpacing.md),
            _SettingRow(
              label: l10n.protectedBranchForcePush,
              enabled: rule.allowForcePush,
            ),
            _SettingRow(
              label: l10n.protectedBranchCodeOwnerApproval,
              enabled: rule.codeOwnerApprovalRequired,
            ),
            if (onEditForcePush != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              OutlinedButton(
                key: const ValueKey('protected-branch-force-push-edit'),
                onPressed: onEditForcePush,
                child: Text(l10n.protectedBranchForcePushEditTitle),
              ),
            ],
            if (onEditMergeRole != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              OutlinedButton(
                key: const ValueKey('protected-branch-merge-role-edit'),
                onPressed: onEditMergeRole,
                child: Text(l10n.protectedBranchMergeRoleEditTitle),
              ),
            ],
            if (onUnprotect != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              OutlinedButton(
                onPressed: onUnprotect,
                child: Text(l10n.protectedBranchUnprotectTitle),
              ),
            ],
            if (onEditPushRole != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              OutlinedButton(
                key: const ValueKey('protected-branch-push-role-edit'),
                onPressed: onEditPushRole,
                child: Text(l10n.protectedBranchPushRoleEditTitle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        enabled ? l10n.protectedBranchEnabled : l10n.protectedBranchDisabled,
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.title, required this.entries});

  final String title;
  final List<ProtectedBranchAccess> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: LabFoxTextRoles.of(context).sectionHeader),
            const SizedBox(height: LabFoxSpacing.sm),
            if (entries.isEmpty)
              Text(l10n.protectedBranchNoAccess)
            else
              for (final entry in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LabFoxIcons.person),
                  title: Text(
                    entry.description ?? l10n.protectedBranchNoAccess,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
