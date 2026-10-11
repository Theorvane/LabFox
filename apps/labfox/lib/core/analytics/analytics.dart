import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where events go and which project they belong to.
///
/// Defaults point at the LabFox OpenPanel project and can be overridden at
/// build time (`--dart-define=OPENPANEL_URL=... OPENPANEL_CLIENT_ID=...`).
/// Only the public client id is used here — the server-events secret is never
/// needed by the app and must never enter this repository (AGENTS §7).
class AnalyticsConfig {
  const AnalyticsConfig({
    this.endpoint = const String.fromEnvironment(
      'OPENPANEL_URL',
      defaultValue: 'https://panel.sanhouse.kr/api',
    ),
    this.clientId = const String.fromEnvironment(
      'OPENPANEL_CLIENT_ID',
      defaultValue: '70da32fe-76b3-4547-9d02-431e08abc3f4',
    ),
  });

  final String endpoint;
  final String clientId;
}

/// Fire-and-forget product analytics against OpenPanel.
///
/// Owns its own Dio — never the GitLab client — so an Authorization header
/// can never ride along to the analytics host. Failures are swallowed: a slow
/// or down panel must never surface in the UI. Events carry no PII: no
/// usernames, ids, titles, tokens, or full URLs; screen views send only a
/// [sanitizeRoute]d path.
class Analytics {
  Analytics({required AnalyticsConfig config, Dio? dio})
    : _config = config,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );

  final AnalyticsConfig _config;
  final Dio _dio;

  Future<void> track(String name, [Map<String, Object?>? properties]) async {
    try {
      await _dio.post<dynamic>(
        '${_config.endpoint}/track',
        options: Options(
          headers: {
            'openpanel-client-id': _config.clientId,
            // OpenPanel validates client ingestion against a stable origin.
            // This identifies the app, not the signed-in user.
            'origin': 'app://labfox',
          },
          contentType: Headers.jsonContentType,
        ),
        data: {
          'type': 'track',
          'payload': {'name': name, 'properties': properties ?? const {}},
        },
      );
    } catch (_) {
      // Analytics must never break the app; drop the event.
    }
  }
}

/// Collapses numeric path segments (`/projects/42` → `/projects/:id`) so a
/// screen-view route never carries an identifying or high-cardinality value.
/// Commit route parameters are hidden even when an invalid deep link is visited.
String sanitizeRoute(String path) {
  final segments = path.split('/');
  return [
    for (var i = 0; i < segments.length; i++)
      if (i > 0 &&
          (segments[i - 1] == 'commit' || segments[i - 1] == 'commits'))
        ':sha'
      else if (int.tryParse(segments[i]) != null)
        ':id'
      else
        segments[i],
  ].join('/');
}

final analyticsProvider = Provider<Analytics>((ref) {
  return Analytics(config: const AnalyticsConfig());
});

/// Emits one `screen_view` per screen the user actually reaches.
///
/// Owns the "last path" memory so it outlives the router: `routerProvider` is
/// rebuilt on every auth change, and a tracker rebuilt with it would forget
/// where the user was and count the current screen again.
class RouteTracker {
  RouteTracker(this._analytics);

  final Analytics _analytics;
  String? _lastPath;

  void visit(String path) {
    if (path == _lastPath) {
      return;
    }
    _lastPath = path;
    unawaited(_analytics.track('screen_view', {'route': sanitizeRoute(path)}));
  }
}

/// Watches nothing that changes at runtime, so router rebuilds cannot reset it.
final routeTrackerProvider = Provider<RouteTracker>((ref) {
  return RouteTracker(ref.read(analyticsProvider));
});
