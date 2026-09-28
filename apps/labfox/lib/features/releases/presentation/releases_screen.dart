import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/releases_controller.dart';

/// Project Releases, newest published first.
class ReleasesScreen extends ConsumerWidget {
  const ReleasesScreen({required this.projectId, super.key});

  final int projectId;

  Future<void> _openCreate(BuildContext context) async {
    final created = await showDialog<GitLabRelease>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateReleaseDialog(projectId: projectId),
    );
    if (created != null && context.mounted) {
      unawaited(context.push(Routes.release(projectId, created.tagName)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final releases = ref.watch(releaseListControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.releasesTitle),
        actions: [
          TextButton.icon(
            onPressed: () => _openCreate(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.releaseNew),
          ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(projectId)),
        ),
      ),
      body: releases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.releasesError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(releaseListControllerProvider(projectId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? Center(child: Text(l10n.releasesEmpty))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  releaseListControllerProvider(projectId).future,
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
                                for (final release in page.items)
                                  ListTile(
                                    leading: const Icon(LabFoxIcons.release),
                                    title: Text(release.name),
                                    subtitle: Text(
                                      [
                                        release.tagName,
                                        if (release.releasedAt != null)
                                          DateFormat.yMMMd(
                                            Localizations.localeOf(
                                              context,
                                            ).toString(),
                                          ).format(release.releasedAt!),
                                      ].join(' · '),
                                    ),
                                    trailing: release.upcomingRelease == true
                                        ? Chip(
                                            label: Text(l10n.releaseUpcoming),
                                          )
                                        : const Icon(LabFoxIcons.chevron),
                                    onTap: () => context.push(
                                      Routes.release(
                                        projectId,
                                        release.tagName,
                                      ),
                                    ),
                                  ),
                                if (page.hasMore)
                                  TextButton(
                                    onPressed: () => ref
                                        .read(
                                          releaseListControllerProvider(
                                            projectId,
                                          ).notifier,
                                        )
                                        .loadMore(),
                                    child: Text(l10n.releaseLoadMore),
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

class _CreateReleaseDialog extends ConsumerStatefulWidget {
  const _CreateReleaseDialog({required this.projectId});

  final int projectId;

  @override
  ConsumerState<_CreateReleaseDialog> createState() =>
      _CreateReleaseDialogState();
}

class _CreateReleaseDialogState extends ConsumerState<_CreateReleaseDialog> {
  final _tag = TextEditingController();
  final _ref = TextEditingController();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _milestoneTitle = TextEditingController();
  final _milestones = <String>[];
  String? _milestoneError;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _tag.dispose();
    _ref.dispose();
    _name.dispose();
    _description.dispose();
    _milestoneTitle.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    if (_tag.text.trim().isEmpty) {
      setState(() => _error = l10n.releaseTagRequired);
      return;
    }
    if (_milestoneTitle.text.trim().isNotEmpty && !_addMilestone()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final created = await ref
          .read(releaseListControllerProvider(widget.projectId).notifier)
          .create(
            tagName: _tag.text,
            ref: _ref.text,
            name: _name.text,
            description: _description.text,
            milestones: _milestones,
          );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.releaseCreateError;
      });
    }
  }

  bool _addMilestone() {
    final title = _milestoneTitle.text.trim();
    final l10n = AppLocalizations.of(context);
    if (title.isEmpty || _milestones.contains(title)) {
      setState(
        () => _milestoneError = title.isEmpty
            ? l10n.releaseCreationMilestoneRequired
            : l10n.releaseCreationMilestoneDuplicate,
      );
      return false;
    }
    setState(() {
      _milestones.add(title);
      _milestoneTitle.clear();
      _milestoneError = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.releaseNew),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tag,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l10n.releaseTagName),
            ),
            TextField(
              controller: _ref,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: l10n.releaseRef,
                helperText: l10n.releaseRefHelp,
              ),
            ),
            TextField(
              controller: _name,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l10n.releaseName),
            ),
            TextField(
              controller: _description,
              enabled: !_saving,
              maxLines: 5,
              decoration: InputDecoration(labelText: l10n.releaseDescription),
            ),
            const SizedBox(height: LabFoxSpacing.md),
            TextField(
              controller: _milestoneTitle,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: l10n.releaseCreationMilestoneTitle,
                helperText: l10n.releaseCreationMilestoneHelp,
                helperMaxLines: 3,
                errorText: _milestoneError,
              ),
            ),
            TextButton(
              onPressed: _saving ? null : _addMilestone,
              child: Text(l10n.releaseCreationMilestoneAdd),
            ),
            Wrap(
              spacing: LabFoxSpacing.sm,
              children: [
                for (final title in _milestones)
                  InputChip(
                    label: Text(title),
                    deleteButtonTooltipMessage: l10n
                        .releaseCreationMilestoneRemove(title),
                    onDeleted: _saving
                        ? null
                        : () => setState(() {
                            _milestones.remove(title);
                            _milestoneError = null;
                          }),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _create,
          child: Text(l10n.releaseCreate),
        ),
      ],
    );
  }
}
