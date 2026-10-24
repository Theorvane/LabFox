import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_environments_controller.dart';

class ProtectedEnvironmentRemoveRoleDialog extends ConsumerStatefulWidget {
  const ProtectedEnvironmentRemoveRoleDialog({
    required this.target,
    required this.rule,
    super.key,
  });

  final ProtectedEnvironmentRef target;
  final ProtectedEnvironment rule;

  @override
  ConsumerState<ProtectedEnvironmentRemoveRoleDialog> createState() =>
      _ProtectedEnvironmentRemoveRoleDialogState();
}

class _ProtectedEnvironmentRemoveRoleDialogState
    extends ConsumerState<ProtectedEnvironmentRemoveRoleDialog> {
  final _name = TextEditingController();
  late final Object _session;
  late ProtectedEnvironment _expected;
  int? _grantId;
  bool _busy = false;
  bool _acknowledged = false;
  bool _needsReload = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedEnvironmentsRepositoryProvider.future);
    _expected = widget.rule;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _sessionChanged => !identical(
    _session,
    ref.read(protectedEnvironmentsRepositoryProvider.future),
  );
  bool get _locked => _busy || _needsReload || _sessionChanged;
  List<ProtectedEnvironmentAccess> get _roleGrants => _expected
      .deployAccessLevels
      .where(
        (grant) =>
            grant.id != null &&
            grant.id! > 0 &&
            {30, 40}.contains(grant.accessLevel) &&
            grant.userId == null &&
            grant.groupId == null,
      )
      .toList();
  bool get _canSave =>
      !_locked &&
      _grantId != null &&
      _roleGrants.where((grant) => grant.id == _grantId).length == 1 &&
      _name.text == _expected.name &&
      _acknowledged;

  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabAuthException() => l10n.protectedEnvironmentUnprotectAuth,
    GitLabForbiddenException() => l10n.protectedEnvironmentRemoveRoleForbidden,
    GitLabNotFoundException() => l10n.protectedEnvironmentUnprotectUnavailable,
    GitLabConflictException() => l10n.protectedEnvironmentUnprotectStale,
    GitLabRateLimitException() => l10n.protectedEnvironmentUnprotectRateLimited,
    _ => l10n.protectedEnvironmentRemoveRoleError,
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
            protectedEnvironmentRemoveDeployRoleControllerProvider(
              widget.target,
            ).notifier,
          )
          .inspect();
      if (!mounted || _sessionChanged) return;
      ref.invalidate(protectedEnvironmentDetailProvider(widget.target));
      setState(() {
        _expected = fresh;
        _name.clear();
        _grantId = null;
        _needsReload = false;
      });
    } catch (error) {
      if (mounted && !_sessionChanged) {
        setState(() => _error = _message(error, l10n));
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
            protectedEnvironmentRemoveDeployRoleControllerProvider(
              widget.target,
            ).notifier,
          )
          .remove(expected: _expected, grantId: _grantId!);
      if (mounted && !_sessionChanged) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _needsReload = true;
          _acknowledged = false;
          _error = _message(error, l10n);
        });
      }
    }
  }

  Widget _entries(
    List<ProtectedEnvironmentAccess> entries,
    AppLocalizations l10n,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final entry in entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.sm),
          child: Text(
            entry.description ?? l10n.protectedEnvironmentUnprotectUnreported,
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(protectedEnvironmentsRepositoryProvider.future);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.protectedEnvironmentRemoveRoleTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.protectedEnvironmentUnprotectTarget(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.target.projectId),
                    _expected.name,
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.protectedEnvironmentRemoveRoleWarning),
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  l10n.protectedEnvironmentDeployAccess,
                  style: LabFoxTextRoles.of(context).sectionHeader,
                ),
                _entries(_expected.deployAccessLevels, l10n),
                const SizedBox(height: LabFoxSpacing.sm),
                Text(
                  l10n.protectedEnvironmentApprovalRules,
                  style: LabFoxTextRoles.of(context).sectionHeader,
                ),
                _entries(_expected.approvalRules, l10n),
                const SizedBox(height: LabFoxSpacing.md),
                Wrap(
                  spacing: LabFoxSpacing.sm,
                  runSpacing: LabFoxSpacing.sm,
                  children: [
                    for (final grant in _roleGrants)
                      ChoiceChip(
                        key: ValueKey(
                          'protected-environment-remove-role-${grant.id}',
                        ),
                        label: Text(
                          l10n.protectedEnvironmentRemoveRoleGrantLabel(
                            grant.accessLevel == 30
                                ? l10n.protectedEnvironmentCreateDeveloper
                                : l10n.protectedEnvironmentCreateMaintainer,
                            NumberFormat.decimalPattern(
                              l10n.localeName,
                            ).format(grant.id),
                          ),
                        ),
                        selected: _grantId == grant.id,
                        onSelected: _locked
                            ? null
                            : (_) => setState(() {
                                _grantId = grant.id;
                                _acknowledged = false;
                              }),
                      ),
                  ],
                ),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey('protected-environment-remove-role-name'),
                  controller: _name,
                  readOnly: _locked,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.protectedEnvironmentUnprotectName,
                  ),
                  onChanged: (_) {
                    if (!_locked) setState(() => _acknowledged = false);
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.protectedEnvironmentRemoveRoleAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value == true),
                ),
                if (_sessionChanged)
                  Text(l10n.protectedEnvironmentUnprotectSessionChanged),
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
              key: const ValueKey('protected-environment-remove-role-reload'),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedEnvironmentUnprotectReload),
            ),
          FilledButton(
            key: const ValueKey('protected-environment-remove-role-save'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: _canSave ? _save : null,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.protectedEnvironmentRemoveRoleTitle),
          ),
        ],
      ),
    );
  }
}
