import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/entitlement/entitlement_providers.dart';
import '../../../core/entitlement/paywall.dart';
import '../../../core/notifications/notifications_providers.dart';
import '../../../core/settings/app_settings_providers.dart';
import '../../../core/ui/link_opener.dart';
import '../../../l10n/app_localizations.dart';

/// App settings.
///
/// For 1.0 this is the account entry point and the open-source license notice,
/// which LabFox is obliged to expose (see THIRD_PARTY_NOTICES.md). Flutter
/// collects each pub dependency's license automatically, so [showLicensePage]
/// satisfies the attribution requirement.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// The name shown on the license page.
  static const _applicationName = 'LabFox';

  /// Copyright line shown on the license page. Not localized: it is a notice,
  /// not UI copy.
  static const _legalese = '© 2026 sloki9637 · Apache-2.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final open = ref.watch(linkOpenerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final mobile = ref.watch(mobilePlatformProvider);
    final backgroundChecks = ref.watch(backgroundNotificationsProvider);
    final version = ref.watch(appVersionProvider);
    final entitlement = ref.watch(entitlementProvider);
    final freePlatform = ref.watch(freePlatformProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          // First, not buried: the subscription is the one row here a user
          // may need to find in a hurry. Hidden where the app ships with
          // every feature — an entry would sell what the user already has.
          if (!freePlatform) ...[
            ListTile(
              leading: Icon(
                LabFoxIcons.star,
                color: entitlement.isSubscribed
                    ? LabFoxStatusColors.of(context).merged.foreground
                    : null,
              ),
              title: Text(l10n.subscriptionTitle),
              subtitle: Text(
                entitlement.isSubscribed
                    ? l10n.subscriptionActive
                    : l10n.subscriptionInactive,
              ),
              trailing: const Icon(LabFoxIcons.chevron),
              onTap: () => context.push(Routes.subscription),
            ),
            const Divider(height: 1),
          ],
          ListTile(
            leading: const Icon(LabFoxIcons.account),
            title: Text(l10n.settingsAccounts),
            trailing: const Icon(LabFoxIcons.chevron),
            onTap: () => context.push(Routes.accounts),
          ),
          const Divider(height: 1),
          if (mobile) ...[
            _SectionHeader(l10n.settingsNotifications),
            SwitchListTile(
              value: backgroundChecks,
              title: Text(l10n.settingsBackgroundChecks),
              subtitle: Text(l10n.settingsBackgroundChecksHelp),
              onChanged: (value) => runSubscribed(
                context,
                ref,
                feature: PaidFeature.notifications,
                action: () => _setBackgroundChecks(context, ref, value),
              ),
            ),
            const Divider(height: 1),
          ],
          _SectionHeader(l10n.settingsAppearance),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).set(value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(switch (mode) {
                      ThemeMode.system => l10n.settingsThemeSystem,
                      ThemeMode.light => l10n.settingsThemeLight,
                      ThemeMode.dark => l10n.settingsThemeDark,
                    }),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SectionHeader(l10n.settingsAbout),
          ListTile(
            leading: const Icon(LabFoxIcons.document),
            title: Text(l10n.settingsVersion),
            trailing: Text(
              version.valueOrNull ?? '',
              style: LabFoxTextRoles.of(context).meta,
            ),
          ),
          ListTile(
            leading: const Icon(LabFoxIcons.private),
            title: Text(l10n.settingsPrivacyPolicy),
            trailing: const Icon(LabFoxIcons.chevron),
            onTap: () => context.push(Routes.privacy),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(LabFoxIcons.document),
            title: Text(l10n.settingsTerms),
            trailing: const Icon(LabFoxIcons.openInBrowser),
            onTap: () => open(Uri.parse('https://www.sloki9637.com/terms')),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(LabFoxIcons.public),
            title: Text(l10n.settingsWebsite),
            trailing: const Icon(LabFoxIcons.openInBrowser),
            onTap: () => open(Uri.parse('https://www.sloki9637.com')),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(LabFoxIcons.document),
            title: Text(l10n.settingsLicenses),
            trailing: const Icon(LabFoxIcons.chevron),
            onTap: () => showLicensePage(
              context: context,
              applicationName: _applicationName,
              applicationLegalese: _legalese,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LabFoxSpacing.lg),
            child: Text(
              _legalese,
              textAlign: TextAlign.center,
              style: LabFoxTextRoles.of(context).meta,
            ),
          ),
        ],
      ),
    );
  }
}

/// Flips the background-check setting, and says so if the system refused the
/// notification permission — the switch snapping back with no explanation
/// reads as a bug.
Future<void> _setBackgroundChecks(
  BuildContext context,
  WidgetRef ref,
  bool value,
) async {
  await ref.read(backgroundNotificationsProvider.notifier).set(value);
  if (!context.mounted || !value || ref.read(backgroundNotificationsProvider)) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context).settingsNotificationsDenied),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: LabFoxSpacing.md,
        right: LabFoxSpacing.md,
        top: LabFoxSpacing.md,
        bottom: LabFoxSpacing.xs,
      ),
      child: Text(label, style: LabFoxTextRoles.of(context).sectionHeader),
    );
  }
}
