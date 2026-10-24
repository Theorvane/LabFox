import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/package_file_delete_controller.dart';

/// Keeps confirmation open on rejection and prevents dismissal during a write.
class PackageFileDeleteDialog extends ConsumerStatefulWidget {
  const PackageFileDeleteDialog({
    required this.fileRef,
    required this.package,
    required this.file,
    super.key,
  });
  final PackageFileRef fileRef;
  final GitLabPackage package;
  final PackageFile file;

  @override
  ConsumerState<PackageFileDeleteDialog> createState() => _DeleteState();
}

class _DeleteState extends ConsumerState<PackageFileDeleteDialog> {
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
          .read(packageFileDeleteControllerProvider(widget.fileRef).notifier)
          .delete();
      if (!mounted) return;
      setState(() => _busy = false);
      Navigator.of(context).pop();
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
        title: Text(l10n.packageFileDeleteConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.packageFileDeleteConfirmBody(
                  widget.file.fileName,
                  widget.package.name,
                ),
              ),
              if (widget.package.version != null) ...[
                const SizedBox(height: LabFoxSpacing.sm),
                Text(widget.package.version!),
              ],
              const SizedBox(height: LabFoxSpacing.md),
              Text(l10n.packageFileDeleteWarning),
              if (_failed) ...[
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  _forbidden
                      ? l10n.packageFileDeleteForbidden
                      : l10n.packageFileDeleteError,
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
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: _busy ? null : _delete,
            child: Text(l10n.packageFileDelete),
          ),
        ],
      ),
    );
  }
}
