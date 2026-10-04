import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/comments_controller.dart';

/// A comment thread with a composer, for an issue or merge request.
///
/// System notes are filtered out so the thread reads as a conversation. Posting
/// shows a pending state and surfaces a 403 as an actionable message rather than
/// a raw error.
class CommentThread extends ConsumerStatefulWidget {
  const CommentThread({
    required this.type,
    required this.projectId,
    required this.iid,
    this.conversation,
    this.onPost,
    this.postingAllowed = true,
    this.heading,
    this.composerHint,
    this.composerSubmit,
    this.preserveWhitespace = false,
    super.key,
  });

  final NoteableType type;
  final int projectId;
  final int iid;

  /// A grouped conversation supplied by MR review while reusing the composer.
  final Widget? conversation;
  final Future<bool> Function(String body)? onPost;
  final bool postingAllowed;
  final String? heading;
  final String? composerHint;
  final String? composerSubmit;
  final bool preserveWhitespace;

  @override
  ConsumerState<CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends ConsumerState<CommentThread> {
  final _controller = TextEditingController();
  bool _posting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CommentsRef get _ref => CommentsRef(
    type: widget.type,
    projectId: widget.projectId,
    iid: widget.iid,
  );

  Future<void> _post() async {
    final body = widget.preserveWhitespace
        ? _controller.text
        : _controller.text.trim();
    if (body.trim().isEmpty || _posting || !widget.postingAllowed) {
      return;
    }
    setState(() {
      _posting = true;
      _error = null;
    });
    try {
      if (widget.onPost case final post?) {
        if (!await post(body)) return;
      } else {
        await ref.read(commentsControllerProvider(_ref).notifier).post(body);
      }
      if (!mounted) {
        return;
      }
      _controller.clear();
    } on GitLabException catch (error) {
      // The user may have left the screen while the post was in flight; touching
      // context or setState after dispose would throw, so bail out first.
      if (!mounted) {
        return;
      }
      setState(() => _error = _messageFor(error, AppLocalizations.of(context)));
    } finally {
      if (mounted) {
        setState(() => _posting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notes = widget.conversation == null
        ? ref.watch(commentsControllerProvider(_ref))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.heading ?? l10n.commentsHeading,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        widget.conversation ??
            notes!.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(LabFoxSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(l10n.commentsError),
              data: (all) {
                final comments = all.where((n) => !n.isSystem).toList();
                if (comments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: LabFoxSpacing.sm,
                    ),
                    child: Text(
                      l10n.commentsEmpty,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final note in comments) _NoteView(note: note),
                  ],
                );
              },
            ),
        const SizedBox(height: LabFoxSpacing.md),
        _Composer(
          controller: _controller,
          posting: _posting,
          error: _error,
          onSubmit: _post,
          canSubmit: widget.postingAllowed,
          hint: widget.composerHint,
          submit: widget.composerSubmit,
        ),
      ],
    );
  }

  String _messageFor(GitLabException error, AppLocalizations l10n) {
    return switch (error) {
      GitLabForbiddenException() => l10n.commentPostForbidden,
      GitLabAuthException() => l10n.commentPostForbidden,
      _ => l10n.commentPostError,
    };
  }
}

class _NoteView extends StatelessWidget {
  const _NoteView({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                note.author?.username ?? '',
                style: theme.textTheme.labelLarge,
              ),
              if (note.createdAt != null) ...[
                const SizedBox(width: LabFoxSpacing.sm),
                Text(
                  DateFormat.yMMMd().add_jm().format(note.createdAt!.toLocal()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: LabFoxSpacing.xs),
          MarkdownViewer(data: note.body),
          const Divider(),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.posting,
    required this.error,
    required this.onSubmit,
    required this.canSubmit,
    this.hint,
    this.submit,
  });

  final TextEditingController controller;
  final bool posting;
  final String? error;
  final VoidCallback onSubmit;
  final bool canSubmit;
  final String? hint;
  final String? submit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          enabled: !posting,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: hint ?? l10n.commentComposerHint,
            border: const OutlineInputBorder(),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: LabFoxSpacing.sm),
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: LabFoxSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: posting || !canSubmit ? null : onSubmit,
            child: posting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(submit ?? l10n.commentComposerSubmit),
          ),
        ),
      ],
    );
  }
}
