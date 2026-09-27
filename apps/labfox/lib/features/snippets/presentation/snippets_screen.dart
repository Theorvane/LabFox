import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/snippets_controller.dart';

/// A project's snippets, styled as compact GitLab work items.
class SnippetsScreen extends ConsumerWidget {
  const SnippetsScreen({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snippets = ref.watch(projectSnippetsProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.snippetsTitle),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final created = await showDialog<Snippet>(
                context: context,
                builder: (_) => _CreateSnippetDialog(projectId: projectId),
              );
              if (created != null && context.mounted) {
                unawaited(context.push(Routes.snippet(projectId, created.id)));
              }
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.snippetNew),
          ),
        ],
      ),
      body: snippets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Retry(
          message: l10n.snippetsError,
          onRetry: () => ref.invalidate(projectSnippetsProvider(projectId)),
        ),
        data: (items) => items.isEmpty
            ? EmptyState(icon: LabFoxIcons.code, title: l10n.snippetsEmpty)
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(projectSnippetsProvider(projectId).future),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final snippet = items[index];
                        return ListTile(
                          leading: const Icon(LabFoxIcons.code),
                          title: Text(snippet.title),
                          subtitle: snippet.description?.isNotEmpty == true
                              ? Text(
                                  snippet.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : (snippet.fileName == null
                                    ? null
                                    : Text(snippet.fileName!)),
                          trailing: const Icon(LabFoxIcons.chevron),
                          onTap: () => context.push(
                            Routes.snippet(projectId, snippet.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CreateSnippetDialog extends ConsumerStatefulWidget {
  const _CreateSnippetDialog({required this.projectId});

  final int projectId;

  @override
  ConsumerState<_CreateSnippetDialog> createState() =>
      _CreateSnippetDialogState();
}

class _CreateSnippetDialogState extends ConsumerState<_CreateSnippetDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _filePath = TextEditingController();
  final _content = TextEditingController();
  String _visibility = 'private';
  bool _busy = false;
  bool _invalid = false;
  bool _failed = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _filePath.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _title.text.trim();
    final description = _description.text.trim();
    final filePath = _filePath.text.trim();
    final content = _content.text;
    if (title.isEmpty ||
        filePath.isEmpty ||
        filePath.startsWith('/') ||
        filePath.contains('\\') ||
        filePath
            .split('/')
            .any((part) => part.isEmpty || part == '.' || part == '..') ||
        content.trim().isEmpty) {
      setState(() {
        _invalid = true;
        _failed = false;
      });
      return;
    }
    setState(() {
      _busy = true;
      _invalid = false;
      _failed = false;
    });
    try {
      final snippet = await ref
          .read(createSnippetControllerProvider.notifier)
          .create(
            projectId: widget.projectId,
            title: title,
            description: description,
            visibility: _visibility,
            filePath: filePath,
            content: content,
          );
      if (mounted) Navigator.of(context).pop(snippet);
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.snippetNew),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.snippetTitleField),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            TextField(
              controller: _description,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.snippetDescriptionField,
              ),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            TextField(
              controller: _filePath,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.snippetFilePathField),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            TextField(
              controller: _content,
              enabled: !_busy,
              minLines: 6,
              maxLines: 12,
              decoration: InputDecoration(
                labelText: l10n.snippetContentField,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _visibility,
              decoration: InputDecoration(
                labelText: l10n.snippetVisibilityField,
              ),
              items: [
                DropdownMenuItem(
                  value: 'private',
                  child: Text(l10n.snippetPrivate),
                ),
                DropdownMenuItem(
                  value: 'public',
                  child: Text(l10n.snippetPublic),
                ),
              ],
              onChanged: _busy
                  ? null
                  : (value) {
                      if (value != null) setState(() => _visibility = value);
                    },
            ),
            if (_invalid) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.snippetCreateValidationError),
            ],
            if (_failed) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.snippetCreateError),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: Text(l10n.snippetCreate),
        ),
      ],
    );
  }
}

class SnippetDetailScreen extends ConsumerWidget {
  const SnippetDetailScreen({
    required this.projectId,
    required this.snippetId,
    super.key,
  });

  final int projectId;
  final int snippetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = SnippetRef(projectId, snippetId);
    final snippet = ref.watch(projectSnippetProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(snippet.valueOrNull?.title ?? l10n.snippetsTitle),
        actions: [
          if (snippet.valueOrNull case final item?)
            IconButton(
              tooltip: l10n.snippetEditAction,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) =>
                    _EditSnippetDialog(projectId: projectId, snippet: item),
              ),
            ),
          if (snippet.hasValue)
            IconButton(
              tooltip: l10n.snippetDeleteAction,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final deleted = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => _DeleteSnippetDialog(
                    projectId: projectId,
                    snippetId: snippetId,
                  ),
                );
                if (deleted == true && context.mounted) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.snippets(projectId));
                  }
                }
              },
            ),
        ],
      ),
      body: snippet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Retry(
          message: l10n.snippetError,
          onRetry: () => ref.invalidate(projectSnippetProvider(key)),
        ),
        data: (item) => _SnippetBody(projectId: projectId, snippet: item),
      ),
    );
  }
}

class _EditSnippetDialog extends ConsumerStatefulWidget {
  const _EditSnippetDialog({required this.projectId, required this.snippet});

  final int projectId;
  final Snippet snippet;

  @override
  ConsumerState<_EditSnippetDialog> createState() => _EditSnippetDialogState();
}

