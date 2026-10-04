import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/entitlement/paywall.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_actions_controller.dart';

/// The approve / merge controls for a merge request.
///
/// Merge is irreversible, so it goes behind a confirmation dialog. Both actions
/// re-fetch the MR afterward; the widget never fabricates the merged state.
class MrActions extends ConsumerWidget {
  const MrActions({required this.mr, required this.projectId, super.key});

  final MergeRequest mr;
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mrRef = MergeRequestRef(projectId: projectId, iid: mr.iid);
    final actionState = ref.watch(mrActionsControllerProvider(mrRef));
    final approvals = ref.watch(mrApprovalsProvider(mrRef));
    final busy = actionState.isLoading;

    // A merged or closed MR has no actions.
    if (!mr.isOpen) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        approvals.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          data: (a) => a == null
              ? const SizedBox.shrink()
              : _ApprovalSummary(approvals: a),
          loading: () => Row(
            children: [
              const SizedBox(
                width: LabFoxIconSize.sm,
                height: LabFoxIconSize.sm,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: LabFoxSpacing.sm),
              Expanded(child: Text(l10n.mrApprovalStatusLoading)),
            ],
          ),
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.mrApprovalStatusError),
              TextButton(
                key: const ValueKey('mr-approvals-retry'),
                onPressed: busy
                    ? null
                    : () => ref.invalidate(mrApprovalsProvider(mrRef)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        if (mr.isMergeable != null) ...[
          const SizedBox(height: LabFoxSpacing.xs),
          _MergeabilityLine(mergeable: mr.isMergeable!),
        ],
        const SizedBox(height: LabFoxSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy || approvals.isLoading || approvals.hasError
                    ? null
                    : () => runSubscribed(
                        context,
                        ref,
                        feature: PaidFeature.mergeRequestActions,
                        action: () => _toggleApproval(context, ref, mrRef),
                      ),
                icon: const Icon(LabFoxIcons.approval, size: 18),
                label: Text(_approveLabel(l10n, approvals)),
              ),
            ),
            const SizedBox(width: LabFoxSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => runSubscribed(
                        context,
                        ref,
                        feature: PaidFeature.mergeRequestActions,
                        action: () => _startMerge(context, ref, mrRef),
                      ),
                icon: const Icon(LabFoxIcons.merged, size: 18),
                label: Text(l10n.mrMerge),
              ),
            ),
          ],
        ),
        if (busy) ...[
          const SizedBox(height: LabFoxSpacing.sm),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  /// Merge is a two-step choice: pick the method, then confirm — because a
  /// squash rewrites history and a merge is irreversible either way.
  Future<void> _startMerge(
    BuildContext context,
    WidgetRef ref,
    MergeRequestRef mrRef,
  ) async {
    final squash = await _pickMergeMethod(context);
    if (squash == null || !context.mounted) {
      return;
    }
    await _confirmMerge(context, ref, mrRef, squash: squash);
  }

  /// Offers the merge methods in a sheet. Returns true for squash, false for a
  /// plain merge commit, or null if the user dismissed the sheet.
  Future<bool?> _pickMergeMethod(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(LabFoxSpacing.md),
              child: Text(
                l10n.mrMergeMethodTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(LabFoxIcons.merged),
              title: Text(l10n.mrMergeCommit),
              onTap: () => Navigator.of(context).pop(false),
            ),
            ListTile(
              leading: const Icon(Icons.compress),
              title: Text(l10n.mrMergeSquash),
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
          ],
        ),
      ),
    );
  }

  String _approveLabel(
    AppLocalizations l10n,
    AsyncValue<MergeRequestApprovals?> approvals,
  ) {
    final approved = approvals.valueOrNull?.userHasApproved ?? false;
    return approved ? l10n.mrUnapprove : l10n.mrApprove;
  }

  Future<void> _toggleApproval(
    BuildContext context,
    WidgetRef ref,
    MergeRequestRef mrRef,
  ) async {
    final approvals = ref.read(mrApprovalsProvider(mrRef));
    if (approvals.isLoading || approvals.hasError) return;
    final notifier = ref.read(mrActionsControllerProvider(mrRef).notifier);
    final approved = approvals.valueOrNull?.userHasApproved ?? false;
    final l10n = AppLocalizations.of(context);
    try {
      await (approved ? notifier.unapprove() : notifier.approve());
    } on GitLabException catch (error) {
      if (context.mounted) {
        _showError(context, _messageFor(error, l10n));
      }
    }
  }

  Future<void> _confirmMerge(
    BuildContext context,
    WidgetRef ref,
    MergeRequestRef mrRef, {
    required bool squash,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.mrMergeConfirmTitle),
        content: Text(l10n.mrMergeConfirmBody('!${mr.iid}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.mrMerge),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(mrActionsControllerProvider(mrRef).notifier)
          .merge(squash: squash);
    } on GitLabException catch (error) {
      if (context.mounted) {
        _showError(context, _messageFor(error, l10n));
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageFor(GitLabException error, AppLocalizations l10n) {
    return switch (error) {
      GitLabNotMergeableException() => l10n.mrNotMergeable,
      GitLabForbiddenException() => l10n.mrActionForbidden,
      GitLabAuthException() => l10n.mrActionForbidden,
      _ => l10n.mrActionError,
    };
  }
}

/// A one-line mergeability status from GitLab's `merge_status`, so the user
/// knows whether the merge will go through before they tap.
class _MergeabilityLine extends StatelessWidget {
  const _MergeabilityLine({required this.mergeable});

  final bool mergeable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final colors = mergeable ? status.open : status.warning;
    return Row(
      children: [
        Icon(
          mergeable ? LabFoxIcons.issueClosed : Icons.error_outline,
          size: LabFoxIconSize.sm,
          color: colors.foreground,
        ),
        const SizedBox(width: LabFoxSpacing.xs),
        Expanded(
          child: Text(
            mergeable ? l10n.mrReadyToMerge : l10n.mrCannotMergeNow,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.foreground),
          ),
        ),
      ],
    );
  }
}

class _ApprovalSummary extends StatelessWidget {
  const _ApprovalSummary({required this.approvals});

  final MergeRequestApprovals approvals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          approvals.approvedCount >= approvals.approvalsRequired
              ? LabFoxIcons.issueClosed
              : Icons.pending_outlined,
          size: LabFoxIconSize.sm,
          color: LabFoxColors.pending,
        ),
        const SizedBox(width: LabFoxSpacing.xs),
        Expanded(
          child: Text(
            l10n.mrApprovalsSummary(
              approvals.approvedCount,
              approvals.approvalsRequired,
            ),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
