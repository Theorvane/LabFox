import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_repository_protection_controller.dart';
import '../controllers/container_repository_protection_delete_clear_controller.dart';

/// Freezes the reviewed rule until an explicit reload and fresh acknowledgement.
class ContainerRepositoryProtectionDeleteClearDialog
    extends ConsumerStatefulWidget {
  const ContainerRepositoryProtectionDeleteClearDialog({
    required this.projectId,
    required this.rule,
    super.key,
  });
  final int projectId;
  final ContainerRepositoryProtectionRule rule;
  @override
  ConsumerState<ContainerRepositoryProtectionDeleteClearDialog> createState() =>
      _ContainerRepositoryProtectionDeleteClearDialogState();
}

class _ContainerRepositoryProtectionDeleteClearDialogState
    extends ConsumerState<ContainerRepositoryProtectionDeleteClearDialog> {
  late ContainerRepositoryProtectionRule _expected;
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
      _roles.contains(_expected.minimumAccessLevelForDelete) &&
      _roles.contains(_expected.minimumAccessLevelForPush);
  bool get _valid =>
      !_missing &&
      _eligible &&
      widget.projectId > 0 &&
      _expected.projectId == widget.projectId &&
      _expected.id > 0 &&
      _expected.repositoryPathPattern.isNotEmpty;
  bool get _locked => _busy || _reloading || _stale || !_valid;

  String _message(Object error) {
    final l10n = AppLocalizations.of(context);
    return switch (error) {
      GitLabForbiddenException() =>
        l10n.containerProtectionDeleteClearForbidden,
      GitLabNotFoundException() => l10n.containerProtectionDeleteClearMissing,
      GitLabConflictException(statusCode: 422) =>
        l10n.containerProtectionDeleteClearInvalid,
      GitLabServerException(statusCode: 400) =>
        l10n.containerProtectionDeleteClearInvalid,
      GitLabConflictException() => l10n.containerProtectionDeleteClearStale,
      GitLabRateLimitException() =>
        l10n.containerProtectionDeleteClearRateLimited,
      _ => l10n.containerProtectionDeleteClearError,
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
        containerRepositoryProtectionControllerProvider(
          widget.projectId,
        ).future,
      );
      if (!mounted) return;
      final matches = rules.where((rule) => rule.id == widget.rule.id).toList();
      setState(() {
        _reloading = false;
        if (matches.length != 1 ||
            matches.single.projectId != widget.projectId ||
            matches.single.repositoryPathPattern.isEmpty) {
          _missing = true;
          _stale = true;
          _error = AppLocalizations.of(
            context,
          ).containerProtectionDeleteClearMissing;
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
            containerRepositoryProtectionDeleteClearControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .clearDeleteRole(expected: _expected);
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
    null || '' => l10n.containerRepositoryProtectionRoleUnset,
    'maintainer' => l10n.memberRoleMaintainer,
    'owner' => l10n.memberRoleOwner,
    'admin' => l10n.containerRepositoryProtectionRoleAdmin,
    _ => l10n.memberRoleUnknown,
  };
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(l10n.localeName);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerProtectionDeleteClearTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.containerProtectionDeleteClearTarget(
                    number.format(widget.projectId),
                    number.format(_expected.id),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(_expected.repositoryPathPattern),
                const SizedBox(height: LabFoxSpacing.sm),
                Text(
                  l10n.containerRepositoryProtectionDeleteRole(
                    _role(l10n, _expected.minimumAccessLevelForDelete),
                  ),
                ),
                Text(
                  l10n.containerRepositoryProtectionPushRole(
                    _role(l10n, _expected.minimumAccessLevelForPush),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                if (!_eligible)
                  Text(l10n.containerProtectionDeleteClearBlocked),
                Text(l10n.containerProtectionDeleteClearWarning),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.containerProtectionDeleteClearAcknowledge),
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
          if (_error != null || _stale)
            TextButton(
              onPressed: _busy || _reloading ? null : _reload,
              child: Text(l10n.containerProtectionDeleteClearReload),
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
                : Text(l10n.containerProtectionDeleteClearSave),
          ),
        ],
      ),
    );
  }
}
