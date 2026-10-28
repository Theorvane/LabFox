import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_tag_protection_create_controller.dart';

class ContainerTagProtectionCreateDialog extends ConsumerStatefulWidget {
  const ContainerTagProtectionCreateDialog({
    required this.projectId,
    super.key,
  });
  final int projectId;
  @override
  ConsumerState<ContainerTagProtectionCreateDialog> createState() =>
      _ContainerTagProtectionCreateDialogState();
}

class _ContainerTagProtectionCreateDialogState
    extends ConsumerState<ContainerTagProtectionCreateDialog> {
  final _pattern = TextEditingController();
  String? _push;
  String? _delete;
  bool _acknowledged = false;
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  void _edited() => setState(() {
    _acknowledged = false;
    _error = null;
  });

  Future<void> _create() async {
    if (_busy ||
        !_acknowledged ||
        _pattern.text.trim().isEmpty ||
        (_push == null || _delete == null)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(
            containerTagProtectionCreateControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .create(
            tagNamePattern: _pattern.text,
            minimumAccessLevelForPush: _push,
            minimumAccessLevelForDelete: _delete,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error;
        });
      }
    }
  }

  Widget _role(
    AppLocalizations l10n, {
    required String key,
    required String? value,
    required String label,
    required void Function(String?) changed,
  }) => DropdownButtonFormField<String>(
    key: ValueKey(key),
    initialValue: value ?? '',
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      DropdownMenuItem(
        value: '',
        child: Text(l10n.containerTagProtectionCreateUnset),
      ),
      DropdownMenuItem(
        value: 'maintainer',
        child: Text(l10n.memberRoleMaintainer),
      ),
      DropdownMenuItem(value: 'owner', child: Text(l10n.memberRoleOwner)),
      DropdownMenuItem(
        value: 'admin',
        child: Text(l10n.containerTagProtectionRoleAdmin),
      ),
    ],
    onChanged: _busy
        ? null
        : (role) {
            changed(role == '' ? null : role);
            _edited();
          },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid =
        widget.projectId > 0 &&
        _pattern.text.trim().isNotEmpty &&
        (_push != null && _delete != null) &&
        _acknowledged;
    final error = _error;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerTagProtectionCreateTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.containerTagProtectionCreateProject(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.projectId),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey('tagProtectionCreatePattern'),
                  controller: _pattern,
                  enabled: !_busy,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.containerTagProtectionCreatePattern,
                  ),
                  onChanged: (_) => _edited(),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                _role(
                  l10n,
                  key: 'tagProtectionCreatePush',
                  value: _push,
                  label: l10n.containerTagProtectionCreatePush,
                  changed: (role) => _push = role,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                _role(
                  l10n,
                  key: 'tagProtectionCreateDelete',
                  value: _delete,
                  label: l10n.containerTagProtectionCreateDelete,
                  changed: (role) => _delete = role,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.containerTagProtectionCreateWarning),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.containerTagProtectionCreateAcknowledge),
                  value: _acknowledged,
                  onChanged: _busy
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value ?? false),
                ),
                if (error != null)
                  Text(
                    switch (error) {
                      GitLabForbiddenException() =>
                        l10n.containerTagProtectionCreateForbidden,
                      GitLabConflictException() =>
                        l10n.containerTagProtectionCreateInvalid,
                      GitLabServerException(statusCode: 400) =>
                        l10n.containerTagProtectionCreateInvalid,
                      GitLabNotFoundException() =>
                        l10n.containerTagProtectionCreateUnavailable,
                      GitLabRateLimitException() =>
                        l10n.containerTagProtectionCreateRateLimited,
                      _ => l10n.containerTagProtectionCreateError,
                    },
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
          FilledButton(
            key: const ValueKey('tagProtectionCreateSave'),
            onPressed: _busy || !valid ? null : _create,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.containerTagProtectionCreateSave),
          ),
        ],
      ),
    );
  }
}
