import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/release_milestone_picker_controller.dart';

/// Returns exact project milestone titles without mutating a release.
class ReleaseMilestonePickerDialog extends ConsumerStatefulWidget {
  const ReleaseMilestonePickerDialog({
    required this.projectId,
    this.selectedTitles = const [],
    super.key,
  });
  final int projectId;
  final List<String> selectedTitles;

  @override
  ConsumerState<ReleaseMilestonePickerDialog> createState() =>
      _ReleaseMilestonePickerDialogState();
}

class _ReleaseMilestonePickerDialogState
    extends ConsumerState<ReleaseMilestonePickerDialog> {
  final _search = TextEditingController();
  late final Set<String> _selected = Set.of(widget.selectedTitles);
  String _query = '';
  bool _paging = false;
  bool _pageFailed = false;
  ReleaseMilestoneQuery get _key =>
      (projectId: widget.projectId, search: _query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _submitSearch() => setState(() {
    _query = _search.text.trim();
    _pageFailed = false;
    _paging = false;
  });

  Future<void> _more() async {
    final key = _key;
    setState(() {
      _paging = true;
      _pageFailed = false;
    });
    try {
      await ref
          .read(releaseMilestonePickerControllerProvider(key).notifier)
          .loadMore();
    } catch (_) {
      if (mounted && key == _key) setState(() => _pageFailed = true);
    } finally {
      if (mounted && key == _key) setState(() => _paging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final page = ref.watch(releaseMilestonePickerControllerProvider(_key));
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.releasePickerTitle),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      labelText: l10n.releasePickerSearch,
                    ),
                    onSubmitted: (_) => _submitSearch(),
                  ),
                ),
                IconButton(
                  tooltip: l10n.releasePickerSearch,
                  icon: const Icon(Icons.search),
                  onPressed: _submitSearch,
                ),
              ],
            ),
            Wrap(
              spacing: LabFoxSpacing.sm,
              children: [
                for (final title in _selected)
                  InputChip(
                    label: Text(title),
                    deleteButtonTooltipMessage: l10n.releasePickerRemove(title),
                    onDeleted: () => setState(() => _selected.remove(title)),
                  ),
              ],
            ),
            SizedBox(
              height: 240,
              child: page.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.releasePickerError),
                    TextButton(
                      onPressed: () => ref.invalidate(
                        releaseMilestonePickerControllerProvider(_key),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
                data: (data) => data.items.isEmpty
                    ? Center(child: Text(l10n.releasePickerEmpty))
                    : ListView(
                        children: [
                          for (final milestone in data.items)
                            CheckboxListTile(
                              value: _selected.contains(milestone.title),
                              title: Text(milestone.title),
                              onChanged: (selected) => setState(() {
                                if (selected == true) {
                                  _selected.add(milestone.title);
                                } else {
                                  _selected.remove(milestone.title);
                                }
                              }),
                            ),
                        ],
                      ),
              ),
            ),
            if (_pageFailed)
              Text(
                l10n.releasePickerError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (page.valueOrNull?.hasMore == true)
              TextButton(
                onPressed: _paging ? null : _more,
                child: Text(l10n.releasePickerMore),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(List<String>.unmodifiable(_selected)),
          child: Text(l10n.releasePickerUse),
        ),
      ],
    );
  }
}
