import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labfox/app/router.dart';
import 'package:labfox/core/analytics/analytics.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status);

  final int status;
  final List<RequestOptions> captured = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured.add(options);
    return ResponseBody.fromString('{}', status);
  }

  @override
  void close({bool force = false}) {}
}

Analytics _analytics(_Adapter adapter) {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.httpClientAdapter = adapter;
  return Analytics(
    config: const AnalyticsConfig(
      endpoint: 'https://panel.example.test/api',
      clientId: 'client-123',
    ),
    dio: dio,
  );
}

void main() {
  test('track posts the event with the client id header', () async {
    final adapter = _Adapter(200);
    final analytics = _analytics(adapter);

    await analytics.track('screen_view', {'route': '/inbox'});

    final request = adapter.captured.single;
    expect(request.path, 'https://panel.example.test/api/track');
    expect(request.headers['openpanel-client-id'], 'client-123');
    expect(request.headers['origin'], 'app://labfox');
    expect(request.headers, isNot(contains('openpanel-client-secret')));
    final body = jsonDecode(jsonEncode(request.data)) as Map<String, dynamic>;
    expect(body['type'], 'track');
    expect(body['payload']['name'], 'screen_view');
    expect(body['payload']['properties']['route'], '/inbox');
  });

  test('a failing endpoint never throws into the app', () async {
    final adapter = _Adapter(500);
    final analytics = _analytics(adapter);

    await expectLater(analytics.track('app_open'), completes);
  });

  test('matched route templates keep numeric and static paths anonymous', () {
    expect(
      sanitizeRoute(
        '/projects/42/merge_requests/7',
        routeTemplate: '/projects/:id/merge_requests/:iid',
      ),
      '/projects/:id/merge_requests/:iid',
    );
    expect(
      sanitizeRoute('/dashboard/issues', routeTemplate: '/dashboard/issues'),
      '/dashboard/issues',
    );
    expect(sanitizeRoute('/', routeTemplate: '/'), '/');
  });

  test('private values in unmatched routes are never reported', () {
    for (final path in [
      '/projects/42/releases/customer-secret',
      '/projects/42/container_registry/7/tags/customer-secret',
      '/projects/42/protected_branches/customer-secret',
      '/projects/42/protected_tags/customer-secret',
      '/projects/42/protected_environments/customer-secret',
      '/groups/42/protected_environments/customer-secret',
    ]) {
      expect(sanitizeRoute(path), '/:unknown', reason: path);
    }
  });

  test('matched detail routes hide private path values', () {
    final cases = <(String, String)>[
      (
        Routes.release(42, 'customer-secret'),
        '/projects/:id/releases/:tagName',
      ),
      (
        Routes.containerTag(42, 7, 'customer-secret'),
        '/projects/:id/container_registry/:repositoryId/tags/:tagName',
      ),
      (
        Routes.protectedBranch(42, 'customer-secret'),
        '/projects/:id/protected_branches/:name',
      ),
      (
        Routes.protectedTag(42, 'customer-secret'),
        '/projects/:id/protected_tags/:name',
      ),
      (
        Routes.protectedEnvironment(42, 'customer-secret'),
        '/projects/:id/protected_environments/:name',
      ),
      (
        Routes.groupProtectedEnvironment(42, 'customer-secret'),
        '/groups/:id/protected_environments/:name',
      ),
      (
        Routes.protectedBranch(42, 'release/secret'),
        '/projects/:id/protected_branches/:name',
      ),
      (Routes.release(42, 'releases'), '/projects/:id/releases/:tagName'),
      (Routes.wikiPage(42, 'customer-secret'), '/projects/:id/wikis/page'),
    ];

    for (final (location, routeTemplate) in cases) {
      final route = sanitizeRoute(location, routeTemplate: routeTemplate);
      expect(route, routeTemplate, reason: location);
      expect(route, isNot(contains('customer-secret')));
      expect(route, isNot(contains('release/secret')));
    }
  });

  test('mismatched or invalid templates fail closed', () {
    const location = '/projects/42/releases/customer-secret';
    expect(
      sanitizeRoute(location, routeTemplate: '/projects/:id/releases'),
      '/:unknown',
    );
    expect(
      sanitizeRoute(
        location,
        routeTemplate: '/projects/:id/protected_branches/:name',
      ),
      '/:unknown',
    );
    expect(sanitizeRoute(location, routeTemplate: ''), '/:unknown');
    expect(
      sanitizeRoute(location, routeTemplate: '/projects/42/releases/:tagName'),
      '/:unknown',
    );
  });
}
