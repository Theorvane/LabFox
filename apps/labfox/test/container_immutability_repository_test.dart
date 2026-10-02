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
  test('a changed session during preflight cannot send the mutation', () async {
    var current = true;
    final repository = create((r) {
      if (r.method == 'GET') {
        current = false;
        return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
      }
      if (r.data['operationName'] != 'ContainerImmutabilityRules') {
        fail('A stale session cannot write');
      }
      return page([]);
    });
    await expectLater(
      repository.createImmutableTagRule(7, '^v.*', isCurrent: () => current),
      throwsStateError,
    );
  });
  test(
    'creation resolves project identity and preserves exact regex in one mutation',
    () async {
      var writes = 0;
      final repository = create((r) {
        if (r.method == 'GET') {
          return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
        }
        if (r.data['operationName'] == 'ContainerImmutabilityRules') {
          return page([]);
        }
        writes++;
        expect(r.data['variables']['input']['projectPath'], 'team/app');
        expect(r.data['variables']['input']['tagNamePattern'], r' ^v\d+$ ');
        return {
          'data': {
            'createContainerProtectionTagRule': {
              'errors': [],
              'containerProtectionTagRule': {
                'id': 'opaque',
                'tagNamePattern': r' ^v\d+$ ',
                'immutable': true,
              },
            },
          },
        };
      });
      final result = await repository.createImmutableTagRule(7, r' ^v\d+$ ');
      expect(result.tagNamePattern, r' ^v\d+$ ');
      expect(writes, 1);
    },
  );
  test('duplicate immutable pattern preflight never writes', () async {
    final repository = create((r) {
      if (r.method == 'GET') {
        return {'id': 7, 'name': 'App', 'path_with_namespace': 'team/app'};
      }
      expect(r.data['operationName'], 'ContainerImmutabilityRules');
      return page([node('existing', true)]);
    });
    await expectLater(
      repository.createImmutableTagRule(7, 'existing'),
      throwsA(isA<GitLabConflictException>()),
    );
  });
  test('project mismatch after preflight never writes', () async {
    var gets = 0;
    final repository = create((r) {
      if (r.method == 'GET') {
        return {
          'id': ++gets == 1 ? 7 : 8,
          'name': 'App',
          'path_with_namespace': 'team/app',
        };
      }
      expect(r.data['operationName'], 'ContainerImmutabilityRules');
      return page([]);
    });
    await expectLater(
      repository.createImmutableTagRule(7, '^v.*'),
      throwsA(isA<GitLabServerException>()),
    );
    expect(gets, 2);
  });
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
