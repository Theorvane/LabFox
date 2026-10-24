import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/ui/link_opener.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/environments_controller.dart';

/// Environment state, description, external URL, and latest deployment.
class EnvironmentDetailScreen extends ConsumerWidget {
  const EnvironmentDetailScreen({
    required this.projectId,
    required this.environmentId,
    super.key,
  });

  final int projectId;
  final int environmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = EnvironmentRef(
      projectId: projectId,
      environmentId: environmentId,
    );
    final environment = ref.watch(environmentDetailProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(environment.valueOrNull?.name ?? l10n.environmentsTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.environments(projectId)),
        ),
      ),
      body: environment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.environmentDetailError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(environmentDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(environmentDetailProvider(key).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final metadata = _EnvironmentMetadata(data: data);
              final details = _EnvironmentDetails(data: data);
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: constraints.maxWidth >= LabFoxBreakpoints.tablet
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 280, child: metadata),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: details),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  metadata,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  details,
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

class _EnvironmentMetadata extends ConsumerWidget {
  const _EnvironmentMetadata({required this.data});
  final GitLabEnvironment data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final externalUrl = Uri.tryParse(data.externalUrl ?? '');
    final validUrl =
        externalUrl != null &&
        (externalUrl.isScheme('https') || externalUrl.isScheme('http')) &&
        externalUrl.host.isNotEmpty;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: LabFoxSpacing.sm),
            Chip(
              label: Text(switch (data.state) {
                'available' => l10n.environmentsAvailable,
                'stopping' => l10n.environmentsStopping,
                'stopped' => l10n.environmentsStopped,
                _ => data.state,
              }),
            ),
            if (data.tier != null) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(data.tier!),
            ],
            if (data.autoStopAt != null) ...[
              const SizedBox(height: LabFoxSpacing.md),
              Text(
                l10n.environmentAutoStop,
                style: LabFoxTextRoles.of(context).sectionHeader,
              ),
              Text(
                DateFormat.yMMMd(
                  Localizations.localeOf(context).toString(),
                ).add_jm().format(data.autoStopAt!.toLocal()),
              ),
            ],
            if (validUrl) ...[
              const SizedBox(height: LabFoxSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.read(linkOpenerProvider)(externalUrl),
                icon: const Icon(LabFoxIcons.openInBrowser),
                label: Text(l10n.environmentOpenUrl),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EnvironmentDetails extends StatelessWidget {
  const _EnvironmentDetails({required this.data});
  final GitLabEnvironment data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.description != null && data.description!.isNotEmpty)
          Card.outlined(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(LabFoxSpacing.md),
              child: MarkdownViewer(data: data.description!),
            ),
          ),
        if (data.lastDeployment != null) ...[
          const SizedBox(height: LabFoxSpacing.md),
          Card.outlined(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(LabFoxSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.environmentLatestDeployment,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: LabFoxSpacing.sm),
                  Text(
                    data.lastDeployment!.status ??
                        l10n.environmentUnknownStatus,
                  ),
                  if (data.lastDeployment!.ref != null)
                    Text(data.lastDeployment!.ref!),
                  if (data.lastDeployment!.createdAt != null)
                    Text(
                      DateFormat.yMMMd(
                        Localizations.localeOf(context).toString(),
                      ).add_jm().format(
                        data.lastDeployment!.createdAt!.toLocal(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
