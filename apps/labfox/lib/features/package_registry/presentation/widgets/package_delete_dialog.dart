import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/package_controllers.dart';
import '../controllers/package_delete_controller.dart';

/// Explicit confirmation; deletion never starts merely by opening this dialog.
class PackageDeleteDialog extends ConsumerStatefulWidget {
  const PackageDeleteDialog({
    required this.packageRef,
    required this.package,
    super.key,
  });
  final PackageRef packageRef;
  final GitLabPackage package;

  @override
  ConsumerState<PackageDeleteDialog> createState() => _DeleteState();
}

class _DeleteState extends ConsumerState<PackageDeleteDialog> {
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
          .read(packageDeleteControllerProvider(widget.packageRef).notifier)
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
        title: Text(l10n.packageDeleteConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.packageDeleteConfirmBody(widget.package.name)),
              if (widget.package.version != null) ...[
                const SizedBox(height: LabFoxSpacing.sm),
                Text(widget.package.version!),
              ],
              const SizedBox(height: LabFoxSpacing.md),
              Text(l10n.packageDeleteForwardingWarning),
              if (_failed) ...[
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  _forbidden
                      ? l10n.packageDeleteForbidden
                      : l10n.packageDeleteError,
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
            child: Text(l10n.packageDelete),
          ),
        ],
      ),
    );
  }
}
