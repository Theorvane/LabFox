import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:labfox/features/comments/data/comments_repository.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<dynamic>? cancel,
  ) async {
    requests.add(options);
    final body = options.method == 'PUT'
        ? [
            {'id': 8, 'applied': true},
            {'id': 7, 'applied': true},
          ]
        : {'id': 'thread /#', 'individual_note': false, 'notes': []};
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  for (final message in [null, '', '  Exact\nMessage  ']) {
    test(
      'repository forwards authenticated read and exact batch application message $message',
      () async {
        final adapter = _Adapter();
        final client = GitLabClient(
          baseUrl: 'https://gitlab.example.com/subpath',
          token: 'glpat-xxxxxxxxxxxx',
          dio: Dio()..httpClientAdapter = adapter,
        );
        addTearDown(client.close);
        final repo = CommentsRepository(client);
        final group = await repo.discussion(
          projectId: 8,
          iid: 142,
          discussionId: 'thread /#',
        );
        expect(group.id, 'thread /#');
        final applied = await repo.applySuggestions(
          suggestionIds: [7, 8],
          commitMessage: message,
        );
        expect(applied.map((s) => s.id), [8, 7]);
        expect(applied.every((s) => s.applied == true), true);
        expect(adapter.requests.map((r) => r.method), ['GET', 'PUT']);
        expect(
          adapter.requests.first.uri.toString(),
          'https://gitlab.example.com/subpath/api/v4/projects/8/merge_requests/142/discussions/thread%20%2F%23',
        );
        final write = adapter.requests.last;
        expect(
          write.uri.toString(),
          'https://gitlab.example.com/subpath/api/v4/suggestions/batch_apply',
        );
        expect(write.data, {
          'ids': [7, 8],
          'commit_message': ?message,
        });
        expect(write.followRedirects, false);
        expect(write.extra['labfox_no_auth_retry'], true);
        expect(write.headers['PRIVATE-TOKEN'], 'glpat-xxxxxxxxxxxx');
      },
    );
  }
}
