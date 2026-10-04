import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/ui/ci_visual.dart';
import '../../../core/ui/work_meta.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/pipelines_controllers.dart';

/// An independently retryable, immediate upstream relationship.
class UpstreamPipelineSection extends ConsumerWidget {
  const UpstreamPipelineSection({required this.pipelineRef, super.key});
  final PipelineRef pipelineRef;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = pipelineUpstreamProvider(pipelineRef);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LabFoxSpacing.md),
          child: Text(
            l10n.pipelineUpstreamTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        ref
            .watch(provider)
            .when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(LabFoxSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.pipelineUpstreamError),
                    TextButton(
                      onPressed: () => ref.invalidate(provider),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (target) => target == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LabFoxSpacing.md,
                      ),
                      child: Text(l10n.pipelineUpstreamEmpty),
                    )
                  : _UpstreamTile(target: target),
            ),
      ],
    );
  }
}

class _UpstreamTile extends StatelessWidget {
  const _UpstreamTile({required this.target});
  final PipelineUpstream target;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projectId = target.projectId;
    final pipelineId = target.pipelineId;
    final canOpen = projectId != null && pipelineId != null;
    final (icon, colors) = ciVisual(
      target.ciStatus,
      LabFoxStatusColors.of(context),
    );
    return WorkTile(
      title:
          target.ref ??
          (pipelineId == null
              ? l10n.pipelineUpstreamUnavailable
              : l10n.pipelineSchedulePipelineNumber(pipelineId)),
      icon: icon,
      iconColor: colors.foreground,
      metadata: [
        StatusPill(
          label: ciLabel(target.status.toLowerCase()),
          colors: colors,
          dot: true,
        ),
        MetaText(
          canOpen
              ? l10n.pipelineUpstreamTarget(projectId, pipelineId)
              : l10n.pipelineUpstreamUnavailable,
        ),
      ],
      trailing: canOpen ? const Icon(LabFoxIcons.chevron) : null,
      onTap: canOpen
          ? () => context.push(Routes.pipeline(projectId, pipelineId))
          : null,
    );
  }
}
