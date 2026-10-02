import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_tag_protection_controller.dart';
import 'widgets/container_tag_protection_delete_clear_dialog.dart';
import 'widgets/container_tag_protection_pattern_dialog.dart';

/// Reviews patterns and explicitly edits protection settings without guessing user access.
class ContainerTagProtectionScreen extends ConsumerWidget {
  const ContainerTagProtectionScreen({required this.projectId, super.key});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = containerTagProtectionControllerProvider(projectId);
    final rules = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.containerTagProtectionTitle),
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
                    l10n.containerTagProtectionForbidden,
                  GitLabNotFoundException() =>
                    l10n.containerTagProtectionUnavailable,
                  _ => l10n.containerTagProtectionError,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.containerTagProtectionHint),
                        const SizedBox(height: LabFoxSpacing.md),
                        if (data.isEmpty)
                          Text(l10n.containerTagProtectionEmpty),
                        for (final rule in data)
                          Card.outlined(
                            child: Padding(
                              padding: const EdgeInsets.all(LabFoxSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        tooltip: l10n
                                            .containerTagProtectionDeleteClearTitle,
                                        icon: const Icon(
                                          Icons.lock_open_outlined,
                                        ),
                                        onPressed: () async {
                                          final saved = await showDialog<bool>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) =>
                                                ContainerTagProtectionDeleteClearDialog(
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
                                                  l10n.containerTagProtectionDeleteClearSaved,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        tooltip: l10n
                                            .containerTagProtectionPatternTitle,
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () async {
                                          final saved = await showDialog<bool>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) =>
                                                ContainerTagProtectionPatternDialog(
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
                                                  l10n.containerTagProtectionPatternSaved,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    rule.tagNamePattern,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: LabFoxSpacing.sm),
                                  Text(
                                    l10n.containerTagProtectionPushRole(
                                      _role(
                                        l10n,
                                        rule.minimumAccessLevelForPush,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: LabFoxSpacing.sm),
                                  Text(
                                    l10n.containerTagProtectionDeleteRole(
                                      _role(
                                        l10n,
                                        rule.minimumAccessLevelForDelete,
                                      ),
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
  null || '' => l10n.containerTagProtectionRoleUnset,
  'maintainer' => l10n.memberRoleMaintainer,
  'owner' => l10n.memberRoleOwner,
  'admin' => l10n.containerTagProtectionRoleAdmin,
  _ => l10n.memberRoleUnknown,
};
