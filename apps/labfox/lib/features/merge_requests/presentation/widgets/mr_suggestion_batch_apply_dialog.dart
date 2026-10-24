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

/// Selects an explicit set, reviews every patch, and recovers through reads only.
class MrSuggestionBatchApplyDialog extends ConsumerStatefulWidget {
  const MrSuggestionBatchApplyDialog({
    required this.resource,
    required this.targets,
    required this.session,
    required this.isCurrent,
    required this.viewActive,
    super.key,
  });
  final MergeRequestRef resource;
  final List<SuggestionTarget> targets;
  final AsyncValue<CommentsRepository?> session;
  final bool Function() isCurrent;
  final ValueNotifier<bool> viewActive;
  @override
  ConsumerState<MrSuggestionBatchApplyDialog> createState() => _BatchState();
}

enum _Failure { uncertain, forbidden, changed }

class _BatchState extends ConsumerState<MrSuggestionBatchApplyDialog> {
  final _message = TextEditingController();
  final _selected = <int>{};
  final _unavailable = <int>{};
  late List<SuggestionTarget> _targets;
  bool _reviewing = false;
  bool _busy = false;
  bool _reloading = false;
  bool _needsReload = false;
  bool _reloadFailed = false;
  _Failure? _failure;

  @override
  void initState() {
    super.initState();
    _targets = List.unmodifiable(widget.targets);
    widget.viewActive.addListener(_viewChanged);
  }

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

  List<SuggestionTarget> get _selection => List.unmodifiable(
    _targets.where((target) => _selected.contains(target.suggestion.id)),
  );

