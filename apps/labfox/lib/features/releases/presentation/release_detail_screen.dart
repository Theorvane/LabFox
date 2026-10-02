import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/ui/link_opener.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/releases_controller.dart';
import 'widgets/release_schedule_dialog.dart';

/// Release notes and published assets, restorable from a project and tag.
class ReleaseDetailScreen extends ConsumerWidget {
  const ReleaseDetailScreen({
    required this.projectId,
    required this.tagName,
    super.key,
  });

  final int projectId;
  final String tagName;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ReleaseRef key,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.releaseDeleteConfirmTitle),
        content: Text(l10n.releaseDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.releaseDelete),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    try {
      await ref.read(releaseDeleteControllerProvider(key).notifier).delete();
      if (!context.mounted) return;
      context.go(Routes.releases(projectId));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.releaseDeleteError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = ReleaseRef(projectId: projectId, tagName: tagName);
    final release = ref.watch(releaseDetailProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(release.valueOrNull?.name ?? tagName),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.releases(projectId)),
        ),
        actions: [
          if (release.valueOrNull != null)
            IconButton(
              tooltip: l10n.releaseScheduleEdit,
              icon: const Icon(Icons.event_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ReleaseScheduleDialog(
                  keyRef: key,
                  releasedAt: release.valueOrNull!.releasedAt,
                ),
              ),
            ),
          if (release.valueOrNull != null)
            IconButton(
              tooltip: l10n.releaseEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => _EditReleaseDialog(
                  keyRef: key,
                  release: release.valueOrNull!,
                ),
              ),
            ),
          if (release.hasValue)
            IconButton(
              tooltip: l10n.releaseDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed:
                  ref.watch(releaseDeleteControllerProvider(key)).isLoading
                  ? null
                  : () => _delete(context, ref, key),
            ),
        ],
      ),
      body: release.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.releaseDetailError),
              const SizedBox(height: LabFoxSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(releaseDetailProvider(key)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(releaseDetailProvider(key).future),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= LabFoxBreakpoints.tablet;
              final metadata = _Metadata(release: data);
              final content = _Content(release: data, keyRef: key);
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
                                  SizedBox(width: 260, child: metadata),
                                  const SizedBox(width: LabFoxSpacing.md),
                                  Expanded(child: content),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  metadata,
                                  const SizedBox(height: LabFoxSpacing.md),
                                  content,
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

class _EditReleaseDialog extends ConsumerStatefulWidget {
  const _EditReleaseDialog({required this.keyRef, required this.release});

  final ReleaseRef keyRef;
  final GitLabRelease release;

  @override
  ConsumerState<_EditReleaseDialog> createState() => _EditReleaseDialogState();
}

class _EditReleaseDialogState extends ConsumerState<_EditReleaseDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.release.name);
    _description = TextEditingController(text: widget.release.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.releaseNameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(releaseEditControllerProvider(widget.keyRef).notifier)
          .save(name: _name.text, description: _description.text);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.releaseEditError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.releaseEdit),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l10n.releaseEditName),
            ),
            TextField(
              controller: _description,
              enabled: !_saving,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: l10n.releaseEditDescription,
              ),
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
          onPressed: _saving ? null : _save,
          child: Text(l10n.releaseSave),
        ),
      ],
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.release});
  final GitLabRelease release;

  @override
  Widget build(BuildContext context) => Card.outlined(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(LabFoxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(release.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: LabFoxSpacing.sm),
          Text(release.tagName),
          if (release.releasedAt != null) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            Text(
              DateFormat.yMMMd(
                Localizations.localeOf(context).toString(),
              ).format(release.releasedAt!),
            ),
          ],
          if (release.upcomingRelease == true) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            Chip(label: Text(AppLocalizations.of(context).releaseUpcoming)),
          ],
        ],
      ),
    ),
  );
}

class _Content extends ConsumerWidget {
  const _Content({required this.release, required this.keyRef});
  final GitLabRelease release;
  final ReleaseRef keyRef;

