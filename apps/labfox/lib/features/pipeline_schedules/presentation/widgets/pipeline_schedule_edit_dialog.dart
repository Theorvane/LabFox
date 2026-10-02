import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/pipeline_schedules_controller.dart';

/// Edits timing metadata; other schedule settings are deliberately preserved.
class PipelineScheduleEditDialog extends ConsumerStatefulWidget {
  const PipelineScheduleEditDialog({
    required this.schedule,
    required this.scheduleRef,
    super.key,
  });
  final PipelineSchedule schedule;
  final PipelineScheduleRef scheduleRef;

  @override
  ConsumerState<PipelineScheduleEditDialog> createState() => _EditState();
}

class _EditState extends ConsumerState<PipelineScheduleEditDialog> {
  final _form = GlobalKey<FormState>();
  late final _description = TextEditingController(
    text: widget.schedule.description,
  );
  late final _cron = TextEditingController(text: widget.schedule.cron);
  late final _timezone = TextEditingController(
    text: widget.schedule.cronTimezone ?? '',
  );
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _description.dispose();
    _cron.dispose();
    _timezone.dispose();
    super.dispose();
  }

  String? _changed(TextEditingController controller, String? original) {
    final value = controller.text.trim();
    return value == (original ?? '').trim() ? null : value;
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    final description = _changed(_description, widget.schedule.description);
    final cron = _changed(_cron, widget.schedule.cron);
    final timezone = _changed(_timezone, widget.schedule.cronTimezone);
    if (description == null && cron == null && timezone == null) {
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
            pipelineScheduleEditControllerProvider(widget.scheduleRef).notifier,
          )
          .save(description: description, cron: cron, cronTimezone: timezone);
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
    String? requiredValue(String? value) => (value ?? '').trim().isEmpty
        ? l10n.pipelineScheduleFieldRequired
        : null;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.pipelineScheduleEdit),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _description,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: l10n.pipelineScheduleDescription,
                    ),
                    validator: requiredValue,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  TextFormField(
                    controller: _cron,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: l10n.pipelineScheduleCron,
                    ),
                    validator: requiredValue,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  TextFormField(
                    controller: _timezone,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: l10n.pipelineScheduleTimezone,
                    ),
                    validator: (value) =>
                        _changed(_timezone, widget.schedule.cronTimezone) ==
                            null
                        ? null
                        : requiredValue(value),
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l10n.pipelineScheduleEditHint),
                  if (_failed) ...[
                    const SizedBox(height: LabFoxSpacing.md),
                    Text(
                      l10n.pipelineScheduleEditError,
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
            child: Text(l10n.pipelineScheduleSave),
          ),
        ],
      ),
    );
  }
}
