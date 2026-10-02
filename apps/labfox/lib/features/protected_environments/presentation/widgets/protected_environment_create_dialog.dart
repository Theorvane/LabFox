import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_environments_controller.dart';

class ProtectedEnvironmentCreateDialog extends ConsumerStatefulWidget {
  const ProtectedEnvironmentCreateDialog({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<ProtectedEnvironmentCreateDialog> createState() =>
      _ProtectedEnvironmentCreateDialogState();
}

class _ProtectedEnvironmentCreateDialogState
    extends ConsumerState<ProtectedEnvironmentCreateDialog> {
  final _name = TextEditingController();
  late final Object _session;
  int? _accessLevel;
  bool _acknowledged = false;
  bool _busy = false;
  bool _needsReload = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedEnvironmentsRepositoryProvider.future);
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
  bool get _validName =>
      _name.text.trim().isNotEmpty &&
      _name.text == _name.text.trim() &&
      !_name.text.contains('*');

  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabConflictException() => l10n.protectedEnvironmentCreateDuplicate,
    GitLabForbiddenException() ||
    GitLabAuthException() => l10n.protectedEnvironmentCreateForbidden,
    _ => l10n.protectedEnvironmentCreateError,
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
      await ref
          .read(
            protectedEnvironmentCreateControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .inspectName(_name.text);
      if (!mounted || _sessionChanged) return;
      ref.invalidate(protectedEnvironmentsControllerProvider(widget.projectId));
      setState(() => _needsReload = false);
    } catch (error) {
      if (mounted && !_sessionChanged) {
        setState(() => _error = _message(error, l10n));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_locked || !_validName || _accessLevel == null || !_acknowledged) {
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
            protectedEnvironmentCreateControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .create(_name.text, accessLevel: _accessLevel!);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(protectedEnvironmentsRepositoryProvider.future);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.protectedEnvironmentCreateTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const ValueKey('protected-environment-create-name'),
                  controller: _name,
                  enabled: !_locked,
                  decoration: InputDecoration(
                    labelText: l10n.protectedEnvironmentCreateName,
                    errorText: _name.text.isNotEmpty && !_validName
                        ? l10n.protectedEnvironmentCreateInvalidName
                        : null,
                  ),
                  onChanged: (_) => setState(() => _acknowledged = false),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Wrap(
                  spacing: LabFoxSpacing.sm,
                  runSpacing: LabFoxSpacing.sm,
                  children: [
                    for (final level in [30, 40])
                      ChoiceChip(
                        key: ValueKey(
                          'protected-environment-create-role-$level',
                        ),
                        label: Text(
                          level == 30
                              ? l10n.protectedEnvironmentCreateDeveloper
                              : l10n.protectedEnvironmentCreateMaintainer,
                        ),
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
                Text(l10n.protectedEnvironmentCreateWarning),
                const SizedBox(height: LabFoxSpacing.md),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.protectedEnvironmentCreateAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value == true),
                ),
                if (_sessionChanged)
                  Text(l10n.protectedEnvironmentCreateSessionChanged),
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
              key: const ValueKey('protected-environment-create-reload'),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedEnvironmentCreateReload),
            ),
          FilledButton(
            key: const ValueKey('protected-environment-create-save'),
            onPressed:
                _locked || !_validName || _accessLevel == null || !_acknowledged
                ? null
                : _save,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.protectedEnvironmentCreateSave),
          ),
        ],
      ),
    );
  }
}
