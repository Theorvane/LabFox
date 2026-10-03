import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_branches_controller.dart';

class ProtectedBranchUnprotectDialog extends ConsumerStatefulWidget {
  const ProtectedBranchUnprotectDialog({
    required this.target,
    required this.rule,
    super.key,
  });

  final ProtectedBranchRef target;
  final ProtectedBranch rule;

  @override
  ConsumerState<ProtectedBranchUnprotectDialog> createState() =>
      _ProtectedBranchUnprotectDialogState();
}

class _ProtectedBranchUnprotectDialogState
    extends ConsumerState<ProtectedBranchUnprotectDialog> {
  late final Object _session;
  late ProtectedBranch _expected;
  final _name = TextEditingController();
  bool _busy = false;
  bool _acknowledged = false;
  bool _needsReload = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedBranchesRepositoryProvider.future);
    _expected = widget.rule;
    _needsReload = ref
        .read(
          protectedBranchUnprotectControllerProvider(widget.target).notifier,
        )
        .requiresInspection;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _sessionChanged => !identical(
    _session,
    ref.read(protectedBranchesRepositoryProvider.future),
  );
  bool get _locked => _busy || _needsReload || _sessionChanged;

  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabAuthException() => l10n.protectedBranchUnprotectAuth,
    GitLabForbiddenException() => l10n.protectedBranchUnprotectForbidden,
    GitLabNotFoundException() => l10n.protectedBranchUnprotectUnavailable,
    GitLabConflictException() => l10n.protectedBranchUnprotectStale,
    GitLabRateLimitException() => l10n.protectedBranchUnprotectRateLimited,
    _ => l10n.protectedBranchUnprotectError,
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
            protectedBranchUnprotectControllerProvider(widget.target).notifier,
          )
          .inspect();
      if (!mounted || _sessionChanged) return;
      if (fresh.inherited == true) {
        throw const GitLabForbiddenException('Inherited protection rule');
      }
      ref.invalidate(protectedBranchDetailProvider(widget.target));
      setState(() {
        _expected = fresh;
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
    if (_locked || !_acknowledged || _name.text != _expected.name) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(
            protectedBranchUnprotectControllerProvider(widget.target).notifier,
          )
          .unprotect(expected: _expected);
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
        title: Text(l10n.protectedBranchUnprotectTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.protectedBranchUnprotectTarget(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.target.projectId),
                    _expected.name,
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.protectedBranchUnprotectWarning),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey('protected-branch-unprotect-name'),
                  controller: _name,
                  readOnly: _locked,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.protectedBranchUnprotectName,
                  ),
                  onChanged: (_) {
                    if (!_locked) setState(() {});
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.protectedBranchUnprotectAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value == true),
                ),
                if (_sessionChanged)
                  Text(l10n.protectedBranchUnprotectSessionChanged),
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
              key: const ValueKey('protected-branch-unprotect-reload'),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedBranchUnprotectReload),
            ),
          FilledButton(
            key: const ValueKey('protected-branch-unprotect-save'),
            onPressed: _locked || !_acknowledged || _name.text != _expected.name
                ? null
                : _save,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.protectedBranchUnprotectTitle),
          ),
        ],
      ),
    );
  }
}
