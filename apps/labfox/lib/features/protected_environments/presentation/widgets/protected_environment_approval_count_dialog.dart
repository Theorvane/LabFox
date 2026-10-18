import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_environments_controller.dart';

class ProtectedEnvironmentApprovalCountDialog extends ConsumerStatefulWidget {
  const ProtectedEnvironmentApprovalCountDialog({
    required this.target,
    required this.rule,
    super.key,
  });

  final ProtectedEnvironmentRef target;
  final ProtectedEnvironment rule;

  @override
  ConsumerState<ProtectedEnvironmentApprovalCountDialog> createState() =>
      _ProtectedEnvironmentApprovalCountDialogState();
}

class _ProtectedEnvironmentApprovalCountDialogState
    extends ConsumerState<ProtectedEnvironmentApprovalCountDialog> {
  final _name = TextEditingController();
  late final Object _session;
  late ProtectedEnvironment _expected;
  int? _ruleId;
  int? _requiredApprovals;
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
  List<ProtectedEnvironmentAccess> get _approvalRules => _expected.approvalRules
      .where(
        (rule) =>
            rule.id != null &&
            rule.id! > 0 &&
            rule.requiredApprovals != null &&
            rule.requiredApprovals! >= 1 &&
            rule.requiredApprovals! <= 5,
      )
      .toList();
  bool get _canSave =>
      !_locked &&
      _ruleId != null &&
      _approvalRules.where((rule) => rule.id == _ruleId).length == 1 &&
      _requiredApprovals != null &&
      _requiredApprovals! >= 1 &&
      _requiredApprovals! <= 5 &&
      _approvalRules
              .singleWhere((rule) => rule.id == _ruleId)
              .requiredApprovals !=
          _requiredApprovals &&
      _name.text == _expected.name &&
      _acknowledged;

  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabAuthException() => l10n.protectedEnvironmentUnprotectAuth,
    GitLabForbiddenException() =>
      l10n.protectedEnvironmentApprovalCountForbidden,
    GitLabNotFoundException() => l10n.protectedEnvironmentUnprotectUnavailable,
    GitLabConflictException() => l10n.protectedEnvironmentUnprotectStale,
    GitLabRateLimitException() => l10n.protectedEnvironmentUnprotectRateLimited,
    _ => l10n.protectedEnvironmentApprovalCountError,
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
            protectedEnvironmentApprovalCountControllerProvider(
              widget.target,
            ).notifier,
          )
          .inspect();
      if (!mounted || _sessionChanged) return;
      ref.invalidate(protectedEnvironmentDetailProvider(widget.target));
      setState(() {
        _expected = fresh;
        _name.clear();
        _ruleId = null;
        _requiredApprovals = null;
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
            protectedEnvironmentApprovalCountControllerProvider(
              widget.target,
            ).notifier,
          )
          .edit(
            expected: _expected,
            ruleId: _ruleId!,
            requiredApprovals: _requiredApprovals!,
          );
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
        title: Text(l10n.protectedEnvironmentApprovalCountTitle),
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
                Text(l10n.protectedEnvironmentApprovalCountWarning),
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
                RadioGroup<int>(
                  groupValue: _ruleId,
                  onChanged: (value) {
                    if (!_locked && value != null) {
                      setState(() {
                        _ruleId = value;
                        _requiredApprovals = null;
                        _acknowledged = false;
                      });
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final rule in _approvalRules)
                        RadioListTile<int>(
                          key: ValueKey(
                            'protected-environment-approval-count-rule-${rule.id}',
                          ),
                          value: rule.id!,
                          enabled: !_locked,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.protectedEnvironmentApprovalCountRuleLabel(
                              rule.description ??
                                  l10n.protectedEnvironmentUnprotectUnreported,
                              NumberFormat.decimalPattern(
                                l10n.localeName,
                              ).format(rule.id),
                              NumberFormat.decimalPattern(
                                l10n.localeName,
                              ).format(rule.requiredApprovals),
                            ),
                          ),
                          selected: _ruleId == rule.id,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.protectedEnvironmentApprovalCountLevel),
                Wrap(
                  spacing: LabFoxSpacing.sm,
                  runSpacing: LabFoxSpacing.sm,
                  children: [
                    for (final count in [1, 2, 3, 4, 5])
                      ChoiceChip(
                        key: ValueKey(
                          'protected-environment-approval-count-count-$count',
                        ),
                        label: Text(
                          NumberFormat.decimalPattern(
                            l10n.localeName,
                          ).format(count),
                        ),
                        selected: _requiredApprovals == count,
                        onSelected:
                            _locked ||
                                _ruleId == null ||
                                _approvalRules.any(
                                  (rule) =>
                                      rule.id == _ruleId &&
                                      rule.requiredApprovals == count,
                                )
                            ? null
                            : (_) => setState(() {
                                _requiredApprovals = count;
                                _acknowledged = false;
                              }),
                      ),
                  ],
                ),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey(
                    'protected-environment-approval-count-name',
                  ),
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
                  title: Text(
                    l10n.protectedEnvironmentApprovalCountAcknowledge,
                  ),
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
              key: const ValueKey(
                'protected-environment-approval-count-reload',
              ),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedEnvironmentUnprotectReload),
            ),
          FilledButton(
            key: const ValueKey('protected-environment-approval-count-save'),
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
                : Text(l10n.protectedEnvironmentApprovalCountTitle),
          ),
        ],
      ),
    );
  }
}
