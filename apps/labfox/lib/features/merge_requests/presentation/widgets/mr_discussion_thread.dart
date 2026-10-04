import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import '../../../comments/presentation/widgets/comment_thread.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_discussions_controller.dart';

/// Grouped MR replies with explicit pagination and the shared note composer.
class MrDiscussionThread extends ConsumerWidget {
  const MrDiscussionThread({
    required this.projectId,
    required this.iid,
    super.key,
  });
  final int projectId;
  final int iid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arg = MergeRequestRef(projectId: projectId, iid: iid);
    final session = ref.watch(commentsRepositoryProvider);
    final discussions = ref.watch(mrDiscussionsControllerProvider(arg));
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LabFoxBreakpoints.desktop),
        child: CommentThread(
          // Replacement disposes the old composer and pending pagination UI. Mere
          // page reads and window resizing preserve the current draft and errors.
          key: ValueKey((arg, session)),
          type: NoteableType.mergeRequest,
          projectId: projectId,
          iid: iid,
          postingAllowed:
              discussions.hasValue &&
              !discussions.isLoading &&
              !discussions.hasError,
          onPost: (body) => ref
              .read(mrDiscussionsControllerProvider(arg).notifier)
              .post(body),
          conversation: discussions.when(
            skipLoadingOnRefresh: false,
            skipLoadingOnReload: false,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.commentsError),
                TextButton(
                  key: const ValueKey('mr-discussions-retry'),
                  onPressed: () =>
                      ref.invalidate(mrDiscussionsControllerProvider(arg)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
            data: (page) {
              final groups = page.items
                  .where((group) => group.notes.any((note) => !note.isSystem))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (groups.isEmpty)
                    Text(
                      page.hasMore
                          ? l10n.mrDiscussionsPartial
                          : l10n.commentsEmpty,
                    ),
                  for (final group in groups)
                    _DiscussionView(
                      key: ValueKey('mr-discussion-${group.id}'),
                      discussion: group,
                    ),
                  if (page.hasMore)
                    _MoreDiscussions(key: ValueKey((arg, session)), arg: arg),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MoreDiscussions extends ConsumerStatefulWidget {
  const _MoreDiscussions({required this.arg, super.key});
  final MergeRequestRef arg;
  @override
  ConsumerState<_MoreDiscussions> createState() => _MoreDiscussionsState();
}

class _MoreDiscussionsState extends ConsumerState<_MoreDiscussions> {
  bool _loading = false;
  bool _failed = false;
  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await ref
          .read(mrDiscussionsControllerProvider(widget.arg).notifier)
          .loadMore();
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (_failed) Text(l10n.mrDiscussionsMoreError),
        TextButton(
          key: const ValueKey('mr-discussions-more'),
          onPressed: _loading ? null : _load,
          child: _loading
              ? const CircularProgressIndicator()
              : Text(_failed ? l10n.retry : l10n.mrDiscussionsLoadMore),
        ),
      ],
    );
  }
}

class _DiscussionView extends StatelessWidget {
  const _DiscussionView({required this.discussion, super.key});
  final Discussion discussion;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notes = discussion.notes.where((note) => !note.isSystem).toList();
    final resolvable = discussion.notes
        .where((note) => note.resolvable == true)
        .toList();
    final bool? resolved = resolvable.any((note) => note.resolved == false)
        ? false
        : resolvable.isNotEmpty &&
              resolvable.every((note) => note.resolved == true)
        ? true
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (resolved != null)
              Text(
                resolved
                    ? l10n.mrDiscussionResolved
                    : l10n.mrDiscussionUnresolved,
                style: theme.textTheme.labelLarge,
              ),
            for (final note in notes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.author?.username ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        if (note.createdAt != null)
                          Flexible(
                            child: Text(
                              DateFormat.yMMMd(
                                l10n.localeName,
                              ).add_jm().format(note.createdAt!.toLocal()),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: LabFoxSpacing.xs),
                    MarkdownViewer(data: note.body),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
