import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/core/auth/auth_controller.dart';
import 'package:labfox/core/auth/gitlab_client_provider.dart';
import 'package:labfox/features/merge_requests/data/mr_draft_notes_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_draft_notes_provider.dart';

const _account = Account(
  instanceUrl: 'https://gitlab.example.com',
  user: User(id: 23, username: 'reviewer', name: 'Reviewer'),
);
const _resource = MergeRequestRef(projectId: 8, iid: 142);
const _query = MrDraftNotesQuery(mergeRequest: _resource);
final _accountState = StateProvider<Account?>((ref) => _account);
final _clientState = StateProvider<Future<GitLabClient?>>((ref) async => null);
Map<String, Object?> _draft({int authorId = 23, int id = 5}) => {
  'id': id,
  'author_id': authorId,
  'merge_request_id': 1100,
  'note': '  **Private review**\n\n  ',
};

void main() {
  test('repository forwards identity and paging without publishing', () async {
    late RequestOptions request;
    final client = _client((o) async {
      request = o;
      return [_draft()];
    });
    addTearDown(client.close);
    final repo = MrDraftNotesRepository(client, authorId: 23);
    final page = await repo.list(projectId: 8, iid: 142, page: 3, perPage: 10);
    expect(request.method, 'GET');
    expect(request.path, '/projects/8/merge_requests/142/draft_notes');
    expect(request.queryParameters, {'page': 3, 'per_page': 10});
    expect(page.items.single.note, _draft()['note']);
  });
  test(
    'other-author page is rejected completely without private error text',
    () async {
      final client = _client(
        (o) async => [_draft(), _draft(authorId: 24, id: 6)],
      );
      addTearDown(client.close);
      await expectLater(
        MrDraftNotesRepository(
          client,
          authorId: 23,
        ).list(projectId: 8, iid: 142),
        throwsA(
          isA<GitLabServerException>().having(
            (e) => e.message,
            'sanitized',
            'Invalid draft notes ownership.',
          ),
        ),
      );
    },
  );
  test('invalid authenticated author fails before any network read', () async {
    var calls = 0;
    final client = _client((o) async {
      calls++;
      return [];
    });
    addTearDown(client.close);
    expect(
      () => MrDraftNotesRepository(client, authorId: 0),
      throwsArgumentError,
    );
    expect(calls, 0);
  });
  test('page query retains distinct MR and paging identities', () {
    expect(_query, const MrDraftNotesQuery(mergeRequest: _resource));
    expect(
      _query.hashCode,
      const MrDraftNotesQuery(mergeRequest: _resource).hashCode,
    );
    for (final other in [
      const MrDraftNotesQuery(
        mergeRequest: MergeRequestRef(projectId: 9, iid: 142),
      ),
      const MrDraftNotesQuery(
        mergeRequest: MergeRequestRef(projectId: 8, iid: 143),
      ),
      const MrDraftNotesQuery(mergeRequest: _resource, page: 2),
      const MrDraftNotesQuery(mergeRequest: _resource, perPage: 10),
    ]) {
      expect(_query, isNot(other));
    }
  });
  test(
    'provider reads one explicitly requested page, preserving cursor',
    () async {
      final reads = <int>[];
      final client = _client((o) async {
        reads.add(o.queryParameters['page'] as int);
        return [_draft()];
      }, nextPage: '4');
      final container = _container(Future.value(client));
      final sub = container.listen(
        mrDraftNotesPageProvider(
          const MrDraftNotesQuery(mergeRequest: _resource, page: 3),
        ),
        (_, _) {},
      );
      addTearDown(sub.close);
      final page = await container.read(
        mrDraftNotesReadProvider(
          const MrDraftNotesQuery(mergeRequest: _resource, page: 3),
        ).future,
      );
      expect(page.items.single.authorId, 23);
      expect(page.nextPage, 4);
      expect(reads, [3]);
      addTearDown(client.close);
    },
  );
  test(
    'signed-out provider reports auth failure without resolving a client',
    () async {
      var resolved = 0;
      final container = ProviderContainer(
        overrides: [
          currentAccountProvider.overrideWithValue(null),
          gitLabClientProvider.overrideWith((ref) async {
            resolved++;
            return null;
          }),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
      addTearDown(sub.close);
      await expectLater(
        container.read(mrDraftNotesReadProvider(_query).future),
        throwsA(isA<GitLabAuthException>()),
      );
      expect(resolved, 0);
    },
  );
  test('missing token/client reports auth failure', () async {
    final container = _container(Future.value(null));
    final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
    addTearDown(sub.close);
    await expectLater(
      container.read(mrDraftNotesReadProvider(_query).future),
      throwsA(isA<GitLabAuthException>()),
    );
  });
  for (final fail in [false, true]) {
    test(
      'old-account ${fail ? 'error' : 'data'} cannot replace the new account page',
      () async {
        final old = Completer<Object?>();
        final oldClient = _client((o) => old.future);
        final newClient = _client((o) async => [_draft(authorId: 24, id: 6)]);
        addTearDown(oldClient.close);
        addTearDown(newClient.close);
        final container = _container(Future.value(oldClient));
        final sub = container.listen(
          mrDraftNotesPageProvider(_query),
          (_, _) {},
        );
        addTearDown(sub.close);
        await container.pump();
        container.read(_accountState.notifier).state = _account.copyWith(
          user: const User(id: 24, username: 'other', name: 'Other'),
        );
        container.read(_clientState.notifier).state = Future.value(newClient);
        await container.pump();
        final page = await container.read(
          mrDraftNotesReadProvider(_query).future,
        );
        expect(page.items.single.authorId, 24);
        if (fail) {
          old.completeError(
            const GitLabForbiddenException('Private old error'),
          );
        } else {
          old.complete([_draft()]);
        }
        await container.pump();
        expect(
          container
              .read(mrDraftNotesPageProvider(_query))
              .value!
              .items
              .single
              .id,
          6,
        );
        expect(
          container.read(mrDraftNotesPageProvider(_query)).hasError,
          false,
        );
      },
    );
  }
  test(
    'account replacement before token resolution never dispatches the old read',
    () async {
      final pending = Completer<GitLabClient?>();
      var oldReads = 0;
      final oldClient = _client((o) async {
        oldReads++;
        return [_draft()];
      });
      final newClient = _client((o) async => [_draft(authorId: 24)]);
      addTearDown(oldClient.close);
      addTearDown(newClient.close);
      final container = _container(pending.future);
      final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
      addTearDown(sub.close);
      await container.pump();
      container.read(_accountState.notifier).state = _account.copyWith(
        user: const User(id: 24, username: 'other', name: 'Other'),
      );
      container.read(_clientState.notifier).state = Future.value(newClient);
      await container.pump();
      expect(
        (await container.read(
          mrDraftNotesReadProvider(_query).future,
        )).items.single.authorId,
        24,
      );
      pending.complete(oldClient);
      await container.pump();
      expect(oldReads, 0);
    },
  );
  test(
    'sign-out clears retained private rows and ignores the pending read',
    () async {
      final pending = Completer<Object?>();
      final client = _client((o) => pending.future);
      addTearDown(client.close);
      final container = _container(Future.value(client));
      final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
      addTearDown(sub.close);
      await container.pump();
      container.read(_accountState.notifier).state = null;
      container.read(_clientState.notifier).state = Future.value(null);
      await container.pump();
      await expectLater(
        container.read(mrDraftNotesReadProvider(_query).future),
        throwsA(isA<GitLabAuthException>()),
      );
      pending.complete([_draft()]);
      await container.pump();
      expect(
        container.read(mrDraftNotesPageProvider(_query)).valueOrNull,
        isNull,
      );
    },
  );
  test(
    'account replacement removes loaded private rows while the new read waits',
    () async {
      final pending = Completer<Object?>();
      final oldClient = _client((o) async => [_draft()]);
      final newClient = _client((o) => pending.future);
      addTearDown(oldClient.close);
      addTearDown(newClient.close);
      final container = _container(Future.value(oldClient));
      final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
      addTearDown(sub.close);
      expect(
        (await container.read(
          mrDraftNotesReadProvider(_query).future,
        )).items.single.authorId,
        23,
      );
      container.read(_accountState.notifier).state = _account.copyWith(
        user: const User(id: 24, username: 'other', name: 'Other'),
      );
      container.read(_clientState.notifier).state = Future.value(newClient);
      await container.pump();
      final waiting = container.read(mrDraftNotesPageProvider(_query));
      expect(waiting.isLoading, true);
      expect(waiting.valueOrNull, isNull);
      pending.complete([_draft(authorId: 24)]);
      await container.read(mrDraftNotesReadProvider(_query).future);
    },
  );
  for (final change in ['instance', 'client', 'sign-out']) {
    test(
      'loaded private rows disappear immediately on $change replacement',
      () async {
        final pending = Completer<Object?>();
        final oldClient = _client((o) async => [_draft()]);
        final newClient = _client((o) => pending.future);
        addTearDown(oldClient.close);
        addTearDown(newClient.close);
        final container = _container(Future.value(oldClient));
        final sub = container.listen(
          mrDraftNotesPageProvider(_query),
          (_, _) {},
        );
        addTearDown(sub.close);
        await container.read(mrDraftNotesReadProvider(_query).future);
        if (change == 'instance') {
          container.read(_accountState.notifier).state = _account.copyWith(
            instanceUrl: 'https://other.example.com',
          );
        } else if (change == 'sign-out') {
          container.read(_accountState.notifier).state = null;
        }
        container.read(_clientState.notifier).state = Future.value(
          change == 'sign-out' ? null : newClient,
        );
        // No pump: presentation must never expose the old page after replacement.
        expect(
          container.read(mrDraftNotesPageProvider(_query)).valueOrNull,
          isNull,
        );
        await container.pump();
        if (change == 'sign-out') {
          await expectLater(
            container.read(mrDraftNotesReadProvider(_query).future),
            throwsA(isA<GitLabAuthException>()),
          );
        } else {
          pending.complete([_draft()]);
          await container.read(mrDraftNotesReadProvider(_query).future);
        }
      },
    );
  }
  test('failed refresh hides the previously loaded private page', () async {
    var reads = 0;
    final client = _client((o) async {
      reads++;
      if (reads > 1) {
        throw DioException(
          requestOptions: o,
          response: Response<Object?>(requestOptions: o, statusCode: 403),
        );
      }
      return [_draft()];
    });
    addTearDown(client.close);
    final container = _container(Future.value(client));
    final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
    addTearDown(sub.close);
    await container.read(mrDraftNotesReadProvider(_query).future);
    container.invalidate(mrDraftNotesReadProvider(_query));
    expect(
      container.read(mrDraftNotesPageProvider(_query)).valueOrNull,
      isNull,
    );
    await expectLater(
      container.read(mrDraftNotesReadProvider(_query).future),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(container.read(mrDraftNotesPageProvider(_query)).hasError, true);
    expect(
      container.read(mrDraftNotesPageProvider(_query)).valueOrNull,
      isNull,
    );
  });
  test(
    'resource replacement before repository resolution does not dispatch the old MR',
    () async {
      final pending = Completer<GitLabClient?>();
      final paths = <String>[];
      final client = _client((o) async {
        paths.add(o.path);
        return [_draft()];
      });
      addTearDown(client.close);
      final container = _container(pending.future);
      final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
      await container.pump();
      sub.close();
      await container.pump();
      const next = MrDraftNotesQuery(
        mergeRequest: MergeRequestRef(projectId: 9, iid: 143),
      );
      final newSub = container.listen(
        mrDraftNotesPageProvider(next),
        (_, _) {},
      );
      addTearDown(newSub.close);
      pending.complete(client);
      await container.read(mrDraftNotesReadProvider(next).future);
      expect(paths, ['/projects/9/merge_requests/143/draft_notes']);
    },
  );
  test(
    'read failure preserves its type and explicit invalidation retries only GET',
    () async {
      var reads = 0;
      final client = _client((o) async {
        expect(o.method, 'GET');
        reads++;
        if (reads == 1) {
          throw DioException(
            requestOptions: o,
            response: Response<Object?>(requestOptions: o, statusCode: 403),
          );
        }
        return [_draft()];
      });
      addTearDown(client.close);
      final container = _container(Future.value(client));
      final sub = container.listen(mrDraftNotesPageProvider(_query), (_, _) {});
      addTearDown(sub.close);
      await expectLater(
        container.read(mrDraftNotesReadProvider(_query).future),
        throwsA(isA<GitLabForbiddenException>()),
      );
      container.invalidate(mrDraftNotesReadProvider(_query));
      expect(
        (await container.read(
          mrDraftNotesReadProvider(_query).future,
        )).items.single.id,
        5,
      );
      expect(reads, 2);
    },
  );
}

ProviderContainer _container(Future<GitLabClient?> client) {
  final container = ProviderContainer(
    overrides: [
      _clientState.overrideWith((ref) => client),
      currentAccountProvider.overrideWith((ref) => ref.watch(_accountState)),
      gitLabClientProvider.overrideWith((ref) => ref.watch(_clientState)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

GitLabClient _client(
  Future<Object?> Function(RequestOptions) handler, {
  String? nextPage,
}) {
  final dio = Dio();
  dio.httpClientAdapter = _Adapter(handler, nextPage);
  return GitLabClient(
    baseUrl: 'https://gitlab.example.com',
    token: 'glpat-xxxxxxxxxxxx',
    dio: dio,
  );
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler, this.nextPage);
  final Future<Object?> Function(RequestOptions) handler;
  final String? nextPage;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    json.encode(await handler(options)),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      if (nextPage != null) 'x-next-page': [nextPage!],
    },
  );
  @override
  void close({bool force = false}) {}
}
