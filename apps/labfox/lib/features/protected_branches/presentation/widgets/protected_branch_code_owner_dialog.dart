import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_branches_controller.dart';

class ProtectedBranchCodeOwnerDialog extends ConsumerStatefulWidget {
  const ProtectedBranchCodeOwnerDialog({
    required this.target,
    required this.rule,
    super.key,
  });

  final ProtectedBranchRef target;
  final ProtectedBranch rule;

  @override
  ConsumerState<ProtectedBranchCodeOwnerDialog> createState() =>
      _ProtectedBranchCodeOwnerDialogState();
}

class _ProtectedBranchCodeOwnerDialogState
    extends ConsumerState<ProtectedBranchCodeOwnerDialog> {
  final _name = TextEditingController();
  late final Object _session;
  late ProtectedBranch _expected;
  late bool _requireCodeOwner;
  bool _acknowledged = false;
  bool _busy = false;
  bool _needsReload = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedBranchesRepositoryProvider.future);
    _expected = widget.rule;
    _requireCodeOwner = widget.rule.codeOwnerApprovalRequired;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSave =>
      !_locked &&
      _acknowledged &&
      _name.text == _expected.name &&
      _requireCodeOwner != _expected.codeOwnerApprovalRequired;

  bool get _sessionChanged => !identical(
    _session,
    ref.read(protectedBranchesRepositoryProvider.future),
  );
  bool get _locked => _busy || _needsReload || _sessionChanged;

  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabAuthException() => l10n.protectedBranchForcePushAuth,
    GitLabForbiddenException() => l10n.protectedBranchCodeOwnerForbidden,
    GitLabNotFoundException() => l10n.protectedBranchForcePushUnavailable,
    GitLabConflictException() => l10n.protectedBranchForcePushStale,
    GitLabRateLimitException() => l10n.protectedBranchForcePushRateLimited,
    _ => l10n.protectedBranchCodeOwnerError,
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
            protectedBranchCodeOwnerControllerProvider(widget.target).notifier,
          )
          .inspect();
      if (!mounted || _sessionChanged) return;
      if (fresh.inherited == true) {
        throw const GitLabForbiddenException('Inherited protection rule');
      }
      ref.invalidate(protectedBranchDetailProvider(widget.target));
      setState(() {
        _expected = fresh;
        _requireCodeOwner = fresh.codeOwnerApprovalRequired;
        _name.clear();
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
    if (!_canSave) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(
            protectedBranchCodeOwnerControllerProvider(widget.target).notifier,
          )
          .setRequirement(
            expected: _expected,
            codeOwnerApprovalRequired: _requireCodeOwner,
          );
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
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.protectedBranchCodeOwnerEditTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.protectedBranchForcePushEditTarget(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.target.projectId),
                    _expected.name,
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.protectedBranchCodeOwnerContext),
                const SizedBox(height: LabFoxSpacing.md),
                if (_needsReload)
                  Text(l10n.protectedBranchCodeOwnerInspect)
                else ...[
                  Text(
                    _expected.codeOwnerApprovalRequired
                        ? l10n.protectedBranchCodeOwnerCurrentRequired
                        : l10n.protectedBranchCodeOwnerCurrentOptional,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _requireCodeOwner,
                    title: Text(l10n.protectedBranchCodeOwnerRequire),
                    onChanged: _locked
                        ? null
                        : (value) => setState(() {
                            _requireCodeOwner = value;
                            _acknowledged = false;
                          }),
                  ),
                  Text(
                    _requireCodeOwner
                        ? l10n.protectedBranchCodeOwnerEnableWarning
                        : l10n.protectedBranchCodeOwnerDisableWarning,
                  ),
                ],
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey('protected-branch-code-owner-name'),
                  controller: _name,
                  readOnly: _locked,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.protectedBranchUnprotectName,
                  ),
                  onChanged: (_) {
                    if (!_locked) setState(() => _acknowledged = false);
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.protectedBranchCodeOwnerAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value == true),
                ),
                if (_sessionChanged)
                  Text(l10n.protectedBranchForcePushSessionChanged),
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
              key: const ValueKey('protected-branch-code-owner-reload'),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedBranchForcePushReload),
            ),
          FilledButton(
            key: const ValueKey('protected-branch-code-owner-save'),
            onPressed: _canSave ? _save : null,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.protectedBranchForcePushSave),
          ),
        ],
      ),
    );
  }
}
