import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_branches_controller.dart';

class ProtectedBranchForcePushDialog extends ConsumerStatefulWidget {
  const ProtectedBranchForcePushDialog({
    required this.target,
    required this.rule,
    super.key,
  });

  final ProtectedBranchRef target;
  final ProtectedBranch rule;

  @override
  ConsumerState<ProtectedBranchForcePushDialog> createState() =>
      _ProtectedBranchForcePushDialogState();
}

class _ProtectedBranchForcePushDialogState
    extends ConsumerState<ProtectedBranchForcePushDialog> {
  late final Object _session;
  late ProtectedBranch _expected;
  late bool _allowForcePush;
  bool _acknowledged = false;
  bool _busy = false;
  bool _needsReload = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedBranchesRepositoryProvider.future);
    _expected = widget.rule;
    _allowForcePush = !widget.rule.allowForcePush;
  }

  bool get _sessionChanged => !identical(
    _session,
    ref.read(protectedBranchesRepositoryProvider.future),
  );
  bool get _locked => _busy || _needsReload || _sessionChanged;

  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabAuthException() => l10n.protectedBranchForcePushAuth,
    GitLabForbiddenException() => l10n.protectedBranchForcePushForbidden,
    GitLabNotFoundException() => l10n.protectedBranchForcePushUnavailable,
    GitLabConflictException() => l10n.protectedBranchForcePushStale,
    GitLabRateLimitException() => l10n.protectedBranchForcePushRateLimited,
    _ => l10n.protectedBranchForcePushError,
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
            protectedBranchForcePushControllerProvider(widget.target).notifier,
          )
          .inspect();
      if (!mounted || _sessionChanged) return;
      if (fresh.inherited == true) {
        throw const GitLabForbiddenException('Inherited protection rule');
      }
      ref.invalidate(protectedBranchDetailProvider(widget.target));
      setState(() {
        _expected = fresh;
        _allowForcePush = !fresh.allowForcePush;
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
        _allowForcePush == _expected.allowForcePush) {
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
            protectedBranchForcePushControllerProvider(widget.target).notifier,
          )
          .setForcePush(expected: _expected, allowForcePush: _allowForcePush);
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
        title: Text(l10n.protectedBranchForcePushEditTitle),
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
                Text(
                  _expected.allowForcePush
                      ? l10n.protectedBranchForcePushCurrentAllowed
                      : l10n.protectedBranchForcePushCurrentBlocked,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _allowForcePush,
                  title: Text(l10n.protectedBranchForcePushAllow),
                  onChanged: _locked
                      ? null
                      : (value) => setState(() {
                          _allowForcePush = value;
                          _acknowledged = false;
                        }),
                ),
                Text(
                  _allowForcePush
                      ? l10n.protectedBranchForcePushEnableWarning
                      : l10n.protectedBranchForcePushDisableWarning,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.protectedBranchForcePushAcknowledge),
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
              key: const ValueKey('protected-branch-force-push-reload'),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedBranchForcePushReload),
            ),
          FilledButton(
            key: const ValueKey('protected-branch-force-push-save'),
            onPressed:
                _locked ||
                    !_acknowledged ||
                    _allowForcePush == _expected.allowForcePush
                ? null
                : _save,
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
