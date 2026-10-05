import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/gitlab_client_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../comments/presentation/controllers/comments_controller.dart';
import '../controllers/merge_requests_controllers.dart';
import '../controllers/mr_discussions_controller.dart';
import '../controllers/mr_draft_notes_provider.dart';
import 'mr_pending_review_note.dart';

/// The originating view stays mounted during the controller's own detail refresh.
class MrPendingReviewPublisher extends ConsumerStatefulWidget {
  const MrPendingReviewPublisher({required this.mergeRequest, super.key});
  final MergeRequestRef mergeRequest;
  @override
  ConsumerState<MrPendingReviewPublisher> createState() => _EntryState();
}

class _EntryState extends ConsumerState<MrPendingReviewPublisher> {
  bool _opening = false;
  ValueNotifier<bool>? _view;
  @override
  void dispose() {
    _view?.value = false;
    super.dispose();
  }

  @override
  void didUpdateWidget(MrPendingReviewPublisher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mergeRequest != widget.mergeRequest) _view?.value = false;
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
    final resource = widget.mergeRequest;
    final active = ValueNotifier(true);
    _view = active;
    setState(() => _opening = true);
    try {
      final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _PublicationDialog(
          resource: resource,
          account: account,
          draftSession: drafts.value!,
          detailSession: source.value!,
          viewActive: active,
          isCurrent: () => mounted && widget.mergeRequest == resource,
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
            content: Text(AppLocalizations.of(context).mrPendingPublished),
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
        key: const ValueKey('mr-pending-publish-open'),
        onPressed: ready && !_opening ? _open : null,
        child: Text(AppLocalizations.of(context).mrPendingPublishOpen),
      ),
    );
  }
}

/// Uses the same consent and two-sided recovery flow for a selected saved note.
Future<bool?> showMrPendingReviewPublicationDialog({
  required BuildContext context,
  required MergeRequestRef resource,
  required Account account,
  required Object draftSession,
  required Object detailSession,
  required ValueNotifier<bool> viewActive,
  required bool Function() isCurrent,
  required MergeRequestDraftNote draft,
}) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _PublicationDialog(
    resource: resource,
    account: account,
    draftSession: draftSession,
    detailSession: detailSession,
    viewActive: viewActive,
    isCurrent: isCurrent,
    draft: draft,
  ),
);

class _PublicationDialog extends ConsumerStatefulWidget {
  const _PublicationDialog({
    required this.resource,
    required this.account,
    required this.draftSession,
    required this.detailSession,
    required this.viewActive,
    required this.isCurrent,
    this.draft,
  });
  final MergeRequestDraftNote? draft;
  final MergeRequestRef resource;
  final Account account;
  final Object draftSession, detailSession;
  final ValueNotifier<bool> viewActive;
  final bool Function() isCurrent;
  @override
  ConsumerState<_PublicationDialog> createState() => _PublicationState();
}

class _PublicationState extends ConsumerState<_PublicationDialog> {
  Object? _clientSession, _commentsSession;
  bool _obsolete = false, _started = false, _busy = false, _writing = false;
  bool _needsInspection = false, _acknowledged = false, _readError = false;
  final _summary = TextEditingController();
  ReviewerSubmissionState? _reviewerState;
  bool get _hasOptions =>
      widget.draft == null &&
      (_summary.text.trim().isNotEmpty || _reviewerState != null);
  bool get _hasSubmission =>
      _snapshot != null && (_snapshot!.items.isNotEmpty || _hasOptions);
  MrPendingReviewPublication? _snapshot;
  MrPendingReviewPublicationInspection? _inspection;
  @override
  void initState() {
    super.initState();
    widget.viewActive.addListener(_observe);
  }

