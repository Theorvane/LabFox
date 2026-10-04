import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../comments/data/comments_repository.dart';
import '../../../comments/data/suggestion_application.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_discussions_controller.dart';
import 'mr_suggestion_preview.dart';

/// Explicit confirmation and read-only recovery for one repository write.
class MrSuggestionApplyDialog extends ConsumerStatefulWidget {
  const MrSuggestionApplyDialog({
    required this.resource,
    required this.discussionId,
    required this.note,
    required this.suggestion,
    required this.session,
    required this.isCurrent,
    required this.viewActive,
    super.key,
  });
  final MergeRequestRef resource;
  final String discussionId;
  final Note note;
  final Suggestion suggestion;
  final AsyncValue<CommentsRepository?> session;
  final bool Function() isCurrent;
  final ValueNotifier<bool> viewActive;
  @override
  ConsumerState<MrSuggestionApplyDialog> createState() => _ApplicationState();
}

enum _Failure { uncertain, forbidden, changed }

class _ApplicationState extends ConsumerState<MrSuggestionApplyDialog> {
  final _message = TextEditingController();
  late Note _note;
  Suggestion? _suggestion;
  bool _busy = false;
  bool _reloading = false;
  bool _needsReload = false;
  bool _reloadFailed = false;
  _Failure? _failure;
  @override
  void initState() {
    super.initState();
    widget.viewActive.addListener(_viewChanged);
    _note = widget.note;
    _suggestion = widget.suggestion;
  }

  // The originating view can end during tree finalization; rebuild afterwards.
  void _viewChanged() {
    scheduleMicrotask(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    widget.viewActive.removeListener(_viewChanged);
    _message.dispose();
    super.dispose();
  }

  bool _current() =>
      mounted &&
      widget.viewActive.value &&
      widget.isCurrent() &&
      ref.read(commentsRepositoryProvider) == widget.session;

  Future<void> _apply() async {
    final suggestion = _suggestion;
    if (_busy || _needsReload || !_current() || suggestion == null) return;
    setState(() => _busy = true);
    try {
      final applied = await ref
          .read(mrDiscussionsControllerProvider(widget.resource).notifier)
          .applySuggestion(
            discussionId: widget.discussionId,
            note: _note,
            suggestion: suggestion,
            commitMessage: _message.text.isEmpty ? null : _message.text,
            isCurrent: _current,
          );
      if (!mounted || !_current()) return;
      if (applied) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _needsReload = true;
          _failure = _Failure.uncertain;
        });
      }
    } catch (error) {
      if (!_current()) return;
      setState(() {
        _needsReload = true;
        _failure = switch (error) {
          GitLabAuthException() ||
          GitLabForbiddenException() => _Failure.forbidden,
          GitLabConflictException() => _Failure.changed,
          _ => _Failure.uncertain,
        };
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reload() async {
    if (_busy || !_current()) return;
    setState(() {
      _busy = true;
      _reloading = true;
      _reloadFailed = false;
    });
    try {
      final fresh = await ref
          .read(mrDiscussionsControllerProvider(widget.resource).notifier)
          .inspectDiscussion(widget.discussionId, isCurrent: _current);
      if (!_current()) return;
      if (fresh == null) {
        setState(() => _reloadFailed = true);
        return;
      }
      Note? foundNote;
      Suggestion? found;
      var count = 0;
      for (final note in fresh.notes) {
        for (final suggestion in note.suggestions ?? <Suggestion>[]) {
          if (suggestion.id == widget.suggestion.id) {
            count++;
            if (note.id == widget.note.id) {
              foundNote = note;
              found = suggestion;
            }
          }
        }
      }
      setState(() {
        _suggestion = count == 1 && foundNote != null ? found : null;
        if (foundNote != null) _note = foundNote;
        _needsReload = false;
        _failure = null;
      });
    } catch (_) {
      if (_current()) setState(() => _reloadFailed = true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _reloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(commentsRepositoryProvider);
    final page = ref.watch(mrDiscussionsControllerProvider(widget.resource));
    final current = _current();
    final suggestion = _suggestion;
    final eligible =
        current &&
        suggestion != null &&
        page.hasValue &&
        !page.isLoading &&
        !page.hasError &&
        containsApplicableSuggestion(
          page.value!.items,
          discussionId: widget.discussionId,
          note: _note,
          suggestion: suggestion,
        );
    final error = switch (_failure) {
      _Failure.uncertain => l10n.mrSuggestionApplyError,
      _Failure.forbidden => l10n.mrSuggestionApplyForbidden,
      _Failure.changed => l10n.mrSuggestionApplyChanged,
      null => null,
    };
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        title: Text(
          l10n.mrSuggestionApplyTitle(
            NumberFormat.decimalPattern(
              l10n.localeName,
            ).format(widget.suggestion.id),
          ),
        ),
        content: SizedBox(
          width: LabFoxBreakpoints.tablet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!current)
                Text(l10n.mrSuggestionSessionChanged)
              else ...[
                Text(l10n.mrSuggestionApplyImpact),
                if (_note.position?.newPath != null)
                  Text(_note.position!.newPath!),
                if (suggestion != null)
                  MrSuggestionPreview(
                    key: ValueKey((_note.id, suggestion)),
                    noteId: _note.id,
                    suggestion: suggestion,
                    initiallyExpanded: true,
                  ),
                if (!eligible && !_busy && !_needsReload)
                  Text(l10n.mrSuggestionUnavailable),
                TextField(
                  key: const ValueKey('mr-suggestion-commit-message'),
                  controller: _message,
                  enabled: !_busy,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.mrSuggestionCommitMessageLabel,
                    helperText: l10n.mrSuggestionCommitMessageHint,
                    helperMaxLines: 4,
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: LabFoxSpacing.md),
                    child: Text(error),
                  ),
                if (_reloadFailed) Text(l10n.mrSuggestionReloadError),
              ],
              if (_busy) ...[
                const SizedBox(height: LabFoxSpacing.md),
                const LinearProgressIndicator(),
                Text(
                  _reloading
                      ? l10n.mrSuggestionReloadProgress
                      : l10n.mrSuggestionApplyProgress,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const ValueKey('mr-suggestion-apply-cancel'),
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          if (current && _needsReload)
            TextButton(
              key: const ValueKey('mr-suggestion-apply-reload'),
              onPressed: _busy ? null : _reload,
              child: Text(l10n.mrSuggestionReloadButton),
            ),
          TextButton(
            key: const ValueKey('mr-suggestion-apply-confirm'),
            onPressed: eligible && !_busy && !_needsReload ? _apply : null,
            child: Text(l10n.mrSuggestionApplyButton),
          ),
        ],
      ),
    );
  }
}
