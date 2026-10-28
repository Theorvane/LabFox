import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/container_immutability_create_controller.dart';
import '../controllers/container_registry_controllers.dart';

class ContainerImmutabilityCreateDialog extends ConsumerStatefulWidget {
  const ContainerImmutabilityCreateDialog({required this.projectId, super.key});
  final int projectId;
  @override
  ConsumerState<ContainerImmutabilityCreateDialog> createState() =>
      _DialogState();
}

class _DialogState extends ConsumerState<ContainerImmutabilityCreateDialog> {
  final _pattern = TextEditingController();
  bool _acknowledged = false;
  bool _busy = false;
  bool _accountChanged = false;
  Object? _error;
  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  Future<void> _submit({bool inspect = false}) async {
    if (_busy || _accountChanged) return;
    final controller = ref.read(
      containerImmutabilityCreateControllerProvider(widget.projectId).notifier,
    );
    if (!inspect &&
        (!_acknowledged ||
            controller.needsInspection ||
            _pattern.text.trim().isEmpty ||
            _pattern.text.runes.length > 100)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (inspect) {
        await controller.inspect(_pattern.text);
        if (mounted) setState(() => _acknowledged = false);
      } else {
        await controller.create(_pattern.text);
        if (mounted && !_accountChanged) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _acknowledged = false;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen(containerRegistryRepositoryProvider, (previous, next) {
      if (previous != null && previous != next) {
        setState(() {
          _accountChanged = true;
          _acknowledged = false;
        });
      }
    });
    final provider = containerImmutabilityCreateControllerProvider(
      widget.projectId,
    );
    ref.watch(provider);
    final needsInspection = ref.read(provider.notifier).needsInspection;
    final valid =
        _pattern.text.trim().isNotEmpty && _pattern.text.runes.length <= 100;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerImmutabilityCreateTitle),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.containerImmutabilityProject(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.projectId),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.containerImmutabilityImpact),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  controller: _pattern,
                  enabled: !_busy && !_accountChanged,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.containerImmutabilityPattern,
                  ),
                  onChanged: (_) => setState(() => _acknowledged = false),
                ),
                const SizedBox(height: LabFoxSpacing.sm),
                Text(l10n.containerImmutabilityPatternHint),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  onChanged: _busy || _accountChanged
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value ?? false),
                  title: Text(l10n.containerImmutabilityAcknowledge),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_accountChanged)
                  Text(l10n.containerImmutabilityAccountChanged),
                if (_error != null && !_accountChanged)
                  Text(switch (_error) {
                    GitLabAuthException() => l10n.containerImmutabilityAuth,
                    GitLabForbiddenException() =>
                      l10n.containerImmutabilityForbidden,
                    GitLabNotFoundException() =>
                      l10n.containerImmutabilityUnavailable,
                    GitLabConflictException() =>
                      l10n.containerImmutabilityRejected,
                    _ => l10n.containerImmutabilityUncertain,
                  }),
                if (needsInspection && !_accountChanged)
                  TextButton(
                    onPressed: _busy ? null : () => _submit(inspect: true),
                    child: Text(l10n.containerImmutabilityInspect),
                  ),
                if (_busy) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed:
                !_busy &&
                    !_accountChanged &&
                    !needsInspection &&
                    valid &&
                    _acknowledged
                ? () => _submit()
                : null,
            child: Text(l10n.containerImmutabilityCreateButton),
          ),
        ],
      ),
    );
  }
}
