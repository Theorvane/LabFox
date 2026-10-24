import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Lists the connected accounts, marks the active one, and switches, adds, or
/// removes accounts.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(authControllerProvider.notifier);
    // Rebuild when the session changes so the active marker and list stay live.
    ref.watch(authControllerProvider);
    final accounts = notifier.accounts();
    final active = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
        // This route lives outside the navigation shell, so it carries its own
        // way back; entered with context.go there is no stack to pop.
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
        ),
      ),
      body: ListView(
        children: [
          for (final account in accounts)
            ListTile(
              leading: Icon(
                account.id == active?.id
                    ? Icons.check_circle
                    : LabFoxIcons.account,
                color: account.id == active?.id
                    ? LabFoxColors.success
                    : LabFoxColors.pending,
              ),
              title: Text(account.user.username),
              subtitle: Text(Uri.parse(account.instanceUrl).host),
              trailing: IconButton(
                icon: const Icon(LabFoxIcons.signOut),
                tooltip: l10n.accountRemove,
                onPressed: () => notifier.signOut(account),
              ),
              onTap: account.id == active?.id
                  ? null
                  : () => notifier.switchTo(account),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(LabFoxIcons.add),
            title: Text(l10n.accountAdd),
            onTap: () => context.push(Routes.addAccount),
          ),
        ],
      ),
    );
  }
}
