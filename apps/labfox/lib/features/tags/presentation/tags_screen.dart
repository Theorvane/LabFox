import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/tags_controller.dart';

/// Repository tags and a route into each tagged tree.
class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({required this.projectId, super.key});
  final int projectId;

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projectId = widget.projectId;
    final tags = ref.watch(tagsControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tagsTitle),
        actions: [
          IconButton(
            icon: const Icon(LabFoxIcons.private),
            tooltip: l10n.protectedTagsTitle,
            onPressed: () => context.push(Routes.protectedTags(projectId)),
          ),
          IconButton(
            icon: const Icon(LabFoxIcons.add),
            tooltip: l10n.tagNew,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _CreateTagDialog(projectId: projectId),
            ),
          ),
        ],
      ),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Error(
          message: l10n.tagsError,
          onRetry: () => ref.invalidate(tagsControllerProvider(projectId)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(icon: LabFoxIcons.branch, title: l10n.tagsEmpty);
          }
          final shown = items
              .where(
                (tag) => tag.name.toLowerCase().contains(_filter.toLowerCase()),
              )
              .toList();
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(tagsControllerProvider(projectId).future),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(LabFoxSpacing.md),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(LabFoxIcons.search),
                          hintText: l10n.tagSearchHint,
                        ),
                        onChanged: (value) => setState(() => _filter = value),
                      ),
                    ),
                    if (shown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.lg),
                        child: Text(
                          l10n.tagsNoMatch,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final tag in shown) ...[
                      ListTile(
                        leading: const Icon(LabFoxIcons.branch),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                tag.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tag.isProtected) ...[
                              const SizedBox(width: LabFoxSpacing.xs),
                              Icon(
                                LabFoxIcons.private,
                                size: LabFoxIconSize.xs,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ],
                        ),
                        subtitle: tag.commit?.title == null
                            ? null
                            : Text(tag.commit!.title),
                        trailing: const Icon(LabFoxIcons.chevron),
                        onTap: () =>
                            context.push(Routes.tag(projectId, tag.name)),
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Loads by project id and tag name, so deep links work independently of list state.
class TagDetailScreen extends ConsumerWidget {
  const TagDetailScreen({
    required this.projectId,
    required this.name,
    super.key,
  });
  final int projectId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = TagRef(projectId, name);
    final tag = ref.watch(tagProvider(key));
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: tag.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Error(
          message: l10n.tagError,
          onRetry: () => ref.invalidate(tagProvider(key)),
        ),
        data: (item) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(LabFoxSpacing.md),
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (item.isProtected) ...[
                  const SizedBox(height: LabFoxSpacing.sm),
                  Row(
                    children: [
                      const Icon(LabFoxIcons.private, size: LabFoxIconSize.sm),
                      const SizedBox(width: LabFoxSpacing.xs),
                      Text(l10n.tagProtected),
                    ],
                  ),
                ],
                if (item.message?.isNotEmpty == true) ...[
                  const SizedBox(height: LabFoxSpacing.md),
                  SelectableText(item.message!),
                ],
                const SizedBox(height: LabFoxSpacing.lg),
                if (item.commit != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(LabFoxIcons.commit),
                      title: Text(item.commit!.title),
                      subtitle: Text(item.commit!.shortId),
                      trailing: const Icon(LabFoxIcons.chevron),
                      onTap: () => context.push(
                        Routes.commit(projectId, item.commit!.id),
                      ),
                    ),
                  ),
                const SizedBox(height: LabFoxSpacing.md),
                FilledButton.icon(
                  onPressed: () =>
                      context.push(Routes.repository(projectId, item.name)),
                  icon: const Icon(LabFoxIcons.code),
                  label: Text(l10n.projectOverviewBrowseCode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateTagDialog extends ConsumerStatefulWidget {
  const _CreateTagDialog({required this.projectId});
  final int projectId;

  @override
  ConsumerState<_CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends ConsumerState<_CreateTagDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _ref = TextEditingController();
  final _message = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _ref.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_form.currentState!.validate() || _saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(tagsControllerProvider(widget.projectId).notifier)
          .create(
            name: _name.text.trim(),
            fromRef: _ref.text.trim(),
            message: _message.text.trim().isEmpty ? null : _message.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tagCreateError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? requiredField(String? value) =>
        value == null || value.trim().isEmpty ? l10n.tagFieldRequired : null;
    return AlertDialog(
      title: Text(l10n.tagNew),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.tagName),
                  validator: requiredField,
                ),
                TextFormField(
                  controller: _ref,
                  decoration: InputDecoration(labelText: l10n.tagFromRef),
                  validator: requiredField,
                ),
                TextFormField(
                  controller: _message,
                  decoration: InputDecoration(labelText: l10n.tagMessage),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(
                  l10n.tagPipelineNotice,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _create,
          child: Text(l10n.tagCreate),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: LabFoxSpacing.md),
        FilledButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    ),
  );
}
