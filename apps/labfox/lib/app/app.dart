import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/app_settings_providers.dart';
import '../l10n/app_localizations.dart';
import 'app_lifecycle.dart';
import 'router.dart';

/// Root widget.
///
/// Stateful purely to own the launch: [initState] runs once per app start,
/// while [build] re-runs on every auth and theme change.
class LabFoxApp extends ConsumerStatefulWidget {
  const LabFoxApp({super.key});

  @override
  ConsumerState<LabFoxApp> createState() => _LabFoxAppState();
}

class _LabFoxAppState extends ConsumerState<LabFoxApp> {
  @override
  void initState() {
    super.initState();
    ref.read(appLifecycleProvider).appOpened();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: router,
      theme: LabFoxTheme.light,
      darkTheme: LabFoxTheme.dark,
      // The user's persisted choice; System until they pick one.
      themeMode: ref.watch(themeModeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
