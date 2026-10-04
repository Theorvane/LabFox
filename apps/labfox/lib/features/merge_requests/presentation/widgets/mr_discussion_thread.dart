import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../comments/data/discussion_resolution.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import '../../../comments/presentation/widgets/comment_thread.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_discussions_controller.dart';
import 'mr_discussion_position_context.dart';

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
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LabFoxBreakpoints.desktop),
        child: _Conversation(
          key: ValueKey((arg, session)),
          arg: arg,
          discussions: discussions,
        ),
      ),
    );
  }
}

class _Conversation extends ConsumerStatefulWidget {
  const _Conversation({
    required this.arg,
    required this.discussions,
    super.key,
  });
  final MergeRequestRef arg;
  final AsyncValue<Paginated<Discussion>> discussions;
  @override
  ConsumerState<_Conversation> createState() => _ConversationState();
}

class _ConversationState extends ConsumerState<_Conversation> {
  String? _replyId;
  bool _replyPosting = false;
  bool _topPosting = false;
  String? _resolutionId;
  String? _resolutionErrorId;
  bool _resolutionForbidden = false;

  Future<void> _setResolved(String id, bool resolved) async {
    if (_resolutionId != null || _topPosting || _replyId != null) return;
    setState(() {
      _resolutionId = id;
      _resolutionErrorId = null;
    });
    try {
      await ref
          .read(mrDiscussionsControllerProvider(widget.arg).notifier)
          .setResolved(discussionId: id, resolved: resolved);
    } on GitLabException catch (error) {
      if (mounted) {
        setState(() {
          _resolutionErrorId = id;
          _resolutionForbidden =
              error is GitLabForbiddenException || error is GitLabAuthException;
        });
      }
    } finally {
      if (mounted) setState(() => _resolutionId = null);
    }
  }

  @override
  void didUpdateWidget(covariant _Conversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = widget.discussions;
    if (!value.isLoading &&
        !value.hasError &&
        !value.value!.items.any(
          (group) =>
              group.id == _replyId && group.notes.any((note) => !note.isSystem),
        )) {
      _replyId = null;
    }
  }

  Future<bool> _post(String body) async {
    if (_topPosting || _replyId != null || _resolutionId != null) return false;
    setState(() => _topPosting = true);
    try {
      return await ref
          .read(mrDiscussionsControllerProvider(widget.arg).notifier)
          .post(body);
    } finally {
      if (mounted) setState(() => _topPosting = false);
    }
  }

  Future<bool> _reply(String body) async {
    final id = _replyId;
    if (id == null || _replyPosting || _topPosting || _resolutionId != null) {
      return false;
    }
    setState(() => _replyPosting = true);
    try {
      final posted = await ref
          .read(mrDiscussionsControllerProvider(widget.arg).notifier)
          .reply(discussionId: id, body: body);
      if (mounted && posted) setState(() => _replyId = null);
      return posted;
    } finally {
      if (mounted) setState(() => _replyPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final discussions = widget.discussions;
    final canPost =
        discussions.hasValue && !discussions.isLoading && !discussions.hasError;
    return CommentThread(
      type: NoteableType.mergeRequest,
      projectId: widget.arg.projectId,
      iid: widget.arg.iid,
      postingAllowed:
          canPost &&
          _replyId == null &&
          !_replyPosting &&
          _resolutionId == null,
      onPost: _post,
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
                  ref.invalidate(mrDiscussionsControllerProvider(widget.arg)),
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
                  page.hasMore ? l10n.mrDiscussionsPartial : l10n.commentsEmpty,
                ),
              for (final group in groups)
                _DiscussionView(
                  key: ValueKey('mr-discussion-${group.id}'),
                  discussion: group,
                  resource: widget.arg,
                  resolutionControl: discussionResolution(group) == null
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_resolutionErrorId == group.id)
                              Text(
                                _resolutionForbidden
                                    ? l10n.mrDiscussionResolveForbidden
                                    : l10n.mrDiscussionResolveError,
                              ),
                            TextButton(
                              key: ValueKey(
                                'mr-discussion-resolution-${group.id}',
                              ),
                              onPressed:
                                  canPost &&
                                      _replyId == null &&
                                      !_topPosting &&
                                      !_replyPosting &&
                                      _resolutionId == null
                                  ? () => _setResolved(
                                      group.id,
                                      !discussionResolution(group)!,
                                    )
                                  : null,
                              child: _resolutionId == group.id
                                  ? const SizedBox(
                                      width: LabFoxSpacing.lg,
                                      height: LabFoxSpacing.lg,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      discussionResolution(group)!
                                          ? l10n.mrDiscussionReopenButton
                                          : l10n.mrDiscussionResolveButton,
                                    ),
                            ),
                          ],
                        ),
                  replyControl: _replyId == group.id
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CommentThread(
                              key: const ValueKey('mr-reply-composer'),
                              type: NoteableType.mergeRequest,
                              projectId: widget.arg.projectId,
                              iid: widget.arg.iid,
                              heading: l10n.mrDiscussionReplyTitle,
                              composerHint: l10n.mrDiscussionReplyHint,
                              composerSubmit: l10n.mrDiscussionReplyButton,
                              conversation: const SizedBox.shrink(),
                              onPost: _reply,
                              postingAllowed: canPost,
                              preserveWhitespace: true,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                key: const ValueKey('mr-reply-cancel'),
                                onPressed: _replyPosting
                                    ? null
                                    : () => setState(() => _replyId = null),
                                child: Text(l10n.cancel),
                              ),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            key: ValueKey('mr-discussion-reply-${group.id}'),
                            onPressed:
                                canPost &&
                                    _replyId == null &&
                                    !_topPosting &&
                                    !_replyPosting &&
                                    _resolutionId == null
                                ? () => setState(() => _replyId = group.id)
                                : null,
                            child: Text(l10n.mrDiscussionReplyButton),
                          ),
                        ),
                ),
              if (page.hasMore) _MoreDiscussions(arg: widget.arg),
            ],
          );
        },
      ),
    );
  }
}

class _MoreDiscussions extends ConsumerStatefulWidget {
  const _MoreDiscussions({required this.arg});
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
  const _DiscussionView({
    required this.discussion,
    required this.resource,
    required this.replyControl,
    this.resolutionControl,
    super.key,
  });
  final Discussion discussion;
  final MergeRequestRef resource;
  final Widget replyControl;
  final Widget? resolutionControl;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notes = discussion.notes.where((note) => !note.isSystem).toList();
    final resolved = discussionResolution(discussion);
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
                    if (note.position != null)
                      MrDiscussionPositionContext(
                        key: ValueKey((resource, note.id, note.position)),
                        projectId: resource.projectId,
                        iid: resource.iid,
                        noteId: note.id,
                        position: note.position!,
                      ),
                  ],
                ),
              ),
            replyControl,
            ?resolutionControl,
          ],
        ),
      ),
    );
  }
}
