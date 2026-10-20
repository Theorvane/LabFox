import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';

/// The "Me" destination: who is signed in, and the account / settings actions.
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(currentAccountProvider);
    final user = account?.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.meTitle)),
      body: ListView(
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(LabFoxSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: user.avatarUrl == null
                        ? null
                        : NetworkImage(user.avatarUrl!),
                    child: user.avatarUrl == null
                        ? Text(
                            user.name.characters.first.toUpperCase(),
                            style: Theme.of(context).textTheme.headlineSmall,
                          )
                        : null,
                  ),
                  const SizedBox(height: LabFoxSpacing.md),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (account != null)
                    Text(
                      Uri.parse(account.instanceUrl).host,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(LabFoxIcons.switchAccount),
            title: Text(l10n.meAccounts),
            trailing: const Icon(LabFoxIcons.chevron),
            onTap: () => context.push(Routes.accounts),
          ),
          ListTile(
            leading: const Icon(LabFoxIcons.settings),
            title: Text(l10n.meSettings),
            trailing: const Icon(LabFoxIcons.chevron),
            onTap: () => context.go(Routes.settings),
          ),
          if (account != null)
            ListTile(
              leading: const Icon(LabFoxIcons.share),
              title: Text(l10n.meShareProfile),
              onTap: () {
                final url =
                    account.user.webUrl ??
                    '${account.instanceUrl}/${account.user.username}';
                SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
              },
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(LabFoxIcons.signOut),
            title: Text(l10n.signOut),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
