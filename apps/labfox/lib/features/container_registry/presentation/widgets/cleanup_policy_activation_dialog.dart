import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/cleanup_policy_activation_controller.dart';
import '../controllers/container_cleanup_policy_controller.dart';

/// Confirms project-wide activation without editing any retention criteria.
class CleanupPolicyActivationDialog extends ConsumerStatefulWidget {
  const CleanupPolicyActivationDialog({required this.projectId, super.key});
  final int projectId;

  @override
  ConsumerState<CleanupPolicyActivationDialog> createState() =>
      _CleanupPolicyActivationDialogState();
}

class _CleanupPolicyActivationDialogState
    extends ConsumerState<CleanupPolicyActivationDialog> {
  bool _busy = false;
  bool _stale = false;
  String? _error;

  void _reload() {
    if (_busy) return;
    setState(() {
      _error = null;
      _stale = false;
    });
    ref.invalidate(containerCleanupPolicyControllerProvider(widget.projectId));
  }

  String _message(AppLocalizations l10n, Object error) => switch (error) {
    GitLabConflictException() => l10n.containerActivationStale,
    GitLabForbiddenException() => l10n.containerActivationForbidden,
    GitLabRateLimitException() => l10n.containerActivationRateLimited,
    GitLabException(statusCode: 400 || 422) => l10n.containerActivationInvalid,
    _ => l10n.containerActivationError,
  };

  Future<void> _apply(ContainerCleanupPolicy policy) async {
    if (_busy || _stale || policy.enabled == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(
            cleanupPolicyActivationControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .setEnabled(expected: policy, enabled: !policy.enabled!);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _stale = error is GitLabConflictException;
        _error = _message(l10n, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final load = ref.watch(
      containerCleanupPolicyControllerProvider(widget.projectId),
    );
    final policy = load.valueOrNull;
    final actionable =
        !load.isLoading &&
        !load.hasError &&
        policy?.enabled != null &&
        (policy!.enabled! || canEnableCleanupPolicy(policy));
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerActivationTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.containerActivationTarget(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.projectId),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                load.when(
                  skipLoadingOnRefresh: false,
                  skipLoadingOnReload: false,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text(switch (error) {
                    GitLabForbiddenException() => l10n.containerPolicyForbidden,
                    GitLabNotFoundException() =>
                      l10n.containerPolicyUnavailable,
                    _ => l10n.containerPolicyError,
                  }),
                  data: (data) => data?.enabled == null
                      ? Text(l10n.containerActivationUnknown)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data!.enabled!
                                  ? l10n.containerActivationDisableWarning
                                  : l10n.containerActivationEnableWarning,
                            ),
                            const SizedBox(height: LabFoxSpacing.md),
                            _Criteria(policy: data),
                            if (!data.enabled! && !canEnableCleanupPolicy(data))
                              Text(l10n.containerActivationIncomplete),
                          ],
                        ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          if (_error != null || load.hasError || !actionable && !load.isLoading)
            TextButton(
              onPressed: _busy ? null : _reload,
              child: Text(l10n.containerActivationReload),
            ),
          if (actionable || _busy)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: _busy || _stale ? null : () => _apply(policy!),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      policy!.enabled!
                          ? l10n.containerActivationDisable
                          : l10n.containerActivationEnable,
                    ),
            ),
        ],
      ),
    );
  }
}

class _Criteria extends StatelessWidget {
  const _Criteria({required this.policy});
  final ContainerCleanupPolicy policy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String value(String? text, {bool pattern = false}) => text == null
        ? l10n.containerPolicyNotReported
        : text.isEmpty
        ? (pattern
              ? l10n.containerPolicyEmptyPattern
              : l10n.containerPolicyEmptySetting)
        : text;
    final fields = <(String, String)>[
      (
        l10n.containerPolicyStatus,
        policy.enabled!
            ? l10n.containerPolicyEnabled
            : l10n.containerPolicyDisabled,
      ),
      (l10n.containerPolicyCadence, value(policy.cadence)),
      (
        l10n.containerPolicyKeepCount,
        policy.keepN == null
            ? l10n.containerPolicyNotReported
            : NumberFormat.decimalPattern(l10n.localeName).format(policy.keepN),
      ),
      (l10n.containerPolicyAge, value(policy.olderThan)),
      (
        policy.nameRegexDelete == null && policy.nameRegex != null
            ? l10n.containerPolicyLegacyPattern
            : l10n.containerPolicyDeletePattern,
        value(policy.nameRegexDelete ?? policy.nameRegex, pattern: true),
      ),
      (
        l10n.containerPolicyKeepPattern,
        value(policy.nameRegexKeep, pattern: true),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, text) in fields) ...[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          Text(text),
          const SizedBox(height: LabFoxSpacing.sm),
        ],
      ],
    );
  }
}
