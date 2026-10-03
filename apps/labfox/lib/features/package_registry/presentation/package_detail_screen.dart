import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../data/package_overview.dart';
import 'controllers/package_controllers.dart';
import 'controllers/package_delete_controller.dart';
import 'controllers/package_file_delete_controller.dart';
import 'widgets/package_delete_dialog.dart';
import 'widgets/package_file_delete_dialog.dart';

/// Package metadata and its published files.
class PackageDetailScreen extends ConsumerWidget {
  const PackageDetailScreen({
    required this.projectId,
    required this.packageId,
    super.key,
  });

  final int projectId;
  final int packageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final packageRef = PackageRef(projectId: projectId, packageId: packageId);
    final overview = ref.watch(packageDetailControllerProvider(packageRef));
    final deletion = ref.watch(packageDeleteControllerProvider(packageRef));
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.packageDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed:
                overview.isLoading ||
                    overview.hasError ||
                    !overview.hasValue ||
                    deletion.isLoading
                ? null
                : () async {
                    final deleted = await showDialog<bool>(
                      context: context,
                      builder: (_) => PackageDeleteDialog(
                        packageRef: packageRef,
                        package: overview.requireValue.package,
                      ),
                    );
                    if (deleted == true && context.mounted) {
                      context.go(Routes.packages(projectId));
                    }
                  },
          ),
        ],
        title: Text(
          overview.valueOrNull?.package.name ?? l10n.packageRegistryTitle,
        ),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.packages(projectId)),
        ),
      ),
      body: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.packageDetailError, textAlign: TextAlign.center),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    packageDetailControllerProvider(packageRef),
                  ),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(packageDetailControllerProvider(packageRef).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final metadata = _Metadata(data: data);
              final files = _Files(data: data, packageRef: packageRef);
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
                                  SizedBox(
                                    width:
                                        constraints.maxWidth >=
                                            LabFoxBreakpoints.desktop
                                        ? 320
                                        : 240,
                                    child: metadata,
                                  ),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: files),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  metadata,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  files,
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

class _Metadata extends StatelessWidget {
  const _Metadata({required this.data});

  final PackageOverview data;

  @override
  Widget build(BuildContext context) => Card.outlined(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(LabFoxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.package.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: LabFoxSpacing.sm),
          Chip(label: Text(data.package.packageType)),
          if (data.package.version != null) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            Text(data.package.version!),
          ],
        ],
      ),
    ),
  );
}

class _Files extends ConsumerWidget {
  const _Files({required this.data, required this.packageRef});

  final PackageOverview data;
  final PackageRef packageRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: Text(
              l10n.packageFiles,
              style: LabFoxTextRoles.of(context).sectionHeader,
            ),
          ),
          if (data.files.items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(LabFoxSpacing.md),
              child: Text(l10n.packageFilesEmpty),
            )
          else
            for (final file in data.files.items)
              ListTile(
                leading: const Icon(LabFoxIcons.file),
                title: Text(file.fileName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.packageFileDelete,
                  onPressed:
                      ref
                          .watch(
                            packageFileDeleteControllerProvider(
                              PackageFileRef(
                                projectId: packageRef.projectId,
                                packageId: packageRef.packageId,
                                fileId: file.id,
                              ),
                            ),
                          )
                          .isLoading
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          builder: (_) => PackageFileDeleteDialog(
                            fileRef: PackageFileRef(
                              projectId: packageRef.projectId,
                              packageId: packageRef.packageId,
                              fileId: file.id,
                            ),
                            package: data.package,
                            file: file,
                          ),
                        ),
                ),
              ),
          if (data.files.hasMore)
            TextButton(
              onPressed: () => ref
                  .read(packageDetailControllerProvider(packageRef).notifier)
                  .loadMoreFiles(),
              child: Text(l10n.packageLoadMore),
            ),
        ],
      ),
    );
  }
}
