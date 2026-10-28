import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/storage/local_projects_providers.dart';
import '../../../core/ui/link_opener.dart';
import '../../../core/ui/share_link_button.dart';
import '../../../l10n/app_localizations.dart';
import '../data/project_overview.dart';
import 'controllers/project_overview_controller.dart';

/// A project's overview: identity, README, and links into its sections.
class ProjectOverviewScreen extends ConsumerStatefulWidget {
  const ProjectOverviewScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<ProjectOverviewScreen> createState() =>
      _ProjectOverviewScreenState();
}

class _ProjectOverviewScreenState extends ConsumerState<ProjectOverviewScreen> {
  @override
  void initState() {
    super.initState();
    // Record the project as recently opened once it has loaded. Fires
    // immediately so an already-cached project still counts, and recording is
    // idempotent (it just moves the project to the front).
    ref.listenManual(projectOverviewControllerProvider(widget.projectId), (
      _,
      next,
    ) {
      final project = next.valueOrNull?.project;
      if (project != null) {
        ref.read(recentProjectsProvider.notifier).record(project);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId;
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(projectOverviewControllerProvider(projectId));

    final project = overview.valueOrNull?.project;
    final isFavorite = ref.watch(
      favoriteProjectsProvider.select(
        (favorites) => favorites.any((p) => p.id == projectId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.name ?? l10n.projectOverviewTitle),
        actions: [
          if (project != null)
            IconButton(
              icon: Icon(
                isFavorite ? LabFoxIcons.star : LabFoxIcons.starBorder,
              ),
              tooltip: isFavorite
                  ? l10n.projectRemoveFavorite
                  : l10n.projectAddFavorite,
              onPressed: () =>
                  ref.read(favoriteProjectsProvider.notifier).toggle(project),
            ),
          ShareLinkButton(url: project?.webUrl),
        ],
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Error(
          message: l10n.projectOverviewError,
          onRetry: () => ref
              .read(projectOverviewControllerProvider(projectId).notifier)
              .refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref
              .read(projectOverviewControllerProvider(projectId).notifier)
              .refresh(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final navigation = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data.project.defaultBranch != null) ...[
                    Card.outlined(
                      margin: EdgeInsets.zero,
                      child: _CodeSection(project: data.project),
                    ),
                    const SizedBox(height: LabFoxSpacing.md),
                  ],
                  Card.outlined(
                    margin: EdgeInsets.zero,
                    child: _Categories(project: data.project),
                  ),
                ],
              );
              final readme = Card.outlined(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(LabFoxSpacing.md),
                  child: _Readme(overview: data),
                ),
              );
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Header(project: data.project),
                            const SizedBox(height: LabFoxSpacing.lg),
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        constraints.maxWidth >=
                                            LabFoxBreakpoints.desktop
                                        ? 320
                                        : 240,
                                    child: navigation,
                                  ),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: readme),
                                ],
                              )
                            else ...[
                              navigation,
                              const SizedBox(height: LabFoxSpacing.md),
                              readme,
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

/// Quick access to project work areas, retaining the available issue count.
class _Categories extends StatelessWidget {
  const _Categories({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final branch = project.defaultBranch;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LauncherTile(
          icon: Icons.error_outline,
          color: status.open.foreground,
          label: l10n.projectOverviewIssues,
          count: project.openIssuesCount,
          onTap: () => context.push(Routes.issues(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.mergeRequest,
          color: status.merged.foreground,
          label: l10n.projectOverviewMergeRequests,
          onTap: () => context.push(Routes.mergeRequests(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.pipeline,
          color: status.running.foreground,
          label: l10n.projectOverviewPipelines,
          onTap: () => context.push(Routes.pipelines(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.pipeline,
          color: status.pending.foreground,
          label: l10n.pipelineSchedulesTitle,
          onTap: () => context.push(Routes.pipelineSchedules(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.history,
          color: status.pending.foreground,
          label: l10n.activityTitle,
          onTap: () => context.push(Routes.projectActivity(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.release,
          color: status.pending.foreground,
          label: l10n.releasesTitle,
          onTap: () => context.push(Routes.releases(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.code,
          color: status.pending.foreground,
          label: l10n.snippetsTitle,
          onTap: () => context.push(Routes.snippets(project.id)),
        ),
        if (project.containerRegistryAccessLevel != 'disabled')
          LauncherTile(
            icon: LabFoxIcons.containerRegistry,
            color: status.pending.foreground,
            label: l10n.containerRegistryTitle,
            onTap: () => context.push(Routes.containerRegistry(project.id)),
          ),
        if (project.wikiAccessLevel != 'disabled' &&
            project.wikiEnabled != false)
          LauncherTile(
            icon: LabFoxIcons.document,
            color: status.pending.foreground,
            label: l10n.wikiTitle,
            onTap: () => context.push(Routes.wiki(project.id)),
          ),
        if (project.packageRegistryAccessLevel != 'disabled')
          LauncherTile(
            icon: LabFoxIcons.packageRegistry,
            color: status.pending.foreground,
            label: l10n.packageRegistryTitle,
            onTap: () => context.push(Routes.packages(project.id)),
          ),
        LauncherTile(
          icon: LabFoxIcons.label,
          color: status.pending.foreground,
          label: l10n.projectLabelsTitle,
          onTap: () => context.push(Routes.projectLabels(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.person,
          color: status.pending.foreground,
          label: l10n.projectMembersTitle,
          onTap: () => context.push(Routes.projectMembers(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.milestone,
          color: status.pending.foreground,
          label: l10n.milestonesTitle,
          onTap: () => context.push(Routes.milestones(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.environment,
          color: status.running.foreground,
          label: l10n.environmentsTitle,
          onTap: () => context.push(Routes.environments(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.pipeline,
          color: status.running.foreground,
          label: l10n.deploymentsTitle,
          onTap: () => context.push(Routes.deployments(project.id)),
        ),
        if (branch != null)
          LauncherTile(
            icon: LabFoxIcons.history,
            color: status.pending.foreground,
            label: l10n.projectOverviewCommits,
            onTap: () => context.push(Routes.commits(project.id, branch)),
          ),
      ],
    );
  }
}

/// Code access for the current default branch. Hidden for an empty repository.
class _CodeSection extends StatelessWidget {
  const _CodeSection({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = LabFoxStatusColors.of(context);
    final branch = project.defaultBranch;
    if (branch == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: LabFoxSpacing.md,
            right: LabFoxSpacing.md,
            top: LabFoxSpacing.md,
          ),
          child: Text(
            l10n.projectOverviewCode,
            style: LabFoxTextRoles.of(context).sectionHeader,
          ),
        ),
        const SizedBox(height: LabFoxSpacing.xs),
        LauncherTile(
          icon: LabFoxIcons.branch,
          color: status.pending.foreground,
          label: branch,
          onTap: () => context.push(Routes.branches(project.id)),
        ),
        LauncherTile(
          icon: LabFoxIcons.code,
          color: status.pending.foreground,
          label: l10n.projectOverviewBrowseCode,
          onTap: () => context.push(Routes.repository(project.id, branch)),
        ),
        LauncherTile(
          icon: LabFoxIcons.branch,
          color: status.pending.foreground,
          label: l10n.tagsTitle,
          onTap: () => context.push(Routes.tags(project.id)),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
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
            image: project.avatarUrl == null
                ? null
                : DecorationImage(
                    image: NetworkImage(project.avatarUrl!),
                    fit: BoxFit.cover,
                  ),
          ),
          child: project.avatarUrl == null
              ? const Icon(LabFoxIcons.project)
              : null,
        ),
        const SizedBox(width: LabFoxSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: LabFoxSpacing.xs),
              Text(
                project.pathWithNamespace,
                style: LabFoxTextRoles.of(context).meta,
              ),
              if (project.description?.trim().isNotEmpty == true) ...[
                const SizedBox(height: LabFoxSpacing.sm),
                Text(project.description!),
              ],
              const SizedBox(height: LabFoxSpacing.sm),
              Wrap(
                spacing: LabFoxSpacing.md,
                runSpacing: LabFoxSpacing.xs,
                children: [
                  if (project.visibility != null)
                    _HeaderStat(
                      icon: project.visibility == 'private'
                          ? LabFoxIcons.private
                          : LabFoxIcons.public,
                      label: project.visibility!,
                    ),
                  _HeaderStat(
                    icon: LabFoxIcons.starBorder,
                    label: '${project.starCount}',
                  ),
                  if (project.forksCount != null)
                    _HeaderStat(
                      icon: LabFoxIcons.fork,
                      label: '${project.forksCount}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: LabFoxIconSize.sm, color: LabFoxColors.pending),
      const SizedBox(width: LabFoxSpacing.xs),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

class _Readme extends ConsumerWidget {
  const _Readme({required this.overview});

  final ProjectOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final readme = overview.readme;
    if (readme == null || readme.trim().isEmpty) {
      return Text(
        l10n.projectOverviewNoReadme,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final open = ref.watch(linkOpenerProvider);
    return MarkdownViewer(
      data: readme,
      onTapLink: (href) {
        final uri = Uri.tryParse(href);
        if (uri != null) {
          open(uri);
        }
      },
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: LabFoxSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
