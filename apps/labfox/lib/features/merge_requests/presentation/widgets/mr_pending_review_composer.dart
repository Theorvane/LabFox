import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_discussions_controller.dart';
import '../controllers/mr_draft_notes_provider.dart';
import 'mr_pending_review_note.dart';

/// The originating view stays mounted during the controller's own detail refresh.
class MrPendingReviewComposer extends ConsumerStatefulWidget {
  const MrPendingReviewComposer({required this.mergeRequest, super.key});
  final MergeRequestRef mergeRequest;
  @override
  ConsumerState<MrPendingReviewComposer> createState() => _EntryState();
}

class _EntryState extends ConsumerState<MrPendingReviewComposer> {
  bool _opening = false;
  ValueNotifier<bool>? _view;
  @override
  void dispose() {
    _view?.value = false;
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening) return;
    final account = ref.read(currentAccountProvider);
    final drafts = ref.read(mrDraftNotesRepositoryProvider).unwrapPrevious();
    final source = ref.read(mergeRequestsRepositoryProvider).unwrapPrevious();
    if (account == null ||
        drafts.valueOrNull == null ||
        source.valueOrNull == null) {
      return;
    }
    final active = ValueNotifier(true);
    _view = active;
    setState(() => _opening = true);
    try {
      final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ComposeDialog(
          resource: widget.mergeRequest,
          account: account,
          draftSession: drafts.value!,
          detailSession: source.value!,
          viewActive: active,
          isCurrent: () => mounted,
        ),
      );
      if (mounted &&
          active.value &&
          saved == true &&
          ref.read(currentAccountProvider) == account &&
          identical(
            ref
                .read(mrDraftNotesRepositoryProvider)
                .unwrapPrevious()
                .valueOrNull,
            drafts.valueOrNull,
          ) &&
          identical(
            ref
                .read(mergeRequestsRepositoryProvider)
                .unwrapPrevious()
                .valueOrNull,
            source.valueOrNull,
          )) {
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
    final account = ref.watch(currentAccountProvider);
    final drafts = ref.watch(mrDraftNotesRepositoryProvider).unwrapPrevious();
    final source = ref.watch(mergeRequestsRepositoryProvider).unwrapPrevious();
    final detail = ref
        .watch(mergeRequestControllerProvider(widget.mergeRequest))
        .unwrapPrevious();
    final mr = detail.valueOrNull;
    final ready =
        account != null &&
        !drafts.isLoading &&
        !drafts.hasError &&
        drafts.valueOrNull != null &&
        !source.isLoading &&
        !source.hasError &&
        source.valueOrNull != null &&
        !detail.isLoading &&
        !detail.hasError &&
        mr != null &&
        mr.id > 0 &&
        mr.iid == widget.mergeRequest.iid &&
        (mr.projectId == null || mr.projectId == widget.mergeRequest.projectId);
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton(
        key: const ValueKey('mr-pending-compose-open'),
        onPressed: ready && !_opening ? _open : null,
        child: Text(AppLocalizations.of(context).mrPendingComposeOpen),
      ),
    );
  }
}

class _ComposeDialog extends ConsumerStatefulWidget {
  const _ComposeDialog({
    required this.resource,
    required this.account,
    required this.draftSession,
    required this.detailSession,
    required this.viewActive,
    required this.isCurrent,
  });
  final MergeRequestRef resource;
  final Account account;
  final Object draftSession;
  final Object detailSession;
  final ValueNotifier<bool> viewActive;
  final bool Function() isCurrent;
  @override
  ConsumerState<_ComposeDialog> createState() => _ComposeState();
}

class _ComposeState extends ConsumerState<_ComposeDialog> {
  final _text = TextEditingController();
  Object? _commentsSession;
  bool _obsolete = false, _busy = false, _inspecting = false;
  bool _needsInspection = false,
      _acknowledged = false,
      _inspectionError = false,
      _saveError = false;
  List<MergeRequestDraftNote>? _inspection;
  @override
  void initState() {
    super.initState();
    widget.viewActive.addListener(_observe);
    _text.addListener(_edited);
  }

  @override
  void dispose() {
    widget.viewActive.removeListener(_observe);
    _text.dispose();
    super.dispose();
  }

