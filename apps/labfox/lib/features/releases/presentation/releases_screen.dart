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
  DateTime? _releasedAt;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _tag.dispose();
    _ref.dispose();
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    if (_tag.text.trim().isEmpty) {
      setState(() => _error = l10n.releaseTagRequired);
      return;
    }
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
            releasedAt: _releasedAt,
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

  Future<void> _chooseDate() async {
    final initial = _releasedAt ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(9998, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(
      () => _releasedAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _releasedAt?.hour ?? 0,
        _releasedAt?.minute ?? 0,
      ),
    );
  }

  Future<void> _chooseTime() async {
    final date = _releasedAt;
    if (date == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (!mounted || picked == null) return;
    setState(
      () => _releasedAt = DateTime(
        date.year,
        date.month,
        date.day,
        picked.hour,
        picked.minute,
      ),
    );
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.releaseCreationDateLabel),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _releasedAt == null
                    ? l10n.releaseCreationDateDefault
                    : DateFormat.yMMMd(
                        Localizations.localeOf(context).toString(),
                      ).add_jm().format(_releasedAt!),
              ),
            ),
            if (_releasedAt != null)
              Text(l10n.releaseCreationDateHelp(_releasedAt!.timeZoneName)),
            Wrap(
              children: [
                TextButton(
                  onPressed: _saving ? null : _chooseDate,
                  child: Text(l10n.releaseCreationChooseDate),
                ),
                if (_releasedAt != null) ...[
                  TextButton(
                    onPressed: _saving ? null : _chooseTime,
                    child: Text(l10n.releaseCreationChooseTime),
                  ),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() => _releasedAt = null),
                    child: Text(l10n.releaseCreationClearDate),
                  ),
                ],
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
