import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// A compact, navigable list of project wiki pages.
class WikiPageLinks extends StatelessWidget {
  const WikiPageLinks({
    required this.pages,
    required this.onOpen,
    this.selectedSlug,
    super.key,
  });

  final List<WikiPage> pages;
  final String? selectedSlug;
  final void Function(String slug) onOpen;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final page in pages)
        ListTile(
          leading: const Icon(LabFoxIcons.document),
          title: Text(page.title),
          subtitle: page.slug.contains('/') ? Text(page.slug) : null,
          selected: page.slug == selectedSlug,
          trailing: const Icon(LabFoxIcons.chevron),
          onTap: () => onOpen(page.slug),
        ),
    ],
  );
}
