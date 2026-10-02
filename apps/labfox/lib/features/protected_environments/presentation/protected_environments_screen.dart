import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_environments_controller.dart';
import 'widgets/protected_environment_create_dialog.dart';

/// Project or group protected deployment environments.
class ProtectedEnvironmentsScreen extends ConsumerWidget {
  const ProtectedEnvironmentsScreen({required this.projectId, super.key})
    : groupId = null;

  const ProtectedEnvironmentsScreen.group({required this.groupId, super.key})
    : projectId = null;

  final int? projectId;
  final int? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projectId = this.projectId;
    final groupId = this.groupId;
    final rules = groupId == null
        ? ref.watch(protectedEnvironmentsControllerProvider(projectId!))
        : ref.watch(groupProtectedEnvironmentsControllerProvider(groupId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.protectedEnvironmentsTitle),
        actions: [
          if (projectId != null)
            IconButton(
              key: const ValueKey('protected-environment-create-open'),
              tooltip: l10n.protectedEnvironmentCreateTitle,
              icon: const Icon(LabFoxIcons.add),
              onPressed: () async {
                final created = await showDialog<bool>(
                  context: context,
                  builder: (_) =>
                      ProtectedEnvironmentCreateDialog(projectId: projectId),
                );
                if (created == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.protectedEnvironmentCreateSuccess),
                    ),
                  );
                }
              },
            ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(
                  groupId == null
                      ? Routes.environments(projectId!)
                      : Routes.group(groupId),
                ),
        ),
      ),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error is GitLabForbiddenException
                    ? l10n.protectedEnvironmentsUnavailable
                    : l10n.protectedEnvironmentsError,
              ),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => groupId == null
                    ? ref.invalidate(
                        protectedEnvironmentsControllerProvider(projectId!),
                      )
                    : ref.invalidate(
                        groupProtectedEnvironmentsControllerProvider(groupId),
                      ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? EmptyState(
                icon: LabFoxIcons.private,
                title: l10n.protectedEnvironmentsEmpty,
              )
            : RefreshIndicator(
                onRefresh: () => groupId == null
                    ? ref.refresh(
                        protectedEnvironmentsControllerProvider(
                          projectId!,
                        ).future,
                      )
                    : ref.refresh(
                        groupProtectedEnvironmentsControllerProvider(
                          groupId,
                        ).future,
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
                                for (final rule in page.items)
                                  ListTile(
                                    leading: const Icon(LabFoxIcons.private),
                                    title: Text(rule.name),
                                    subtitle: rule.requiredApprovalCount > 0
                                        ? Text(
                                            l10n.protectedEnvironmentApprovalCount(
                                              rule.requiredApprovalCount,
                                            ),
                                          )
                                        : null,
                                    trailing: const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      groupId == null
                                          ? Routes.protectedEnvironment(
                                              projectId!,
                                              rule.name,
                                            )
                                          : Routes.groupProtectedEnvironment(
                                              groupId,
                                              rule.name,
                                            ),
                                    ),
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => groupId == null
                                        ? ref
                                              .read(
                                                protectedEnvironmentsControllerProvider(
                                                  projectId!,
                                                ).notifier,
                                              )
                                              .loadMore()
                                        : ref
                                              .read(
                                                groupProtectedEnvironmentsControllerProvider(
                                                  groupId,
                                                ).notifier,
                                              )
                                              .loadMore(),
                                    child: Text(
                                      l10n.protectedEnvironmentsLoadMore,
                                    ),
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
