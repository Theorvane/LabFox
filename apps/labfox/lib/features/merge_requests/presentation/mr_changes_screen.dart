import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../comments/presentation/controllers/comments_controller.dart';
import '../../diff/presentation/changes_screen.dart';
import '../../diff/presentation/controllers/diff_controllers.dart';
import 'controllers/merge_requests_controllers.dart';
import 'controllers/mr_discussions_controller.dart';
import 'controllers/mr_review_snapshot_controller.dart';

/// Reviews one authoritative diff version and starts positioned discussions.
class MrChangesScreen extends ConsumerWidget {
  const MrChangesScreen({
    required this.projectId,
    required this.iid,
    super.key,
  });
  final int projectId;
  final int iid;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(commentsRepositoryProvider);
    final diffs = ref.watch(diffRepositoryProvider);
    final arg = MergeRequestRef(projectId: projectId, iid: iid);
    return _ReviewContent(key: ValueKey((arg, comments, diffs)), arg: arg);
  }
}

class _ReviewContent extends ConsumerStatefulWidget {
  const _ReviewContent({required this.arg, super.key});
  final MergeRequestRef arg;
  @override
  ConsumerState<_ReviewContent> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<_ReviewContent> {
  final _draft = TextEditingController();
  DiffNotePosition? _selected;
  DiffNotePosition? _startAnchor;
  bool _choosingEnd = false;
  bool _posting = false, _reloading = false, _needsReload = false;
  String? _error;
  bool _inspection = false;
  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final position = _selected;
    if (_posting ||
        _reloading ||
        _needsReload ||
        _choosingEnd ||
        position == null ||
        _draft.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _posting = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final created = await ref
          .read(mrDiscussionsControllerProvider(widget.arg).notifier)
          .createPositioned(body: _draft.text, position: position);
      if (!mounted || !created) return;
      setState(() {
        _selected = null;
        _startAnchor = null;
        _choosingEnd = false;
        _inspection = false;
        _draft.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mrDiffDiscussionCreated)));
    } catch (error) {
      if (mounted) {
        setState(() {
          _needsReload = true;
          _error = error is GitLabForbiddenException
              ? l10n.mrDiffDiscussionPermissionError
              : l10n.mrDiffDiscussionError;
        });
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _reloadDiscussions() async {
    if (_posting || _reloading) return;
    setState(() {
      _reloading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final provider = mrDiscussionsControllerProvider(widget.arg);
    try {
      ref.invalidate(provider);
      await ref.read(provider.future);
      if (mounted) {
        setState(() {
          _needsReload = false;
          _inspection = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.mrDiffDiscussionReloadFailed);
    } finally {
      if (mounted) setState(() => _reloading = false);
    }
  }

  bool _samePosition(DiffNotePosition? p) {
    final selected = _selected;
    return p != null &&
        selected != null &&
        p.positionType == 'text' &&
        _sameRange(selected.lineRange, p.lineRange) &&
        p.baseSha == selected.baseSha &&
        p.startSha == selected.startSha &&
        p.headSha == selected.headSha &&
        p.oldPath == selected.oldPath &&
        p.newPath == selected.newPath &&
        p.oldLine == selected.oldLine &&
        p.newLine == selected.newLine;
  }

  bool _sameRange(DiffNoteLineRange? a, DiffNoteLineRange? b) {
    if (a == null || b == null) return a == b;
    bool same(DiffNoteRangeEndpoint? start, DiffNoteRangeEndpoint? end) =>
        start != null &&
        end != null &&
        start.lineCode == end.lineCode &&
        start.type == end.type &&
        (end.oldLine == null || end.oldLine == start.oldLine) &&
        (end.newLine == null || end.newLine == start.newLine);
    return same(a.start, b.start) && same(a.end, b.end);
  }

  String _endpointLabel(DiffNoteRangeEndpoint endpoint, AppLocalizations l10n) {
    final old = endpoint.type == 'old';
    return (old ? '-' : '+') +
        NumberFormat.decimalPattern(
          l10n.localeName,
        ).format(old ? endpoint.oldLine : endpoint.newLine);
  }

  Future<void> _loadMore() async {
    if (_posting || _reloading) return;
    setState(() {
      _reloading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(mrDiscussionsControllerProvider(widget.arg).notifier)
          .loadMore();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.mrDiscussionsMoreError);
    } finally {
      if (mounted) setState(() => _reloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = mrReviewSnapshotControllerProvider(widget.arg);
    final snapshot = ref.watch(provider);
    final discussions = _selected == null
        ? null
        : ref.watch(mrDiscussionsControllerProvider(widget.arg));
    final ready =
        discussions != null &&
        !discussions.isLoading &&
        !discussions.hasError &&
        discussions.hasValue;
    final matching = ready && _inspection && !_needsReload
        ? discussions.value!.items
              .expand((group) => group.notes)
              .where((note) => !note.isSystem && _samePosition(note.position))
              .toList()
        : <Note>[];
    return PopScope(
      canPop: !_posting && !_reloading,
      child: Scaffold(
        appBar: AppBar(title: Text('!${widget.arg.iid}')),
        body: snapshot.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.changesError),
                TextButton(
                  onPressed: () => ref.invalidate(provider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (value) {
            if (value.unavailable) {
              return Center(child: Text(l10n.mrReviewUnavailable));
            }
            if (value.files.isEmpty) {
              return Center(child: Text(l10n.changesEmpty));
            }
            final version = NumberFormat.decimalPattern(
              l10n.localeName,
            ).format(value.version!.id);
            final positionValid =
                _selected != null && value.containsPosition(_selected!);
            (FileDiff, DiffLine)? rangeStart;
            if (_startAnchor != null) {
              for (final file in value.files) {
                final lines = value.linesForPosition(file, _startAnchor!);
                if (lines.length == 1) rangeStart = (file, lines.single);
              }
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final files = ListView.builder(
                  itemCount: value.files.length,
                  itemBuilder: (context, index) {
                    final file = value.files[index];
                    final selected = _selected == null
                        ? <DiffLine>[]
                        : value.linesForPosition(file, _selected!);
                    final rangeMode =
                        _choosingEnd && identical(file, rangeStart?.$1);
                    return DiffFileCard(
                      file: file,
                      highlightedLine:
                          _selected?.lineRange == null && selected.length == 1
                          ? selected.single
                          : null,
                      highlightedLines: _selected?.lineRange == null
                          ? const []
                          : selected,
                      highlightedLineLabel: l10n.mrDiffSelectedLineLabel,
                      lineActionLabel: rangeMode
                          ? l10n.mrDiffRangeEndButton
                          : l10n.mrDiffDiscussLineButton,
                      canSelectLine: (line) => rangeMode
                          ? rangeStart != null &&
                                value.rangePositionFor(
                                      file,
                                      rangeStart.$2,
                                      line,
                                    ) !=
                                    null
                          : value.positionFor(file, line) != null,
                      onLineSelected:
                          _posting ||
                              _reloading ||
                              (_selected != null && !rangeMode)
                          ? null
                          : (line) {
                              final position = rangeMode
                                  ? value.rangePositionFor(
                                      file,
                                      rangeStart!.$2,
                                      line,
                                    )
                                  : value.positionFor(file, line);
                              if (position != null) {
                                setState(() {
                                  _selected = position;
                                  if (!rangeMode) _startAnchor = position;
                                  _choosingEnd = false;
                                  _inspection = false;
                                  _error = null;
                                  _needsReload = false;
                                });
                              }
                            },
                    );
                  },
                );
                final composer = _selected == null
                    ? null
                    : SafeArea(
                        top: false,
                        child: Center(
                          heightFactor: 1,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: LabFoxBreakpoints.desktop,
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(LabFoxSpacing.md),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.mrDiffDiscussionTitle(
                                        _selected!.newPath!,
                                        version,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    if (_selected!.lineRange != null)
                                      Text(
                                        l10n.mrDiffSelectedRangeLabel(
                                          _endpointLabel(
                                            _selected!.lineRange!.start!,
                                            l10n,
                                          ),
                                          _endpointLabel(
                                            _selected!.lineRange!.end!,
                                            l10n,
                                          ),
                                        ),
                                      ),
                                    if (_choosingEnd)
                                      Text(l10n.mrDiffRangeChooseEnd),
                                    Wrap(
                                      spacing: LabFoxSpacing.sm,
                                      children: [
                                        if (!_choosingEnd)
                                          TextButton(
                                            onPressed:
                                                _posting ||
                                                    _reloading ||
                                                    _needsReload ||
                                                    !positionValid ||
                                                    rangeStart == null
                                                ? null
                                                : () => setState(() {
                                                    _selected = _startAnchor;
                                                    _choosingEnd = true;
                                                    _inspection = false;
                                                    _error = null;
                                                  }),
                                            child: Text(
                                              l10n.mrDiffSelectRangeButton,
                                            ),
                                          ),
                                        if (_choosingEnd ||
                                            _selected!.lineRange != null)
                                          TextButton(
                                            onPressed:
                                                _posting ||
                                                    _reloading ||
                                                    _needsReload ||
                                                    !positionValid ||
                                                    rangeStart == null
                                                ? null
                                                : () => setState(() {
                                                    _selected = _startAnchor;
                                                    _choosingEnd = false;
                                                    _inspection = false;
                                                    _error = null;
                                                  }),
                                            child: Text(
                                              l10n.mrDiffSingleLineButton,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: LabFoxSpacing.sm),
                                    TextField(
                                      key: const ValueKey(
                                        'mr-diff-discussion-draft',
                                      ),
                                      controller: _draft,
                                      enabled: !_posting && !_reloading,
                                      minLines: 2,
                                      maxLines: 4,
                                      onChanged: (_) => setState(() {}),
                                      decoration: InputDecoration(
                                        hintText: l10n.mrDiffDiscussionHint,
                                      ),
                                    ),
                                    if (_posting ||
                                        _reloading ||
                                        discussions?.isLoading == true) ...[
                                      const SizedBox(height: LabFoxSpacing.sm),
                                      Text(
                                        _posting
                                            ? l10n.mrDiffDiscussionPending
                                            : l10n.mrDiffDiscussionReloading,
                                      ),
                                      const LinearProgressIndicator(),
                                    ],
                                    if (_error != null) Text(_error!),
                                    if (!positionValid)
                                      Text(l10n.mrReviewUnavailable),
                                    if (_needsReload)
                                      Text(l10n.mrDiffDiscussionReloadRequired),
                                    if (discussions?.hasError == true &&
                                        _error == null)
                                      Text(l10n.mrDiffDiscussionReloadFailed),
                                    if (_needsReload ||
                                        discussions?.hasError == true)
                                      TextButton(
                                        onPressed: _posting || _reloading
                                            ? null
                                            : _reloadDiscussions,
                                        child: Text(
                                          l10n.mrDiffDiscussionReloadButton,
                                        ),
                                      ),
                                    if (_inspection &&
                                        ready &&
                                        !_needsReload) ...[
                                      Text(l10n.mrDiffDiscussionInspect),
                                      if (matching.isEmpty)
                                        Text(l10n.mrDiffDiscussionNoMatches),
                                      for (final note in matching)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: LabFoxSpacing.sm,
                                          ),
                                          child: MarkdownViewer(
                                            data: note.body,
                                          ),
                                        ),
                                      if (discussions.value!.hasMore)
                                        TextButton(
                                          onPressed: _posting || _reloading
                                              ? null
                                              : _loadMore,
                                          child: Text(
                                            l10n.mrDiscussionsLoadMore,
                                          ),
                                        ),
                                    ],
                                    Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: LabFoxSpacing.sm,
                                      children: [
                                        TextButton(
                                          onPressed: _posting || _reloading
                                              ? null
                                              : () => setState(() {
                                                  _selected = null;
                                                  _startAnchor = null;
                                                  _choosingEnd = false;
                                                  _inspection = false;
                                                  _draft.clear();
                                                  _error = null;
                                                  _needsReload = false;
                                                }),
                                          child: Text(
                                            l10n.mrDiffDiscussionCancel,
                                          ),
                                        ),
                                        FilledButton(
                                          key: const ValueKey(
                                            'mr-diff-discussion-submit',
                                          ),
                                          onPressed:
                                              _posting ||
                                                  _reloading ||
                                                  _needsReload ||
                                                  _choosingEnd ||
                                                  !ready ||
                                                  !positionValid ||
                                                  _draft.text.trim().isEmpty
                                              ? null
                                              : _submit,
                                          child: Text(
                                            l10n.mrDiffDiscussionSubmit,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(LabFoxSpacing.sm),
                      child: Text(l10n.mrReviewVersionTitle(version)),
                    ),
                    Expanded(
                      child: wide && composer != null
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: files),
                                const VerticalDivider(width: LabFoxSpacing.md),
                                SizedBox(
                                  width: constraints.maxWidth * 0.4,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: composer,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(flex: 2, child: files),
                                if (composer != null) Flexible(child: composer),
                              ],
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
