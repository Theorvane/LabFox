import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/releases_controller.dart';

/// Edits an instant in device local time; the controller sends UTC to GitLab.
class ReleaseScheduleDialog extends ConsumerStatefulWidget {
  const ReleaseScheduleDialog({
    required this.keyRef,
    required this.releasedAt,
    super.key,
  });
  final ReleaseRef keyRef;
  final DateTime? releasedAt;

  @override
  ConsumerState<ReleaseScheduleDialog> createState() =>
      _ReleaseScheduleDialogState();
}

class _ReleaseScheduleDialogState extends ConsumerState<ReleaseScheduleDialog> {
  late DateTime _draft;
  late DateTime _initial;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _draft = (widget.releasedAt ?? DateTime.now()).toLocal();
    _initial = _draft;
  }

  Future<void> _date() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft,
      firstDate: DateTime(_draft.year < 1900 ? _draft.year : 1900),
      lastDate: DateTime(_draft.year > 9998 ? _draft.year : 9998, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(
      () => _draft = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _draft.hour,
        _draft.minute,
        _draft.second,
        _draft.millisecond,
        _draft.microsecond,
      ),
    );
  }

  Future<void> _time() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_draft),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (!mounted || picked == null) return;
    // Reconfirming an unchanged minute must not truncate the original seconds.
    if (picked == TimeOfDay.fromDateTime(_draft)) return;
    setState(
      () => _draft = DateTime(
        _draft.year,
        _draft.month,
        _draft.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (_draft.isAtSameMomentAs(_initial)) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(releaseScheduleControllerProvider(widget.keyRef).notifier)
          .save(_draft);
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
    final locale = Localizations.localeOf(context).toString();
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        title: Text(l10n.releaseScheduleEdit),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.releaseScheduleHelp(_draft.timeZoneName)),
              const SizedBox(height: LabFoxSpacing.md),
              Text(DateFormat.yMMMd(locale).format(_draft)),
              TextButton(
                onPressed: _busy ? null : _date,
                child: Text(l10n.releaseScheduleChangeDate),
              ),
              Text(TimeOfDay.fromDateTime(_draft).format(context)),
              TextButton(
                onPressed: _busy ? null : _time,
                child: Text(l10n.releaseScheduleChangeTime),
              ),
              if (_failed)
                Text(
                  l10n.releaseScheduleError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(l10n.releaseScheduleSave),
          ),
        ],
      ),
    );
  }
}
