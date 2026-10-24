import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_registry_controllers.dart';
import '../controllers/container_tag_delete_controller.dart';

/// Explicit confirmation that stays open on rejection and during a write.
class ContainerTagDeleteDialog extends ConsumerStatefulWidget {
  const ContainerTagDeleteDialog({
    required this.tagRef,
    required this.path,
    super.key,
  });
  final RegistryTagRef tagRef;
  final String path;

  @override
  ConsumerState<ContainerTagDeleteDialog> createState() => _DeleteState();
}

class _DeleteState extends ConsumerState<ContainerTagDeleteDialog> {
  bool _busy = false;
  bool _failed = false;
  bool _forbidden = false;

  Future<void> _delete() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
      _forbidden = false;
    });
    try {
      await ref
          .read(containerTagDeleteControllerProvider(widget.tagRef).notifier)
          .delete();
      if (!mounted) return;
      setState(() => _busy = false);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
        _forbidden = error is GitLabForbiddenException;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerTagDeleteConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.containerTagDeleteConfirmBody(
                  widget.tagRef.name,
                  widget.path,
                ),
              ),
              const SizedBox(height: LabFoxSpacing.md),
              Text(l10n.containerTagDeleteWarning),
              if (_failed) ...[
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  _forbidden
                      ? l10n.containerTagDeleteForbidden
                      : l10n.containerTagDeleteError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_busy) ...[
                const SizedBox(height: LabFoxSpacing.md),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
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
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: _busy ? null : _delete,
            child: Text(l10n.containerTagDelete),
          ),
        ],
      ),
    );
  }
}
