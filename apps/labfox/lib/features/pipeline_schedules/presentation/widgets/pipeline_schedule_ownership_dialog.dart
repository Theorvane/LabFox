import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/pipeline_schedule_ownership_controller.dart';
import '../controllers/pipeline_schedules_controller.dart';

class PipelineScheduleOwnershipDialog extends ConsumerStatefulWidget {
  const PipelineScheduleOwnershipDialog({
    required this.scheduleRef,
    required this.description,
    super.key,
  });
  final PipelineScheduleRef scheduleRef;
  final String description;

  @override
  ConsumerState<PipelineScheduleOwnershipDialog> createState() =>
      _OwnershipState();
}

class _OwnershipState extends ConsumerState<PipelineScheduleOwnershipDialog> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _takeOwnership() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(
            pipelineScheduleOwnershipControllerProvider(
              widget.scheduleRef,
            ).notifier,
          )
          .takeOwnership();
      if (mounted) Navigator.of(context).pop();
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
        title: Text(l10n.pipelineScheduleOwnershipConfirmTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pipelineScheduleOwnershipConfirmBody(widget.description),
              ),
              if (_failed) ...[
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  l10n.pipelineScheduleOwnershipError,
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
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _busy ? null : _takeOwnership,
            child: Text(l10n.pipelineScheduleTakeOwnership),
          ),
        ],
      ),
    );
  }
}
