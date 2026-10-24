import 'package:dio/dio.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:test/test.dart';
import 'mr_draft_note_maintenance_api_test.dart' show makeClient;

void main() {
  for (final project in [8, 'group/project +']) {
    test('single publication sends only one scoped PUT $project', () async {
      final requests = <RequestOptions>[];
      final c = makeClient((o) {
        requests.add(o);
        return (status: 204, body: '{private-marker');
      }, raw: true);
      addTearDown(c.close);
      await c.mergeRequests.publishDraftNote(project, iid: 142, draftNoteId: 7);
      final o = requests.single;
      expect(
        o.path,
        '/projects/${project is int ? project : 'group%2Fproject%20%2B'}/merge_requests/142/draft_notes/7/publish',
      );
      expect(o.baseUrl, 'https://gitlab.example.com/subpath/api/v4');
      expect(o.method, 'PUT');
      expect(o.data, isNull);
      expect(o.queryParameters, isEmpty);
      expect(o.followRedirects, false);
      expect(o.extra['labfox_no_auth_retry'], true);
    });
  }
  for (final project in [0, -1, '', ' ', 8.5]) {
    test('invalid project prevents publication $project', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.publishDraftNote(project, iid: 142, draftNoteId: 7),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final iid in [0, -1]) {
    test('invalid IID prevents publication $iid', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.publishDraftNote(8, iid: iid, draftNoteId: 7),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
  for (final status in [
    200,
    201,
    202,
    302,
    307,
    400,
    401,
    403,
    404,
    409,
    412,
    422,
    429,
    500,
  ]) {
    for (final thrown in [false, true]) {
      test(
        'publication HTTP $status thrown $thrown stays typed before decode',
        () async {
          var calls = 0, refreshes = 0;
          final c = makeClient(
            (o) {
              calls++;
              if (thrown) {
                throw DioException(
                  requestOptions: o,
                  type: DioExceptionType.badResponse,
                  response: Response<Object?>(
                    requestOptions: o,
                    statusCode: status,
                    data: '{private-marker',
                  ),
                );
              }
              return (status: status, body: '{private-marker');
            },
            raw: true,
            onUnauthorized: () async {
              refreshes++;
              return 'dummy-token';
            },
          );
          addTearDown(c.close);
          final matcher = switch (status) {
            401 => isA<GitLabAuthException>(),
            403 => isA<GitLabForbiddenException>(),
            404 => isA<GitLabNotFoundException>(),
            409 || 412 || 422 => isA<GitLabConflictException>(),
            429 => isA<GitLabRateLimitException>(),
            _ => isA<GitLabServerException>(),
          };
          await expectLater(
            c.mergeRequests.publishDraftNote(8, iid: 142, draftNoteId: 7),
            throwsA(
              allOf(
                matcher,
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
          expect(refreshes, 0);
        },
      );
    }
  }
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('publication transport $type never replays', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        throw DioException(
          requestOptions: o,
          type: type,
          message: 'private-marker',
        );
      });
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.publishDraftNote(8, iid: 142, draftNoteId: 7),
        throwsA(
          isA<GitLabConnectionException>().having(
            (e) => e.toString(),
            'sanitized',
            isNot(contains('private-marker')),
          ),
        ),
      );
      expect(calls, 1);
    });
  }
  for (final id in [0, -1]) {
    test('invalid draft ID $id prevents publication', () async {
      var calls = 0;
      final c = makeClient((o) {
        calls++;
        return (status: 204, body: null);
      });
      addTearDown(c.close);
      await expectLater(
        c.mergeRequests.publishDraftNote(8, iid: 142, draftNoteId: id),
        throwsArgumentError,
      );
      expect(calls, 0);
    });
  }
}
