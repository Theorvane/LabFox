import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/pipeline_schedule_execution_controller.dart';
import '../controllers/pipeline_schedules_controller.dart';

class PipelineScheduleExecutionDialog extends ConsumerStatefulWidget {
  const PipelineScheduleExecutionDialog({
    required this.scheduleRef,
    required this.schedule,
    super.key,
  });
  final PipelineScheduleRef scheduleRef;
  final PipelineSchedule schedule;

  @override
  ConsumerState<PipelineScheduleExecutionDialog> createState() =>
      _ExecutionState();
}

class _ExecutionState extends ConsumerState<PipelineScheduleExecutionDialog> {
  final _form = GlobalKey<FormState>();
  late final _ref = TextEditingController(text: widget.schedule.ref);
  late bool _active = widget.schedule.active;
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _ref.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    final value = _ref.text.trim();
    final changedRef = value == widget.schedule.ref.trim() ? null : value;
    final changedActive = _active == widget.schedule.active ? null : _active;
    if (changedRef == null && changedActive == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(
            pipelineScheduleExecutionControllerProvider(
              widget.scheduleRef,
            ).notifier,
          )
          .save(ref: changedRef, active: changedActive);
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
        title: Text(l10n.pipelineScheduleExecutionEdit),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _ref,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: l10n.pipelineScheduleRef,
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? l10n.pipelineScheduleExecutionRefRequired
                        : null,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.pipelineScheduleExecutionActive),
                    value: _active,
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _active = value),
                  ),
                  Text(l10n.pipelineScheduleExecutionHint),
                  if (_failed) ...[
                    const SizedBox(height: LabFoxSpacing.md),
                    Text(
                      l10n.pipelineScheduleExecutionError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (_busy) ...[
                    const SizedBox(height: LabFoxSpacing.md),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(l10n.pipelineScheduleExecutionSave),
          ),
        ],
      ),
    );
  }
}
