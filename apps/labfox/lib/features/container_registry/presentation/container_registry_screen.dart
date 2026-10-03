import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_registry_controllers.dart';
import 'controllers/container_repository_delete_controller.dart';
import 'widgets/cleanup_policy_cadence_dialog.dart';
import 'widgets/cleanup_policy_keep_count_dialog.dart';
import 'widgets/cleanup_policy_keep_pattern_dialog.dart';
import 'widgets/container_repository_delete_dialog.dart';

/// Project container image repositories.
class ContainerRegistryScreen extends ConsumerWidget {
  const ContainerRegistryScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repositories = ref.watch(
      containerRepositoriesControllerProvider(projectId),
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(projectId)),
        ),
        actions: [
          IconButton(
            icon: const Icon(LabFoxIcons.private),
            tooltip: l10n.containerRepositoryProtectionTitle,
            onPressed: () => context.push(
              Routes.containerRepositoryProtectionRules(projectId),
            ),
          ),
          IconButton(
            tooltip: l10n.containerKeepPatternTitle,
            icon: const Icon(Icons.shield_outlined),
            onPressed: () async {
              final accepted = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    CleanupPolicyKeepPatternDialog(projectId: projectId),
              );
              if (accepted == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.containerKeepPatternAccepted)),
                );
              }
            },
          ),
          IconButton(
            tooltip: l10n.containerKeepCountTitle,
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () async {
              final accepted = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    CleanupPolicyKeepCountDialog(projectId: projectId),
              );
              if (accepted == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.containerKeepCountAccepted)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: l10n.containerImmutabilityTitle,
            onPressed: () =>
                context.push(Routes.containerImmutability(projectId)),
          ),
          IconButton(
            tooltip: l10n.containerCadenceTitle,
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              final accepted = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    CleanupPolicyCadenceDialog(projectId: projectId),
              );
              if (accepted == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.containerCadenceAccepted)),
                );
              }
            },
          ),
          IconButton(
            tooltip: l10n.containerTagProtectionTitle,
            icon: const Icon(Icons.shield_outlined),
            onPressed: () =>
                context.push(Routes.containerTagProtectionRules(projectId)),
          ),
        ],
        title: Text(l10n.containerRegistryTitle),
      ),
      body: repositories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.containerRegistryError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(
                  containerRepositoriesControllerProvider(projectId),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? Center(child: Text(l10n.containerRegistryEmpty))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  containerRepositoriesControllerProvider(projectId).future,
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Padding(
                          padding: const EdgeInsets.all(LabFoxSpacing.md),
                          child: Card.outlined(
                            margin: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (final repository in page.items)
                                  _RepositoryTile(
                                    projectId: projectId,
                                    repository: repository,
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          containerRepositoriesControllerProvider(
                                            projectId,
                                          ).notifier,
                                        )
                                        .loadMore(),
                                    child: Text(l10n.containerLoadMore),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RepositoryTile extends ConsumerWidget {
  const _RepositoryTile({required this.projectId, required this.repository});
  final int projectId;
  final RegistryRepository repository;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = RegistryRef(projectId: projectId, repositoryId: repository.id);
    final deletion = ref.watch(
      containerRepositoryDeleteControllerProvider(key),
    );
    final scheduled =
        deletion.valueOrNull == true ||
        repository.status == 'delete_scheduled' ||
        repository.status == 'delete_ongoing';
    return ListTile(
      leading: const Icon(LabFoxIcons.containerRegistry),
      title: Text(repository.path),
      subtitle: scheduled
          ? Text(l10n.containerRepositoryDeletionScheduled)
          : repository.location == null
          ? null
          : Text(repository.location!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.containerRepositoryDelete,
            onPressed: scheduled || deletion.isLoading
                ? null
                : () async {
                    final accepted = await showDialog<bool>(
                      context: context,
                      builder: (_) => ContainerRepositoryDeleteDialog(
                        repositoryRef: key,
                        path: repository.path,
                      ),
                    );
                    if (accepted == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.containerRepositoryDeletionNotice),
                        ),
                      );
                    }
                  },
          ),
          const Icon(LabFoxIcons.chevron),
        ],
      ),
      onTap: scheduled || deletion.isLoading
          ? null
          : () => context.push(
              Routes.containerRepository(projectId, repository.id),
            ),
    );
  }
}
