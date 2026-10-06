import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const head = '0123456789abcdef0123456789abcdef01234567';
const parent = '1123456789abcdef0123456789abcdef01234567';
const second = '2123456789abcdef0123456789abcdef01234567';
Map<String, Object?> file({String path = 'lib/a.dart'}) => {
  'old_path': path,
  'new_path': path,
  'new_file': false,
  'deleted_file': false,
  'renamed_file': false,
  'diff': '@@ -1 +1 @@\n-old  \n+new\n\\ No newline at end of file\n',
  'a_mode': '100644',
  'b_mode': '100755',
};
ResponseBody response(
  Object? body, {
  int status = 200,
  Map<String, List<String>> headers = const {},
  bool raw = false,
}) => ResponseBody.fromString(
  raw ? '$body' : jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
    ...headers,
  },
);
GitLabClient client(
  FutureOr<ResponseBody> Function(RequestOptions) handler, {
  Future<String?> Function()? onUnauthorized,
}) {
  final dio = Dio()..httpClientAdapter = Adapter(handler);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com/subpath',
    token: 'glpat-xxxxxxxxxxxx',
    bearer: onUnauthorized != null,
    onUnauthorized: onUnauthorized,
    dio: dio,
  );
}

class Adapter implements HttpClientAdapter {
  Adapter(this.handler);
  final FutureOr<ResponseBody> Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async => handler(o);
  @override
  void close({bool force = false}) {}
}

String link(int next, {String project = '8', int perPage = 20}) =>
    '<https://gitlab.example.com/subpath/api/v4/projects/$project/repository/commits/$head/diff?unidiff=true&page=$next&per_page=$perPage>; rel="next"';
