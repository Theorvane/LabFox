import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_repository_protection_create_controller.dart';

class ContainerRepositoryProtectionCreateDialog extends ConsumerStatefulWidget {
  const ContainerRepositoryProtectionCreateDialog({
    required this.projectId,
    super.key,
  });
  final int projectId;
  @override
  ConsumerState<ContainerRepositoryProtectionCreateDialog> createState() =>
      _ContainerRepositoryProtectionCreateDialogState();
}

class _ContainerRepositoryProtectionCreateDialogState
    extends ConsumerState<ContainerRepositoryProtectionCreateDialog> {
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
        (_push == null && _delete == null)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(
            containerRepositoryProtectionCreateControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .create(
            repositoryPathPattern: _pattern.text,
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
        child: Text(l10n.containerProtectionCreateUnset),
      ),
      DropdownMenuItem(
        value: 'maintainer',
        child: Text(l10n.memberRoleMaintainer),
      ),
      DropdownMenuItem(value: 'owner', child: Text(l10n.memberRoleOwner)),
      DropdownMenuItem(
        value: 'admin',
        child: Text(l10n.containerRepositoryProtectionRoleAdmin),
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
        (_push != null || _delete != null) &&
        _acknowledged;
    final error = _error;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerProtectionCreateTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.containerProtectionCreateProject(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.projectId),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey('protectionCreatePattern'),
                  controller: _pattern,
                  enabled: !_busy,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.containerProtectionCreatePattern,
                  ),
                  onChanged: (_) => _edited(),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                _role(
                  l10n,
                  key: 'protectionCreatePush',
                  value: _push,
                  label: l10n.containerProtectionCreatePush,
                  changed: (role) => _push = role,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                _role(
                  l10n,
                  key: 'protectionCreateDelete',
                  value: _delete,
                  label: l10n.containerProtectionCreateDelete,
                  changed: (role) => _delete = role,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.containerProtectionCreateWarning),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.containerProtectionCreateAcknowledge),
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
                        l10n.containerProtectionCreateForbidden,
                      GitLabConflictException() =>
                        l10n.containerProtectionCreateInvalid,
                      GitLabServerException(statusCode: 400) =>
                        l10n.containerProtectionCreateInvalid,
                      _ => l10n.containerProtectionCreateError,
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
            key: const ValueKey('protectionCreateSave'),
            onPressed: _busy || !valid ? null : _create,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.containerProtectionCreateSave),
          ),
        ],
      ),
    );
  }
}
