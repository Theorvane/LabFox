import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';

const head = '0123456789abcdef0123456789abcdef01234567';
const parent = '1123456789abcdef0123456789abcdef01234567';
const second = '2123456789abcdef0123456789abcdef01234567';
Map<String, Object?> commit({String id = head}) => {
  'id': id,
  'title': '  Exact commit title  ',
  'message': 'Exact message\n\nBody.',
  'parent_ids': [if (id != parent) parent, if (id != second) second],
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
    '<https://gitlab.example.com/subpath/api/v4/projects/$project/merge_requests/142/commits?page=$next&per_page=$perPage>; rel="next"';
Future<Object?> read(
  GitLabClient c, {
  Object project = 8,
  int iid = 142,
  int page = 1,
  int perPage = 20,
}) => c.mergeRequests.commits(project, iid: iid, page: page, perPage: perPage);

void main() {
  for (final project in [8, 'group/project +']) {
    test(
      'MR commit page uses exact route IID, encoded project and offset $project',
      () async {
        final requests = <RequestOptions>[];
        final c = client((o) {
          requests.add(o);
          return response(
            [commit()],
            headers: {
              'x-next-page': ['4'],
              'x-page': ['3'],
              'x-per-page': ['10'],
              'x-total': ['50'],
              'x-total-pages': ['5'],
            },
          );
        });
        addTearDown(c.close);
        final p = await c.mergeRequests.commits(
          project,
          iid: 142,
          page: 3,
          perPage: 10,
        );
        final o = requests.single;
        expect(
          o.path,
          '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/merge_requests/142/commits',
        );
        expect(o.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
        expect(o.queryParameters, {'page': 3, 'per_page': 10});
        expect(o.method, 'GET');
        expect(o.data, isNull);
        expect(o.followRedirects, false);
        expect(o.responseType, ResponseType.plain);
        expect(p.nextPage, 4);
        expect(p.total, 50);
        expect(p.totalPages, 5);
        expect(p.items.single.id, head);
        expect(p.items.single.parentIds, [parent, second]);
        expect(p.items.single.title, '  Exact commit title  ');
        expect(() => p.items.clear(), throwsUnsupportedError);
      },
    );
  }
  for (final invalid in [0, -1, '', '  ', 8.5]) {
    test('invalid project prevents MR commit GET $invalid', () async {
      var calls = 0;
      final c = client((o) {
        calls++;
        return response([]);
      });
      addTearDown(c.close);
      await expectLater(read(c, project: invalid), throwsArgumentError);
      expect(calls, 0);
    });
  }
  for (final args in [
    (0, 1, 20),
    (-1, 1, 20),
    (142, 0, 20),
    (142, -1, 20),
    (142, 1, 0),
    (142, 1, 101),
  ]) {
    test('invalid route or offset prevents dispatch $args', () async {
      var calls = 0;
      final c = client((o) {
        calls++;
        return response([]);
      });
      addTearDown(c.close);
      await expectLater(
        read(c, iid: args.$1, page: args.$2, perPage: args.$3),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final extra in [
    <String, Object?>{},
    {'parent_ids': null},
    {'parent_ids': []},
    {
      'parent_ids': [parent],
    },
  ]) {
    test(
      'parent absence, root and single parent are retained $extra',
      () async {
        final value = {'id': head, 'title': '', ...extra};
        final c = client((o) => response([value]));
        addTearDown(c.close);
        final p = await c.mergeRequests.commits(8, iid: 142);
        expect(p.items.single.parentIds, extra['parent_ids']);
        expect(p.nextPage, isNull);
        expect(p.total, isNull);
      },
    );
  }
  final badBodies = <Object?>[
    null,
    {},
    'private-marker',
    [null],
    [1],
    [
      {...commit(), 'id': ''},
    ],
    [
      {...commit(), 'id': head.substring(0, 8)},
    ],
    [
      {...commit(), 'id': head.toUpperCase()},
    ],
    [
      {...commit(), 'id': 'g${head.substring(1)}'},
    ],
    [
      {...commit(), 'id': 7},
    ],
    [commit(), commit()],
    [
      {...commit(), 'title': null},
    ],
    [
      {...commit(), 'message': 7},
    ],
    [
      {...commit(), 'authored_date': 'not-a-date'},
    ],
    [
      {...commit(), 'parent_ids': 'private-marker'},
    ],
    [
      {
        ...commit(),
        'parent_ids': [null],
      },
    ],
    [
      {
        ...commit(),
        'parent_ids': [7],
      },
    ],
    [
      {
        ...commit(),
        'parent_ids': [parent.substring(0, 8)],
      },
    ],
    [
      {
        ...commit(),
        'parent_ids': [parent, parent],
      },
    ],
    [
      {
        ...commit(),
        'parent_ids': [head],
      },
    ],
  ];
  for (var i = 0; i < badBodies.length; i++) {
    test(
      'malformed commit or parent identity $i is typed and sanitized',
      () async {
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
      },
    );
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
      'MR commit failure $status maps before malformed JSON decoding',
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
          requests.length == 1 ? {} : [commit()],
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
            o.path == '/projects/8/merge_requests/142/commits' &&
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
        '${link(3)}, <https://gitlab.example.com/subpath/api/v4/projects/8/merge_requests/142/commits?page=1&per_page=20>; rel="prev"',
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
        final p = await c.mergeRequests.commits(8, iid: 142, page: 2);
        expect(p.nextPage, i < 2 ? null : 3);
        expect(p.totalPages, isNull);
      },
    );
  }
  for (final value in [
    link(3).replaceFirst('rel="next"', 'REL="NEXT"'),
    '<?page=3&per_page=20>; rel=next',
    '</subpath/api/v4/projects/8/merge_requests/142/commits?page=3&per_page=20>; rel="next"',
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
          (await c.mergeRequests.commits(8, iid: 142, page: 2)).nextPage,
          3,
        );
      },
    );
  }
  test('a Link anchor override cannot change MR pagination context', () async {
    final c = client(
      (o) => response(
        [],
        headers: {
          'link': ['${link(3)}; anchor="/another/context"'],
        },
      ),
    );
    addTearDown(c.close);
    await expectLater(read(c, page: 2), throwsA(isA<GitLabServerException>()));
  });
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
        (await c.mergeRequests.commits(
          'group/project +',
          iid: 142,
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
      'malformed relation token cannot silently end MR commit traversal $relation',
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
              'id=${Uri.encodeQueryComponent('$project')}&merge_request_iid=142&page=3',
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
          (await c.mergeRequests.commits(project, iid: 142, page: 2)).nextPage,
          3,
        );
      },
    );
  }
  for (final echo in [
    'id=9',
    'merge_request_iid=1100',
    'id=8&id=8',
    'merge_request_iid=142&merge_request_iid=142',
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
      'link': [
        link(3).replaceFirst('/merge_requests/142/', '/merge_requests/1100/'),
      ],
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
        return response([commit()], headers: badHeaders[i]);
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
