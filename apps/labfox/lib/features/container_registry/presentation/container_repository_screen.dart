import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_registry_controllers.dart';
import 'widgets/container_tag_cleanup_dialog.dart';

/// Tags published to one container image repository.
class ContainerRepositoryScreen extends ConsumerWidget {
  const ContainerRepositoryScreen({
    required this.projectId,
    required this.repositoryId,
    super.key,
  });

  final int projectId;
  final int repositoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = RegistryRef(projectId: projectId, repositoryId: repositoryId);
    final tags = ref.watch(containerTagsControllerProvider(key));
    final pending = ref
        .watch(containerTagCleanupControllerProvider(key))
        .isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.containerTagsTitle),
        leading: BackButton(
          onPressed: pending
              ? null
              : () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.containerRegistry(projectId)),
        ),
        actions: [
          IconButton(
            tooltip: l10n.containerCleanupTitle,
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed:
                pending || tags.isLoading || tags.hasError || !tags.hasValue
                ? null
                : () async {
                    final scheduled = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          ContainerTagCleanupDialog(repository: key),
                    );
                    if (scheduled == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.containerCleanupScheduled)),
                      );
                    }
                  },
          ),
        ],
      ),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.containerTagsError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(containerTagsControllerProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? Center(child: Text(l10n.containerTagsEmpty))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(containerTagsControllerProvider(key).future),
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
                                for (final tag in page.items)
                                  ListTile(
                                    leading: const Icon(
                                      LabFoxIcons.containerRegistry,
                                    ),
                                    title: Text(tag.name),
                                    trailing: const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      Routes.containerTag(
                                        projectId,
                                        repositoryId,
                                        tag.name,
                                      ),
                                    ),
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          containerTagsControllerProvider(
                                            key,
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
