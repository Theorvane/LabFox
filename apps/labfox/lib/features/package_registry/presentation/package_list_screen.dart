import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/package_controllers.dart';

/// Project package registry, ordered by publication time.
class PackageListScreen extends ConsumerWidget {
  const PackageListScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final packages = ref.watch(packageListControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packageRegistryTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(projectId)),
        ),
      ),
      body: packages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Error(
          message: l10n.packageRegistryError,
          onRetry: () =>
              ref.invalidate(packageListControllerProvider(projectId)),
        ),
        data: (page) => page.items.isEmpty
            ? Center(child: Text(l10n.packageRegistryEmpty))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  packageListControllerProvider(projectId).future,
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
                                for (final package in page.items)
                                  _PackageTile(
                                    package: package,
                                    onTap:
                                        package.status == null ||
                                            package.status == 'default' ||
                                            package.status == 'deprecated'
                                        ? () => context.push(
                                            Routes.packageDetail(
                                              projectId,
                                              package.id,
                                            ),
                                          )
                                        : null,
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          packageListControllerProvider(
                                            projectId,
                                          ).notifier,
                                        )
                                        .loadMore(),
                                    child: Text(l10n.packageLoadMore),
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

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.package, required this.onTap});

  final GitLabPackage package;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(LabFoxIcons.packageRegistry),
    title: Text(package.name),
    subtitle: package.version == null ? null : Text(package.version!),
    trailing: Chip(label: Text(package.packageType)),
    onTap: onTap,
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(LabFoxSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: LabFoxSpacing.md),
          FilledButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
}
