import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../auth/account_store.dart';
import '../auth/auth_repository.dart';
import '../storage/local_projects_store.dart';
import 'todo_digest.dart';

/// Whether the user asked for background checks. Off until they do: this
/// spends battery and network on their behalf.
const backgroundNotificationsKey = 'background_notifications';

/// The ids announced at the last check, so the next one only reports news.
const _seenTodosKey = 'background_seen_todos';

const _taskName = 'labfox.todo_check';

/// The identifier the work is scheduled under.
///
/// On iOS this is also the BGTaskScheduler identifier, which has to be
/// permitted in `Info.plist` and registered in the AppDelegate — exported so a
/// test can hold all three to the same string.
const backgroundTaskIdentifier = 'labfox.todo_check.periodic';

/// The floor Android enforces on periodic work. Asking for less does not make
/// it run more often; it just makes the request a lie.
const _frequency = Duration(minutes: 15);

const _channelId = 'labfox_todos';

/// The background entry point.
///
/// Runs in its own isolate with no app state, so everything it needs — the
/// account, the token, what was already announced — is read from storage
/// rather than passed in.
@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) => runTodoCheck());
}

/// Checks the to-do list once and posts what is new.
///
/// Always reports success: a background task that reports failure is retried
/// with backoff, and there is nothing here worth retrying — the next scheduled
/// run is soon enough, and a retry storm on a failing instance would cost the
/// user battery for nothing.
Future<bool> runTodoCheck() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // Recheck the setting because a scheduled task can remain queued after
    // the user turns background checks off.
    if (prefs.getBool(backgroundNotificationsKey) != true) {
      return true;
    }

    final account = AccountStore(prefs).readActive();
    if (account == null) {
      return true;
    }
    final auth = AuthRepository(
      accountStore: AccountStore(prefs),
      credentialStore: CredentialStore(),
      projectsStore: LocalProjectsStore(prefs),
    );
    final token = await auth.tokenFor(account);
    if (token == null) {
      return true;
    }

    final client = GitLabClient(
      baseUrl: account.instanceUrl,
      token: token,
      bearer: account.authMethod == AuthMethod.oauth,
    );
    try {
      final page = await client.todos.list(state: TodoState.pending);
      final stored = prefs.getStringList(_seenTodosKey);
      final digest = digestTodos(page.items, stored?.map(int.parse).toSet());
      await prefs.setStringList(
        _seenTodosKey,
        digest.seenIds.map((id) => '$id').toList(growable: false),
      );
      if (digest.entries.isNotEmpty) {
        await _show(digest.entries);
      }
    } finally {
      client.close();
    }
  } catch (_) {
    // Never surfaces: this runs with no one watching.
  }
  return true;
}

Future<void> _show(List<TodoNotification> entries) async {
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'To-do list',
      channelDescription: 'New items on your GitLab to-do list.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );
  for (final entry in entries) {
    await plugin.show(
      id: entry.id,
      title: entry.title,
      body: entry.body,
      notificationDetails: details,
    );
  }
}

/// Starts and stops the periodic check.
///
/// Kept behind an interface so the settings toggle can be tested without a
/// platform channel.
abstract class BackgroundChecks {
  /// Asks for the notification permission and schedules the check.
  ///
  /// Returns false when the user refused: scheduling work whose notifications
  /// the system will drop is a silent failure, so the caller turns the setting
  /// back off instead.
  Future<bool> enable();

  Future<void> disable();
}

class WorkmanagerBackgroundChecks implements BackgroundChecks {
  const WorkmanagerBackgroundChecks();

  @override
  Future<bool> enable() async {
    if (!await _requestPermission()) {
      return false;
    }
    await Workmanager().initialize(backgroundCallbackDispatcher);
    await Workmanager().registerPeriodicTask(
      backgroundTaskIdentifier,
      _taskName,
      frequency: _frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
    return true;
  }

  /// Android 13+ and every iOS version ask before the first notification.
  /// A null answer means the platform has nothing to ask — treat it as granted.
  Future<bool> _requestPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    if (Platform.isAndroid) {
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? true;
    }
    final ios = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
  }

  @override
  Future<void> disable() =>
      Workmanager().cancelByUniqueName(backgroundTaskIdentifier);
}
