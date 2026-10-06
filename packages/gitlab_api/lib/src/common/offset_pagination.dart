import 'package:dio/dio.dart';

/// Link URLs only provide an offset: the next request keeps the captured route.
/// Reject contradictory metadata rather than silently truncating membership.
int? validatedOffsetNextPage(
  Response<String> response, {
  required int page,
  required int perPage,
  Map<String, String> fixedQuery = const {},
  Map<String, String> routeEchoes = const {},
}) {
  String? single(String key) {
    final values = response.headers[key];
    if (values == null) return null;
    if (values.length != 1) throw const FormatException();
    return values.single;
  }

  int positive(String value) {
    if (value.isEmpty ||
        value.startsWith('0') ||
        RegExp(r'[^0-9]').hasMatch(value)) {
      throw const FormatException();
    }
    final number = int.tryParse(value);
    if (number == null || number < 1) throw const FormatException();
    return number;
  }

  final reportedPage = single('x-page'), reportedSize = single('x-per-page');
  if ((reportedPage != null && positive(reportedPage) != page) ||
      (reportedSize != null && positive(reportedSize) != perPage)) {
    throw const FormatException();
  }
  final rawNext = single('x-next-page');
  final headerNext = rawNext == null || rawNext.isEmpty
      ? null
      : positive(rawNext);
  int? linkNext;
  final links = response.headers['link'];
  if (links != null) {
    for (final value in links) {
      for (final part in value.split(RegExp(r',(?=\s*<)'))) {
        final target = RegExp(r'^\s*<([^<>]+)>(.*)$').firstMatch(part);
        if (target == null) throw const FormatException();
        final suffix = target.group(2)!;
        String? relation;
        var offset = 0;
        for (final attribute in RegExp(
          r';\s*([a-zA-Z][a-zA-Z0-9_-]*)\s*=\s*(?:"([^"]*)"|([!#$%&\x27*+.^_`|~a-zA-Z0-9-]+))',
        ).allMatches(suffix)) {
          if (suffix.substring(offset, attribute.start).trim().isNotEmpty) {
            throw const FormatException();
          }
          offset = attribute.end;
          if (attribute.group(1)!.toLowerCase() == 'anchor') {
            throw const FormatException();
          }
          if (attribute.group(1)!.toLowerCase() == 'rel') {
            if (relation != null) throw const FormatException();
            relation = attribute.group(2) ?? attribute.group(3);
          }
        }
        if (suffix.substring(offset).trim().isNotEmpty || relation == null) {
          throw const FormatException();
        }
        final relations = relation.toLowerCase().trim().split(RegExp(r'\s+'));
        if (relation.trim().isEmpty ||
            relations.any(
              (value) =>
                  !RegExp(r'^[a-z][a-z0-9.-]*$').hasMatch(value) &&
                  Uri.tryParse(value)?.hasScheme != true,
            )) {
          throw const FormatException();
        }
        if (!relations.contains('next')) {
          continue;
        }
        if (linkNext != null) throw const FormatException();
        final request = response.requestOptions.uri;
        final uri = request.resolve(target.group(1)!);
        if (uri.scheme != request.scheme ||
            uri.host != request.host ||
            uri.port != request.port ||
            uri.path != request.path ||
            uri.userInfo.isNotEmpty ||
            uri.fragment.isNotEmpty) {
          throw const FormatException();
        }
        final query = uri.queryParametersAll;
        // GitLab repeats route parameters in offset links. Confirm them;
        // only the page offset is used for the next captured-route request.
        bool matchesRouteEcho(String key, String expected) {
          final values = query[key];
          return values == null ||
              (values.length == 1 && values.single == expected);
        }

        final allowed = {
          'page',
          'per_page',
          ...fixedQuery.keys,
          ...routeEchoes.keys,
        };
        if (query.keys.any((key) => !allowed.contains(key)) ||
            routeEchoes.entries.any((e) => !matchesRouteEcho(e.key, e.value)) ||
            fixedQuery.entries.any(
              (e) =>
                  query[e.key]?.length != 1 || query[e.key]!.single != e.value,
            ) ||
            query['page']?.length != 1 ||
            query['per_page']?.length != 1 ||
            positive(query['per_page']!.single) != perPage) {
          throw const FormatException();
        }
        linkNext = positive(query['page']!.single);
      }
    }
  }
  if (linkNext != null && rawNext != null && linkNext != headerNext) {
    throw const FormatException();
  }
  if (links != null && headerNext != null && linkNext == null) {
    throw const FormatException();
  }
  final next = linkNext ?? headerNext;
  if (next != null && next <= page) throw const FormatException();
  return next;
}