  Future<void> _deleteLink(
    BuildContext context,
    WidgetRef ref,
    ReleaseAssetLink link,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.releaseAssetDeleteConfirmTitle),
        content: Text(l10n.releaseAssetDeleteConfirmBody(link.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.releaseDeleteLink),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    try {
      await ref
          .read(releaseAssetLinkDeleteControllerProvider(keyRef).notifier)
          .delete(link.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.releaseAssetDeleteError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final open = ref.watch(linkOpenerProvider);
    final links = release.assets?.links ?? const <ReleaseAssetLink>[];
    final sources = release.assets?.sources ?? const <ReleaseSource>[];
    final deleting = ref
        .watch(releaseAssetLinkDeleteControllerProvider(keyRef))
        .isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (release.description != null && release.description!.isNotEmpty) ...[
          Card.outlined(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(LabFoxSpacing.md),
              child: MarkdownViewer(data: release.description!),
            ),
          ),
          const SizedBox(height: LabFoxSpacing.md),
        ],
        Card.outlined(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(LabFoxSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.releaseAssetsTitle,
                        style: LabFoxTextRoles.of(context).sectionHeader,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.releaseAddAssetLink,
                      icon: const Icon(Icons.add_link),
                      onPressed: () => showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => _AddAssetLinkDialog(
                          keyRef: keyRef,
                          existingLinks: links,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (links.isEmpty && sources.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(LabFoxSpacing.md),
                  child: Text(l10n.releaseNoAssets),
                ),
              for (final asset in links)
                _AssetTile(
                  name: asset.name,
                  url: asset.directAssetUrl ?? asset.url,
                  open: open,
                  deleteAction: IconButton(
                    tooltip: l10n.releaseDeleteAssetLink,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: deleting
                        ? null
                        : () => _deleteLink(context, ref, asset),
                  ),
                  editAction: IconButton(
                    tooltip: l10n.releaseEditAssetLink,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => _EditAssetLinkDialog(
                        keyRef: keyRef,
                        link: asset,
                        existingLinks: links,
                      ),
                    ),
                  ),
                ),
              for (final source in sources)
                _AssetTile(name: source.format, url: source.url, open: open),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddAssetLinkDialog extends ConsumerStatefulWidget {
  const _AddAssetLinkDialog({
    required this.keyRef,
    required this.existingLinks,
  });

  final ReleaseRef keyRef;
  final List<ReleaseAssetLink> existingLinks;

  @override
  ConsumerState<_AddAssetLinkDialog> createState() =>
      _AddAssetLinkDialogState();
}

class _AddAssetLinkDialogState extends ConsumerState<_AddAssetLinkDialog> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final url = _url.text.trim();
    final uri = Uri.tryParse(url);
    if (name.isEmpty) {
      setState(() => _error = l10n.releaseAssetNameRequired);
      return;
    }
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      setState(() => _error = l10n.releaseAssetUrlInvalid);
      return;
    }
    if (widget.existingLinks.any((link) => link.name == name)) {
      setState(() => _error = l10n.releaseAssetNameDuplicate);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(releaseAssetLinkControllerProvider(widget.keyRef).notifier)
          .create(name: name, url: url);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.releaseAssetCreateError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.releaseAddAssetLink),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l10n.releaseAssetName),
            ),
            TextField(
              controller: _url,
              enabled: !_saving,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: l10n.releaseAssetUrl),
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
          onPressed: _saving ? null : _save,
          child: Text(l10n.releaseAddLink),
        ),
      ],
    );
  }
}

class _EditAssetLinkDialog extends ConsumerStatefulWidget {
  const _EditAssetLinkDialog({
    required this.keyRef,
    required this.link,
    required this.existingLinks,
  });
  final ReleaseRef keyRef;
  final ReleaseAssetLink link;
  final List<ReleaseAssetLink> existingLinks;

  @override
  ConsumerState<_EditAssetLinkDialog> createState() =>
      _EditAssetLinkDialogState();
}

class _EditAssetLinkDialogState extends ConsumerState<_EditAssetLinkDialog> {
  final _directPath = TextEditingController();
  static const _types = ['other', 'runbook', 'image', 'package'];
  String? _linkType;
  late final TextEditingController _name;
  late final TextEditingController _url;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.link.name);
    _url = TextEditingController(text: widget.link.url);
    _linkType = _types.contains(widget.link.linkType)
        ? widget.link.linkType
        : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _directPath.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final url = _url.text.trim();
    final directPath = _directPath.text.trim();
    final pathUri = Uri.tryParse(directPath);
    if (directPath.isNotEmpty &&
        (!directPath.startsWith('/') ||
            pathUri == null ||
            pathUri.hasAuthority ||
            pathUri.hasScheme ||
            pathUri.hasQuery ||
            pathUri.hasFragment)) {
      setState(() => _error = l10n.releaseAssetDirectPathInvalid);
      return;
    }
    final uri = Uri.tryParse(url);
    if (name.isEmpty) {
      setState(() => _error = l10n.releaseAssetNameRequired);
      return;
    }
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      setState(() => _error = l10n.releaseAssetUrlInvalid);
      return;
    }
    if (widget.existingLinks.any(
      (link) => link.id != widget.link.id && link.name == name,
    )) {
      setState(() => _error = l10n.releaseAssetNameDuplicate);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(releaseAssetLinkEditControllerProvider(widget.keyRef).notifier)
          .save(
            widget.link.id,
            name: name,
            url: url,
            directAssetPath: directPath.isEmpty ? null : directPath,
            linkType: _linkType == widget.link.linkType ? null : _linkType,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.releaseAssetEditError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.releaseEditAssetLink),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l10n.releaseAssetName),
            ),
            TextField(
              controller: _url,
              enabled: !_saving,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: l10n.releaseAssetUrl),
            ),
            TextField(
              controller: _directPath,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: l10n.releaseAssetDirectPath,
                helperText: l10n.releaseAssetDirectPathHelp,
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _linkType,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.releaseAssetType),
              hint: Text(l10n.releaseAssetKeepType),
              items: [
                DropdownMenuItem(
                  value: 'other',
                  child: Text(l10n.releaseAssetTypeOther),
                ),
                DropdownMenuItem(
                  value: 'runbook',
                  child: Text(l10n.releaseAssetTypeRunbook),
                ),
                DropdownMenuItem(
                  value: 'image',
                  child: Text(l10n.releaseAssetTypeImage),
                ),
                DropdownMenuItem(
                  value: 'package',
                  child: Text(l10n.releaseAssetTypePackage),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _linkType = value),
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
          onPressed: _saving ? null : _save,
          child: Text(l10n.releaseSaveLink),
        ),
      ],
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({
    required this.name,
    required this.url,
    required this.open,
    this.deleteAction,
    this.editAction,
  });
  final String name;
  final String url;
  final Future<void> Function(Uri) open;
  final Widget? deleteAction;
  final Widget? editAction;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final supported =
        uri != null && (uri.isScheme('http') || uri.isScheme('https'));
    return ListTile(
      leading: const Icon(LabFoxIcons.file),
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LabFoxIcons.openInBrowser),
          ?editAction,
          ?deleteAction,
        ],
      ),
      onTap: supported ? () => open(uri) : null,
    );
  }
}
