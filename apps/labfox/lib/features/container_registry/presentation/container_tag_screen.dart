import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_registry_controllers.dart';
import 'controllers/container_tag_delete_controller.dart';
import 'widgets/container_tag_delete_dialog.dart';

/// Digest and revision metadata for one container image tag.
class ContainerTagScreen extends ConsumerWidget {
  const ContainerTagScreen({
    required this.projectId,
    required this.repositoryId,
    required this.tagName,
    super.key,
  });

  final int projectId;
  final int repositoryId;
  final String tagName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = RegistryTagRef(
      repository: RegistryRef(projectId: projectId, repositoryId: repositoryId),
      name: tagName,
    );
    final tag = ref.watch(containerTagProvider(key));
    final deletion = ref.watch(containerTagDeleteControllerProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(tagName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.containerTagDelete,
            onPressed:
                tag.isLoading ||
                    tag.hasError ||
                    tag.valueOrNull == null ||
                    deletion.isLoading
                ? null
                : () async {
                    final deleted = await showDialog<bool>(
                      context: context,
                      builder: (_) => ContainerTagDeleteDialog(
                        tagRef: key,
                        path: tag.requireValue.path,
                      ),
                    );
                    if (deleted == true && context.mounted) {
                      context.go(
                        Routes.containerRepository(projectId, repositoryId),
                      );
                    }
                  },
          ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.containerRepository(projectId, repositoryId)),
        ),
      ),
      body: tag.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.containerTagError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(containerTagProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => ListView(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(LabFoxSpacing.md),
                  child: Card.outlined(
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
                          if (data.digest != null) ...[
                            const SizedBox(height: LabFoxSpacing.md),
                            Text(
                              l10n.containerTagDigest,
                              style: LabFoxTextRoles.of(context).sectionHeader,
                            ),
                            SelectableText(data.digest!),
                          ],
                          if (data.revision != null) ...[
                            const SizedBox(height: LabFoxSpacing.md),
                            Text(
                              l10n.containerTagRevision,
                              style: LabFoxTextRoles.of(context).sectionHeader,
                            ),
                            SelectableText(data.revision!),
                          ],
                          if (data.totalSize != null) ...[
                            const SizedBox(height: LabFoxSpacing.md),
                            Text(
                              l10n.containerTagSize,
                              style: LabFoxTextRoles.of(context).sectionHeader,
                            ),
                            Text(
                              NumberFormat.decimalPattern(
                                Localizations.localeOf(context).toString(),
                              ).format(data.totalSize),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
