import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/releases_controller.dart';

class ReleaseMilestonesDialog extends ConsumerStatefulWidget {
  const ReleaseMilestonesDialog({
    required this.keyRef,
    required this.release,
    super.key,
  });
  final ReleaseRef keyRef;
  final GitLabRelease release;

  @override
  ConsumerState<ReleaseMilestonesDialog> createState() =>
      _ReleaseMilestonesDialogState();
}

class _ReleaseMilestonesDialogState
    extends ConsumerState<ReleaseMilestonesDialog> {
  final _title = TextEditingController();
  late final List<String> _titles;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titles = widget.release.milestones.map((m) => m.title).toList();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool _add() {
    final l10n = AppLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty || _titles.contains(title)) {
      setState(
        () => _error = title.isEmpty
            ? l10n.releaseMilestoneTitleRequired
            : l10n.releaseMilestoneDuplicate,
      );
      return false;
    }
    setState(() {
      _titles.add(title);
      _title.clear();
      _error = null;
    });
    return true;
  }

  Future<void> _save() async {
    if (_title.text.trim().isNotEmpty && !_add()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(releaseMilestonesControllerProvider(widget.keyRef).notifier)
          .save(_titles);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = AppLocalizations.of(context).releaseMilestonesError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.releaseMilestonesEdit),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.releaseMilestonesHelp),
            const SizedBox(height: LabFoxSpacing.sm),
            Wrap(
              spacing: LabFoxSpacing.sm,
              runSpacing: LabFoxSpacing.sm,
              children: [
                for (final title in _titles)
                  InputChip(
                    label: Text(title),
                    deleteButtonTooltipMessage: l10n.releaseMilestoneRemove(
                      title,
                    ),
                    onDeleted: _saving
                        ? null
                        : () => setState(() => _titles.remove(title)),
                  ),
              ],
            ),
            TextField(
              controller: _title,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: l10n.releaseMilestoneTitle,
              ),
              onSubmitted: _saving ? null : (_) => _add(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _saving ? null : _add,
                child: Text(l10n.releaseMilestoneAdd),
              ),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(l10n.releaseMilestonesSave),
        ),
      ],
    );
  }
}
