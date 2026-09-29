import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_registry_controllers.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: l10n.containerImmutabilityTitle,
            onPressed: () =>
                context.push(Routes.containerImmutability(projectId)),
          ),
        ],
        title: Text(l10n.containerRegistryTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(projectId)),
        ),
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
                                  ListTile(
                                    leading: const Icon(
                                      LabFoxIcons.containerRegistry,
                                    ),
                                    title: Text(repository.path),
                                    subtitle: repository.location == null
                                        ? null
                                        : Text(repository.location!),
                                    trailing: const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      Routes.containerRepository(
                                        projectId,
                                        repository.id,
                                      ),
                                    ),
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
