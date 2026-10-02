import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_branches_controller.dart';
import 'protected_branch_protect_dialog.dart';

/// Project protected branch rules, including wildcard rules.
class ProtectedBranchesScreen extends ConsumerWidget {
  const ProtectedBranchesScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rules = ref.watch(protectedBranchesControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.protectedBranchesTitle),
        actions: [
          IconButton(
            key: const ValueKey('protected-branch-protect'),
            tooltip: l10n.protectedBranchProtectTitle,
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await showDialog<bool>(
                context: context,
                builder: (_) =>
                    ProtectedBranchProtectDialog(projectId: projectId),
              );
              if (created == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.protectedBranchProtectCreated)),
                );
              }
            },
          ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.branches(projectId)),
        ),
      ),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.protectedBranchesError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(
                  protectedBranchesControllerProvider(projectId),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? EmptyState(
                icon: LabFoxIcons.private,
                title: l10n.protectedBranchesEmpty,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  protectedBranchesControllerProvider(projectId).future,
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
                                    subtitle: rule.inherited == true
                                        ? Text(l10n.protectedBranchInherited)
                                        : null,
                                    trailing: const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      Routes.protectedBranch(
                                        projectId,
                                        rule.name,
                                      ),
                                    ),
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          protectedBranchesControllerProvider(
                                            projectId,
                                          ).notifier,
                                        )
                                        .loadMore(),
                                    child: Text(l10n.protectedBranchesLoadMore),
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