  Future<void> _apply() async {
    if (_busy || _needsReload || !_current()) return;
    setState(() => _busy = true);
    try {
      final applied = await ref
          .read(mrDiscussionsControllerProvider(widget.resource).notifier)
          .applySuggestions(
            _selection,
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
    final selection = _selection;
    setState(() {
      _busy = true;
      _reloading = true;
      _reloadFailed = false;
    });
    try {
      final fresh = await ref
          .read(mrDiscussionsControllerProvider(widget.resource).notifier)
          .inspectDiscussions(
            selection.map((t) => t.discussionId).toSet().toList(),
            isCurrent: _current,
          );
      if (!_current()) return;
      if (fresh == null) {
        setState(() => _reloadFailed = true);
        return;
      }
      final replacements = <int, SuggestionTarget>{};
      final counts = <int, int>{};
      for (final group in fresh) {
        for (final note in group.notes) {
          for (final suggestion in note.suggestions ?? <Suggestion>[]) {
            counts.update(suggestion.id, (v) => v + 1, ifAbsent: () => 1);
            if (selection.any(
              (t) =>
                  t.discussionId == group.id &&
                  t.note.id == note.id &&
                  t.suggestion.id == suggestion.id,
            )) {
              replacements[suggestion.id] = (
                discussionId: group.id,
                note: note,
                suggestion: suggestion,
              );
            }
          }
        }
      }
      setState(() {
        for (final target in selection) {
          final id = target.suggestion.id;
          if (counts[id] != 1 || !replacements.containsKey(id)) {
            _unavailable.add(id);
          } else {
            _unavailable.remove(id);
          }
        }
        _targets = List.unmodifiable(
          _targets.map(
            (target) =>
                _selected.contains(target.suggestion.id) &&
                    !_unavailable.contains(target.suggestion.id)
                ? replacements[target.suggestion.id]!
                : target,
          ),
        );
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
    final selection = _selection;
    final groups = page.value?.items ?? <Discussion>[];
    final healthy = page.hasValue && !page.isLoading && !page.hasError;
    final eligible =
        current &&
        healthy &&
        !_selected.any(_unavailable.contains) &&
        containsApplicableSuggestionTargets(groups, selection);
    final error = switch (_failure) {
      _Failure.uncertain => l10n.mrSuggestionsApplyError,
      _Failure.forbidden => l10n.mrSuggestionsApplyForbidden,
      _Failure.changed => l10n.mrSuggestionsApplyChanged,
      null => null,
    };
    // With a keyboard and large text, actions must scroll with the content.
    final compact =
        MediaQuery.sizeOf(context).height -
            MediaQuery.viewInsetsOf(context).bottom <
        500;
    final actions = [
      TextButton(
        key: const ValueKey('mr-suggestions-batch-cancel'),
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        child: Text(l10n.cancel),
      ),
      if (_reviewing)
        TextButton(
          key: const ValueKey('mr-suggestions-batch-back'),
          onPressed: current && !_busy && !_needsReload
              ? () => setState(() => _reviewing = false)
              : null,
          child: Text(l10n.mrSuggestionsBackButton),
        ),
      if (current && _needsReload)
        TextButton(
          key: const ValueKey('mr-suggestions-batch-reload'),
          onPressed: _busy ? null : _reload,
          child: Text(l10n.mrSuggestionsReloadButton),
        ),
      if (_reviewing)
        TextButton(
          key: const ValueKey('mr-suggestions-batch-confirm'),
          onPressed: eligible && !_busy && !_needsReload ? _apply : null,
          child: Text(l10n.mrSuggestionsApplyButton),
        )
      else
        TextButton(
          key: const ValueKey('mr-suggestions-batch-review'),
          onPressed: eligible && !_busy
              ? () => setState(() => _reviewing = true)
              : null,
          child: Text(l10n.mrSuggestionsReviewButton),
        ),
    ];
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        title: Text(
          _reviewing
              ? l10n.mrSuggestionsReviewTitle(
                  NumberFormat.decimalPattern(
                    l10n.localeName,
                  ).format(_selected.length),
                )
              : l10n.mrSuggestionsSelectTitle,
        ),
        content: SizedBox(
          width: LabFoxBreakpoints.tablet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!current)
                Text(l10n.mrSuggestionSessionChanged)
              else ...[
                Text(
                  _reviewing
                      ? l10n.mrSuggestionsApplyImpact
                      : l10n.mrSuggestionsSelectHint,
                ),
                for (final target in _reviewing ? selection : _targets) ...[
                  if (!_reviewing)
                    CheckboxListTile(
                      key: ValueKey(
                        'mr-suggestions-select-${target.suggestion.id}',
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.mrSuggestionTitle(
                          NumberFormat.decimalPattern(
                            l10n.localeName,
                          ).format(target.suggestion.id),
                        ),
                      ),
                      value: _selected.contains(target.suggestion.id),
                      onChanged:
                          !_busy &&
                              healthy &&
                              (_selected.contains(target.suggestion.id) ||
                                  (!_unavailable.contains(
                                        target.suggestion.id,
                                      ) &&
                                      containsApplicableSuggestion(
                                        groups,
                                        discussionId: target.discussionId,
                                        note: target.note,
                                        suggestion: target.suggestion,
                                      )))
                          ? (value) => setState(() {
                              if (value == true) {
                                _selected.add(target.suggestion.id);
                              } else {
                                _selected.remove(target.suggestion.id);
                              }
                            })
                          : null,
                    ),
                  if (_unavailable.contains(target.suggestion.id))
                    Text(l10n.mrSuggestionUnavailable)
                  else ...[
                    if (target.note.position?.newPath != null)
                      Text(target.note.position!.newPath!),
                    MrSuggestionPreview(
                      key: ValueKey((
                        target.note.id,
                        target.suggestion,
                        _reviewing,
                      )),
                      noteId: target.note.id,
                      suggestion: target.suggestion,
                      initiallyExpanded: _reviewing,
                    ),
                  ],
                ],
                if (_reviewing) ...[
                  if (!eligible && !_busy && !_needsReload)
                    Text(l10n.mrSuggestionUnavailable),
                  TextField(
                    key: const ValueKey('mr-suggestions-batch-message'),
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
                  if (error != null) Text(error),
                  if (_reloadFailed) Text(l10n.mrSuggestionsReloadError),
                ],
              ],
              if (compact)
                Padding(
                  padding: const EdgeInsets.only(top: LabFoxSpacing.md),
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    overflowAlignment: OverflowBarAlignment.end,
                    children: actions,
                  ),
                ),
              if (_busy) ...[
                const SizedBox(height: LabFoxSpacing.md),
                const LinearProgressIndicator(),
                Text(
                  _reloading
                      ? l10n.mrSuggestionsReloadProgress
                      : l10n.mrSuggestionsApplyProgress,
                ),
              ],
            ],
          ),
        ),
        actions: compact ? null : actions,
      ),
    );
  }
}
