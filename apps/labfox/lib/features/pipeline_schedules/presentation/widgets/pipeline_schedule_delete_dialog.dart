import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/pipeline_schedules_controller.dart';

/// Requires confirmation and retains failed deletions for an explicit retry.
class PipelineScheduleDeleteDialog extends ConsumerStatefulWidget {
  const PipelineScheduleDeleteDialog({
    required this.scheduleRef,
    required this.description,
    super.key,
  });
  final PipelineScheduleRef scheduleRef;
  final String description;

  @override
  ConsumerState<PipelineScheduleDeleteDialog> createState() => _DeleteState();
}

class _DeleteState extends ConsumerState<PipelineScheduleDeleteDialog> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _delete() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(
            pipelineScheduleDeleteControllerProvider(
              widget.scheduleRef,
            ).notifier,
          )
          .delete();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.pipelineScheduleDeleteConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.pipelineScheduleDeleteConfirmBody(widget.description)),
              if (_failed) ...[
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  l10n.pipelineScheduleDeleteError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_busy) ...[
                const SizedBox(height: LabFoxSpacing.md),
                const LinearProgressIndicator(),
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
            onPressed: _busy ? null : _delete,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.pipelineScheduleDelete),
          ),
        ],
      ),
    );
  }
}
