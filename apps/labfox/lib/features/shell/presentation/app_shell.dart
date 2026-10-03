import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/ads/ad_banner.dart';
import '../../../l10n/app_localizations.dart';

/// The top-level navigation shell around the primary destinations.
///
/// One feature, one arrangement: a bottom [NavigationBar] on a phone-width
/// window, a [NavigationRail] once there is room. Detail screens are pushed
/// over the shell and get the whole window, as is normal on mobile.
class AppShell extends StatelessWidget {
  const AppShell({required this.currentIndex, required this.child, super.key});

  /// Index into [_destinations] of the active destination.
  final int currentIndex;

  /// The active destination's screen (its own Scaffold with an app bar).
  final Widget child;

  static const _destinations = [
    (route: Routes.home, icon: Icons.home_outlined, selected: Icons.home),
    (
      route: Routes.settings,
      icon: Icons.settings_outlined,
      selected: LabFoxIcons.settings,
    ),
    (
      route: Routes.search,
      icon: LabFoxIcons.search,
      selected: LabFoxIcons.search,
    ),
    (route: Routes.me, icon: LabFoxIcons.person, selected: Icons.person),
  ];

  List<String> _labels(AppLocalizations l10n) => [
    l10n.navHome,
    l10n.settingsTitle,
    l10n.navSearch,
    l10n.navMe,
  ];

  void _onSelect(BuildContext context, int index) {
    if (index != currentIndex) {
      context.go(_destinations[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = _labels(l10n);
    final wide = LabFoxBreakpoints.ofContext(context).isWide;

    if (!wide) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(child: child),
            // The free tier's banner sits between content and the bar;
            // subscribers and desktop builds render nothing here.
            const AdBanner(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => _onSelect(context, i),
          destinations: [
            for (var i = 0; i < _destinations.length; i++)
              NavigationDestination(
                icon: Icon(_destinations[i].icon),
                selectedIcon: Icon(_destinations[i].selected),
                label: labels[i],
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => _onSelect(context, i),
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (var i = 0; i < _destinations.length; i++)
                NavigationRailDestination(
                  icon: Icon(_destinations[i].icon),
                  selectedIcon: Icon(_destinations[i].selected),
                  label: Text(labels[i]),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                const AdBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
