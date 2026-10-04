import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/mr_discussion_context_controller.dart';

/// Opens original context inside the conversation, retaining its comment draft.
class MrDiscussionPositionContext extends ConsumerStatefulWidget {
  const MrDiscussionPositionContext({
    required this.projectId,
    required this.iid,
    required this.noteId,
    required this.position,
    super.key,
  });
  final int projectId;
  final int iid;
  final int noteId;
  final DiffNotePosition position;
  @override
  ConsumerState<MrDiscussionPositionContext> createState() =>
      _PositionContextState();
}

class _PositionContextState extends ConsumerState<MrDiscussionPositionContext> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = mrDiscussionContextControllerProvider(
      MrDiscussionContextRef(
        projectId: widget.projectId,
        iid: widget.iid,
        position: widget.position,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: ValueKey(
              _expanded
                  ? 'mr-context-hide-${widget.noteId}'
                  : 'mr-context-open-${widget.noteId}',
            ),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded
                  ? l10n.mrDiscussionContextHideButton
                  : l10n.mrDiscussionContextViewButton,
            ),
          ),
        ),
        if (_expanded)
          Padding(
            key: ValueKey('mr-context-${widget.noteId}'),
            padding: const EdgeInsets.all(LabFoxSpacing.sm),
            child: ref
                .watch(provider)
                .when(
                  skipLoadingOnRefresh: false,
                  skipLoadingOnReload: false,
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: l10n.mrDiscussionContextLoading,
                    ),
                  ),
                  error: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.mrDiscussionContextError),
                      TextButton(
                        onPressed: () => ref.invalidate(provider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                  data: (value) {
                    final file = value.file, line = value.line;
                    if (file != null &&
                        line != null &&
                        value.versionId != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.mrDiscussionContextTitle(
                              NumberFormat.decimalPattern(
                                l10n.localeName,
                              ).format(value.versionId),
                            ),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: LabFoxSpacing.xs),
                          Text(file.displayPath),
                          const SizedBox(height: LabFoxSpacing.sm),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.sizeOf(context).height / 2,
                            ),
                            child: SingleChildScrollView(
                              child: DiffViewer(
                                file: file,
                                highlightedLine: line,
                                highlightedLineLabel:
                                    l10n.mrDiscussionContextLineLabel,
                                focusOnHighlightedLine: true,
                                binaryLabel: l10n.changesBinary,
                                omittedLabel: l10n.changesOmitted,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.mrDiscussionContextUnavailable),
                        if (value.loadMoreFailed)
                          Text(l10n.mrDiscussionContextError),
                        if (value.loadingMore)
                          CircularProgressIndicator(
                            semanticsLabel: l10n.mrDiscussionContextLoading,
                          ),
                        if (value.nextPage != null)
                          TextButton(
                            onPressed: value.loadingMore
                                ? null
                                : () => ref.read(provider.notifier).loadMore(),
                            child: Text(l10n.mrDiscussionContextOlderButton),
                          ),
                      ],
                    );
                  },
                ),
          ),
      ],
    );
  }
}
