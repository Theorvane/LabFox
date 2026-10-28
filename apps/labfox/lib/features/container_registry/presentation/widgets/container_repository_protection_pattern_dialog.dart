import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_repository_protection_controller.dart';
import '../controllers/container_repository_protection_pattern_controller.dart';

/// Freezes the reviewed rule until an explicit reload and fresh acknowledgement.
class ContainerRepositoryProtectionPatternDialog
    extends ConsumerStatefulWidget {
  const ContainerRepositoryProtectionPatternDialog({
    required this.projectId,
    required this.rule,
    super.key,
  });
  final int projectId;
  final ContainerRepositoryProtectionRule rule;
  @override
  ConsumerState<ContainerRepositoryProtectionPatternDialog> createState() =>
      _ContainerRepositoryProtectionPatternDialogState();
}

class _ContainerRepositoryProtectionPatternDialogState
    extends ConsumerState<ContainerRepositoryProtectionPatternDialog> {
  late ContainerRepositoryProtectionRule _expected;
  late final TextEditingController _pattern;
  bool _acknowledged = false;
  bool _busy = false;
  bool _reloading = false;
  bool _stale = false;
  bool _missing = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _expected = widget.rule;
    _pattern = TextEditingController(text: widget.rule.repositoryPathPattern);
  }

  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  bool get _draftValid =>
      _pattern.text.trim().isNotEmpty &&
      _pattern.text != _expected.repositoryPathPattern;
  bool get _valid =>
      !_missing &&
      _expected.projectId == widget.projectId &&
      _expected.id > 0 &&
      _expected.repositoryPathPattern.isNotEmpty;
  bool get _locked => _busy || _reloading || _stale || !_valid;

  String _message(Object error) {
    final l10n = AppLocalizations.of(context);
    return switch (error) {
      GitLabForbiddenException() => l10n.containerProtectionPatternForbidden,
      GitLabNotFoundException() => l10n.containerProtectionPatternMissing,
      GitLabConflictException(statusCode: 422) =>
        l10n.containerProtectionPatternInvalid,
      GitLabServerException(statusCode: 400) =>
        l10n.containerProtectionPatternInvalid,
      GitLabConflictException() => l10n.containerProtectionPatternStale,
      GitLabRateLimitException() => l10n.containerProtectionPatternRateLimited,
      _ => l10n.containerProtectionPatternError,
    };
  }

  Future<void> _reload() async {
    if (_busy || _reloading) return;
    setState(() {
      _reloading = true;
      _acknowledged = false;
      _error = null;
    });
    try {
      final rules = await ref.refresh(
        containerRepositoryProtectionControllerProvider(
          widget.projectId,
        ).future,
      );
      if (!mounted) return;
      final matches = rules.where((rule) => rule.id == widget.rule.id).toList();
      setState(() {
        _reloading = false;
        if (matches.length != 1 ||
            matches.single.projectId != widget.projectId ||
            matches.single.repositoryPathPattern.isEmpty) {
          _missing = true;
          _stale = true;
          _error = AppLocalizations.of(
            context,
          ).containerProtectionPatternMissing;
        } else {
          _expected = matches.single;
          _missing = false;
          _stale = false;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reloading = false;
        _stale = true;
        _error = _message(error);
      });
    }
  }

  Future<void> _update() async {
    if (_locked || !_draftValid || !_acknowledged) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(
            containerRepositoryProtectionPatternControllerProvider(
              widget.projectId,
            ).notifier,
          )
          .savePattern(expected: _expected, pattern: _pattern.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _stale =
            (error is GitLabConflictException && error.statusCode != 422) ||
            error is GitLabNotFoundException;
        _error = _message(error);
      });
    }
  }

  String _role(AppLocalizations l10n, String? role) => switch (role) {
    null || '' => l10n.containerRepositoryProtectionRoleUnset,
    'maintainer' => l10n.memberRoleMaintainer,
    'owner' => l10n.memberRoleOwner,
    'admin' => l10n.containerRepositoryProtectionRoleAdmin,
    _ => l10n.memberRoleUnknown,
  };
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(l10n.localeName);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerProtectionPatternTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.containerProtectionPatternTarget(
                    number.format(widget.projectId),
                    number.format(_expected.id),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(_expected.repositoryPathPattern),
                const SizedBox(height: LabFoxSpacing.sm),
                Text(
                  l10n.containerRepositoryProtectionPushRole(
                    _role(l10n, _expected.minimumAccessLevelForPush),
                  ),
                ),
                Text(
                  l10n.containerRepositoryProtectionDeleteRole(
                    _role(l10n, _expected.minimumAccessLevelForDelete),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey('protectionPatternDraft'),
                  controller: _pattern,
                  enabled: !_locked,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.containerProtectionPatternDraft,
                  ),
                  onChanged: (_) => setState(() {
                    _acknowledged = false;
                    _error = null;
                  }),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.containerProtectionPatternWarning),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  title: Text(l10n.containerProtectionPatternAcknowledge),
                  onChanged: _locked
                      ? null
                      : (value) => setState(() {
                          _acknowledged = value == true;
                          _error = null;
                        }),
                ),
                if (_reloading)
                  const Center(child: CircularProgressIndicator()),
                if (_error != null)
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
          if (_error != null || _stale)
            TextButton(
              onPressed: _busy || _reloading ? null : _reload,
              child: Text(l10n.containerProtectionPatternReload),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _locked || !_draftValid || !_acknowledged
                ? null
                : _update,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.containerProtectionPatternSave),
          ),
        ],
      ),
    );
  }
}
