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

/// Reports only the matched route template, never values from the location.
/// An absent or mismatched template fails closed, including invalid deep links.
String sanitizeRoute(String location, {String? routeTemplate}) {
  const unknownRoute = '/:unknown';
  if (routeTemplate == null || !routeTemplate.startsWith('/')) {
    return unknownRoute;
  }

  final uri = Uri.tryParse(location);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !location.startsWith('/')) {
    return unknownRoute;
  }
  if (routeTemplate == '/') {
    return uri.path == '/' ? '/' : unknownRoute;
  }

  final templateSegments = routeTemplate.substring(1).split('/');
  final actualSegments = uri.pathSegments;
  if (templateSegments.length != actualSegments.length) {
    return unknownRoute;
  }
  final parameter = RegExp(r'^:[A-Za-z][A-Za-z0-9_]*$');
  final literal = RegExp(r'^[a-z][a-z0-9_-]*$');
  for (var i = 0; i < templateSegments.length; i++) {
    final segment = templateSegments[i];
    if (parameter.hasMatch(segment)) {
      continue;
    }
    if (!literal.hasMatch(segment) || segment != actualSegments[i]) {
      return unknownRoute;
    }
  }
  return routeTemplate;
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

  void visit(String location, {String? routeTemplate}) {
    if (location == _lastPath) {
      return;
    }
    _lastPath = location;
    unawaited(
      _analytics.track('screen_view', {
        'route': sanitizeRoute(location, routeTemplate: routeTemplate),
      }),
    );
  }
}

/// Watches nothing that changes at runtime, so router rebuilds cannot reset it.
final routeTrackerProvider = Provider<RouteTracker>((ref) {
  return RouteTracker(ref.read(analyticsProvider));
});
