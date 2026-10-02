import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../data/protected_branches_repository.dart';
import 'controllers/protected_branch_protect_controller.dart';
import 'controllers/protected_branches_controller.dart';

/// Retains an uncertain draft until the full rule inventory is scanned again.
class ProtectedBranchProtectDialog extends ConsumerStatefulWidget {
  const ProtectedBranchProtectDialog({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<ProtectedBranchProtectDialog> createState() =>
      _ProtectedBranchProtectDialogState();
}

class _ProtectedBranchProtectDialogState
    extends ConsumerState<ProtectedBranchProtectDialog> {
  final _name = TextEditingController();
  late final Future<ProtectedBranchesRepository?> _session;
  int _pushRole = 0;
  int _mergeRole = 40;
  bool _acknowledged = false;
  bool _busy = false;
  bool _needsReload = false;
  bool _existing = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedBranchesRepositoryProvider.future);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _validName => _name.text.trim().isNotEmpty;

  Future<void> _create() async {
    if (_busy || !_validName || !_acknowledged || _needsReload || _existing) {
      return;
    }
    if (!identical(
      _session,
      ref.read(protectedBranchesRepositoryProvider.future),
    )) {
      setState(() => _error = StateError('Session changed'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(
            protectedBranchProtectControllerProvider(widget.projectId).notifier,
          )
          .protect(
            name: _name.text,
            pushAccessLevel: _pushRole,
            mergeAccessLevel: _mergeRole,
          );
      if (!mounted) return;
      if (!identical(
        _session,
        ref.read(protectedBranchesRepositoryProvider.future),
      )) {
        setState(() => _error = StateError('Session changed'));
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _needsReload = true;
        _acknowledged = false;
        _existing = error is GitLabConflictException;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reload() async {
    if (_busy || !_validName) return;
    if (!identical(
      _session,
      ref.read(protectedBranchesRepositoryProvider.future),
    )) {
      setState(() => _error = StateError('Session changed'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final existing = await ref
          .read(
            protectedBranchProtectControllerProvider(widget.projectId).notifier,
          )
          .inspect(_name.text);
      if (!mounted) return;
      if (!identical(
        _session,
        ref.read(protectedBranchesRepositoryProvider.future),
      )) {
        setState(() => _error = StateError('Session changed'));
        return;
      }
      setState(() {
        _existing = existing;
        _needsReload = false;
        _error = existing ? const GitLabConflictException('Rule exists') : null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(AppLocalizations l10n, bool sessionChanged) {
    if (sessionChanged) return l10n.protectedBranchProtectSessionChanged;
    if (_existing) return l10n.protectedBranchProtectExisting;
    if (_error is GitLabForbiddenException) {
      return l10n.protectedBranchProtectForbidden;
    }
    if (_error is GitLabAuthException) {
      return l10n.protectedBranchProtectUnauthorized;
    }
    if (_error is GitLabRateLimitException) {
      return l10n.protectedBranchProtectRateLimited;
    }
    if (_error is GitLabNotFoundException) {
      return l10n.protectedBranchProtectUnavailable;
    }
    if (_needsReload) return l10n.protectedBranchProtectUncertain;
    return l10n.protectedBranchProtectLoadError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionChanged = !identical(
      _session,
      ref.watch(protectedBranchesRepositoryProvider.future),
    );
    final canSubmit =
        !_busy &&
        !sessionChanged &&
        _validName &&
        _acknowledged &&
        !_needsReload &&
        !_existing;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.protectedBranchProtectTitle),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const ValueKey('protected-branch-name'),
                  controller: _name,
                  enabled: !_busy && !sessionChanged,
                  decoration: InputDecoration(
                    labelText: l10n.protectedBranchProtectName,
                  ),
                  onChanged: (_) => setState(() {
                    _acknowledged = false;
                    _existing = false;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 16),
                _roleField(l10n, push: true, sessionChanged: sessionChanged),
                const SizedBox(height: 16),
                _roleField(l10n, push: false, sessionChanged: sessionChanged),
                const SizedBox(height: 16),
                Text(
                  l10n.protectedBranchProtectWarning(
                    NumberFormat.decimalPattern(
                      Localizations.localeOf(context).toString(),
                    ).format(widget.projectId),
                  ),
                ),
                if (_name.text.contains('*')) ...[
                  const SizedBox(height: 8),
                  Text(l10n.protectedBranchProtectWildcard),
                ],
                CheckboxListTile(
                  key: const ValueKey('protected-branch-ack'),
                  value: _acknowledged,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.protectedBranchProtectAcknowledge),
                  onChanged:
                      _busy ||
                          sessionChanged ||
                          !_validName ||
                          _needsReload ||
                          _existing
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value ?? false),
                ),
                if (_error != null || sessionChanged)
                  Text(
                    _message(l10n, sessionChanged),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (_needsReload && !sessionChanged)
                  TextButton(
                    key: const ValueKey('protected-branch-reload'),
                    onPressed: _busy || !_validName ? null : _reload,
                    child: Text(l10n.protectedBranchProtectReload),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.protectedBranchProtectCancel),
          ),
          FilledButton(
            key: const ValueKey('protected-branch-submit'),
            onPressed: canSubmit ? _create : null,
            child: Text(l10n.protectedBranchProtectSubmit),
          ),
        ],
      ),
    );
  }

  Widget _roleField(
    AppLocalizations l10n, {
    required bool push,
    required bool sessionChanged,
  }) {
    return DropdownButtonFormField<int>(
      key: ValueKey(push ? 'protected-branch-push' : 'protected-branch-merge'),
      isExpanded: true,
      initialValue: push ? _pushRole : _mergeRole,
      decoration: InputDecoration(
        labelText: push
            ? l10n.protectedBranchProtectPush
            : l10n.protectedBranchProtectMerge,
      ),
      items: [
        DropdownMenuItem(
          value: 0,
          child: Text(l10n.protectedBranchProtectNoOne),
        ),
        DropdownMenuItem(
          value: 30,
          child: Text(l10n.protectedBranchProtectDevelopers),
        ),
        DropdownMenuItem(
          value: 40,
          child: Text(l10n.protectedBranchProtectMaintainers),
        ),
      ],
      onChanged: _busy || sessionChanged
          ? null
          : (value) => setState(() {
              if (push) {
                _pushRole = value ?? 0;
              } else {
                _mergeRole = value ?? 40;
              }
              _acknowledged = false;
            }),
    );
  }
}
