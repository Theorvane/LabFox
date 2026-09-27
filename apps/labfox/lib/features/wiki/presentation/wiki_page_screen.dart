import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ui/link_opener.dart';
import '../../../l10n/app_localizations.dart';
import '../data/wiki_repository.dart';
import 'controllers/wiki_controllers.dart';
import 'widgets/wiki_error.dart';
import 'widgets/wiki_page_links.dart';

/// Reads one wiki page, with a page sidebar on wider screens.
class WikiPageScreen extends ConsumerWidget {
  const WikiPageScreen({
    required this.projectId,
    required this.slug,
    super.key,
  });

  final int projectId;
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pageRef = WikiPageRef(projectId: projectId, slug: slug);
    final page = ref.watch(wikiPageControllerProvider(pageRef));
    final wide = LabFoxBreakpoints.ofContext(context).isWide;
    final pages = wide
        ? ref.watch(wikiPagesControllerProvider(projectId))
        : null;
    final openLink = ref.watch(linkOpenerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(page.valueOrNull?.title ?? l10n.wikiTitle),
        actions: [
          if (page.valueOrNull case final current?)
            TextButton.icon(
              onPressed: () async {
                final saved = await showDialog<WikiPage>(
                  context: context,
                  builder: (_) =>
                      _EditWikiPageDialog(page: current, pageRef: pageRef),
                );
                if (saved != null &&
                    saved.slug != current.slug &&
                    context.mounted) {
                  context.go(Routes.wikiPage(projectId, saved.slug));
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.wikiEditPageAction),
            ),
          if (page.valueOrNull case final current?)
            IconButton(
              tooltip: l10n.wikiDeletePageAction,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final deleted = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      _DeleteWikiPageDialog(page: current, pageRef: pageRef),
                );
                if (deleted == true && context.mounted) {
                  context.go(Routes.wiki(projectId));
                }
              },
            ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.wiki(projectId)),
        ),
      ),
      body: page.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => WikiError(
          message: l10n.wikiPageError,
          onRetry: () => ref.invalidate(wikiPageControllerProvider(pageRef)),
        ),
        data: (item) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wide)
                  SizedBox(
                    width: 280,
                    child: pages?.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => WikiError(
                        message: l10n.wikiListError,
                        onRetry: () => ref.invalidate(
                          wikiPagesControllerProvider(projectId),
                        ),
                      ),
                      data: (items) => ListView(
                        children: [
                          WikiPageLinks(
                            pages: items,
                            selectedSlug: slug,
                            onOpen: (nextSlug) => context.go(
                              Routes.wikiPage(projectId, nextSlug),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (wide) const VerticalDivider(width: LabFoxSpacing.md),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(LabFoxSpacing.md),
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: LabFoxSpacing.md),
                      if (item.format == null || item.format == 'markdown')
                        MarkdownViewer(
                          data: item.content ?? '',
                          onTapLink: (href) {
                            final uri = Uri.tryParse(href);
                            if (uri == null) {
                              return;
                            }
                            if (uri.hasScheme) {
                              openLink(uri);
                            } else if (!uri.hasAuthority &&
                                uri.path.isNotEmpty) {
                              final linkedSlug = Uri(
                                path: slug,
                              ).resolveUri(uri).path;
                              if (linkedSlug.isNotEmpty) {
                                context.push(
                                  Routes.wikiPage(projectId, linkedSlug),
                                );
                              }
                            }
                          },
                        )
                      else
                        SelectableText(item.content ?? ''),
                    ],
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

class _DeleteWikiPageDialog extends ConsumerStatefulWidget {
  const _DeleteWikiPageDialog({required this.page, required this.pageRef});

  final WikiPage page;
  final WikiPageRef pageRef;

  @override
  ConsumerState<_DeleteWikiPageDialog> createState() =>
      _DeleteWikiPageDialogState();
}

class _DeleteWikiPageDialogState extends ConsumerState<_DeleteWikiPageDialog> {
  bool _busy = false;
  bool _failed = false;
  bool _conflict = false;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _failed = false;
      _conflict = false;
    });
    try {
      await ref
          .read(wikiPageControllerProvider(widget.pageRef).notifier)
          .delete(original: widget.page);
      if (mounted) Navigator.of(context).pop(true);
    } on WikiEditConflictException {
      if (mounted) setState(() => _conflict = true);
    } on Exception {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reload() {
    ref.invalidate(wikiPageControllerProvider(widget.pageRef));
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.wikiDeleteConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.page.title),
          const SizedBox(height: LabFoxSpacing.sm),
          Text(l10n.wikiDeleteConfirmMessage),
          if (_failed) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            Text(l10n.wikiDeleteError),
          ],
          if (_conflict) ...[
            const SizedBox(height: LabFoxSpacing.sm),
            Text(l10n.wikiDeleteConflict),
          ],
        ],
      ),
      actions: [
        if (_conflict)
          TextButton(
            onPressed: _busy ? null : _reload,
            child: Text(l10n.wikiReloadPage),
          ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy || _conflict ? null : _delete,
          child: Text(l10n.wikiDeletePageAction),
        ),
      ],
    );
  }
}

class _EditWikiPageDialog extends ConsumerStatefulWidget {
  const _EditWikiPageDialog({required this.page, required this.pageRef});

  final WikiPage page;
  final WikiPageRef pageRef;

  @override
  ConsumerState<_EditWikiPageDialog> createState() =>
      _EditWikiPageDialogState();
}

class _EditWikiPageDialogState extends ConsumerState<_EditWikiPageDialog> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  bool _busy = false;
  bool _invalid = false;
  bool _failed = false;
  bool _conflict = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.page.title);
    _content = TextEditingController(text: widget.page.content ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final content = _content.text;
    if (title.isEmpty || content.trim().isEmpty) {
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
      _conflict = false;
    });
    try {
      final saved = await ref
          .read(wikiPageControllerProvider(widget.pageRef).notifier)
          .save(original: widget.page, title: title, content: content);
      if (mounted) Navigator.of(context).pop(saved);
    } on WikiEditConflictException {
      if (mounted) setState(() => _conflict = true);
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reload() {
    ref.invalidate(wikiPageControllerProvider(widget.pageRef));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.wikiEditPage),
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
              decoration: InputDecoration(labelText: l10n.wikiEditTitle),
            ),
            const SizedBox(height: LabFoxSpacing.md),
            TextField(
              controller: _content,
              enabled: !_busy,
              minLines: 6,
              maxLines: 12,
              decoration: InputDecoration(
                labelText: l10n.wikiEditContent,
                alignLabelWithHint: true,
              ),
            ),
            if (_invalid) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.wikiEditValidationError),
            ],
            if (_failed) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.wikiEditError),
            ],
            if (_conflict) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.wikiEditConflict),
            ],
          ],
        ),
      ),
      actions: [
        if (_conflict)
          TextButton(
            onPressed: _busy ? null : _reload,
            child: Text(l10n.wikiReloadPage),
          ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy || _conflict ? null : _save,
          child: Text(l10n.wikiSaveChanges),
        ),
      ],
    );
  }
}
