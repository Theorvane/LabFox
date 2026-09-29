import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';

Map<String, dynamic> node(String id, bool immutable) => {
  'id': 'gid://gitlab/Rule/$id',
  'tagNamePattern': id,
  'immutable': immutable,
};
void main() {
  test(
    'resolves ID once and scans non-immutable pages before collecting rules',
    () async {
      final cursors = <Object?>[];
      final repository = create((r) {
        if (r.method == 'GET') {
          return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
        }
        expect(r.data['variables']['fullPath'], 'team/app');
        final after = r.data['variables']['after'];
        cursors.add(after);
        return page(
          after == null ? [node('a', false)] : [node('b', true)],
          more: after == null,
          cursor: after == null ? 'opaque' : null,
        );
      });
      final rules = await repository.immutableTagRules(7);
      expect(rules.map((r) => r.tagNamePattern), ['b']);
      expect(cursors, [null, 'opaque']);
    },
  );
  for (final repeated in [false, true]) {
    test(
      'cursor cycle is rejected without a partial list repeated=$repeated',
      () async {
        var reads = 0;
        final repository = create((r) {
          if (r.method == 'GET') {
            return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
          }
          reads++;
          return page(
            [node(reads.toString(), true)],
            more: true,
            cursor: repeated || reads.isOdd ? 'a' : 'b',
          );
        });
        await expectLater(
          repository.immutableTagRules(7),
          throwsA(isA<GitLabServerException>()),
        );
        expect(reads, repeated ? 2 : 3);
      },
    );
  }
  test(
    'later partial failure does not expose earlier immutable rules',
    () async {
      var reads = 0;
      final repository = create((r) {
        if (r.method == 'GET') {
          return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
        }
        reads++;
        if (reads == 1) {
          return page([node('a', true)], more: true, cursor: 'next');
        }
        return {
          'errors': [
            {'message': 'private details'},
          ],
        };
      });
      await expectLater(
        repository.immutableTagRules(7),
        throwsA(isA<GitLabServerException>()),
      );
    },
  );
  test('duplicate global IDs cannot hide ambiguous rules', () async {
    final repository = create(
      (r) => r.method == 'GET'
          ? {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'}
          : page([node('a', true), node('a', true)]),
    );
    await expectLater(
      repository.immutableTagRules(7),
      throwsA(isA<GitLabServerException>()),
    );
  });
  test('wrong REST project cannot redirect the GraphQL read', () async {
    var reads = 0;
    final repository = create((r) {
      reads++;
      return {'id': 8, 'name': 'App', 'path_with_namespace': 'other/app'};
    });
    await expectLater(
      repository.immutableTagRules(7),
      throwsA(isA<GitLabServerException>()),
    );
    expect(reads, 1);
  });
}

Object page(List<Object> nodes, {bool more = false, String? cursor}) => {
  'data': {
    'project': {
      'fullPath': 'team/app',
      'rules': {
        'nodes': nodes,
        'pageInfo': {'hasNextPage': more, 'endCursor': cursor},
      },
    },
  },
};
ContainerRegistryRepository create(Object? Function(RequestOptions) handler) {
  final dio = Dio()..httpClientAdapter = Adapter(handler);
  return ContainerRegistryRepository(
    GitLabClient(
      baseUrl: 'https://gitlab.example.com',
      token: 'glpat-xxxxxxxxxxxx',
      dio: dio,
    ),
  );
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final Object? Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions r,
    Stream<Uint8List>? stream,
    Future<dynamic>? cancel,
  ) async => ResponseBody.fromString(
    jsonEncode(handler(r)),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
  @override
  void close({bool force = false}) {}
}
