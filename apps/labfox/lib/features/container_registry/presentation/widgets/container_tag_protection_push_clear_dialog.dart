import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_tag_protection_controller.dart';
import '../controllers/container_tag_protection_push_clear_controller.dart';

/// Freezes the reviewed rule until an explicit reload and fresh acknowledgement.
class ContainerTagProtectionPushClearDialog extends ConsumerStatefulWidget {
  const ContainerTagProtectionPushClearDialog({
    required this.projectId,
    required this.rule,
    super.key,
  });
  final int projectId;
  final ContainerTagProtectionRule rule;
  @override
  ConsumerState<ContainerTagProtectionPushClearDialog> createState() =>
      _ContainerTagProtectionPushClearDialogState();
}

class _ContainerTagProtectionPushClearDialogState
    extends ConsumerState<ContainerTagProtectionPushClearDialog> {
  late ContainerTagProtectionRule _expected;
  bool _acknowledged = false;
  bool _busy = false;
  bool _reloading = false;
  bool _stale = false;
  bool _missing = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _expected = widget.rule;
  }

  static const _roles = {'maintainer', 'owner', 'admin'};
  bool get _eligible =>
      _roles.contains(_expected.minimumAccessLevelForPush) &&
      _roles.contains(_expected.minimumAccessLevelForDelete);
  bool get _valid =>
      !_missing &&
      _eligible &&
      widget.projectId > 0 &&
      _expected.projectId == widget.projectId &&
      _expected.id > 0 &&
      _expected.tagNamePattern.trim().isNotEmpty;
  bool get _locked => _busy || _reloading || _stale || !_valid;

  String _message(Object error) {
    final l10n = AppLocalizations.of(context);
    return switch (error) {
      GitLabForbiddenException() =>
        l10n.containerTagProtectionPushClearForbidden,
      GitLabNotFoundException() => l10n.containerTagProtectionPushClearMissing,
      GitLabConflictException(statusCode: 422) =>
        l10n.containerTagProtectionPushClearInvalid,
      GitLabServerException(statusCode: 400) =>
        l10n.containerTagProtectionPushClearInvalid,
      GitLabConflictException() => l10n.containerTagProtectionPushClearStale,
      GitLabRateLimitException() =>
        l10n.containerTagProtectionPushClearRateLimited,
      _ => l10n.containerTagProtectionPushClearError,
    };
  }

  Future<void> _reload() async {
    if (_busy || _reloading) return;
    setState(() {
      _reloading = true;
      _acknowledged = false;
      _error = null;
    });
    try {
      final rules = await ref.refresh(
        containerTagProtectionControllerProvider(widget.projectId).future,
      );
      if (!mounted) return;
      final matches = rules.where((rule) => rule.id == widget.rule.id).toList();
      setState(() {
        _reloading = false;
        if (matches.length != 1 ||
            matches.single.projectId != widget.projectId ||
            matches.single.tagNamePattern.trim().isEmpty) {
          _missing = true;
          _stale = true;
          _error = AppLocalizations.of(
            context,
          ).containerTagProtectionPushClearMissing;
        } else {
          _expected = matches.single;
          _missing = false;
          _stale = false;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reloading = false;
        _stale = true;
        _error = _message(error);
      });
    }
  }

  Future<void> _clear() async {
    if (_locked || !_acknowledged) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(
            containerTagProtectionPushClearControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .clearPushRole(expected: _expected);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _stale =
            (error is GitLabConflictException && error.statusCode != 422) ||
            error is GitLabNotFoundException;
        _error = _message(error);
      });
    }
  }

  String _role(AppLocalizations l10n, String? role) => switch (role) {
    null || '' => l10n.containerTagProtectionRoleUnset,
    'maintainer' => l10n.memberRoleMaintainer,
    'owner' => l10n.memberRoleOwner,
    'admin' => l10n.containerTagProtectionRoleAdmin,
    _ => l10n.memberRoleUnknown,
  };
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(l10n.localeName);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerTagProtectionPushClearTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.containerTagProtectionPushClearTarget(
                    number.format(widget.projectId),
                    number.format(_expected.id),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(_expected.tagNamePattern),
                const SizedBox(height: LabFoxSpacing.sm),
                Text(
                  l10n.containerTagProtectionPushRole(
                    _role(l10n, _expected.minimumAccessLevelForPush),
                  ),
                ),
                Text(
                  l10n.containerTagProtectionDeleteRole(
                    _role(l10n, _expected.minimumAccessLevelForDelete),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                if (!_eligible)
                  Text(l10n.containerTagProtectionPushClearBlocked),
                Text(l10n.containerTagProtectionPushClearWarning),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.containerTagProtectionPushClearAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) => setState(() {
                          _acknowledged = value == true;
                          _error = null;
                        }),
                ),
                if (_reloading)
                  const Center(child: CircularProgressIndicator()),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          if (_error != null || _stale || !_eligible)
            TextButton(
              onPressed: _busy || _reloading ? null : _reload,
              child: Text(l10n.containerTagProtectionPushClearReload),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _locked || !_acknowledged ? null : _clear,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.containerTagProtectionPushClearSave),
          ),
        ],
      ),
    );
  }
}