  bool _current() =>
      mounted &&
      !_obsolete &&
      widget.viewActive.value &&
      widget.isCurrent() &&
      ref.read(currentAccountProvider) == widget.account &&
      identical(
        ref.read(mrDraftNotesRepositoryProvider).unwrapPrevious().valueOrNull,
        widget.draftSession,
      ) &&
      identical(
        ref.read(mergeRequestsRepositoryProvider).unwrapPrevious().valueOrNull,
        widget.detailSession,
      ) &&
      (_commentsSession == null ||
          identical(
            ref.read(commentsRepositoryProvider).unwrapPrevious().valueOrNull,
            _commentsSession,
          ));
  void _observe() {
    if (_current()) return;
    // Origin disposal can occur during tree finalization. Hide immediately in
    // build, then permanently discard local private state outside that frame.
    scheduleMicrotask(() {
      if (!mounted || _obsolete) return;
      _obsolete = true;
      _text.clear();
      setState(() {
        _inspection = null;
        _acknowledged = false;
      });
    });
  }

  void _edited() {
    if (mounted && !_obsolete) setState(() => _acknowledged = false);
  }

  Future<void> _save() async {
    if (_busy || !_current() || _text.text.trim().isEmpty) return;
    final controller = ref.read(
      mrDiscussionsControllerProvider(widget.resource).notifier,
    );
    if (controller.pendingSaveNeedsInspection ||
        (_needsInspection && (_inspection == null || !_acknowledged))) {
      return;
    }
    setState(() {
      _busy = true;
      _inspection = null;
      _acknowledged = false;
      _saveError = false;
      _inspectionError = false;
    });
    try {
      final saved = await controller.savePendingNote(
        _text.text,
        isCurrent: _current,
      );
      if (!mounted || !_current()) return;
      if (saved != null) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _saveError = true;
          _needsInspection = controller.pendingSaveNeedsInspection;
        });
      }
    } catch (_) {
      if (_current()) {
        setState(() {
          _saveError = true;
          _needsInspection = controller.pendingSaveNeedsInspection;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _inspect() async {
    if (_busy || !_current()) return;
    setState(() {
      _busy = true;
      _inspecting = true;
      _inspection = null;
      _acknowledged = false;
      _inspectionError = false;
    });
    try {
      final notes = await ref
          .read(mrDiscussionsControllerProvider(widget.resource).notifier)
          .inspectPendingNotes(isCurrent: _current);
      if (!mounted || !_current()) return;
      setState(() {
        _inspection = notes;
        _inspectionError = notes == null;
      });
    } catch (_) {
      if (_current()) setState(() => _inspectionError = true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _inspecting = false;
        });
      }
    }
  }

  void _retryPreparation() {
    if (_busy || !_current()) return;
    final comments = ref.read(commentsRepositoryProvider).unwrapPrevious();
    if (_commentsSession == null &&
        (comments.hasError || comments.valueOrNull == null)) {
      ref.invalidate(commentsRepositoryProvider);
    }
    ref.invalidate(mrDiscussionsControllerProvider(widget.resource));
    ref.invalidate(mergeRequestControllerProvider(widget.resource));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.watch(currentAccountProvider);
    ref.watch(mrDraftNotesRepositoryProvider);
    ref.watch(mergeRequestsRepositoryProvider);
    final comments = ref.watch(commentsRepositoryProvider).unwrapPrevious();
    ref.listen(currentAccountProvider, (_, _) => _observe());
    ref.listen(mrDraftNotesRepositoryProvider, (_, _) => _observe());
    ref.listen(mergeRequestsRepositoryProvider, (_, _) => _observe());
    ref.listen(commentsRepositoryProvider, (_, _) => _observe());
    if (_current() &&
        _commentsSession == null &&
        !comments.isLoading &&
        !comments.hasError) {
      _commentsSession = comments.valueOrNull;
    }
    final current = _current();
    if (!current) _observe();
    final discussions = current
        ? ref
              .watch(mrDiscussionsControllerProvider(widget.resource))
              .unwrapPrevious()
        : null;
    final detail = current
        ? ref
              .watch(mergeRequestControllerProvider(widget.resource))
              .unwrapPrevious()
        : null;
    final controller = current
        ? ref.read(mrDiscussionsControllerProvider(widget.resource).notifier)
        : null;
    final gated = controller?.pendingSaveNeedsInspection ?? true;
    if (current && gated) _needsInspection = true;
    final mr = detail?.valueOrNull;
    final preparing =
        current &&
        (comments.isLoading || discussions!.isLoading || detail!.isLoading);
    final ready =
        current &&
        !preparing &&
        !comments.hasError &&
        comments.valueOrNull != null &&
        !discussions!.hasError &&
        discussions.hasValue &&
        !detail!.hasError &&
        mr != null &&
        mr.id > 0 &&
        mr.iid == widget.resource.iid &&
        (mr.projectId == null || mr.projectId == widget.resource.projectId);
    final canSave =
        ready &&
        !_busy &&
        _text.text.trim().isNotEmpty &&
        !gated &&
        (!_needsInspection || (_inspection != null && _acknowledged));
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.all(LabFoxSpacing.md),
        title: Text(l.mrPendingComposeTitle),
        content: SizedBox(
          width: LabFoxBreakpoints.tablet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!current)
                Text(l.mrPendingComposeChanged)
              else ...[
                Text(l.mrPendingComposeHint),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  key: const ValueKey('mr-pending-compose-input'),
                  controller: _text,
                  enabled: !_busy,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l.mrPendingComposeLabel,
                  ),
                ),
                if (preparing && !_busy) ...[
                  const SizedBox(height: LabFoxSpacing.sm),
                  LinearProgressIndicator(
                    semanticsLabel: l.mrPendingComposePrepare,
                  ),
                  Text(l.mrPendingComposePrepare),
                ],
                if (!ready && !preparing && !_busy) ...[
                  Text(l.mrPendingComposePrepareError),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const ValueKey('mr-pending-compose-prepare-retry'),
                      onPressed: _retryPreparation,
                      child: Text(l.retry),
                    ),
                  ),
                ],
                if (_saveError) Text(l.mrPendingComposeSaveError),
                if (_needsInspection) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l.mrPendingComposeUncertain),
                ],
                if (_inspectionError) Text(l.mrPendingComposeInspectError),
                if (_inspection case final notes?) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(
                    l.mrPendingComposeInspectionTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(l.mrPendingComposeInspectionHint),
                  Text(l.mrPendingReviewCount(notes.length)),
                  if (notes.isEmpty)
                    Text(l.mrPendingReviewEmpty)
                  else
                    SizedBox(
                      height:
                          LabFoxSpacing.minTouchTarget *
                          (notes.length == 1 ? 4 : 8),
                      child: ListView.separated(
                        primary: false,
                        itemCount: notes.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: LabFoxSpacing.xl),
                        itemBuilder: (_, index) => MrPendingReviewNote(
                          key: ValueKey(notes[index].id),
                          draft: notes[index],
                        ),
                      ),
                    ),
                  CheckboxListTile(
                    key: const ValueKey('mr-pending-compose-acknowledge'),
                    contentPadding: EdgeInsets.zero,
                    value: _acknowledged,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l.mrPendingComposeAcknowledge),
                    onChanged: _busy
                        ? null
                        : (value) =>
                              setState(() => _acknowledged = value ?? false),
                  ),
                ],
                if (_busy) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  LinearProgressIndicator(
                    semanticsLabel: _inspecting
                        ? l.mrPendingComposeInspecting
                        : l.mrPendingComposeSaving,
                  ),
                  Text(
                    _inspecting
                        ? l.mrPendingComposeInspecting
                        : l.mrPendingComposeSaving,
                  ),
                ],
              ],
              const SizedBox(height: LabFoxSpacing.md),
              // Keep actions in the same scroll surface so large translated
              // labels cannot consume the entire dialog above a keyboard.
              Wrap(
                alignment: WrapAlignment.end,
                spacing: LabFoxSpacing.sm,
                children: [
                  TextButton(
                    key: const ValueKey('mr-pending-compose-cancel'),
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(l.cancel),
                  ),
                  if (current && _needsInspection)
                    TextButton(
                      key: const ValueKey('mr-pending-compose-inspect'),
                      onPressed: ready && !_busy ? _inspect : null,
                      child: Text(l.mrPendingComposeInspect),
                    ),
                  TextButton(
                    key: const ValueKey('mr-pending-compose-save'),
                    onPressed: canSave ? _save : null,
                    child: Text(l.mrPendingComposeSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
