import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/deployments_controller.dart';
import 'deployments_screen.dart';

/// Details and related resources for one deployment.
class DeploymentDetailScreen extends ConsumerWidget {
  const DeploymentDetailScreen({
    required this.projectId,
    required this.deploymentId,
    super.key,
  });

  final int projectId;
  final int deploymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = DeploymentRef(projectId: projectId, deploymentId: deploymentId);
    final deployment = ref.watch(deploymentDetailProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.deploymentNumber(deployment.valueOrNull?.iid ?? deploymentId),
        ),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.deployments(projectId)),
        ),
      ),
      body: deployment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.deploymentDetailError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(deploymentDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(deploymentDetailProvider(key).future),
          child: LayoutBuilder(
            builder: (context, constraints) => ListView(
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
                                SizedBox(
                                  width: 300,
                                  child: _Summary(data: data),
                                ),
                                const SizedBox(width: LabFoxSpacing.md),
                                Expanded(
                                  child: _Links(
                                    data: data,
                                    projectId: projectId,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _Summary(data: data),
                                const SizedBox(height: LabFoxSpacing.md),
                                _Links(data: data, projectId: projectId),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.data});
  final GitLabDeployment data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale).add_jm();
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deploymentStatusLabel(l10n, data.status),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (data.ref != null)
              ListTile(
                title: Text(l10n.deploymentRef),
                subtitle: Text(data.ref!),
              ),
            if (data.createdAt != null)
              ListTile(
                title: Text(l10n.deploymentCreatedAt),
                subtitle: Text(dateFormat.format(data.createdAt!.toLocal())),
              ),
            if (data.updatedAt != null)
              ListTile(
                title: Text(l10n.deploymentUpdatedAt),
                subtitle: Text(dateFormat.format(data.updatedAt!.toLocal())),
              ),
            if (data.user?.name != null)
              ListTile(
                title: Text(l10n.deploymentUser),
                subtitle: Text(data.user!.name!),
              ),
          ],
        ),
      ),
    );
  }
}

class _Links extends StatelessWidget {
  const _Links({required this.data, required this.projectId});
  final GitLabDeployment data;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final environment = data.environment;
    final job = data.deployable;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          if (environment != null)
            ListTile(
              title: Text(l10n.deploymentEnvironment),
              subtitle: Text(environment.name),
              onTap: environment.id == null
                  ? null
                  : () => context.push(
                      Routes.environment(projectId, environment.id!),
                    ),
            ),
          if (data.sha != null)
            ListTile(
              title: Text(l10n.deploymentCommit),
              subtitle: Text(data.sha!),
              onTap: () => context.push(Routes.commit(projectId, data.sha!)),
            ),
          if (job != null)
            ListTile(
              title: Text(l10n.deploymentJob),
              subtitle: Text(job.name ?? job.id.toString()),
              onTap: () => context.push(Routes.job(projectId, job.id)),
            ),
          if (job?.pipeline != null)
            ListTile(
              title: Text(l10n.deploymentPipeline),
              subtitle: Text(job!.pipeline!.id.toString()),
              onTap: () =>
                  context.push(Routes.pipeline(projectId, job.pipeline!.id)),
            ),
        ],
      ),
    );
  }
}
