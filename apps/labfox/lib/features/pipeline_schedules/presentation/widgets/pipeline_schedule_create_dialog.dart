import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/pipeline_schedule_create_controller.dart';

class PipelineScheduleCreateDialog extends ConsumerStatefulWidget {
  const PipelineScheduleCreateDialog({required this.projectId, super.key});
  final int projectId;

  @override
  ConsumerState<PipelineScheduleCreateDialog> createState() => _CreateState();
}

class _CreateState extends ConsumerState<PipelineScheduleCreateDialog> {
  final _form = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _ref = TextEditingController();
  final _cron = TextEditingController();
  final _timezone = TextEditingController();
  bool _active = true;
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _description.dispose();
    _ref.dispose();
    _cron.dispose();
    _timezone.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final timezone = _timezone.text.trim();
      final schedule = await ref
          .read(
            pipelineScheduleCreateControllerProvider(widget.projectId).notifier,
          )
          .create(
            description: _description.text.trim(),
            ref: _ref.text.trim(),
            cron: _cron.text.trim(),
            cronTimezone: timezone.isEmpty ? null : timezone,
            active: _active,
          );
      if (mounted) Navigator.of(context).pop(schedule.id);
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
        ? l10n.pipelineScheduleCreateFieldRequired
        : null;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.pipelineScheduleCreateTitle),
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
                      labelText: l10n.pipelineScheduleCreateDescription,
                    ),
                    validator: requiredValue,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  TextFormField(
                    controller: _ref,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: l10n.pipelineScheduleRef,
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
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.pipelineScheduleCreateActive),
                    value: _active,
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _active = value),
                  ),
                  Text(l10n.pipelineScheduleCreateHint),
                  if (_failed) ...[
                    const SizedBox(height: LabFoxSpacing.md),
                    Text(
                      l10n.pipelineScheduleCreateError,
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
            onPressed: _busy ? null : _create,
            child: Text(l10n.pipelineScheduleCreate),
          ),
        ],
      ),
    );
  }
}
