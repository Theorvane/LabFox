import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

/// Literal server code with an optional caller-owned action after the preview.
class MrSuggestionPreview extends StatefulWidget {
  const MrSuggestionPreview({
    required this.noteId,
    required this.suggestion,
    this.action,
    this.initiallyExpanded = false,
    super.key,
  });
  final int noteId;
  final Suggestion suggestion;
  final Widget? action;
  final bool initiallyExpanded;
  @override
  State<MrSuggestionPreview> createState() => _SuggestionPreviewState();
}

class _SuggestionPreviewState extends State<MrSuggestionPreview> {
  late bool _expanded;
  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggestion = widget.suggestion;
    final format = NumberFormat.decimalPattern(l10n.localeName);
    final from = suggestion.fromLine, to = suggestion.toLine;
    final knownRange = from != null && to != null && from > 0 && to >= from;
    final applied = switch (suggestion.applied) {
      true => l10n.mrSuggestionApplied,
      false => l10n.mrSuggestionNotApplied,
      null => l10n.mrSuggestionAppliedUnknown,
    };
    final applicable = switch (suggestion.patchApplicable) {
      true => l10n.mrSuggestionApplicable,
      false => l10n.mrSuggestionNotApplicable,
      null => l10n.mrSuggestionApplicableUnknown,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.mrSuggestionTitle(format.format(suggestion.id)),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            knownRange
                ? l10n.mrSuggestionRange(format.format(from), format.format(to))
                : l10n.mrSuggestionRangeUnknown,
          ),
          Text(applied),
          Text(applicable),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: ValueKey(
                'mr-suggestion-${_expanded ? 'hide' : 'open'}-${widget.noteId}-${suggestion.id}',
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? l10n.mrSuggestionHideButton
                    : l10n.mrSuggestionViewButton,
              ),
            ),
          ),
          if (_expanded) ...[
            _CodePreview(
              label: l10n.mrSuggestionOriginal,
              content: suggestion.fromContent,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            _CodePreview(
              label: l10n.mrSuggestionReplacement,
              content: suggestion.toContent,
            ),
            ?widget.action,
          ],
        ],
      ),
    );
  }
}

class _CodePreview extends StatelessWidget {
  const _CodePreview({required this.label, required this.content});
  final String label;
  final String? content;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: LabFoxSpacing.xs),
        if (content == null)
          Text(l10n.mrSuggestionContentUnknown)
        else if (content!.isEmpty)
          Text(l10n.mrSuggestionContentEmpty)
        else
          Container(
            padding: const EdgeInsets.all(LabFoxSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(LabFoxRadius.sm),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  content!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
