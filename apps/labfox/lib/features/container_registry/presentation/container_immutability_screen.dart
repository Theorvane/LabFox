import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_immutability_controller.dart';
import 'widgets/container_immutability_delete_dialog.dart';

/// Project-wide rules, not per-tag access decisions.
class ContainerImmutabilityScreen extends ConsumerWidget {
  const ContainerImmutabilityScreen({required this.projectId, super.key});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = containerImmutabilityControllerProvider(projectId);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.containerImmutabilityTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.containerRegistry(projectId)),
        ),
      ),
      body: ref
          .watch(provider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(LabFoxSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(switch (error) {
                      GitLabForbiddenException() =>
                        l10n.containerImmutabilityForbidden,
                      GitLabNotFoundException() =>
                        l10n.containerImmutabilityUnavailable,
                      _ => l10n.containerImmutabilityError,
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
            data: (rules) => RefreshIndicator(
              onRefresh: () async {
                try {
                  final refreshed = ref.refresh(provider.future);
                  await refreshed;
                } catch (_) {
                  // The provider renders the safe error state.
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
                            Text(l10n.containerImmutabilityHint),
                            const SizedBox(height: LabFoxSpacing.md),
                            if (rules.isEmpty)
                              Text(l10n.containerImmutabilityEmpty),
                            for (final rule in rules)
                              Card.outlined(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    LabFoxSpacing.md,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(rule.tagNamePattern),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerEnd,
                                        child: IconButton(
                                          tooltip: l10n
                                              .containerImmutabilityDeleteTitle,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () async {
                                            final deleted = await showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) =>
                                                  ContainerImmutabilityDeleteDialog(
                                                    projectId: projectId,
                                                    rule: rule,
                                                  ),
                                            );
                                            if (deleted == true &&
                                                context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    l10n.containerImmutabilityDeleteDone,
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
