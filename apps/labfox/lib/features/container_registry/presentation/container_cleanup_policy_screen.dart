import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/container_cleanup_policy_controller.dart';

/// Read-only project-wide cleanup settings from the authenticated project API.
class ContainerCleanupPolicyScreen extends ConsumerWidget {
  const ContainerCleanupPolicyScreen({required this.projectId, super.key});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = containerCleanupPolicyControllerProvider(projectId);
    final policy = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.containerPolicyTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.containerRegistry(projectId)),
        ),
      ),
      body: policy.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(switch (error) {
                  GitLabForbiddenException() => l10n.containerPolicyForbidden,
                  GitLabNotFoundException() => l10n.containerPolicyUnavailable,
                  _ => l10n.containerPolicyError,
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
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            try {
              final refresh = ref.refresh(provider.future);
              await refresh;
            } catch (_) {
              // The provider renders the typed error and retry action.
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
                        Text(l10n.containerPolicyHint),
                        const SizedBox(height: LabFoxSpacing.md),
                        if (data == null)
                          Text(l10n.containerPolicyAbsent)
                        else
                          _PolicyDetails(policy: data),
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

class _PolicyDetails extends StatelessWidget {
  const _PolicyDetails({required this.policy});
  final ContainerCleanupPolicy policy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = policy.keepN;
    final nextRun = policy.nextRunAt;
    final legacyDelete =
        policy.nameRegexDelete == null && policy.nameRegex != null;
    String pattern(String? value) => value == null
        ? l10n.containerPolicyNotReported
        : value.isEmpty
        ? l10n.containerPolicyEmptyPattern
        : value;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          _Field(
            label: l10n.containerPolicyStatus,
            value: switch (policy.enabled) {
              true => l10n.containerPolicyEnabled,
              false => l10n.containerPolicyDisabled,
              null => l10n.containerPolicyNotReported,
            },
          ),
          _Field(
            label: l10n.containerPolicyCadence,
            value: _duration(l10n, policy.cadence),
          ),
          _Field(
            label: l10n.containerPolicyKeepCount,
            value: count == null
                ? l10n.containerPolicyNotReported
                : NumberFormat.decimalPattern(l10n.localeName).format(count),
          ),
          _Field(
            label: l10n.containerPolicyAge,
            value: _duration(l10n, policy.olderThan),
          ),
          _Field(
            label: legacyDelete
                ? l10n.containerPolicyLegacyPattern
                : l10n.containerPolicyDeletePattern,
            value: pattern(policy.nameRegexDelete ?? policy.nameRegex),
          ),
          _Field(
            label: l10n.containerPolicyKeepPattern,
            value: pattern(policy.nameRegexKeep),
          ),
          _Field(
            label: l10n.containerPolicyNextRun,
            value: nextRun == null
                ? l10n.containerPolicyNotReported
                : DateFormat.yMd(
                    l10n.localeName,
                  ).add_jm().format(nextRun.toLocal()),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) =>
      ListTile(title: Text(label), subtitle: Text(value));
}

String _duration(AppLocalizations l10n, String? value) {
  if (value == null) return l10n.containerPolicyNotReported;
  if (value.isEmpty) return l10n.containerPolicyEmptySetting;
  // Preserve unknown server settings rather than guessing an interval.
  final match = RegExp(r'^([1-9][0-9]*)(d|month)$').firstMatch(value);
  if (match == null) return value;
  final count = int.tryParse(match.group(1)!);
  if (count == null) return value;
  return match.group(2) == 'd'
      ? l10n.containerPolicyDays(count)
      : l10n.containerPolicyMonths(count);
}
