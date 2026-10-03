import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_repository_protection_controller.dart';
import 'widgets/container_repository_protection_create_dialog.dart';
import 'widgets/container_repository_protection_delete_clear_dialog.dart';
import 'widgets/container_repository_protection_delete_dialog.dart';

/// Reads protection patterns and required roles without guessing user access.
class ContainerRepositoryProtectionScreen extends ConsumerWidget {
  const ContainerRepositoryProtectionScreen({
    required this.projectId,
    super.key,
  });
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = containerRepositoryProtectionControllerProvider(projectId);
    final rules = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.containerRepositoryProtectionTitle),
        actions: [
          IconButton(
            tooltip: l10n.containerProtectionCreateTitle,
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ContainerRepositoryProtectionCreateDialog(
                  projectId: projectId,
                ),
              );
              if (created == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.containerProtectionCreateCreated),
                  ),
                );
              }
            },
          ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.containerRegistry(projectId)),
        ),
      ),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(switch (error) {
                  GitLabForbiddenException() =>
                    l10n.containerRepositoryProtectionForbidden,
                  GitLabNotFoundException() =>
                    l10n.containerRepositoryProtectionUnavailable,
                  _ => l10n.containerRepositoryProtectionError,
                }, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () => ref.invalidate(provider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            try {
              final refreshed = ref.refresh(provider.future);
              await refreshed;
            } catch (_) {
              // The provider renders the typed error and retry action.
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.all(LabFoxSpacing.md),
                    child: data.isEmpty
                        ? Text(l10n.containerRepositoryProtectionEmpty)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final rule in data)
                                Card.outlined(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      LabFoxSpacing.md,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rule.repositoryPathPattern,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(
                                          height: LabFoxSpacing.sm,
                                        ),
                                        Text(
                                          l10n.containerRepositoryProtectionPushRole(
                                            _role(
                                              l10n,
                                              rule.minimumAccessLevelForPush,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: LabFoxSpacing.sm,
                                        ),
                                        Text(
                                          l10n.containerRepositoryProtectionDeleteRole(
                                            _role(
                                              l10n,
                                              rule.minimumAccessLevelForDelete,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            tooltip: l10n
                                                .containerProtectionDeleteClearTitle,
                                            icon: const Icon(
                                              Icons.lock_open_outlined,
                                            ),
                                            onPressed: () async {
                                              final saved = await showDialog<bool>(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) =>
                                                    ContainerRepositoryProtectionDeleteClearDialog(
                                                      projectId: projectId,
                                                      rule: rule,
                                                    ),
                                              );
                                              if (saved == true &&
                                                  context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.containerProtectionDeleteClearSaved,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            tooltip: l10n
                                                .containerProtectionRemoveTitle,
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            onPressed: () async {
                                              final removed =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (_) =>
                                                        ContainerRepositoryProtectionDeleteDialog(
                                                          projectId: projectId,
                                                          rule: rule,
                                                        ),
                                                  );
                                              if (removed == true &&
                                                  context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.containerProtectionRemoveDeleted,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
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

String _role(AppLocalizations l10n, String? role) => switch (role) {
  null || '' => l10n.containerRepositoryProtectionRoleUnset,
  'maintainer' => l10n.memberRoleMaintainer,
  'owner' => l10n.memberRoleOwner,
  'admin' => l10n.containerRepositoryProtectionRoleAdmin,
  _ => l10n.memberRoleUnknown,
};
