import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
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

  test('numeric path segments collapse so routes stay anonymous', () {
    expect(
      sanitizeRoute('/projects/42/merge_requests/7'),
      '/projects/:id/merge_requests/:id',
    );
    expect(sanitizeRoute('/dashboard/issues'), '/dashboard/issues');
    expect(sanitizeRoute('/'), '/');
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
}
