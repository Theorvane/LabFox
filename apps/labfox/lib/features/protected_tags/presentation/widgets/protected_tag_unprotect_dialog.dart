import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/protected_tags_controller.dart';

class ProtectedTagUnprotectDialog extends ConsumerStatefulWidget {
  const ProtectedTagUnprotectDialog({
    required this.target,
    required this.rule,
    super.key,
  });
  final ProtectedTagRef target;
  final ProtectedTag rule;
  @override
  ConsumerState<ProtectedTagUnprotectDialog> createState() =>
      _ProtectedTagUnprotectDialogState();
}

class _ProtectedTagUnprotectDialogState
    extends ConsumerState<ProtectedTagUnprotectDialog> {
  late final Object _session;
  late ProtectedTag _expected;
  final _name = TextEditingController();
  bool _busy = false;
  bool _acknowledged = false;
  bool _needsReload = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _session = ref.read(protectedTagsRepositoryProvider.future);
    _expected = widget.rule;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _sessionChanged =>
      !identical(_session, ref.read(protectedTagsRepositoryProvider.future));
  bool get _locked => _busy || _needsReload || _sessionChanged;
  String _message(Object error, AppLocalizations l10n) => switch (error) {
    GitLabAuthException() => l10n.protectedTagUnprotectAuth,
    GitLabForbiddenException() => l10n.protectedTagUnprotectForbidden,
    GitLabNotFoundException() => l10n.protectedTagUnprotectUnavailable,
    GitLabConflictException() => l10n.protectedTagUnprotectStale,
    GitLabRateLimitException() => l10n.protectedTagUnprotectRateLimited,
    _ => l10n.protectedTagUnprotectError,
  };
  Future<void> _reload() async {
    if (_busy || _sessionChanged) return;
    setState(() {
      _busy = true;
      _acknowledged = false;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final fresh = await ref.refresh(
        protectedTagDetailProvider(widget.target).future,
      );
      if (!mounted || _sessionChanged) return;
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
          .read(protectedTagUnprotectControllerProvider(widget.target).notifier)
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
    ref.watch(protectedTagsRepositoryProvider.future);
    String id(int? value) => value == null
        ? l10n.protectedTagUnprotectUnreported
        : NumberFormat.decimalPattern(l10n.localeName).format(value);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.protectedTagUnprotectTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.protectedTagUnprotectTarget(
                    id(widget.target.projectId),
                    _expected.name,
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.protectedTagUnprotectWarning),
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  l10n.protectedTagCreateAccess,
                  style: LabFoxTextRoles.of(context).sectionHeader,
                ),
                if (_expected.createAccessLevels.isEmpty)
                  Text(l10n.protectedTagUnprotectUnreported),
                for (final entry in _expected.createAccessLevels)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: LabFoxSpacing.sm,
                    ),
                    child: Text(
                      l10n.protectedTagUnprotectAccess(
                        entry.description ??
                            l10n.protectedTagUnprotectUnreported,
                        id(entry.accessLevel),
                        id(entry.userId),
                        id(entry.groupId),
                        id(entry.deployKeyId),
                      ),
                    ),
                  ),
                TextField(
                  key: const ValueKey('protected-tag-unprotect-name'),
                  controller: _name,
                  readOnly: _locked,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.protectedTagUnprotectName,
                  ),
                  onChanged: (_) {
                    if (!_locked) setState(() => _acknowledged = false);
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.protectedTagUnprotectAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value == true),
                ),
                if (_sessionChanged)
                  Text(l10n.protectedTagUnprotectSessionChanged),
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
              key: const ValueKey('protected-tag-unprotect-reload'),
              onPressed: _busy || _sessionChanged ? null : _reload,
              child: Text(l10n.protectedTagUnprotectReload),
            ),
          FilledButton(
            key: const ValueKey('protected-tag-unprotect-save'),
            onPressed: _locked || !_acknowledged || _name.text != _expected.name
                ? null
                : _save,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.protectedTagUnprotectTitle),
          ),
        ],
      ),
    );
  }
}
