import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/deployments_controller.dart';

/// Recent deployments in one project, optionally scoped to an environment.
class DeploymentsScreen extends ConsumerStatefulWidget {
  const DeploymentsScreen({
    required this.projectId,
    this.initialEnvironment,
    super.key,
  });

  final int projectId;
  final String? initialEnvironment;

  @override
  ConsumerState<DeploymentsScreen> createState() => _DeploymentsScreenState();
}

class _DeploymentsScreenState extends ConsumerState<DeploymentsScreen> {
  late final TextEditingController _environmentController;
  String? _environment;
  String? _status;

  @override
  void initState() {
    super.initState();
    _environment = widget.initialEnvironment;
    _environmentController = TextEditingController(text: _environment);
  }

  @override
  void didUpdateWidget(covariant DeploymentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialEnvironment != widget.initialEnvironment) {
      _environment = widget.initialEnvironment;
      _environmentController.text = _environment ?? '';
    }
  }

  @override
  void dispose() {
    _environmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = DeploymentListRef(
      projectId: widget.projectId,
      environment: _environment,
      status: _status,
    );
    final deployments = ref.watch(deploymentListControllerProvider(key));
    final filters = <(String?, String)>[
      (null, l10n.deploymentsAll),
      ('success', l10n.deploymentsSuccess),
      ('failed', l10n.deploymentsFailed),
      ('running', l10n.deploymentsRunning),
      ('canceled', l10n.deploymentsCanceled),
      ('created', l10n.deploymentsCreated),
      ('blocked', l10n.deploymentsBlocked),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deploymentsTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(widget.projectId)),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LabFoxSpacing.md,
                  LabFoxSpacing.md,
                  LabFoxSpacing.md,
                  0,
                ),
                child: TextField(
                  controller: _environmentController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LabFoxIcons.search),
                    hintText: l10n.deploymentsEnvironmentSearch,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => setState(() {
                    final trimmed = value.trim();
                    _environment = trimmed.isEmpty ? null : trimmed;
                  }),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: LabFoxSpacing.md,
                ),
                child: Row(
                  children: [
                    for (final filter in filters) ...[
                      ChoiceChip(
                        label: Text(filter.$2),
                        selected: _status == filter.$1,
                        onSelected: (_) => setState(() => _status = filter.$1),
                      ),
                      const SizedBox(width: LabFoxSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: deployments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.deploymentsError),
                    const SizedBox(height: LabFoxSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(deploymentListControllerProvider(key)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(child: Text(l10n.deploymentsEmpty))
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        deploymentListControllerProvider(key).future,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth =
                              constraints.maxWidth >= LabFoxBreakpoints.tablet
                              ? 900.0
                              : constraints.maxWidth;
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: maxWidth,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      LabFoxSpacing.md,
                                    ),
                                    child: Card.outlined(
                                      margin: EdgeInsets.zero,
                                      child: Column(
                                        children: [
                                          for (final deployment in page.items)
                                            _DeploymentTile(
                                              deployment: deployment,
                                              projectId: widget.projectId,
                                            ),
                                          if (page.hasMore)
                                            TextButton(
                                              onPressed: () => ref
                                                  .read(
                                                    deploymentListControllerProvider(
                                                      key,
                                                    ).notifier,
                                                  )
                                                  .loadMore(),
                                              child: Text(
                                                l10n.deploymentsLoadMore,
                                              ),
                                            ),
                                        ],
                                      ),
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
          ),
        ],
      ),
    );
  }
}

class _DeploymentTile extends StatelessWidget {
  const _DeploymentTile({required this.deployment, required this.projectId});

  final GitLabDeployment deployment;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = deployment.createdAt == null
        ? null
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).add_jm().format(deployment.createdAt!.toLocal());
    return ListTile(
      leading: const Icon(LabFoxIcons.pipeline),
      title: Text(
        deployment.environment?.name ?? l10n.deploymentsUnknownEnvironment,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(deploymentStatusLabel(l10n, deployment.status)),
          if (deployment.ref != null) Text(deployment.ref!),
          if (date != null) Text(date),
        ],
      ),
      trailing: const Icon(LabFoxIcons.chevron),
      onTap: () => context.push(Routes.deployment(projectId, deployment.id)),
    );
  }
}

String deploymentStatusLabel(AppLocalizations l10n, String? status) =>
    switch (status) {
      'success' => l10n.deploymentsSuccess,
      'failed' => l10n.deploymentsFailed,
      'running' => l10n.deploymentsRunning,
      'canceled' => l10n.deploymentsCanceled,
      'created' => l10n.deploymentsCreated,
      'blocked' => l10n.deploymentsBlocked,
      _ => l10n.deploymentsUnknownStatus,
    };
