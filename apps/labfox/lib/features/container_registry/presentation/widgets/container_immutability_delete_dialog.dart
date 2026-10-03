import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/container_immutability_delete_controller.dart';
import '../controllers/container_registry_controllers.dart';

class ContainerImmutabilityDeleteDialog extends ConsumerStatefulWidget {
  const ContainerImmutabilityDeleteDialog({
    required this.projectId,
    required this.rule,
    super.key,
  });
  final int projectId;
  final ContainerTagImmutabilityRule rule;
  @override
  ConsumerState<ContainerImmutabilityDeleteDialog> createState() =>
      _DialogState();
}

class _DialogState extends ConsumerState<ContainerImmutabilityDeleteDialog> {
  final _confirmation = TextEditingController();
  late ContainerTagImmutabilityRule _rule = widget.rule;
  bool _acknowledged = false;
  bool _busy = false;
  bool _accountChanged = false;
  Object? _error;
  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit({bool reload = false}) async {
    if (_busy || _accountChanged) return;
    final controller = ref.read(
      containerImmutabilityDeleteControllerProvider(widget.projectId).notifier,
    );
    if (!reload &&
        (!_acknowledged ||
            controller.needsReload ||
            _confirmation.text != _rule.tagNamePattern)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (reload) {
        final fresh = await controller.reload(_rule.id);
        if (mounted && !_accountChanged) {
          setState(() {
            _rule = fresh;
            _confirmation.clear();
            _acknowledged = false;
          });
        }
      } else {
        await controller.delete(_rule);
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
    final provider = containerImmutabilityDeleteControllerProvider(
      widget.projectId,
    );
    ref.watch(provider);
    final needsReload = ref.read(provider.notifier).needsReload;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(l10n.containerImmutabilityDeleteTitle),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.containerImmutabilityDeleteProject(
                    NumberFormat.decimalPattern(
                      l10n.localeName,
                    ).format(widget.projectId),
                  ),
                ),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.containerImmutabilityDeleteRuleId),
                Text(_rule.id),
                const SizedBox(height: LabFoxSpacing.md),
                Text(_rule.tagNamePattern),
                const SizedBox(height: LabFoxSpacing.md),
                Text(l10n.containerImmutabilityDeleteImpact),
                const SizedBox(height: LabFoxSpacing.md),
                TextField(
                  controller: _confirmation,
                  enabled: !_busy && !_accountChanged,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.containerImmutabilityDeleteConfirm,
                  ),
                  onChanged: (_) => setState(() => _acknowledged = false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _acknowledged,
                  onChanged: _busy || _accountChanged
                      ? null
                      : (value) =>
                            setState(() => _acknowledged = value ?? false),
                  title: Text(l10n.containerImmutabilityDeleteAcknowledge),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_accountChanged)
                  Text(l10n.containerImmutabilityDeleteAccountChanged),
                if (_error != null && !_accountChanged)
                  Text(switch (_error) {
                    GitLabAuthException() =>
                      l10n.containerImmutabilityDeleteAuth,
                    GitLabForbiddenException() =>
                      l10n.containerImmutabilityForbidden,
                    GitLabNotFoundException() =>
                      l10n.containerImmutabilityUnavailable,
                    GitLabConflictException() =>
                      l10n.containerImmutabilityDeleteRejected,
                    _ => l10n.containerImmutabilityDeleteUncertain,
                  }),
                if (needsReload && _error == null && !_accountChanged)
                  Text(l10n.containerImmutabilityDeleteUncertain),
                if (needsReload && !_accountChanged)
                  TextButton(
                    onPressed: _busy ? null : () => _submit(reload: true),
                    child: Text(l10n.containerImmutabilityDeleteReload),
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
                    !needsReload &&
                    _acknowledged &&
                    _confirmation.text == _rule.tagNamePattern
                ? () => _submit()
                : null,
            child: Text(l10n.containerImmutabilityDeleteButton),
          ),
        ],
      ),
    );
  }
}
