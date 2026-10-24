import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../l10n/app_localizations.dart';

/// Shows the files changed by a commit or merge request, each as a diff.
///
/// Both the commit and MR detail screens open this with their own provider, so
/// the diff rendering is shared and neither surface duplicates it.
class ChangesScreen extends ConsumerWidget {
  const ChangesScreen({required this.title, required this.provider, super.key});

  final String title;

  /// The diffs to show. Passed in so this screen is agnostic to whether the
  /// changes belong to a commit or a merge request.
  final ProviderListenable<AsyncValue<List<FileDiff>>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final diffs = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: diffs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Text(l10n.changesError, textAlign: TextAlign.center),
          ),
        ),
        data: (files) {
          if (files.isEmpty) {
            return Center(child: Text(l10n.changesEmpty));
          }
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) => DiffFileCard(file: files[index]),
          );
        },
      ),
    );
  }
}

class DiffFileCard extends StatelessWidget {
  const DiffFileCard({
    required this.file,
    this.onLineSelected,
    this.canSelectLine,
    this.lineActionLabel,
    this.highlightedLine,
    this.highlightedLines = const [],
    this.highlightedLineLabel,
    super.key,
  });

  final FileDiff file;
  final ValueChanged<DiffLine>? onLineSelected;
  final bool Function(DiffLine)? canSelectLine;
  final String? lineActionLabel;
  final DiffLine? highlightedLine;
  final List<DiffLine> highlightedLines;
  final String? highlightedLineLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: scheme.surfaceContainer,
          padding: const EdgeInsets.all(LabFoxSpacing.sm),
          child: Row(
            children: [
              Icon(
                _icon(),
                size: LabFoxIconSize.sm,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: LabFoxSpacing.sm),
              Expanded(
                child: Text(
                  file.displayPath,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DiffViewer(
          file: file,
          onLineSelected: onLineSelected,
          canSelectLine: canSelectLine,
          lineActionLabel: lineActionLabel,
          highlightedLine: highlightedLine,
          highlightedLines: highlightedLines,
          highlightedLineLabel: highlightedLineLabel ?? lineActionLabel,
          binaryLabel: l10n.changesBinary,
          omittedLabel: l10n.changesOmitted,
        ),
        const Divider(height: 1),
      ],
    );
  }

  IconData _icon() {
    if (file.isNew) {
      return LabFoxIcons.add;
    }
    if (file.isDeleted) {
      return Icons.remove;
    }
    if (file.isRenamed) {
      return Icons.drive_file_rename_outline;
    }
    return LabFoxIcons.edit;
  }
}
