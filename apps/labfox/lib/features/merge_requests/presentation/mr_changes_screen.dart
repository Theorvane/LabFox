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

/// Reviews one authoritative diff version and starts single-line discussions.
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
  bool _posting = false, _reloading = false, _needsReload = false;
  String? _error;
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
        position == null ||
        _draft.text.trim().isEmpty)
      return;
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
        _draft.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mrDiffDiscussionCreated)));
    } catch (error) {
      if (mounted)
        setState(() {
          _needsReload = true;
          _error = error is GitLabForbiddenException
              ? l10n.mrDiffDiscussionPermissionError
              : l10n.mrDiffDiscussionError;
        });
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
      if (mounted) setState(() => _needsReload = false);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.mrDiffDiscussionReloadFailed);
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
            if (value.unavailable)
              return Center(child: Text(l10n.mrReviewUnavailable));
            if (value.files.isEmpty)
              return Center(child: Text(l10n.changesEmpty));
            final version = NumberFormat.decimalPattern(
              l10n.localeName,
            ).format(value.version!.id);
            final positionValid =
                _selected != null && value.containsPosition(_selected!);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(LabFoxSpacing.sm),
                  child: Text(l10n.mrReviewVersionTitle(version)),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: value.files.length,
                    itemBuilder: (context, index) {
                      final file = value.files[index];
                      final selected = _selected == null
                          ? null
                          : file.hunks
                                .expand((h) => h.lines)
                                .where(
                                  (line) =>
                                      value.positionFor(file, line) ==
                                      _selected,
                                );
                      return DiffFileCard(
                        file: file,
                        highlightedLine:
                            selected != null && selected.length == 1
                            ? selected.single
                            : null,
                        lineActionLabel: l10n.mrDiffDiscussLineButton,
                        canSelectLine: (line) =>
                            value.positionFor(file, line) != null,
                        onLineSelected:
                            _posting || _reloading || _selected != null
                            ? null
                            : (line) {
                                final position = value.positionFor(file, line);
                                if (position != null)
                                  setState(() {
                                    _selected = position;
                                    _error = null;
                                    _needsReload = false;
                                  });
                              },
                      );
                    },
                  ),
                ),
                if (_selected != null)
                  Flexible(
                    child: SafeArea(
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: LabFoxSpacing.sm,
                                    children: [
                                      TextButton(
                                        onPressed: _posting || _reloading
                                            ? null
                                            : () => setState(() {
                                                _selected = null;
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
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
