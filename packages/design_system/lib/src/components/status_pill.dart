import 'package:flutter/material.dart';

import '../tokens/icon_size.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/status_colors.dart';
import '../tokens/typography.dart';

/// A soft status chip — a rounded pill filled with a status container colour,
/// its label (and optional dot or icon) in the matching foreground.
///
/// This is the redesign's state marker: open / merged / closed / running and
/// so on. Colour is never the only signal — the label carries the meaning — so
/// a dot or icon is optional emphasis, not a replacement for words.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.colors,
    this.icon,
    this.dot = false,
    this.filled = false,
    super.key,
  });

  final String label;

  /// The foreground / container pair, usually from
  /// `LabFoxStatusColors.of(context)`.
  final StatusColor colors;

  /// An optional leading icon, in the foreground colour.
  final IconData? icon;

  /// A small leading dot in the foreground colour. Ignored when [icon] is set.
  final bool dot;

  /// Fills the pill with the status foreground colour and renders the label in
  /// a contrasting black or white — the emphatic form a detail header uses,
  /// where the state is the headline rather than row metadata.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled ? colors.foreground : colors.container;
    final foreground = filled
        ? (background.computeLuminance() > 0.5 ? Colors.black : Colors.white)
        : colors.foreground;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(LabFoxRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LabFoxSpacing.sm,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(icon, size: LabFoxIconSize.xs, color: foreground),
              )
            else if (dot)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foreground,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 7, height: 7),
                ),
              ),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LabFoxTextRoles.of(
                  context,
                ).chipLabel.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
