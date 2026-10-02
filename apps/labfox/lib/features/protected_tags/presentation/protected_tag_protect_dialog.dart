import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../data/protected_tags_repository.dart';
import 'controllers/protected_tag_protect_controller.dart';
import 'controllers/protected_tags_controller.dart';

/// Keeps an uncertain create result visible until the full inventory is read.
class ProtectedTagProtectDialog extends ConsumerStatefulWidget {
  const ProtectedTagProtectDialog({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<ProtectedTagProtectDialog> createState() =>
      _ProtectedTagProtectDialogState();
}

class _ProtectedTagProtectDialogState
    extends ConsumerState<ProtectedTagProtectDialog> {
  final _name = TextEditingController();
  late final Future<ProtectedTagsRepository?> _session;
  int _role = 40;
  bool _acknowledged = false;
  bool _busy = false;
  bool _needsReload = false;
  bool _existing = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedTagsRepositoryProvider.future);
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
      ref.read(protectedTagsRepositoryProvider.future),
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
            protectedTagProtectControllerProvider(widget.projectId).notifier,
          )
          .protect(name: _name.text, createAccessLevel: _role);
      if (!mounted) return;
      if (!identical(
        _session,
        ref.read(protectedTagsRepositoryProvider.future),
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
      ref.read(protectedTagsRepositoryProvider.future),
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
            protectedTagProtectControllerProvider(widget.projectId).notifier,
          )
          .inspect(_name.text);
      if (!mounted) return;
      if (!identical(
        _session,
        ref.read(protectedTagsRepositoryProvider.future),
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
    if (sessionChanged) return l10n.protectedTagProtectSessionChanged;
    if (_existing) return l10n.protectedTagProtectExisting;
    if (_error is GitLabForbiddenException) {
      return l10n.protectedTagProtectForbidden;
    }
    if (_error is GitLabAuthException) {
      return l10n.protectedTagProtectUnauthorized;
    }
    if (_error is GitLabRateLimitException) {
      return l10n.protectedTagProtectRateLimited;
    }
    if (_error is GitLabNotFoundException) {
      return l10n.protectedTagProtectUnavailable;
    }
    if (_needsReload) return l10n.protectedTagProtectUncertain;
    return l10n.protectedTagProtectLoadError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionChanged = !identical(
      _session,
      ref.watch(protectedTagsRepositoryProvider.future),
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
        title: Text(l10n.protectedTagProtectTitle),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const ValueKey('protected-tag-name'),
                  controller: _name,
                  enabled: !_busy && !sessionChanged,
                  decoration: InputDecoration(
                    labelText: l10n.protectedTagProtectName,
                  ),
                  onChanged: (_) => setState(() {
                    _acknowledged = false;
                    _existing = false;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  key: const ValueKey('protected-tag-role'),
                  isExpanded: true,
                  initialValue: _role,
                  decoration: InputDecoration(
                    labelText: l10n.protectedTagProtectRole,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(l10n.protectedTagProtectNoOne),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text(l10n.protectedTagProtectDevelopers),
                    ),
                    DropdownMenuItem(
                      value: 40,
                      child: Text(l10n.protectedTagProtectMaintainers),
                    ),
                  ],
                  onChanged: _busy || sessionChanged
                      ? null
                      : (value) => setState(() {
                          _role = value ?? 40;
                          _acknowledged = false;
                        }),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.protectedTagProtectWarning(
                    NumberFormat.decimalPattern(
                      Localizations.localeOf(context).toString(),
                    ).format(widget.projectId),
                  ),
                ),
                if (_name.text.contains('*')) ...[
                  const SizedBox(height: 8),
                  Text(l10n.protectedTagProtectWildcard),
                ],
                CheckboxListTile(
                  key: const ValueKey('protected-tag-ack'),
                  value: _acknowledged,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.protectedTagProtectAcknowledge),
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
                    key: const ValueKey('protected-tag-reload'),
                    onPressed: _busy || !_validName ? null : _reload,
                    child: Text(l10n.protectedTagProtectReload),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.protectedTagProtectCancel),
          ),
          FilledButton(
            key: const ValueKey('protected-tag-submit'),
            onPressed: canSubmit ? _create : null,
            child: Text(l10n.protectedTagProtectSubmit),
          ),
        ],
      ),
    );
  }
}
