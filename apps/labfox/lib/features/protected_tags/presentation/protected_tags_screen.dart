import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_tags_controller.dart';
import 'protected_tag_protect_dialog.dart';

/// Project protected tag rules, including wildcard rules.
class ProtectedTagsScreen extends ConsumerWidget {
  const ProtectedTagsScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rules = ref.watch(protectedTagsControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.protectedTagsTitle),
        actions: [
          IconButton(
            key: const ValueKey('protected-tag-protect'),
            tooltip: l10n.protectedTagProtectTitle,
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await showDialog<bool>(
                context: context,
                builder: (_) => ProtectedTagProtectDialog(projectId: projectId),
              );
              if (created == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.protectedTagProtectCreated)),
                );
              }
            },
          ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.tags(projectId)),
        ),
      ),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.protectedTagsError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(protectedTagsControllerProvider(projectId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? EmptyState(
                icon: LabFoxIcons.private,
                title: l10n.protectedTagsEmpty,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  protectedTagsControllerProvider(projectId).future,
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
                                    trailing: const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      Routes.protectedTag(projectId, rule.name),
                                    ),
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          protectedTagsControllerProvider(
                                            projectId,
                                          ).notifier,
                                        )
                                        .loadMore(),
                                    child: Text(l10n.protectedTagsLoadMore),
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
