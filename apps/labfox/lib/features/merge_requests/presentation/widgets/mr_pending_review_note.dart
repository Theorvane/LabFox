import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

/// Exact saved Markdown and known original metadata, without remote rendering.
class MrPendingReviewNote extends StatelessWidget {
  const MrPendingReviewNote({required this.draft, super.key});
  final MergeRequestDraftNote draft;

  bool _positioned(DiffNotePosition? p) =>
      p != null &&
      (p.oldPath != null ||
          p.newPath != null ||
          p.oldLine != null ||
          p.newLine != null ||
          p.lineRange != null ||
          p.baseSha != null ||
          p.headSha != null ||
          p.startSha != null ||
          p.width != null ||
          p.height != null ||
          p.x != null ||
          p.y != null ||
          (p.positionType != null && p.positionType != 'text'));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = draft.position;
    final positioned = _positioned(p) || draft.lineCode != null;
    final badges = [
      if (draft.discussionId != null) l10n.mrPendingReviewReplyNote,
      if (draft.commitId != null) l10n.mrPendingReviewCommitNote,
      if (positioned)
        switch (p?.positionType) {
          'text' =>
            p?.lineRange == null
                ? l10n.mrPendingReviewTextNote
                : l10n.mrPendingReviewMultilineNote,
          'image' => l10n.mrPendingReviewImageNote,
          'file' => l10n.mrPendingReviewFileNote,
          _ => l10n.mrPendingReviewPositionedNote,
        },
      if (!positioned && draft.discussionId == null && draft.commitId == null)
        l10n.mrPendingReviewGeneralNote,
    ];
    final number = NumberFormat.decimalPattern(l10n.localeName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: LabFoxSpacing.sm,
          runSpacing: LabFoxSpacing.xs,
          children: [
            for (final badge in badges)
              Text(badge, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        if (draft.resolveDiscussion == true) ...[
          const SizedBox(height: LabFoxSpacing.xs),
          Text(
            l10n.mrPendingReviewResolve,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (draft.commitId != null)
          SelectableText(l10n.mrPendingReviewCommit(draft.commitId!)),
        if (positioned && p?.oldPath != null)
          SelectableText(l10n.mrPendingReviewOldPath(p!.oldPath!)),
        if (positioned && p?.newPath != null)
          SelectableText(l10n.mrPendingReviewNewPath(p!.newPath!)),
        // Parent coordinates of a multiline anchor are not its complete range.
        if (positioned && p?.positionType == 'text' && p?.lineRange == null)
          Wrap(
            spacing: LabFoxSpacing.sm,
            runSpacing: LabFoxSpacing.xs,
            children: [
              if (p?.oldLine != null)
                Text(l10n.mrPendingReviewOldLine(number.format(p!.oldLine))),
              if (p?.newLine != null)
                Text(l10n.mrPendingReviewNewLine(number.format(p!.newLine))),
            ],
          ),
        const SizedBox(height: LabFoxSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: LabFoxSpacing.minTouchTarget * 6,
          ),
          child: SingleChildScrollView(child: SelectableText(draft.note)),
        ),
      ],
    );
  }
}
