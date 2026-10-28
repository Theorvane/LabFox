import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const rule = {
  'id': 'gid://gitlab/ContainerRegistry::Protection::TagRule/9',
  'tagNamePattern': r'^v\d+.*$',
  'immutable': true,
};
Map<String, dynamic> connection({
  List<Object?> nodes = const [rule],
  bool more = false,
  Object? cursor,
}) => {
  'nodes': nodes,
  'pageInfo': {'hasNextPage': more, 'endCursor': cursor},
};
Map<String, dynamic> response(Object? rules) => {
  'data': {
    'project': {'fullPath': 'team/app', 'rules': rules},
  },
};
GitLabClient client(Object? Function(RequestOptions) handler) {
  final dio = Dio()..httpClientAdapter = Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com/subpath',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

void main() {
  for (final cursor in [null, 'opaque+/==']) {
    test('reads complete connection with opaque cursor $cursor', () async {
      final c = client((r) {
        expect(
          r.uri.toString(),
          'https://gitlab.example.com/subpath/api/graphql',
        );
        expect(r.method, 'POST');
        expect(r.data['operationName'], 'ContainerImmutabilityRules');
        expect(r.data['variables'], {'fullPath': 'team/app', 'after': cursor});
        expect(
          r.data['query'],
          contains('containerProtectionTagRules(first: 100, after: \$after)'),
        );
        expect(r.data['query'], contains('immutable'));
        return response(connection(more: true, cursor: 'next+/=='));
      });
      addTearDown(c.close);
      final page = await c.containerImmutability.listRules(
        'team/app',
        after: cursor,
      );
      expect(page.nodes.single.id, rule['id']);
      expect(page.nodes.single.tagNamePattern, rule['tagNamePattern']);
      expect(page.nodes.single.immutable, isTrue);
      expect(page.pageInfo.hasNextPage, isTrue);
      expect(page.pageInfo.endCursor, 'next+/==');
    });
  }
  test(
    'non-immutable nodes remain available for complete page scanning',
    () async {
      final c = client(
        (_) => response(
          connection(
            nodes: [
              {...rule, 'immutable': false},
            ],
          ),
        ),
      );
      addTearDown(c.close);
      expect(
        (await c.containerImmutability.listRules(
          'team/app',
        )).nodes.single.immutable,
        isFalse,
      );
    },
  );
  test('empty authorized connection is not unavailable', () async {
    final c = client((_) => response(connection(nodes: [])));
    addTearDown(c.close);
    expect(
      (await c.containerImmutability.listRules('team/app')).nodes,
      isEmpty,
    );
  });
  for (final body in [
    {
      'data': {'project': null},
    },
    response(null),
  ]) {
    test('null resource is unavailable rather than empty $body', () async {
      final c = client((_) => body);
      addTearDown(c.close);
      await expectLater(
        c.containerImmutability.listRules('team/app'),
        throwsA(isA<GitLabNotFoundException>()),
      );
    });
  }
  for (final bad in [
    [],
    {},
    {'nodes': []},
    connection(nodes: [null]),
    connection(
      nodes: [
        rule,
        {'id': 'bad', 'tagNamePattern': 'x'},
      ],
    ),
    connection(
      nodes: [
        {...rule, 'immutable': 'true'},
      ],
    ),
    connection(
      nodes: [
        {...rule, 'id': ''},
      ],
    ),
    connection(
      nodes: [
        {...rule, 'tagNamePattern': ' '},
      ],
    ),
    connection(more: true),
    connection(more: true, cursor: ''),
    {
      'nodes': [],
      'pageInfo': {'hasNextPage': 'true', 'endCursor': 'next'},
    },
  ]) {
    test('malformed connection cannot become a partial result $bad', () async {
      final c = client((_) => response(bad));
      addTearDown(c.close);
      await expectLater(
        c.containerImmutability.listRules('team/app'),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  test('wrong project identity is rejected', () async {
    final c = client(
      (_) => {
        'data': {
          'project': {'fullPath': 'other/project', 'rules': connection()},
        },
      },
    );
    addTearDown(c.close);
    await expectLater(
      c.containerImmutability.listRules('team/app'),
      throwsA(isA<GitLabServerException>()),
    );
  });
  test('partial GraphQL failure remains sanitized', () async {
    final c = client(
      (_) => {
        ...response(connection()),
        'errors': [
          {'message': 'private details'},
        ],
      },
    );
    addTearDown(c.close);
    await expectLater(
      c.containerImmutability.listRules('team/app'),
      throwsA(
        isA<GitLabServerException>().having(
          (e) => e.message.contains('private'),
          'private text',
          isFalse,
        ),
      ),
    );
  });
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final Object? Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(handler(options)),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
  @override
  void close({bool force = false}) {}
}
