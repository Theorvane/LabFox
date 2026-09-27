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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pages = ref.watch(wikiPagesControllerProvider(projectId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wikiTitle),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final created = await showDialog<WikiPage>(
                context: context,
                builder: (_) => _CreateWikiPageDialog(projectId: projectId),
              );
              if (created != null && context.mounted) {
                unawaited(
                  context.push(Routes.wikiPage(projectId, created.slug)),
                );
              }
            },
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
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.wikiEmpty))
            : RefreshIndicator(
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
                          child: Card.outlined(
                            margin: EdgeInsets.zero,
                            child: WikiPageLinks(
                              pages: items,
                              onOpen: (slug) => context.push(
                                Routes.wikiPage(projectId, slug),
                              ),
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

class _CreateWikiPageDialog extends ConsumerStatefulWidget {
  const _CreateWikiPageDialog({required this.projectId});

  final int projectId;

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
      final page = await ref
          .read(wikiPagesControllerProvider(widget.projectId).notifier)
          .create(title: title, content: content);
      if (mounted) Navigator.of(context).pop(page);
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
      title: Text(l10n.wikiNewPage),
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
              decoration: InputDecoration(labelText: l10n.wikiPageTitle),
            ),
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
              Text(l10n.wikiCreateError),
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
          child: Text(l10n.wikiCreatePage),
        ),
      ],
    );
  }
}
