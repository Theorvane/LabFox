import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/container_registry_controllers.dart';
import '../controllers/container_repository_delete_controller.dart';

/// Confirms the entire image repository, not merely an individual tag.
class ContainerRepositoryDeleteDialog extends ConsumerStatefulWidget {
  const ContainerRepositoryDeleteDialog({
    required this.repositoryRef,
    required this.path,
    super.key,
  });
  final RegistryRef repositoryRef;
  final String path;

  @override
  ConsumerState<ContainerRepositoryDeleteDialog> createState() =>
      _DeleteState();
}

class _DeleteState extends ConsumerState<ContainerRepositoryDeleteDialog> {
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
          .read(
            containerRepositoryDeleteControllerProvider(
              widget.repositoryRef,
            ).notifier,
          )
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
        title: Text(l10n.containerRepositoryDeleteConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.containerRepositoryDeleteConfirmBody(widget.path)),
              const SizedBox(height: LabFoxSpacing.md),
              Text(l10n.containerRepositoryDeleteWarning),
              if (_failed) ...[
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  _forbidden
                      ? l10n.containerRepositoryDeleteForbidden
                      : l10n.containerRepositoryDeleteError,
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
            child: Text(l10n.containerRepositoryDelete),
          ),
        ],
      ),
    );
  }
}
