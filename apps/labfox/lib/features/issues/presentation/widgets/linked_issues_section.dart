import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/issues_controllers.dart';
import '../controllers/linked_issues_controller.dart';

/// Related issues, including links to issues in other projects.
class LinkedIssuesSection extends ConsumerWidget {
  const LinkedIssuesSection({
    required this.projectId,
    required this.iid,
    super.key,
  });

  final int projectId;
  final int iid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = IssueRef(projectId: projectId, iid: iid);
    final links = ref.watch(linkedIssuesControllerProvider(key));
    final content = links.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.linkedIssuesError),
          TextButton(
            onPressed: () =>
                ref.invalidate(linkedIssuesControllerProvider(key)),
            child: Text(l10n.retry),
          ),
        ],
      ),
      data: (page) => page.items.isEmpty
          ? const SizedBox.shrink()
          : Card.outlined(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final link in page.items) _LinkTile(link: link),
                  if (page.hasMore)
                    TextButton(
                      onPressed: () => ref
                          .read(linkedIssuesControllerProvider(key).notifier)
                          .loadMore(),
                      child: Text(l10n.linkedIssuesLoadMore),
                    ),
                ],
              ),
            ),
    );
    if (links.valueOrNull?.items.isEmpty == true) {
      return const SizedBox.shrink();
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.linkedIssuesTitle,
            style: LabFoxTextRoles.of(context).sectionHeader,
          ),
          const SizedBox(height: LabFoxSpacing.sm),
          content,
          const SizedBox(height: LabFoxSpacing.lg),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.link});

  final IssueLink link;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final relation = switch (link.linkType) {
      'blocks' => l10n.linkedIssuesBlocks,
      'is_blocked_by' => l10n.linkedIssuesBlockedBy,
      _ => l10n.linkedIssuesRelatesTo,
    };
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(link.iid);
    return ListTile(
      leading: Icon(
        link.state == 'opened'
            ? LabFoxIcons.issueOpen
            : LabFoxIcons.issueClosed,
      ),
      title: Text(link.title),
      subtitle: Text('$relation · #$number'),
      trailing: const Icon(LabFoxIcons.chevron),
      onTap: () => context.push(Routes.issue(link.projectId, link.iid)),
    );
  }
}
