import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/gitlab_client_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/merge_requests_controllers.dart';
import 'controllers/mr_commits_controller.dart';
import 'controllers/mr_draft_notes_provider.dart';
import 'controllers/mr_original_review_controller.dart';
import 'widgets/mr_pending_review_composer.dart';

/// Restores an original review from project/IID/full SHA, never route objects.
class MrOriginalChangesScreen extends ConsumerWidget {
  const MrOriginalChangesScreen({
    required this.projectId,
    required this.iid,
    required this.commitId,
    super.key,
  });
  final int projectId, iid;
  final String commitId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (projectId < 1 ||
        iid < 1 ||
        !RegExp(r'^[0-9a-f]{40}$').hasMatch(commitId)) {
      return Scaffold(
        appBar: AppBar(title: Text(l.mrOriginalReviewTitle)),
        body: Center(child: Text(l.mrReviewUnavailable)),
      );
    }
    final resource = MergeRequestRef(projectId: projectId, iid: iid);
    final provider = mrCommitOriginControllerProvider(resource);
    final account = ref.watch(currentAccountProvider);
    final source = ref.watch(mergeRequestsRepositoryProvider);
    return ref
        .watch(provider)
        .when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l.mrOriginalReviewTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Scaffold(
            appBar: AppBar(title: Text(l.mrOriginalReviewTitle)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.changesError),
                  TextButton(
                    onPressed: () => ref.invalidate(provider),
                    child: Text(l.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (mr) => mr == null
              ? Scaffold(
                  appBar: AppBar(title: Text(l.mrOriginalReviewTitle)),
                  body: Center(child: Text(l.mrReviewUnavailable)),
                )
              : _OriginalContent(
                  key: ValueKey((resource, mr.id, commitId, account, source)),
                  original: (
                    projectId: projectId,
                    iid: iid,
                    mergeRequestId: mr.id,
                    commitId: commitId,
                  ),
                ),
        );
  }
}

class _OriginalContent extends ConsumerStatefulWidget {
  const _OriginalContent({required this.original, super.key});
  final MrOriginalReviewRef original;
  @override
  ConsumerState<_OriginalContent> createState() => _OriginalState();
}

class _OriginalState extends ConsumerState<_OriginalContent> {
  MrOriginalReviewSelection? _selection;
  DiffNotePosition? _start;
  bool _choosingEnd = false, _opening = false;
  ValueNotifier<bool>? _view;
  MergeRequestRef get resource => MergeRequestRef(
    projectId: widget.original.projectId,
    iid: widget.original.iid,
  );
  @override
  void dispose() {
    _view?.value = false;
    super.dispose();
  }

  void _clear() {
    setState(() {
      _selection = null;
      _start = null;
      _choosingEnd = false;
    });
  }

