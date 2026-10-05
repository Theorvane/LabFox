import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_draft_notes_provider.dart';
import '../controllers/mr_pending_review_controller.dart';

/// A private, read-only view; identity always comes from current MR detail.
class MrPendingReviewPanel extends ConsumerWidget {
  const MrPendingReviewPanel({required this.mergeRequest, super.key});
  final MergeRequestRef mergeRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    if (account == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(mergeRequestsRepositoryProvider).unwrapPrevious();
    final detail = ref
        .watch(mergeRequestControllerProvider(mergeRequest))
        .unwrapPrevious();
    void reloadDetail() {
      ref.invalidate(mergeRequestsRepositoryProvider);
      ref.invalidate(mergeRequestControllerProvider(mergeRequest));
    }

    final mr = detail.valueOrNull;
    Widget contents;
    if (session.isLoading || detail.isLoading) {
      contents = _Loading(label: l10n.mrPendingReviewLoading);
    } else if (session.hasError ||
        detail.hasError ||
        session.valueOrNull == null ||
        mr == null ||
        mr.id < 1 ||
        mr.iid != mergeRequest.iid ||
        (mr.projectId != null && mr.projectId != mergeRequest.projectId)) {
      contents = _ReadError(onRetry: reloadDetail);
    } else {
      final query = MrPendingReviewQuery(
        mergeRequest: mergeRequest,
        mergeRequestId: mr.id,
        requireCurrentDetail: true,
      );
      final drafts = ref.watch(mrPendingReviewProvider(query));
      void refresh() =>
          ref.read(mrPendingReviewControllerProvider(query).notifier).refresh();
      contents = drafts.when(
        loading: () => _Loading(label: l10n.mrPendingReviewLoading),
        error: (_, _) => _ReadError(onRetry: refresh),
        data: (value) => _Loaded(
          key: ValueKey((
            query,
            account,
            ref.watch(mrDraftNotesRepositoryProvider).valueOrNull,
          )),
          value: value,
          onRefresh: refresh,
          onLoadMore: () async {
            try {
              await ref
                  .read(mrPendingReviewControllerProvider(query).notifier)
                  .loadMore();
            } on GitLabException {
              // The controller exposes the current error; no separate toast.
            }
          },
        ),
      );
    }
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LabFoxBreakpoints.desktop),
        child: Card(
          key: const ValueKey('mr-pending-panel'),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mrPendingReviewTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: LabFoxSpacing.xs),
                Text(
                  l10n.mrPendingReviewPrivate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                contents,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LinearProgressIndicator(semanticsLabel: label),
      const SizedBox(height: LabFoxSpacing.sm),
      Text(label),
    ],
  );
}

class _ReadError extends StatelessWidget {
  const _ReadError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.mrPendingReviewError),
        const SizedBox(height: LabFoxSpacing.sm),
        OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
      ],
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.value,
    required this.onRefresh,
    required this.onLoadMore,
    super.key,
  });
  final MrPendingReviewDrafts value;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.mrPendingReviewCount(value.items.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: l10n.mrPendingReviewRefresh,
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (value.items.isEmpty && value.isComplete)
          Text(l10n.mrPendingReviewEmpty),
        if (value.items.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: LabFoxSpacing.minTouchTarget * 10,
            ),
            child: ListView.separated(
              key: const ValueKey('mr-pending-notes-list'),
              primary: false,
              shrinkWrap: true,
              itemCount: value.items.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: LabFoxSpacing.xl),
              itemBuilder: (context, index) => _Draft(
                key: ValueKey(value.items[index].id),
                draft: value.items[index],
              ),
            ),
          ),
        if (!value.isComplete) ...[
          const SizedBox(height: LabFoxSpacing.sm),
          Text(
            l10n.mrPendingReviewMore,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: LabFoxSpacing.sm),
          if (value.isLoadingMore) ...[
            LinearProgressIndicator(
              semanticsLabel: l10n.mrPendingReviewLoading,
            ),
            const SizedBox(height: LabFoxSpacing.sm),
          ],
          OutlinedButton(
            key: const ValueKey('mr-pending-load-more'),
            onPressed: value.isLoadingMore ? null : onLoadMore,
            child: Text(l10n.mrPendingReviewLoadMore),
          ),
        ],
      ],
    );
  }
}

class _Draft extends StatelessWidget {
  const _Draft({required this.draft, super.key});
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
