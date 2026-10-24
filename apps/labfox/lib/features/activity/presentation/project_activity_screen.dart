import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/project_activity_controller.dart';

/// Recent events visible to the user in a project.
class ProjectActivityScreen extends ConsumerStatefulWidget {
  const ProjectActivityScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<ProjectActivityScreen> createState() =>
      _ProjectActivityScreenState();
}

class _ProjectActivityScreenState extends ConsumerState<ProjectActivityScreen> {
  String? _targetType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = ProjectActivityRef(
      projectId: widget.projectId,
      targetType: _targetType,
    );
    final activity = ref.watch(projectActivityControllerProvider(key));
    final filters = <(String?, String)>[
      (null, l10n.activityAll),
      ('issue', l10n.activityIssues),
      ('merge_request', l10n.activityMergeRequests),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activityTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(widget.projectId)),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: Row(
                  children: [
                    for (final filter in filters) ...[
                      ChoiceChip(
                        label: Text(filter.$2),
                        selected: _targetType == filter.$1,
                        onSelected: (_) =>
                            setState(() => _targetType = filter.$1),
                      ),
                      const SizedBox(width: LabFoxSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: activity.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.activityError),
                    const SizedBox(height: LabFoxSpacing.md),
                    FilledButton(
                      onPressed: () => ref.invalidate(
                        projectActivityControllerProvider(key),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(child: Text(l10n.activityEmpty))
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        projectActivityControllerProvider(key).future,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth =
                              constraints.maxWidth >= LabFoxBreakpoints.tablet
                              ? 900.0
                              : constraints.maxWidth;
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: maxWidth,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      LabFoxSpacing.md,
                                    ),
                                    child: Card.outlined(
                                      margin: EdgeInsets.zero,
                                      child: Column(
                                        children: [
                                          for (final event in page.items)
                                            _ActivityTile(
                                              event: event,
                                              projectId: widget.projectId,
                                            ),
                                          if (page.hasMore)
                                            TextButton(
                                              onPressed: () => ref
                                                  .read(
                                                    projectActivityControllerProvider(
                                                      key,
                                                    ).notifier,
                                                  )
                                                  .loadMore(),
                                              child: Text(
                                                l10n.activityLoadMore,
                                              ),
                                            ),
                                        ],
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.event, required this.projectId});

  final ProjectEvent event;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actor =
        event.author?.name ?? event.authorUsername ?? l10n.activityUnknownActor;
    final title =
        event.targetTitle ??
        event.pushData?.commitTitle ??
        event.pushData?.ref ??
        (event.pushData != null ? l10n.activityPush : l10n.activityEvent);
    final route = switch ((event.targetType, event.targetIid)) {
      ('Issue', final int iid) => Routes.issue(projectId, iid),
      ('MergeRequest', final int iid) => Routes.mergeRequest(projectId, iid),
      _ => null,
    };
    final icon = switch (event.targetType) {
      'Issue' => LabFoxIcons.issueOpen,
      'MergeRequest' => LabFoxIcons.mergeRequest,
      _ when event.pushData != null => LabFoxIcons.commit,
      _ => LabFoxIcons.history,
    };
    final date = event.createdAt == null
        ? null
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).add_jm().format(event.createdAt!.toLocal());
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.activityBy(actor, event.actionName)),
          if (date != null) Text(date),
        ],
      ),
      trailing: route == null ? null : const Icon(LabFoxIcons.chevron),
      onTap: route == null ? null : () => context.push(route),
    );
  }
}