  Future<void> _open() async {
    if (_opening || _choosingEnd) return;
    final selected = _selection;
    if (selected == null) return;
    final displayed = ref.read(
      mrOriginalReviewControllerProvider(widget.original),
    );
    if (displayed.isLoading ||
        displayed.hasError ||
        !displayed.hasValue ||
        !selected.matches(displayed.value!)) {
      return;
    }
    final account = ref.read(currentAccountProvider);
    final drafts = ref
        .read(mrDraftNotesRepositoryProvider)
        .unwrapPrevious()
        .valueOrNull;
    final details = ref
        .read(mergeRequestsRepositoryProvider)
        .unwrapPrevious()
        .valueOrNull;
    final client = ref.read(gitLabClientProvider).unwrapPrevious().valueOrNull;
    if (account == null ||
        drafts == null ||
        details == null ||
        client == null) {
      return;
    }
    final active = ValueNotifier(true);
    _view = active;
    setState(() => _opening = true);
    bool current() =>
        mounted &&
        active.value &&
        ref.read(currentAccountProvider) == account &&
        identical(
          ref.read(mrDraftNotesRepositoryProvider).unwrapPrevious().valueOrNull,
          drafts,
        ) &&
        identical(
          ref
              .read(mergeRequestsRepositoryProvider)
              .unwrapPrevious()
              .valueOrNull,
          details,
        ) &&
        identical(
          ref.read(gitLabClientProvider).unwrapPrevious().valueOrNull,
          client,
        );
    try {
      final saved = await showMrPendingOriginalReviewDialog(
        context: context,
        resource: resource,
        original: widget.original,
        selection: selected,
        account: account,
        draftSession: drafts,
        detailSession: details,
        clientSession: client,
        viewActive: active,
        isCurrent: current,
      );
      if (!mounted || !current()) return;
      if (saved == true) {
        _clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).mrPendingComposeSaved),
          ),
        );
      }
    } finally {
      _view = null;
      active.dispose();
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = mrOriginalReviewControllerProvider(widget.original);
    final drafts = ref.watch(mrDraftNotesRepositoryProvider).unwrapPrevious();
    final client = ref.watch(gitLabClientProvider).unwrapPrevious();
    final privateReady =
        !drafts.isLoading &&
        !drafts.hasError &&
        drafts.valueOrNull != null &&
        !client.isLoading &&
        !client.hasError &&
        client.valueOrNull != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.mrOriginalReviewTitle),
        actions: [
          IconButton(
            tooltip: l.retry,
            onPressed: _opening
                ? null
                : () {
                    _clear();
                    ref.invalidate(provider);
                  },
            icon: const Icon(LabFoxIcons.refresh),
          ),
        ],
      ),
      body: ref
          .watch(provider)
          .when(
            skipLoadingOnRefresh: false,
            skipLoadingOnReload: false,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.changesError),
                  TextButton(
                    onPressed: _opening ? null : () => ref.invalidate(provider),
                    child: Text(l.retry),
                  ),
                ],
              ),
            ),
            data: (s) {
              final contextData = s.context;
              if (contextData == null) {
                return Center(child: Text(l.mrReviewUnavailable));
              }
              if (contextData.files.isEmpty) {
                return Center(child: Text(l.changesEmpty));
              }
              final valid = _selection != null && _selection!.matches(s);
              final marked = valid
                  ? s.linesForPosition(_selection!.position)
                  : <DiffLine>[];
              final starts = _start == null
                  ? <DiffLine>[]
                  : s.linesForPosition(_start!);
              final start = starts.length == 1 ? starts.single : null;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final files = ListView.builder(
                    itemCount: contextData.files.length,
                    itemBuilder: (_, index) {
                      final literal = contextData.files[index];
                      final eligible = s.files
                          .where((f) => identical(f.file, literal))
                          .toList();
                      final file = eligible.length == 1
                          ? eligible.single
                          : null;
                      final rangeMode =
                          _choosingEnd &&
                          start != null &&
                          file != null &&
                          file.hunks.any(
                            (h) => h.lines.any((row) => identical(row, start)),
                          );
                      return Card(
                        margin: const EdgeInsets.all(LabFoxSpacing.sm),
                        child: Padding(
                          padding: const EdgeInsets.all(LabFoxSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                literal.newPath,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (literal.oldPath != literal.newPath)
                                Text(
                                  l.mrPendingReviewOldPath(literal.oldPath),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: LabFoxSpacing.sm),
                              if (file == null)
                                Text(l.mrOriginalReviewDiffUnavailable)
                              else
                                DiffHunksViewer(
                                  hunks: file.hunks,
                                  highlightedLines: marked,
                                  highlightedLineLabel:
                                      l.mrDiffSelectedLineLabel,
                                  lineActionLabel: rangeMode
                                      ? l.mrDiffRangeEndButton
                                      : l.mrPendingComposeOpen,
                                  canSelectLine: (line) => rangeMode
                                      ? s.rangePositionFor(file, start, line) !=
                                            null
                                      : !_choosingEnd &&
                                            _selection == null &&
                                            s.positionFor(file, line) != null,
                                  onLineSelected: _opening
                                      ? null
                                      : (line) {
                                          final p = rangeMode
                                              ? s.rangePositionFor(
                                                  file,
                                                  start,
                                                  line,
                                                )
                                              : s.positionFor(file, line);
                                          if (p == null) return;
                                          final selection =
                                              MrOriginalReviewSelection.capture(
                                                s,
                                                p,
                                              );
                                          if (selection == null) return;
                                          setState(() {
                                            _selection = selection;
                                            if (!rangeMode) _start = p;
                                            _choosingEnd = false;
                                          });
                                        },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  final composer = _selection == null
                      ? null
                      : SafeArea(
                          top: false,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(LabFoxSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selection!.position.newPath!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_selection!.position.lineRange
                                      case final range?)
                                    Text(
                                      l.mrDiffSelectedRangeLabel(
                                        '${range.start!.type == 'old' ? '-' : '+'}${NumberFormat.decimalPattern(l.localeName).format(range.start!.type == 'old' ? range.start!.oldLine : range.start!.newLine)}',
                                        '${range.end!.type == 'old' ? '-' : '+'}${NumberFormat.decimalPattern(l.localeName).format(range.end!.type == 'old' ? range.end!.oldLine : range.end!.newLine)}',
                                      ),
                                    )
                                  else ...[
                                    if (_selection!.position.oldLine
                                        case final line?)
                                      Text(
                                        l.mrPendingReviewOldLine(
                                          NumberFormat.decimalPattern(
                                            l.localeName,
                                          ).format(line),
                                        ),
                                      ),
                                    if (_selection!.position.newLine
                                        case final line?)
                                      Text(
                                        l.mrPendingReviewNewLine(
                                          NumberFormat.decimalPattern(
                                            l.localeName,
                                          ).format(line),
                                        ),
                                      ),
                                  ],
                                  if (!valid) Text(l.mrReviewUnavailable),
                                  if (_choosingEnd)
                                    Text(l.mrDiffRangeChooseEnd),
                                  Wrap(
                                    spacing: LabFoxSpacing.sm,
                                    children: [
                                      TextButton(
                                        key: const ValueKey(
                                          'mr-original-select-range',
                                        ),
                                        onPressed:
                                            _opening ||
                                                _choosingEnd ||
                                                !valid ||
                                                start == null
                                            ? null
                                            : () => setState(
                                                () => _choosingEnd = true,
                                              ),
                                        child: Text(l.mrDiffSelectRangeButton),
                                      ),
                                      TextButton(
                                        onPressed: _opening ? null : _clear,
                                        child: Text(l.cancel),
                                      ),
                                    ],
                                  ),
                                  FilledButton(
                                    key: const ValueKey(
                                      'mr-original-private-open',
                                    ),
                                    onPressed:
                                        _opening ||
                                            _choosingEnd ||
                                            !valid ||
                                            !privateReady
                                        ? null
                                        : _open,
                                    child: Text(l.mrPendingComposeOpen),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                  final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.sm),
                        child: Column(
                          children: [
                            Text(
                              contextData.commit.title.isEmpty
                                  ? widget.original.commitId
                                  : contextData.commit.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SelectableText(widget.original.commitId),
                            if (!s.canSelect) Text(l.mrOriginalReviewReadOnly),
                          ],
                        ),
                      ),
                      Expanded(
                        child: wide && composer != null
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: files),
                                  const VerticalDivider(
                                    width: LabFoxSpacing.md,
                                  ),
                                  SizedBox(
                                    width: constraints.maxWidth * 0.4,
                                    child: composer,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(flex: 2, child: files),
                                  if (composer != null)
                                    Flexible(child: composer),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
    );
  }
}
