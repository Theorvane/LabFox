import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/releases/data/release_group_milestones_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/release_group_milestones_controller.dart';

import 'support/fake_dio.dart';

class _Repository extends ReleaseGroupMilestonesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int? groupId = 42;
  bool rejectMore = false;
  final requests = <({int groupId, String search, int page})>[];
  @override
  Future<int?> getDirectGroupId(int projectId) async => groupId;
  @override
  Future<Paginated<GitLabMilestone>> list(
    int groupId, {
    String search = '',
    int page = 1,
  }) async {
    requests.add((groupId: groupId, search: search, page: page));
    if (rejectMore && page == 4) {
      throw const GitLabForbiddenException('Forbidden');
    }
    return Paginated(
      items: [
        GitLabMilestone(
          id: page,
          iid: 1,
          title: 'Release, phase $page',
          state: 'closed',
          groupId: groupId,
        ),
      ],
      nextPage: page == 1 ? 4 : null,
    );
  }
}

class _PendingRepository extends _Repository {
  int firstPageLoads = 0;
  final pendingPages = <Completer<Paginated<GitLabMilestone>>>[];

  @override
  Future<Paginated<GitLabMilestone>> list(
    int groupId, {
    String search = '',
    int page = 1,
  }) async {
    requests.add((groupId: groupId, search: search, page: page));
    if (page != 1) {
      final pending = Completer<Paginated<GitLabMilestone>>();
      pendingPages.add(pending);
      return pending.future;
    }
    firstPageLoads++;
    return Paginated(
      items: [
        GitLabMilestone(
          id: firstPageLoads * 10,
          iid: 1,
          title: 'Current milestone',
          state: 'active',
          groupId: groupId,
        ),
      ],
      nextPage: 4,
    );
  }

  void completePage(int index) => pendingPages[index].complete(
    const Paginated(
      items: [
        GitLabMilestone(
          id: 99,
          iid: 9,
          title: 'Delayed milestone',
          state: 'active',
          groupId: 42,
        ),
      ],
    ),
  );
}

void main() {
  for (final switchAccount in [false, true]) {
    test('pending page cannot overwrite first page after '
        '${switchAccount ? 'account switch' : 'refresh'}', () async {
      final oldRepository = _PendingRepository();
      final newRepository = _PendingRepository()..groupId = 84;
      final account = StateProvider<_PendingRepository>((ref) => oldRepository);
      final container = ProviderContainer(
        overrides: [
          releaseGroupMilestonesRepositoryProvider.overrideWith(
            (ref) async => ref.watch(account),
          ),
        ],
      );
      addTearDown(container.dispose);
      final provider = releaseGroupMilestonesControllerProvider((
        projectId: 7,
        search: '',
      ));
      await container.read(provider.future);
      final pending = container.read(provider.notifier).loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(oldRepository.pendingPages, hasLength(1));
      if (switchAccount) {
        container.read(account.notifier).state = newRepository;
      } else {
        container.invalidate(provider);
      }
      final fresh = await container.read(provider.future);
      oldRepository.completePage(0);
      await pending;
      expect(container.read(provider).requireValue, fresh);
    });
  }

  test('stale page finally does not release a current page request', () async {
    final repository = _PendingRepository();
    final container = ProviderContainer(
      overrides: [
        releaseGroupMilestonesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = releaseGroupMilestonesControllerProvider((
      projectId: 7,
      search: '',
    ));
    await container.read(provider.future);
    final controller = container.read(provider.notifier);
    final stale = controller.loadMore();
    await Future<void>.delayed(Duration.zero);
    container.invalidate(provider);
    await container.read(provider.future);
    final current = controller.loadMore();
    await Future<void>.delayed(Duration.zero);
    expect(repository.pendingPages, hasLength(2));
    repository.completePage(0);
    await stale;
    await controller.loadMore();
    expect(repository.pendingPages, hasLength(2));
    repository.completePage(1);
    await current;
  });

  test(
    'project lookup errors are not treated as an empty personal namespace',
    () async {
      final client = GitLabClient(
        baseUrl: 'https://gitlab.example.com',
        token: 'glpat-xxxxxxxxxxxx',
        dio: fakeDio((_) => (status: 403, body: const {})),
      );
      await expectLater(
        ReleaseGroupMilestonesRepository(client).getDirectGroupId(7),
        throwsA(isA<GitLabForbiddenException>()),
      );
    },
  );
  for (final namespace in [
    null,
    <String, dynamic>{},
    {'id': 42, 'kind': 'user'},
    {'id': 42, 'kind': 'other'},
    {'kind': 'group'},
    {'id': 0, 'kind': 'group'},
    {'id': 42, 'kind': 'group', 'parent_id': 99},
  ]) {
    test(
      'resolves a direct group only from typed namespace $namespace',
      () async {
        final client = GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
          dio: fakeDio((request) {
            expect(request.path, '/projects/7');
            return (
              status: 200,
              body: {
                'id': 7,
                'name': 'app',
                'path_with_namespace': 'parent/direct/app',
                'namespace': namespace,
              },
            );
          }),
        );
        final actual = await ReleaseGroupMilestonesRepository(
          client,
        ).getDirectGroupId(7);
        expect(
          actual,
          namespace?['kind'] == 'group' && namespace?['id'] == 42 ? 42 : null,
        );
      },
    );
  }
  test(
    'controller trims search and retries the exact header cursor without losing rows',
    () async {
      final repository = _Repository()..rejectMore = true;
      final container = ProviderContainer(
        overrides: [
          releaseGroupMilestonesRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      const query = (projectId: 7, search: ' Release, phase ');
      final provider = releaseGroupMilestonesControllerProvider(query);
      final initial = await container.read(provider.future);
      final controller = container.read(provider.notifier);
      await expectLater(
        controller.loadMore(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      expect(container.read(provider).requireValue.items, initial.items);
      repository.rejectMore = false;
      await controller.loadMore();
      expect(repository.requests.last, (
        groupId: 42,
        search: 'Release, phase',
        page: 4,
      ));
      expect(
        container.read(provider).requireValue.items.map((item) => item.id),
        [1, 4],
      );
      expect(container.read(provider).requireValue.nextPage, isNull);
    },
  );
  test(
    'unknown or personal namespace issues no group milestone request',
    () async {
      final repository = _Repository()..groupId = null;
      final container = ProviderContainer(
        overrides: [
          releaseGroupMilestonesRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      final page = await container.read(
        releaseGroupMilestonesControllerProvider((
          projectId: 7,
          search: '',
        )).future,
      );
      expect(page.items, isEmpty);
      expect(repository.requests, isEmpty);
    },
  );
}
