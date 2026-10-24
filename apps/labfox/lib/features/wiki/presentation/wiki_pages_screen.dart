import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/wiki_controllers.dart';
import 'widgets/wiki_error.dart';
import 'widgets/wiki_page_links.dart';

/// Lists pages in a project wiki.
class WikiPagesScreen extends ConsumerWidget {
  const WikiPagesScreen({required this.projectId, super.key});

  final int projectId;

  Future<void> _openCreate(
    BuildContext context, {
    required bool template,
  }) async {
    final created = await showDialog<WikiPage>(
      context: context,
      builder: (_) =>
          _CreateWikiPageDialog(projectId: projectId, isTemplate: template),
    );
    if (created != null && context.mounted) {
      unawaited(context.push(Routes.wikiPage(projectId, created.slug)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pages = ref.watch(wikiPagesControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wikiTitle),
        actions: [
          IconButton(
            tooltip: l10n.wikiNewTemplate,
            onPressed: () => _openCreate(context, template: true),
            icon: const Icon(Icons.post_add_outlined),
          ),
          TextButton.icon(
            onPressed: () => _openCreate(context, template: false),
            icon: const Icon(Icons.add),
            label: Text(l10n.wikiNewPage),
          ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(projectId)),
        ),
      ),
      body: pages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => WikiError(
          message: l10n.wikiListError,
          onRetry: () => ref.invalidate(wikiPagesControllerProvider(projectId)),
        ),
        data: (items) {
          final templates = items
              .where((page) => page.slug.startsWith('templates/'))
              .toList();
          final ordinary = items
              .where((page) => !page.slug.startsWith('templates/'))
              .toList();
          Widget section(
            String title,
            String emptyMessage,
            List<WikiPage> pages,
          ) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: LabFoxSpacing.sm),
              Card.outlined(
                margin: EdgeInsets.zero,
                child: pages.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(LabFoxSpacing.md),
                        child: Text(emptyMessage),
                      )
                    : WikiPageLinks(
                        pages: pages,
                        onOpen: (slug) =>
                            context.push(Routes.wikiPage(projectId, slug)),
                      ),
              ),
            ],
          );

          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(wikiPagesControllerProvider(projectId).future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(LabFoxSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          section(
                            l10n.wikiPagesSection,
                            l10n.wikiEmpty,
                            ordinary,
                          ),
                          const SizedBox(height: LabFoxSpacing.lg),
                          section(
                            l10n.wikiTemplatesSection,
                            l10n.wikiTemplateEmpty,
                            templates,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CreateWikiPageDialog extends ConsumerStatefulWidget {
  const _CreateWikiPageDialog({
    required this.projectId,
    required this.isTemplate,
  });

  final int projectId;
  final bool isTemplate;

  @override
  ConsumerState<_CreateWikiPageDialog> createState() =>
      _CreateWikiPageDialogState();
}

class _CreateWikiPageDialogState extends ConsumerState<_CreateWikiPageDialog> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _busy = false;
  bool _invalid = false;
  bool _failed = false;
  bool _templateFailed = false;
  String? _selectedTemplate;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _create() async {
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
    });
    try {
      final controller = ref.read(
        wikiPagesControllerProvider(widget.projectId).notifier,
      );
      final page = widget.isTemplate
          ? await controller.createTemplate(title: title, content: content)
          : await controller.create(title: title, content: content);
      if (mounted) Navigator.of(context).pop(page);
    } on GitLabException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyTemplate(String slug) async {
    final l10n = AppLocalizations.of(context);
    if (_content.text.isNotEmpty) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(l10n.wikiReplaceTemplateContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.wikiApplyTemplate),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }
    setState(() {
      _busy = true;
      _templateFailed = false;
    });
    try {
      final template = await ref.read(
        wikiPageControllerProvider(
          WikiPageRef(projectId: widget.projectId, slug: slug),
        ).future,
      );
      if (template.format != null && template.format != 'markdown') {
        throw StateError('Unsupported wiki template format');
      }
      if (mounted) {
        setState(() {
          _content.text = template.content ?? '';
          _selectedTemplate = slug;
          _invalid = false;
        });
      }
    } on Exception {
      if (mounted) setState(() => _templateFailed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final templates =
        ref
            .watch(wikiPagesControllerProvider(widget.projectId))
            .valueOrNull
            ?.where(
              (page) =>
                  page.slug.startsWith('templates/') &&
                  (page.format == null || page.format == 'markdown'),
            )
            .toList() ??
        const <WikiPage>[];
    return AlertDialog(
      title: Text(widget.isTemplate ? l10n.wikiNewTemplate : l10n.wikiNewPage),
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
              decoration: InputDecoration(
                labelText: widget.isTemplate
                    ? l10n.wikiTemplateTitle
                    : l10n.wikiPageTitle,
              ),
            ),
            if (templates.isNotEmpty) ...[
              const SizedBox(height: LabFoxSpacing.md),
              DropdownButton<String>(
                value: _selectedTemplate,
                isExpanded: true,
                hint: Text(l10n.wikiChooseTemplate),
                onChanged: _busy
                    ? null
                    : (slug) {
                        if (slug != null) _applyTemplate(slug);
                      },
                items: [
                  for (final template in templates)
                    DropdownMenuItem<String>(
                      value: template.slug,
                      child: Text(template.title),
                    ),
                ],
              ),
            ],
            const SizedBox(height: LabFoxSpacing.md),
            TextField(
              controller: _content,
              enabled: !_busy,
              minLines: 6,
              maxLines: 12,
              decoration: InputDecoration(
                labelText: l10n.wikiPageContent,
                alignLabelWithHint: true,
              ),
            ),
            if (_invalid) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.wikiCreateValidationError),
            ],
            if (_failed) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(
                widget.isTemplate
                    ? l10n.wikiCreateTemplateError
                    : l10n.wikiCreateError,
              ),
            ],
            if (_templateFailed) ...[
              const SizedBox(height: LabFoxSpacing.sm),
              Text(l10n.wikiTemplateLoadError),
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
          child: Text(
            widget.isTemplate ? l10n.wikiCreateTemplate : l10n.wikiCreatePage,
          ),
        ),
      ],
    );
  }
}
