import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_environments_controller.dart';
import 'widgets/protected_environment_deploy_role_dialog.dart';
import 'widgets/protected_environment_unprotect_dialog.dart';

/// One rule, restorable from its project or group and environment name.
class ProtectedEnvironmentDetailScreen extends ConsumerWidget {
  const ProtectedEnvironmentDetailScreen({
    required this.projectId,
    required this.name,
    super.key,
  }) : groupId = null;

  const ProtectedEnvironmentDetailScreen.group({
    required this.groupId,
    required this.name,
    super.key,
  }) : projectId = null;

  final int? projectId;
  final int? groupId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projectKey = projectId == null
        ? null
        : ProtectedEnvironmentRef(projectId: projectId!, name: name);
    final groupKey = groupId == null
        ? null
        : GroupProtectedEnvironmentRef(groupId: groupId!, name: name);
    final rule = groupKey == null
        ? ref.watch(protectedEnvironmentDetailProvider(projectKey!))
        : ref.watch(groupProtectedEnvironmentDetailProvider(groupKey));
    return Scaffold(
      appBar: AppBar(
        title: Text(rule.valueOrNull?.name ?? l10n.protectedEnvironmentsTitle),
        actions: [
          if (projectKey != null && rule.valueOrNull != null)
            IconButton(
              key: const ValueKey('protected-environment-deploy-role-open'),
              tooltip: l10n.protectedEnvironmentDeployRoleTitle,
              icon: const Icon(Icons.person_add_outlined),
              onPressed: () async {
                final added = await showDialog<bool>(
                  context: context,
                  builder: (_) => ProtectedEnvironmentDeployRoleDialog(
                    target: projectKey,
                    rule: rule.valueOrNull!,
                  ),
                );
                if (added == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.protectedEnvironmentDeployRoleSuccess),
                    ),
                  );
                }
              },
            ),
          if (projectKey != null && rule.valueOrNull != null)
            IconButton(
              key: const ValueKey('protected-environment-unprotect-open'),
              tooltip: l10n.protectedEnvironmentUnprotectTitle,
              icon: const Icon(Icons.lock_open_outlined),
              onPressed: () async {
                final removed = await showDialog<bool>(
                  context: context,
                  builder: (_) => ProtectedEnvironmentUnprotectDialog(
                    target: projectKey,
                    rule: rule.valueOrNull!,
                  ),
                );
                if (removed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.protectedEnvironmentUnprotectSuccess),
                    ),
                  );
                  context.go(Routes.protectedEnvironments(projectId!));
                }
              },
            ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(
                  groupId == null
                      ? Routes.protectedEnvironments(projectId!)
                      : Routes.groupProtectedEnvironments(groupId!),
                ),
        ),
      ),
      body: rule.when(
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
                onPressed: () => groupKey == null
                    ? ref.invalidate(
                        protectedEnvironmentDetailProvider(projectKey!),
                      )
                    : ref.invalidate(
                        groupProtectedEnvironmentDetailProvider(groupKey),
                      ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => groupKey == null
              ? ref.refresh(
                  protectedEnvironmentDetailProvider(projectKey!).future,
                )
              : ref.refresh(
                  groupProtectedEnvironmentDetailProvider(groupKey).future,
                ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final summary = Card.outlined(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(LabFoxSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: LabFoxSpacing.sm),
                      Text(
                        l10n.protectedEnvironmentApprovalCount(
                          data.requiredApprovalCount,
                        ),
                      ),
                    ],
                  ),
                ),
              );
              final permissions = Column(
                children: [
                  _AccessCard(
                    title: l10n.protectedEnvironmentDeployAccess,
                    entries: data.deployAccessLevels,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  _AccessCard(
                    title: l10n.protectedEnvironmentApprovalRules,
                    entries: data.approvalRules,
                    showRequiredApprovals: true,
                  ),
                ],
              );
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 300, child: summary),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: permissions),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  summary,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  permissions,
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

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.title,
    required this.entries,
    this.showRequiredApprovals = false,
  });

  final String title;
  final List<ProtectedEnvironmentAccess> entries;
  final bool showRequiredApprovals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: LabFoxTextRoles.of(context).sectionHeader),
            const SizedBox(height: LabFoxSpacing.sm),
            if (entries.isEmpty)
              Text(l10n.protectedBranchNoAccess)
            else
              for (final entry in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LabFoxIcons.person),
                  title: Text(
                    entry.description ?? l10n.protectedBranchNoAccess,
                  ),
                  subtitle:
                      showRequiredApprovals && entry.requiredApprovals != null
                      ? Text(
                          l10n.protectedEnvironmentApprovalCount(
                            entry.requiredApprovals!,
                          ),
                        )
                      : null,
                ),
          ],
        ),
      ),
    );
  }
}