  @override
  void dispose() {
    widget.viewActive.removeListener(_observe);
    _summary.dispose();
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
      (_clientSession == null ||
          identical(
            ref.read(gitLabClientProvider).unwrapPrevious().valueOrNull,
            _clientSession,
          )) &&
      (_commentsSession == null ||
          identical(
            ref.read(commentsRepositoryProvider).unwrapPrevious().valueOrNull,
            _commentsSession,
          ));
  void _observe() {
    if (_current()) return;
    scheduleMicrotask(() {
      if (!mounted || _obsolete) return;
      setState(() {
        _obsolete = true;
        _summary.clear();
        _reviewerState = null;
        _snapshot = null;
        _inspection = null;
        _acknowledged = false;
      });
    });
  }

  MrDiscussionsController get _controller =>
      ref.read(mrDiscussionsControllerProvider(widget.resource).notifier);
  Future<void> _read({required bool recovery}) async {
    if (_busy || !_current()) return;
    setState(() {
      _busy = true;
      _snapshot = null;
      _inspection = null;
      _acknowledged = false;
      _readError = false;
    });
    try {
      final provider = mrDiscussionsControllerProvider(widget.resource);
      if (ref.read(provider).hasError) {
        ref.invalidate(provider);
        await ref.read(provider.future);
        if (!_current()) return;
      }
      if (recovery) {
        final inspection = await _controller.inspectPendingReviewPublication(
          includeReviewerState: widget.draft == null,
          isCurrent: _current,
        );
        if (!_current()) return;
        if (inspection == null) {
          setState(() => _readError = true);
          return;
        }
        setState(() {
          _inspection = inspection;
          _snapshot = widget.draft == null
              ? inspection.pending
              : inspection.pending.forNote(widget.draft!.id);
          _reconcileOutcome();
        });
      } else {
        final snapshot = widget.draft == null
            ? await _controller.preparePendingReviewPublication(
                includeReviewerState: true,
                isCurrent: _current,
              )
            : await _controller.preparePendingNotePublication(
                widget.draft!,
                isCurrent: _current,
              );
        if (!_current()) return;
        setState(() {
          _snapshot = snapshot;
          _reconcileOutcome();
          _readError = snapshot == null;
        });
      }
    } catch (_) {
      if (_current()) setState(() => _readError = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reconcileOutcome() {
    final snapshot = _snapshot;
    if (snapshot != null &&
        (!snapshot.reviewerStateAvailable ||
            (_reviewerState == ReviewerSubmissionState.reviewed &&
                snapshot.reviewer?.state == 'approved'))) {
      // A newly inspected preview cannot keep an unavailable/disabled outcome.
      _reviewerState = null;
    }
  }

  Future<void> _publish() async {
    final snapshot = _snapshot;
    if (_busy ||
        !_current() ||
        !_acknowledged ||
        snapshot == null ||
        !_hasSubmission ||
        _controller.pendingSaveNeedsInspection) {
      return;
    }
    final summary = widget.draft == null && _summary.text.trim().isNotEmpty
        ? _summary.text
        : null;
    final outcome = _reviewerState;
    setState(() {
      _busy = true;
      _writing = true;
      _acknowledged = false;
      _snapshot = null;
      _inspection = null;
    });
    try {
      final published = widget.draft == null
          ? await _controller.publishPendingReview(
              snapshot,
              summaryNote: summary,
              reviewerState: outcome,
              isCurrent: _current,
            )
          : await _controller.publishPendingNote(snapshot, isCurrent: _current);
      if (!mounted || !_current()) return;
      if (published) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _needsInspection = true);
    } catch (_) {
      if (_current()) setState(() => _needsInspection = true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _writing = false;
        });
      }
    }
  }

  String _reviewLabel(AppLocalizations l, MergeRequestReviewer? reviewer) =>
      switch (reviewer?.state) {
        null => l.mrReviewUnassigned,
        'unreviewed' => l.mrReviewUnreviewed,
        'review_started' => l.mrReviewStarted,
        'reviewed' => l.mrReviewReviewed,
        'requested_changes' => l.mrReviewRequestChanges,
        'approved' => l.mrReviewApproved,
        'unapproved' => l.mrReviewUnapproved,
        _ => l.mrReviewUnknownState,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.listen(currentAccountProvider, (_, _) => _observe());
    ref.listen(mrDraftNotesRepositoryProvider, (_, _) => _observe());
    ref.listen(mergeRequestsRepositoryProvider, (_, _) => _observe());
    ref.listen(gitLabClientProvider, (_, _) => _observe());
    ref.listen(commentsRepositoryProvider, (_, _) => _observe());
    final client = ref.watch(gitLabClientProvider).unwrapPrevious();
    final comments = ref.watch(commentsRepositoryProvider).unwrapPrevious();
    if (_current()) {
      if (!client.isLoading && !client.hasError) {
        _clientSession ??= client.valueOrNull;
      }
      if (!comments.isLoading && !comments.hasError) {
        _commentsSession ??= comments.valueOrNull;
      }
    }
    final current = _current();
    if (!current) _observe();
    final discussions = current
        ? ref
              .watch(mrDiscussionsControllerProvider(widget.resource))
              .unwrapPrevious()
        : null;
    final dependenciesReady =
        current &&
        !client.isLoading &&
        !client.hasError &&
        client.valueOrNull != null &&
        !comments.isLoading &&
        !comments.hasError &&
        comments.valueOrNull != null &&
        discussions != null;
    final ready =
        dependenciesReady && !discussions.isLoading && !discussions.hasError;
    final gated = current && _controller.pendingSaveNeedsInspection;
    if (gated) _needsInspection = true;
    if (ready && !_started) {
      _started = true;
      if (!gated) scheduleMicrotask(() => _read(recovery: false));
    }
    final canPublish =
        ready &&
        !_busy &&
        !gated &&
        _snapshot != null &&
        _hasSubmission &&
        (_reviewerState == null || _snapshot!.reviewerStateAvailable) &&
        !(_reviewerState == ReviewerSubmissionState.reviewed &&
            _snapshot!.reviewer?.state == 'approved') &&
        _acknowledged;
    return PopScope(
      canPop: !_writing,
      child: AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.all(LabFoxSpacing.md),
        title: Text(
          widget.draft == null
              ? l.mrPendingPublishTitle
              : l.mrPendingPublishNoteTitle,
        ),
        content: SizedBox(
          width: LabFoxBreakpoints.tablet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!current)
                Text(l.mrPendingComposeChanged)
              else ...[
                Text(
                  widget.draft == null
                      ? l.mrPendingPublishHint
                      : l.mrPendingPublishNoteHint,
                ),
                const SizedBox(height: LabFoxSpacing.sm),
                Text(
                  widget.draft == null
                      ? l.mrPendingPublishRaceHint
                      : l.mrPendingPublishNoteRaceHint,
                ),
                if (_needsInspection) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l.mrPendingPublishUncertain),
                  if (widget.draft == null) Text(l.mrReviewPartialHint),
                ],
                if (_busy ||
                    (current &&
                        (client.isLoading ||
                            comments.isLoading ||
                            (discussions?.isLoading ?? false))))
                  LinearProgressIndicator(
                    semanticsLabel: l.mrPendingReviewLoading,
                  ),
                if (_readError ||
                    (discussions?.hasError ?? false) ||
                    comments.hasError ||
                    client.hasError)
                  Text(l.mrPendingReviewError),
                if (_snapshot != null) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l.mrPendingReviewCount(_snapshot!.items.length)),
                  if (_snapshot!.items.isEmpty) Text(l.mrPendingReviewEmpty),
                  for (final note in _snapshot!.items) ...[
                    const Divider(height: LabFoxSpacing.xl),
                    MrPendingReviewNote(draft: note),
                  ],
                ],
                if (_inspection != null) ...[
                  if (widget.draft != null && _snapshot == null)
                    Text(l.mrPendingTargetMissing),
                  if (widget.draft != null)
                    for (final note in _inspection!.pending.items.where(
                      (note) => note.id != widget.draft!.id,
                    )) ...[
                      const Divider(height: LabFoxSpacing.xl),
                      MrPendingReviewNote(draft: note),
                    ],
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(l.mrPendingPublishRecoveryHint),
                  const SizedBox(height: LabFoxSpacing.sm),
                  Text(
                    l.mrPendingPublishPublicTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final group in _inspection!.publicDiscussions)
                    for (final note in group.notes) ...[
                      const Divider(height: LabFoxSpacing.xl),
                      SelectableText(note.body),
                    ],
                ],
                if ((_snapshot ?? _inspection?.pending)
                    case final preview?) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  if (preview.reviewerStateAvailable) ...[
                    Text(
                      l.mrReviewCurrentState,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(_reviewLabel(l, preview.reviewer)),
                  ] else if (widget.draft == null)
                    Text(l.mrReviewStateUnavailable),
                ],
                if (widget.draft == null) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  TextField(
                    key: const ValueKey('mr-review-summary'),
                    controller: _summary,
                    minLines: 2,
                    maxLines: 5,
                    enabled: !_busy && !gated && _snapshot != null,
                    decoration: InputDecoration(
                      labelText: l.mrReviewSummaryLabel,
                    ),
                    onChanged: (_) => setState(() => _acknowledged = false),
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  DropdownButtonFormField<ReviewerSubmissionState?>(
                    key: const ValueKey('mr-review-state'),
                    initialValue: _reviewerState,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.mrReviewOutcomeLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l.mrReviewKeepState),
                      ),
                      DropdownMenuItem(
                        value: ReviewerSubmissionState.reviewed,
                        enabled: _snapshot?.reviewer?.state != 'approved',
                        child: Text(l.mrReviewReviewed),
                      ),
                      DropdownMenuItem(
                        value: ReviewerSubmissionState.requestedChanges,
                        child: Text(l.mrReviewRequestChanges),
                      ),
                    ],
                    onChanged:
                        _busy ||
                            gated ||
                            _snapshot?.reviewerStateAvailable != true
                        ? null
                        : (value) => setState(() {
                            _reviewerState = value;
                            _acknowledged = false;
                          }),
                  ),
                  if (_reviewerState == ReviewerSubmissionState.reviewed)
                    Text(l.mrReviewReviewedHint),
                  if (_reviewerState ==
                      ReviewerSubmissionState.requestedChanges)
                    Text(l.mrReviewChangesHint),
                ],
                if (_hasSubmission)
                  CheckboxListTile(
                    key: const ValueKey('mr-pending-publish-acknowledge'),
                    contentPadding: EdgeInsets.zero,
                    value: _acknowledged,
                    onChanged: _busy || gated
                        ? null
                        : (value) =>
                              setState(() => _acknowledged = value == true),
                    title: Text(
                      widget.draft == null
                          ? (_hasOptions
                                ? l.mrReviewSubmissionConsent
                                : l.mrPendingPublishConsent)
                          : l.mrPendingPublishNoteConsent,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
              ],
            ],
          ),
        ),
        actions: [
          Wrap(
            spacing: LabFoxSpacing.sm,
            runSpacing: LabFoxSpacing.sm,
            children: [
              TextButton(
                key: const ValueKey('mr-pending-publish-cancel'),
                onPressed: _writing ? null : () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
              if (current)
                OutlinedButton(
                  key: const ValueKey('mr-pending-publish-inspect'),
                  onPressed: dependenciesReady && !_busy
                      ? () => _read(recovery: true)
                      : null,
                  child: Text(
                    widget.draft == null
                        ? l.mrReviewInspectButton
                        : l.mrPendingPublishInspect,
                  ),
                ),
              FilledButton(
                key: const ValueKey('mr-pending-publish-submit'),
                onPressed: canPublish ? _publish : null,
                child: Text(
                  widget.draft == null
                      ? (_hasOptions
                            ? l.mrReviewSubmitButton
                            : l.mrPendingPublishButton)
                      : l.mrPendingPublishNoteButton,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
