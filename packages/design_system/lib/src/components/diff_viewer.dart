import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../tokens/icon_size.dart';
import '../tokens/icons.dart';
import '../tokens/spacing.dart';

/// Renders one file's unified diff.
///
/// Each hunk's lines are shown with a +/- gutter and add/remove colours; the
/// gutter carries the change type so it survives greyscale and colour
/// blindness. Long lines scroll horizontally rather than wrap, so alignment
/// holds. A binary file shows a placeholder instead of an empty body.
class DiffViewer extends StatelessWidget {
  const DiffViewer({
    required this.file,
    this.binaryLabel = 'Binary file',
    this.omittedLabel = 'Diff not shown',
    this.highlightedLine,
    this.highlightedLines = const [],
    this.highlightedLineLabel,
    this.focusOnHighlightedLine = false,
    this.onLineSelected,
    this.canSelectLine,
    this.lineActionLabel,
    super.key,
  });

  final FileDiff file;

  /// Text shown for a binary file; the caller localizes it.
  final String binaryLabel;

  /// Text shown when GitLab omitted a text diff because it was too large or
  /// collapsed. Distinct from [binaryLabel] so a truncated source file is not
  /// mislabelled as binary.
  final String omittedLabel;

  /// A line from this file to mark with a non-color, accessible indicator.
  final DiffLine? highlightedLine;

  /// Additional literal members from this file; foreign/duplicate lines are ignored.
  final List<DiffLine> highlightedLines;
  final String? highlightedLineLabel;

  /// Show only containing hunks when supplied highlighted lines belong to this file.
  final bool focusOnHighlightedLine;

  /// Optional caller-localized action on eligible original lines.
  final ValueChanged<DiffLine>? onLineSelected;
  final bool Function(DiffLine)? canSelectLine;
  final String? lineActionLabel;

  @override
  Widget build(BuildContext context) {
    if (file.isBinary || file.isOmitted) {
      return Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Text(
          file.isOmitted ? omittedLabel : binaryLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final marked = Set<DiffLine>.identity()..addAll(highlightedLines);
    if (highlightedLine != null) marked.add(highlightedLine!);
    final matching = file.hunks.where(
      (hunk) => hunk.lines.any(marked.contains),
    );
    final hunks = focusOnHighlightedLine && matching.isNotEmpty
        ? matching
        : file.hunks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final hunk in hunks) ...[
          _HunkHeader(header: hunk.header),
          for (final line in hunk.lines)
            _DiffLineRow(
              line: line,
              onSelected:
                  onLineSelected != null &&
                      lineActionLabel != null &&
                      (canSelectLine?.call(line) ?? true)
                  ? () => onLineSelected!(line)
                  : null,
              actionLabel: lineActionLabel,
              showHighlightGutter: marked.isNotEmpty,
              highlighted: marked.contains(line),
              highlightedLabel: highlightedLineLabel,
            ),
        ],
      ],
    );
  }
}

class _HunkHeader extends StatelessWidget {
  const _HunkHeader({required this.header});

  final String header;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: LabFoxSpacing.sm,
        vertical: 2,
      ),
      child: Text(
        header,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DiffLineRow extends StatelessWidget {
  const _DiffLineRow({
    required this.line,
    this.showHighlightGutter = false,
    this.highlighted = false,
    this.highlightedLabel,
    this.onSelected,
    this.actionLabel,
  });

  final DiffLine line;
  final bool showHighlightGutter;
  final bool highlighted;
  final String? highlightedLabel;
  final VoidCallback? onSelected;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (background, marker) = switch (line.type) {
      DiffLineType.added => (
        isDark ? const Color(0x2600FF00) : const Color(0x1A1F8B4C),
        '+',
      ),
      DiffLineType.removed => (
        isDark ? const Color(0x26FF0000) : const Color(0x1AD1293D),
        '-',
      ),
      DiffLineType.context => (Colors.transparent, ' '),
    };

    final row = Container(
      decoration: BoxDecoration(
        color: background,
        border: showHighlightGutter
            ? Border(
                left: BorderSide(
                  color: highlighted
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: LabFoxSpacing.xs,
                ),
              )
            : null,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHighlightGutter)
              SizedBox(
                width: LabFoxIconSize.md,
                child: highlighted
                    ? Icon(
                        LabFoxIcons.comment,
                        size: LabFoxIconSize.sm,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            if (onSelected != null)
              IconButton(
                onPressed: onSelected,
                tooltip: actionLabel,
                icon: const Icon(LabFoxIcons.comment, size: LabFoxIconSize.sm),
                visualDensity: VisualDensity.standard,
              ),
            _gutter(line.oldLine),
            _gutter(line.newLine),
            SizedBox(
              width: 16,
              child: Text(
                marker,
                style: _mono(context),
                textAlign: TextAlign.center,
              ),
            ),
            Text('${line.text} ', style: _mono(context)),
          ],
        ),
      ),
    );
    return highlighted
        ? Semantics(label: highlightedLabel, selected: true, child: row)
        : row;
  }

  Widget _gutter(int? number) => Container(
    width: 44,
    padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.xs),
    child: Text(
      number?.toString() ?? '',
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
  );

  TextStyle _mono(BuildContext context) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
