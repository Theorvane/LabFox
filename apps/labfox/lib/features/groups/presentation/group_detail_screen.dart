import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/share_link_button.dart';
import '../../../l10n/app_localizations.dart';
import '../data/group_overview.dart';
import 'controllers/group_detail_controller.dart';

/// A group and the projects and child groups directly inside it.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(groupDetailControllerProvider(groupId));
    final group = overview.valueOrNull?.group;

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? l10n.groupDetailTitle),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.groups),
        ),
        actions: [
          IconButton(
            tooltip: l10n.milestonesTitle,
            icon: const Icon(LabFoxIcons.milestone),
            onPressed: () => context.push(Routes.groupMilestones(groupId)),
          ),
          IconButton(
            tooltip: l10n.groupLabelsTitle,
            icon: const Icon(LabFoxIcons.label),
            onPressed: () => context.push(Routes.groupLabels(groupId)),
          ),
          IconButton(
            tooltip: l10n.groupMembersTitle,
            icon: const Icon(LabFoxIcons.person),
            onPressed: () => context.push(Routes.groupMembers(groupId)),
          ),
          ShareLinkButton(url: group?.webUrl),
        ],
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.groupDetailError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () => ref
                      .read(groupDetailControllerProvider(groupId).notifier)
                      .refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref
              .read(groupDetailControllerProvider(groupId).notifier)
              .refresh(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sections = <Widget>[
                _GroupSection(
                  title: l10n.groupSubgroups,
                  children: [
                    if (data.subgroups.items.isEmpty)
                      _EmptySection(l10n.groupSubgroupsEmpty)
                    else
                      for (final subgroup in data.subgroups.items)
                        ProjectTile(
                          name: subgroup.name,
                          path: subgroup.fullPath,
                          description: subgroup.description,
                          avatarUrl: subgroup.avatarUrl,
                          visibility: subgroup.visibility,
                          trailing: const Icon(LabFoxIcons.chevron),
                          onTap: () => context.push(Routes.group(subgroup.id)),
                        ),
                    if (data.subgroups.hasMore)
                      TextButton(
                        onPressed: () => ref
                            .read(
                              groupDetailControllerProvider(groupId).notifier,
                            )
                            .loadMoreSubgroups(),
                        child: Text(l10n.groupLoadMore),
                      ),
                  ],
                ),
                _GroupSection(
                  title: l10n.groupProjects,
                  children: [
                    if (data.projects.items.isEmpty)
                      _EmptySection(l10n.groupProjectsEmpty)
                    else
                      for (final project in data.projects.items)
                        ProjectTile(
                          name: project.name,
                          path: project.pathWithNamespace,
                          description: project.description,
                          avatarUrl: project.avatarUrl,
                          visibility: project.visibility,
                          starCount: project.starCount,
                          trailing: const Icon(LabFoxIcons.chevron),
                          onTap: () =>
                              context.push(Routes.projectOverview(project.id)),
                        ),
                    if (data.projects.hasMore)
                      TextButton(
                        onPressed: () => ref
                            .read(
                              groupDetailControllerProvider(groupId).notifier,
                            )
                            .loadMoreProjects(),
                        child: Text(l10n.groupLoadMore),
                      ),
                  ],
                ),
              ];
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _GroupHeader(data: data),
                            const SizedBox(height: LabFoxSpacing.md),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () => context.push(
                                  Routes.groupProtectedEnvironments(groupId),
                                ),
                                icon: const Icon(LabFoxIcons.private),
                                label: Text(l10n.protectedEnvironmentsTitle),
                              ),
                            ),
                            const SizedBox(height: LabFoxSpacing.lg),
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: sections[0]),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: sections[1]),
                                ],
                              )
                            else ...[
                              sections[0],
                              const SizedBox(height: LabFoxSpacing.md),
                              sections[1],
                            ],
                          ],
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
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.data});

  final GroupOverview data;

  @override
  Widget build(BuildContext context) {
    final group = data.group;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(LabFoxRadius.md),
            image: group.avatarUrl == null
                ? null
                : DecorationImage(
                    image: NetworkImage(group.avatarUrl!),
                    fit: BoxFit.cover,
                  ),
          ),
          child: group.avatarUrl == null ? const Icon(LabFoxIcons.group) : null,
        ),
        const SizedBox(width: LabFoxSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: theme.textTheme.headlineSmall),
              Text(group.fullPath, style: LabFoxTextRoles.of(context).meta),
              if (group.description?.trim().isNotEmpty == true) ...[
                const SizedBox(height: LabFoxSpacing.sm),
                Text(group.description!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card.outlined(
    margin: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            LabFoxSpacing.md,
            LabFoxSpacing.md,
            LabFoxSpacing.md,
            LabFoxSpacing.sm,
          ),
          child: Text(title, style: LabFoxTextRoles.of(context).sectionHeader),
        ),
        ...children,
        const SizedBox(height: LabFoxSpacing.sm),
      ],
    ),
  );
}

class _EmptySection extends StatelessWidget {
  const _EmptySection(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(LabFoxSpacing.md),
    child: Text(message, style: LabFoxTextRoles.of(context).meta),
  );
}