class _EditSnippetDialogState extends ConsumerState<_EditSnippetDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.snippet.title,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.snippet.description ?? '',
  );
  bool _busy = false;
  bool _invalid = false;
  bool _failed = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() {
        _invalid = true;
        _failed = false;
      });
      return;
    }
    setState(() {
      _busy = true;
      _invalid = false;
      _failed = false;
    });
    try {
      await ref
          .read(updateSnippetControllerProvider.notifier)
          .updateMetadata(
            projectId: widget.projectId,
            snippetId: widget.snippet.id,
            title: title,
            description: _description.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } on Exception {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.snippetEditTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.snippetTitleField),
            ),
            const SizedBox(height: LabFoxSpacing.sm),
            TextField(
              controller: _description,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.snippetDescriptionField,
              ),
            ),
            if (_invalid) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.snippetEditValidationError),
            ],
            if (_failed) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.snippetEditError),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(l10n.snippetSaveChanges),
        ),
      ],
    );
  }
}

class _DeleteSnippetDialog extends ConsumerStatefulWidget {
  const _DeleteSnippetDialog({
    required this.projectId,
    required this.snippetId,
  });

  final int projectId;
  final int snippetId;

  @override
  ConsumerState<_DeleteSnippetDialog> createState() =>
      _DeleteSnippetDialogState();
}

class _DeleteSnippetDialogState extends ConsumerState<_DeleteSnippetDialog> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(deleteSnippetControllerProvider.notifier)
          .delete(projectId: widget.projectId, snippetId: widget.snippetId);
      if (mounted) Navigator.of(context).pop(true);
    } on Exception {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.snippetDeleteConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.snippetDeleteConfirmMessage),
          if (_failed) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            Text(l10n.snippetDeleteError),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _delete,
          child: Text(l10n.snippetDeleteButton),
        ),
      ],
    );
  }
}

class _SnippetBody extends ConsumerWidget {
  const _SnippetBody({required this.projectId, required this.snippet});

  final int projectId;
  final Snippet snippet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = snippet.files;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(LabFoxSpacing.md),
          children: [
            Text(
              snippet.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (snippet.description?.isNotEmpty == true) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(snippet.description!),
            ],
            const SizedBox(height: LabFoxSpacing.lg),
            if (files.length > 1)
              for (final file in files)
                Card(
                  child: ListTile(
                    leading: const Icon(LabFoxIcons.file),
                    title: Text(file.path),
                    trailing: const Icon(LabFoxIcons.chevron),
                    onTap: () => context.push(
                      Routes.snippetFile(projectId, snippet.id, file.path),
                    ),
                  ),
                )
            else ...[
              _SingleSnippetContent(
                projectId: projectId,
                snippetId: snippet.id,
                filePath: files.isNotEmpty
                    ? files.first.path
                    : snippet.fileName,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SingleSnippetContent extends ConsumerWidget {
  const _SingleSnippetContent({
    required this.projectId,
    required this.snippetId,
    required this.filePath,
  });

  final int projectId;
  final int snippetId;
  final String? filePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(
      snippetRawProvider(SnippetRef(projectId, snippetId)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                filePath ?? l10n.snippetContent,
                style: LabFoxTextRoles.of(context).sectionHeader,
              ),
            ),
            if (filePath case final path?)
              if (content.valueOrNull case final text?)
                TextButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _EditSnippetContentDialog(
                      projectId: projectId,
                      snippetId: snippetId,
                      filePath: path,
                      initialContent: text,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.snippetEditContent),
                ),
          ],
        ),
        const SizedBox(height: LabFoxSpacing.sm),
        _Content(content: content),
      ],
    );
  }
}

class _EditSnippetContentDialog extends ConsumerStatefulWidget {
  const _EditSnippetContentDialog({
    required this.projectId,
    required this.snippetId,
    required this.filePath,
    required this.initialContent,
  });

  final int projectId;
  final int snippetId;
  final String filePath;
  final String initialContent;

  @override
  ConsumerState<_EditSnippetContentDialog> createState() =>
      _EditSnippetContentDialogState();
}

class _EditSnippetContentDialogState
    extends ConsumerState<_EditSnippetContentDialog> {
  late final TextEditingController _content = TextEditingController(
    text: widget.initialContent,
  );
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(updateSnippetContentControllerProvider.notifier)
          .saveContent(
            projectId: widget.projectId,
            snippetId: widget.snippetId,
            filePath: widget.filePath,
            content: _content.text,
          );
      if (mounted) Navigator.of(context).pop();
    } on Exception {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.snippetEditContent),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.filePath),
            const SizedBox(height: LabFoxSpacing.sm),
            TextField(
              controller: _content,
              enabled: !_busy,
              minLines: 8,
              maxLines: 14,
              decoration: InputDecoration(
                labelText: l10n.snippetContentField,
                alignLabelWithHint: true,
              ),
            ),
            if (_failed) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.snippetContentSaveError),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(l10n.snippetSaveContent),
        ),
      ],
    );
  }
}

class SnippetFileScreen extends ConsumerWidget {
  const SnippetFileScreen({
    required this.projectId,
    required this.snippetId,
    required this.path,
    super.key,
  });

  final int projectId;
  final int snippetId;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(
      snippetFileProvider(SnippetFileRef(projectId, snippetId, path)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(path.split('/').last),
        actions: [
          if (content case AsyncData<String>(value: final text))
            IconButton(
              tooltip: l10n.snippetEditContent,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _EditSnippetContentDialog(
                  projectId: projectId,
                  snippetId: snippetId,
                  filePath: path,
                  initialContent: text,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(LabFoxSpacing.md),
        child: _Content(content: content),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.content});
  final AsyncValue<String> content;

  @override
  Widget build(BuildContext context) => content.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) => Text(AppLocalizations.of(context).snippetContentError),
    data: (text) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    ),
  );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});
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
