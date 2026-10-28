import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Error and retry action shared by the wiki list and page reader.
class WikiError extends StatelessWidget {
  const WikiError({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(LabFoxSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: LabFoxSpacing.md),
          FilledButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
}
