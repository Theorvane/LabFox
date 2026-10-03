import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/cleanup_policy_create_controller.dart';

/// Disabled-first creation; no missing-policy inference or automatic activation.
class CleanupPolicyCreateDialog extends ConsumerStatefulWidget {
  const CleanupPolicyCreateDialog({required this.projectId, super.key});
  final int projectId;
  @override
  ConsumerState<CleanupPolicyCreateDialog> createState() =>
      _CleanupPolicyCreateDialogState();
}

class _CleanupPolicyCreateDialogState
    extends ConsumerState<CleanupPolicyCreateDialog> {
  String _cadence = '1month';
  int _keepN = 100;
  String _age = '365d';
  String _delete = '';
  String _keep = '.*';
  bool _acknowledged = false;
  bool _busy = false;
  bool _stale = false;
  String? _error;

  void _draftChanged(VoidCallback change) {
    if (_busy || _stale) return;
    setState(() {
      change();
      _acknowledged = false;
      _error = null;
    });
  }

  void _reload() {
    if (_busy) return;
    setState(() {
      _stale = false;
      _acknowledged = false;
      _error = null;
    });
    ref.invalidate(cleanupPolicySnapshotControllerProvider(widget.projectId));
  }

  Future<void> _save(ContainerCleanupPolicySnapshot expected) async {
    if (_busy || _stale || !_acknowledged || _delete.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(
            cleanupPolicyCreateControllerProvider(widget.projectId).notifier,
          )
          .create(
            expected: expected,
            cadence: _cadence,
            keepN: _keepN,
            olderThan: _age,
            nameRegexDelete: _delete,
            nameRegexKeep: _keep,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _stale = error is GitLabConflictException && error.statusCode != 422;
        _error = switch (error) {
          GitLabException(statusCode: 400 || 422) =>
            l10n.containerCreateInvalid,
          GitLabConflictException() => l10n.containerActivationStale,
          GitLabForbiddenException() => l10n.containerActivationForbidden,
          GitLabRateLimitException() => l10n.containerActivationRateLimited,
          _ => l10n.containerActivationError,
        };
      });
    }
  }

  String _interval(AppLocalizations l10n, String code) => switch (code) {
    '1d' => l10n.containerCreateDaily,
    '7d' => l10n.containerCreateWeekly,
    '14d' => l10n.containerCreateFortnightly,
    '1month' => l10n.containerCreateMonthly,
    _ => l10n.containerCreateQuarterly,
  };
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final load = ref.watch(
      cleanupPolicySnapshotControllerProvider(widget.projectId),
    );
    final snapshot = load.valueOrNull;
    final actionable =
        !load.isLoading &&
        !load.hasError &&
        snapshot != null &&
        canCreateCleanupPolicy(snapshot);
    final locked = _busy || _stale;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerCreateTitle),
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
                  data: (data) => !canCreateCleanupPolicy(data)
                      ? Text(
                          data.reported && data.policy != null
                              ? l10n.containerCreateExisting
                              : l10n.containerCreateUnknown,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.containerCreateWarning),
                            const SizedBox(height: LabFoxSpacing.md),
                            DropdownButtonFormField<String>(
                              key: const ValueKey('cleanup-create-cadence'),
                              initialValue: _cadence,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.containerPolicyCadence,
                              ),
                              items: [
                                for (final code in cleanupCreationCadences)
                                  DropdownMenuItem(
                                    value: code,
                                    child: Text(_interval(l10n, code)),
                                  ),
                              ],
                              onChanged: locked
                                  ? null
                                  : (value) =>
                                        _draftChanged(() => _cadence = value!),
                            ),
                            DropdownButtonFormField<int>(
                              key: const ValueKey('cleanup-create-count'),
                              initialValue: _keepN,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.containerPolicyKeepCount,
                              ),
                              items: [
                                for (final count in cleanupCreationKeepCounts)
                                  DropdownMenuItem(
                                    value: count,
                                    child: Text(
                                      NumberFormat.decimalPattern(
                                        l10n.localeName,
                                      ).format(count),
                                    ),
                                  ),
                              ],
                              onChanged: locked
                                  ? null
                                  : (value) =>
                                        _draftChanged(() => _keepN = value!),
                            ),
                            DropdownButtonFormField<String>(
                              key: const ValueKey('cleanup-create-age'),
                              initialValue: _age,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.containerPolicyAge,
                              ),
                              items: [
                                for (final code in cleanupCreationAges)
                                  DropdownMenuItem(
                                    value: code,
                                    child: Text(
                                      l10n.containerCreateDays(
                                        int.parse(
                                          code.substring(0, code.length - 1),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                              onChanged: locked
                                  ? null
                                  : (value) =>
                                        _draftChanged(() => _age = value!),
                            ),
                            TextFormField(
                              key: const ValueKey('cleanup-create-delete'),
                              initialValue: _delete,
                              minLines: 1,
                              maxLines: 4,
                              readOnly: locked,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                labelText: l10n.containerPolicyDeletePattern,
                              ),
                              onChanged: (value) =>
                                  _draftChanged(() => _delete = value),
                            ),
                            TextFormField(
                              key: const ValueKey('cleanup-create-keep'),
                              initialValue: _keep,
                              minLines: 1,
                              maxLines: 4,
                              readOnly: locked,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                labelText: l10n.containerPolicyKeepPattern,
                              ),
                              onChanged: (value) =>
                                  _draftChanged(() => _keep = value),
                            ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _acknowledged,
                              title: Text(l10n.containerCreateAcknowledge),
                              onChanged: locked
                                  ? null
                                  : (value) => setState(() {
                                      _acknowledged = value == true;
                                      _error = null;
                                    }),
                            ),
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
              onPressed: locked || !_acknowledged || _delete.trim().isEmpty
                  ? null
                  : () => _save(snapshot!),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.containerCreateSave),
            ),
        ],
      ),
    );
  }
}
