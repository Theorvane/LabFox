import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_branches_controller.dart';

class ProtectedBranchPushRoleDialog extends ConsumerStatefulWidget {
  const ProtectedBranchPushRoleDialog({
    required this.target,
    required this.rule,
    super.key,
  });

  final ProtectedBranchRef target;
  final ProtectedBranch rule;

  @override
  ConsumerState<ProtectedBranchPushRoleDialog> createState() =>
      _ProtectedBranchPushRoleDialogState();
}

class _ProtectedBranchPushRoleDialogState
    extends ConsumerState<ProtectedBranchPushRoleDialog> {
  late final Object _session;
  late ProtectedBranch _expected;
  late int _accessLevel;
  bool _acknowledged = false;
  bool _busy = false;
  bool _needsReload = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedBranchesRepositoryProvider.future);
    _expected = widget.rule;
    _accessLevel = editableProtectedBranchPushAccess(widget.rule)!.accessLevel!;
  }

  bool get _sessionChanged => !identical(
    _session,
    ref.read(protectedBranchesRepositoryProvider.future),
  );
  bool get _locked => _busy || _needsReload || _sessionChanged;

  String _role(int level, AppLocalizations l10n) => switch (level) {
    0 => l10n.protectedBranchPushRoleNone,
    30 => l10n.protectedBranchPushRoleDeveloper,
    _ => l10n.protectedBranchPushRoleMaintainer,
  };

  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabAuthException() => l10n.protectedBranchPushRoleAuth,
    GitLabForbiddenException() => l10n.protectedBranchPushRoleForbidden,
    GitLabNotFoundException() => l10n.protectedBranchPushRoleUnavailable,
    GitLabConflictException() => l10n.protectedBranchPushRoleStale,
    GitLabRateLimitException() => l10n.protectedBranchPushRoleRateLimited,
    _ => l10n.protectedBranchPushRoleError,
  };

  Future<void> _reload() async {
    if (!_needsReload || _busy || _sessionChanged) return;
    setState(() {
      _busy = true;
      _acknowledged = false;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final fresh = await ref
          .read(
            protectedBranchPushRoleControllerProvider(widget.target).notifier,
          )
          .inspect();
      if (!mounted || _sessionChanged) return;
      final entry = editableProtectedBranchPushAccess(fresh);
      if (entry == null) {
        throw const GitLabConflictException('Unsupported protection rule');
      }
      ref.invalidate(protectedBranchDetailProvider(widget.target));
      setState(() {
        _expected = fresh;
        _accessLevel = entry.accessLevel!;
        _needsReload = false;
      });
    } catch (error) {
      if (mounted && !_sessionChanged) {
        setState(() {
          _error = _message(error, l10n);
          _needsReload = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_locked ||
        !_acknowledged ||
        _accessLevel ==
            editableProtectedBranchPushAccess(_expected)?.accessLevel) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(
            protectedBranchPushRoleControllerProvider(widget.target).notifier,
          )
          .setPushRole(expected: _expected, accessLevel: _accessLevel);
      if (mounted && !_sessionChanged) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _needsReload = true;
        _acknowledged = false;
        _error = _message(error, l10n);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(protectedBranchesRepositoryProvider.future);
    final current = editableProtectedBranchPushAccess(_expected)!.accessLevel!;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.protectedBranchPushRoleEditTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.protectedBranchPushRoleTarget(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.target.projectId),
                    _expected.name,
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.protectedBranchPushRoleCurrent(_role(current, l10n))),
                const SizedBox(height: LabFoxSpacing.md),
                Wrap(
                  spacing: LabFoxSpacing.sm,
                  runSpacing: LabFoxSpacing.sm,
                  children: [
                    for (final level in [0, 30, 40])
                      ChoiceChip(
                        key: ValueKey('protected-branch-push-role-$level'),
                        label: Text(_role(level, l10n)),
                        selected: _accessLevel == level,
                        onSelected: _locked
                            ? null
                            : (_) => setState(() {
                                _accessLevel = level;
                                _acknowledged = false;
                              }),
                      ),
                  ],
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.protectedBranchPushRoleWarning),
                const SizedBox(height: LabFoxSpacing.md),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.protectedBranchPushRoleAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value == true),
                ),
                if (_sessionChanged)
                  Text(l10n.protectedBranchPushRoleSessionChanged),
                if (_error != null && !_sessionChanged)
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
          if (_needsReload)
            TextButton(
              key: const ValueKey('protected-branch-push-role-reload'),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedBranchPushRoleReload),
            ),
          FilledButton(
            key: const ValueKey('protected-branch-push-role-save'),
            onPressed: _locked || !_acknowledged || _accessLevel == current
                ? null
                : _save,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.protectedBranchPushRoleSave),
          ),
        ],
      ),
    );
  }
}
