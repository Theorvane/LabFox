import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/protected_tags_controller.dart';
import 'widgets/protected_tag_unprotect_dialog.dart';

/// One rule, restorable from its project and tag name.
class ProtectedTagDetailScreen extends ConsumerWidget {
  const ProtectedTagDetailScreen({
    required this.projectId,
    required this.name,
    super.key,
  });

  final int projectId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = ProtectedTagRef(projectId: projectId, name: name);
    final rule = ref.watch(protectedTagDetailProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(rule.valueOrNull?.name ?? l10n.protectedTagsTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.protectedTags(projectId)),
        ),
      ),
      body: rule.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.protectedTagsError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(protectedTagDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(protectedTagDetailProvider(key).future),
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
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: LabFoxSpacing.md),
                            FilledButton.tonal(
                              key: const ValueKey('protected-tag-unprotect'),
                              onPressed: () async {
                                final session = ref.read(
                                  protectedTagsRepositoryProvider.future,
                                );
                                final accepted = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => ProtectedTagUnprotectDialog(
                                    target: key,
                                    rule: data,
                                  ),
                                );
                                if (accepted == true &&
                                    context.mounted &&
                                    identical(
                                      session,
                                      ref.read(
                                        protectedTagsRepositoryProvider.future,
                                      ),
                                    )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.protectedTagUnprotectAccepted,
                                      ),
                                    ),
                                  );
                                  context.go(Routes.protectedTags(projectId));
                                }
                              },
                              child: Text(l10n.protectedTagUnprotectTitle),
                            ),
                            const SizedBox(height: LabFoxSpacing.md),
                            Text(
                              l10n.protectedTagCreateAccess,
                              style: LabFoxTextRoles.of(context).sectionHeader,
                            ),
                            const SizedBox(height: LabFoxSpacing.sm),
                            if (data.createAccessLevels.isEmpty)
                              Text(l10n.protectedBranchNoAccess)
                            else
                              for (final entry in data.createAccessLevels)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(LabFoxIcons.person),
                                  title: Text(
                                    entry.description ??
                                        l10n.protectedBranchNoAccess,
                                  ),
                                ),
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
      ),
    );
  }
}
