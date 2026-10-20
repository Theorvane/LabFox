import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics.dart';
import '../auth/auth_providers.dart';
import 'background_notifications.dart';

/// Whether background scheduling exists on this platform.
///
/// Android's WorkManager and iOS's BGTaskScheduler are what this is built on;
/// the desktop builds have neither, so the setting is not offered there rather
/// than offered and silently doing nothing.
final mobilePlatformProvider = Provider<bool>((ref) {
  return Platform.isAndroid || Platform.isIOS;
});

final backgroundChecksProvider = Provider<BackgroundChecks>((ref) {
  return const WorkmanagerBackgroundChecks();
});

/// Whether the periodic to-do check is on, and the switch that changes it.
class BackgroundNotificationsController extends Notifier<bool> {
  @override
  bool build() {
    return ref
            .watch(sharedPreferencesProvider)
            .getBool(backgroundNotificationsKey) ??
        false;
  }

  /// Persists the choice first, then schedules: the background task re-reads
  /// the flag, so the stored value is what actually decides whether a run does
  /// anything.
  Future<void> set(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final checks = ref.read(backgroundChecksProvider);
    state = enabled;
    await prefs.setBool(backgroundNotificationsKey, enabled);
    if (!enabled) {
      await checks.disable();
      unawaited(
        ref.read(analyticsProvider).track('background_checks', {'on': false}),
      );
      return;
    }
    // The switch only stays on if the system will actually deliver.
    final granted = await checks.enable();
    if (!granted) {
      state = false;
      await prefs.setBool(backgroundNotificationsKey, false);
    }
    // Record refusals as well as successful scheduling.
    unawaited(
      ref.read(analyticsProvider).track('background_checks', {'on': granted}),
    );
  }
}

final backgroundNotificationsProvider =
    NotifierProvider<BackgroundNotificationsController, bool>(
      BackgroundNotificationsController.new,
    );
