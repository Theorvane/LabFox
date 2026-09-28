import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_registry_controllers.dart';

/// Explicit retention criteria and confirmation for asynchronous tag cleanup.
class ContainerTagCleanupDialog extends ConsumerStatefulWidget {
  const ContainerTagCleanupDialog({required this.repository, super.key});

  final RegistryRef repository;

  @override
  ConsumerState<ContainerTagCleanupDialog> createState() =>
      _ContainerTagCleanupDialogState();
}

class _ContainerTagCleanupDialogState
    extends ConsumerState<ContainerTagCleanupDialog> {
  final _form = GlobalKey<FormState>();
  final _deletePattern = TextEditingController();
  final _keepPattern = TextEditingController();
  final _keepCount = TextEditingController(text: '10');
  String _olderThan = '7d';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _deletePattern.dispose();
    _keepPattern.dispose();
    _keepCount.dispose();
    super.dispose();
  }

  Future<void> _schedule() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final keepPattern = _keepPattern.text.trim();
      final count = _keepCount.text.trim();
      await ref
          .read(
            containerTagCleanupControllerProvider(widget.repository).notifier,
          )
          .schedule(
            nameRegexDelete: _deletePattern.text.trim(),
            nameRegexKeep: keepPattern.isEmpty ? null : keepPattern,
            keepN: count.isEmpty ? null : int.parse(count),
            olderThan: _olderThan.isEmpty ? null : _olderThan,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (error) {
          GitLabForbiddenException() => l10n.containerCleanupForbidden,
          GitLabRateLimitException() => l10n.containerCleanupRateLimited,
          GitLabException(statusCode: 400 || 422) =>
            l10n.containerCleanupInvalid,
          _ => l10n.containerCleanupError,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(l10n.localeName);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerCleanupTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.containerCleanupTarget(
                      number.format(widget.repository.projectId),
                      number.format(widget.repository.repositoryId),
                    ),
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l10n.containerCleanupWarning),
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l10n.containerCleanupLimits),
                  const SizedBox(height: LabFoxSpacing.md),
                  TextFormField(
                    key: const ValueKey('cleanup-delete'),
                    controller: _deletePattern,
                    enabled: !_busy,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: l10n.containerCleanupDeletePattern,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.containerCleanupRequired
                        : null,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  TextFormField(
                    key: const ValueKey('cleanup-keep'),
                    controller: _keepPattern,
                    enabled: !_busy,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: l10n.containerCleanupKeepPattern,
                    ),
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  TextFormField(
                    key: const ValueKey('cleanup-count'),
                    controller: _keepCount,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.containerCleanupKeepCount,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final number = int.tryParse(value.trim());
                      return number == null || number < 0
                          ? l10n.containerCleanupCountError
                          : null;
                    },
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('cleanup-age'),
                    initialValue: _olderThan,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.containerCleanupAge,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text(l10n.containerCleanupNoAge),
                      ),
                      DropdownMenuItem(
                        value: '1d',
                        child: Text(l10n.containerCleanupDay),
                      ),
                      DropdownMenuItem(
                        value: '7d',
                        child: Text(l10n.containerCleanupWeek),
                      ),
                      DropdownMenuItem(
                        value: '1month',
                        child: Text(l10n.containerCleanupMonth),
                      ),
                    ],
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _olderThan = value!),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: LabFoxSpacing.md),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _busy ? null : _schedule,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.containerCleanupSchedule),
          ),
        ],
      ),
    );
  }
}