Future<Object?> read(
  GitLabClient c, {
  Object project = 8,
  String commitId = head,
  int page = 1,
  int perPage = 20,
}) => c.repository.commitDiffPage(
  project,
  commitId: commitId,
  page: page,
  perPage: perPage,
);
void main() {
  for (final project in [8, 'group/project +']) {
    test(
      'original diff GET retains encoded project, immutable commit, unidiff and offset $project',
      () async {
        late RequestOptions captured;
        final c = client((o) {
          captured = o;
          return response(
            [file()],
            headers: {
              'x-page': ['2'],
              'x-per-page': ['10'],
              'x-next-page': ['4'],
            },
          );
        });
        addTearDown(c.close);
        final p = await c.repository.commitDiffPage(
          project,
          commitId: head,
          page: 2,
          perPage: 10,
        );
        expect(
          captured.path,
          '/projects/${Uri.encodeComponent('$project')}/repository/commits/$head/diff',
        );
        expect(captured.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
        expect(captured.queryParameters, {
          'unidiff': true,
          'page': 2,
          'per_page': 10,
        });
        expect(captured.method, 'GET');
        expect(captured.data, isNull);
        expect(captured.followRedirects, false);
        expect(captured.responseType, ResponseType.plain);
        expect(p.nextPage, 4);
        expect(p.total, isNull);
        expect(p.totalPages, isNull);
        expect(p.items.single.diff, file()['diff']);
        expect(() => p.items.clear(), throwsUnsupportedError);
      },
    );
  }
  for (final project in [0, -1, '', '  ', 8.5]) {
    test('invalid project prevents original diff dispatch $project', () async {
      var calls = 0;
      final c = client((o) {
        calls++;
        return response([]);
      });
      addTearDown(c.close);
      await expectLater(read(c, project: project), throwsArgumentError);
      expect(calls, 0);
    });
  }
  for (final id in [
    '',
    head.substring(0, 8),
    head.toUpperCase(),
    'main',
    'branch/name',
    '$head\n',
    'g${head.substring(1)}',
  ]) {
    test(
      'nonliteral commit identity prevents original diff dispatch $id',
      () async {
        var calls = 0;
        final c = client((o) {
          calls++;
          return response([]);
        });
        addTearDown(c.close);
        await expectLater(read(c, commitId: id), throwsArgumentError);
        expect(calls, 0);
      },
    );
  }
  for (final offset in [(0, 20), (-1, 20), (1, 0), (1, 101)]) {
    test('invalid original diff offset prevents dispatch $offset', () async {
      var calls = 0;
      final c = client((o) {
        calls++;
        return response([]);
      });
      addTearDown(c.close);
      await expectLater(
        read(c, page: offset.$1, perPage: offset.$2),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final metadata in [
    <String, Object?>{},
    {'diff': null},
    {'diff': ''},
    {'collapsed': true},
    {'too_large': true},
    {'generated_file': true},
  ]) {
    test(
      'literal nullable diff and omission metadata remain reported rather than guessed $metadata',
      () async {
        final value = file()..remove('diff');
        value.addAll(metadata);
        final c = client((o) => response([value]));
        addTearDown(c.close);
        final p = await c.repository.commitDiffPage(8, commitId: head);
        expect(p.items.single.diff, metadata['diff']);
        expect(p.items.single.isCollapsed, metadata['collapsed']);
        expect(p.items.single.isTooLarge, metadata['too_large']);
        expect(p.items.single.isGenerated, metadata['generated_file']);
      },
    );
  }
  test(
    'literal rename paths and raw diff survive without normalization',
    () async {
      final value = {
        ...file(),
        'old_path': ' old/path ',
        'new_path': ' new/path ',
        'renamed_file': true,
      };
      final c = client((o) => response([value]));
      addTearDown(c.close);
      final p = await c.repository.commitDiffPage(8, commitId: head);
      expect(p.items.single.oldPath, value['old_path']);
      expect(p.items.single.newPath, value['new_path']);
      expect(p.items.single.isRenamed, true);
      expect(p.items.single.diff, value['diff']);
    },
  );
  final badBodies = <Object?>[
    null,
    {},
    'private-marker',
    [null],
    [1],
    [file(), file()],
    for (final key in [
      'old_path',
      'new_path',
      'new_file',
      'deleted_file',
      'renamed_file',
    ])
      [file()..remove(key)],
    for (final key in ['old_path', 'new_path'])
      [
        {...file(), key: ''},
      ],
    for (final key in ['old_path', 'new_path'])
      [
        {...file(), key: 'path\u0000private-marker'},
      ],
    for (final key in ['diff', 'a_mode', 'b_mode'])
      [
        {...file(), key: 7},
      ],
    for (final key in [
      'new_file',
      'deleted_file',
      'renamed_file',
      'collapsed',
      'too_large',
      'generated_file',
    ])
      [
        {...file(), key: 'private-marker'},
      ],
  ];
  for (var i = 0; i < badBodies.length; i++) {
    test('malformed original diff payload $i is typed and sanitized', () async {
      final c = client((o) => response(badBodies[i]));
      addTearDown(c.close);
      await expectLater(
        read(c),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.toString(),
            'sanitized',
            isNot(contains('private-marker')),
          ),
        ),
      );
    });
  }
  test('malformed HTTP 200 JSON is sanitized', () async {
    final c = client((o) => response('{private-marker', raw: true));
    addTearDown(c.close);
    await expectLater(
      read(c),
      throwsA(
        isA<GitLabServerException>().having(
          (e) => e.toString(),
          'sanitized',
          isNot(contains('private-marker')),
        ),
      ),
    );
  });
  for (final status in [201, 204, 302, 401, 403, 404, 429, 500]) {
    test(
      'original diff failure $status maps before malformed JSON decoding',
      () async {
        var calls = 0;
        final c = client((o) {
          calls++;
          return response('{private-marker', raw: true, status: status);
        });
        addTearDown(c.close);
        final kind = switch (status) {
          401 => isA<GitLabAuthException>(),
          403 => isA<GitLabForbiddenException>(),
          404 => isA<GitLabNotFoundException>(),
          429 => isA<GitLabRateLimitException>(),
          _ => isA<GitLabServerException>(),
        };
        await expectLater(
          read(c),
          throwsA(
            allOf(
              kind,
              isA<GitLabException>()
                  .having((e) => e.statusCode, 'status', status)
                  .having(
                    (e) => e.toString(),
                    'sanitized',
                    isNot(contains('private-marker')),
                  ),
            ),
          ),
        );
        expect(calls, 1);
      },
    );
  }
  test('read-only OAuth refresh replays only the same captured GET', () async {
    final requests = <RequestOptions>[];
    var refreshes = 0;
    final c = client(
      (o) {
        requests.add(o);
        return response(
          requests.length == 1 ? {} : [file()],
          status: requests.length == 1 ? 401 : 200,
        );
      },
      onUnauthorized: () async {
        refreshes++;
        return 'dummy-refreshed-token';
      },
    );
    addTearDown(c.close);
    await read(c);
    expect(refreshes, 1);
    expect(requests.length, 2);
    expect(
      requests.every(
        (o) =>
            o.method == 'GET' &&
            o.path == '/projects/8/repository/commits/$head/diff' &&
            o.followRedirects == false,
      ),
      true,
    );
  });
  test('connection failures remain typed and sanitized', () async {
    final c = client(
      (o) => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
        message: 'private-marker',
      ),
    );
    addTearDown(c.close);
    await expectLater(
      read(c),
      throwsA(
        isA<GitLabConnectionException>().having(
          (e) => e.toString(),
          'sanitized',
          isNot(contains('private-marker')),
        ),
      ),
    );
  });
  final validHeaders = [
    <String, List<String>>{},
    {
      'x-next-page': [''],
    },
    {
      'x-next-page': ['3'],
    },
    {
      'link': [link(3)],
    },
    {
      'link': [
        '${link(3)}, <https://gitlab.example.com/subpath/api/v4/projects/8/repository/commits/$head/diff?unidiff=true&page=1&per_page=20>; rel="prev"',
      ],
    },
    {
      'x-next-page': ['3'],
      'link': [link(3)],
    },
  ];
  for (var i = 0; i < validHeaders.length; i++) {
    test(
      'authoritative offset pagination $i needs no total or page-size inference',
      () async {
        final c = client((o) => response([], headers: validHeaders[i]));
        addTearDown(c.close);
        final p = await c.repository.commitDiffPage(8, commitId: head, page: 2);
        expect(p.nextPage, i < 2 ? null : 3);
        expect(p.totalPages, isNull);
      },
    );
  }
  for (final value in [
    link(3).replaceFirst('rel="next"', 'REL="NEXT"'),
    '<?unidiff=true&page=3&per_page=20>; rel=next',
    '</subpath/api/v4/projects/8/repository/commits/$head/diff?unidiff=true&page=3&per_page=20>; rel="next"',
  ]) {
    test(
      'registered next relations and relative targets retain the captured context $value',
      () async {
        final c = client(
          (o) => response(
            [],
            headers: {
              'link': [value],
            },
          ),
        );
        addTearDown(c.close);
        expect(
          (await c.repository.commitDiffPage(
            8,
            commitId: head,
            page: 2,
          )).nextPage,
          3,
        );
      },
    );
  }
  test(
    'a Link anchor override cannot change original diff pagination context',
    () async {
      final c = client(
        (o) => response(
          [],
          headers: {
            'link': ['${link(3)}; anchor="/another/context"'],
          },
        ),
      );
      addTearDown(c.close);
      await expectLater(
        read(c, page: 2),
        throwsA(isA<GitLabServerException>()),
      );
    },
  );
  test(
    'encoded project Link continuation matches the captured encoded resource',
    () async {
      final c = client(
        (o) => response(
          [],
          headers: {
            'link': [link(3, project: 'group%2Fproject%20%2B')],
          },
        ),
      );
      addTearDown(c.close);
      expect(
        (await c.repository.commitDiffPage(
          'group/project +',
          commitId: head,
          page: 2,
        )).nextPage,
        3,
      );
    },
  );
  for (final relation in [
    'rel=next,garbage',
    'rel=next"',
    'rel=""',
    'rel="next,"',
  ]) {
    test(
      'malformed relation token cannot silently end original diff traversal $relation',
      () async {
        final c = client(
          (o) => response(
            [],
            headers: {
              'link': [link(3).replaceFirst('rel="next"', relation)],
            },
          ),
        );
        addTearDown(c.close);
        await expectLater(
          read(c, page: 2),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  for (final project in [8, 'group/project +']) {
    test(
      'GitLab route identity echoes retain the captured next target $project',
      () async {
        final value = link(3, project: Uri.encodeComponent('$project'))
            .replaceFirst(
              'page=3',
              'id=${Uri.encodeQueryComponent('$project')}&sha=$head&page=3',
            );
        final c = client(
          (o) => response(
            [],
            headers: {
              'link': [value],
            },
          ),
        );
        addTearDown(c.close);
        expect(
          (await c.repository.commitDiffPage(
            project,
            commitId: head,
            page: 2,
          )).nextPage,
          3,
        );
      },
    );
  }
  for (final echo in [
    'id=9',
    'sha=other',
    'id=8&id=8',
    'sha=$head&sha=$head',
  ]) {
    test(
      'wrong or duplicate route identity echoes cannot alter the captured next route $echo',
      () async {
        final c = client(
          (o) => response(
            [],
            headers: {
              'link': [link(3).replaceFirst('page=3', '$echo&page=3')],
            },
          ),
        );
        addTearDown(c.close);
        await expectLater(
          read(c, page: 2),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  for (final query in [
    'unidiff=false',
    'unidiff=true&unidiff=true',
    'other=true',
  ]) {
    test(
      'next diff target cannot change or omit captured unified format $query',
      () async {
        final c = client(
          (o) => response(
            [],
            headers: {
              'link': [link(3).replaceFirst('unidiff=true', query)],
            },
          ),
        );
        addTearDown(c.close);
        await expectLater(
          read(c, page: 2),
          throwsA(isA<GitLabServerException>()),
        );
      },
    );
  }
  final badHeaders = [
    {
      'x-next-page': ['2'],
    },
    {
      'x-next-page': ['1'],
    },
    {
      'x-next-page': ['0'],
    },
    {
      'x-next-page': ['3.5'],
    },
    {
      'x-next-page': ['+3'],
    },
    {
      'x-next-page': [' 3'],
    },
    {
      'x-next-page': ['3', '4'],
    },
    {
      'x-page': ['1'],
    },
    {
      'x-page': ['2', '2'],
    },
    {
      'x-per-page': ['10'],
    },
    {
      'link': [link(2)],
    },
    {
      'link': [link(3).replaceFirst('gitlab.example.com', 'other.example.com')],
    },
    {
      'link': [link(3).replaceFirst('https:', 'http:')],
    },
    {
      'link': [link(3).replaceFirst('/commits/$head/', '/commits/$parent/')],
    },
    {
      'link': [link(3).replaceFirst('projects/8/', 'projects/9/')],
    },
    {
      'link': [link(3).replaceFirst('page=3', 'page=3&page=4')],
    },
    {
      'link': [link(3, perPage: 10)],
    },
    {
      'link': [
        link(3).replaceFirst('&per_page=20', '&per_page=20&ref_name=other'),
      ],
    },
    {
      'link': [link(3).replaceFirst('>; rel', '#fragment>; rel')],
    },
    {
      'link': [
        link(3).replaceFirst('gitlab.example.com', 'user@gitlab.example.com'),
      ],
    },
    {
      'link': ['${link(3)}, ${link(4)}'],
    },
    {
      'link': ['broken-private-marker'],
    },
    {
      'x-next-page': ['4'],
      'link': [link(3)],
    },
    {
      'x-next-page': [''],
      'link': [link(3)],
    },
  ];
  for (var i = 0; i < badHeaders.length; i++) {
    test('ambiguous, stale or foreign commit cursor $i fails closed', () async {
      var calls = 0;
      final c = client((o) {
        calls++;
        return response([file()], headers: badHeaders[i]);
      });
      addTearDown(c.close);
      await expectLater(
        read(c, page: 2),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.toString(),
            'sanitized',
            isNot(contains('private-marker')),
          ),
        ),
      );
      expect(calls, 1);
    });
  }
}
