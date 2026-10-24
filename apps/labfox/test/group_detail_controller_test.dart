import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/groups/data/group_detail_repository.dart';
import 'package:labfox/features/groups/data/group_overview.dart';
import 'package:labfox/features/groups/presentation/controllers/group_detail_controller.dart';

class _FakeRepository extends GroupDetailRepository {
  _FakeRepository()
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'glpat-x'));

  final projectPages = <int>[];
  final subgroupPages = <int>[];

  @override
  Future<GroupOverview> load(int groupId) async => const GroupOverview(
    group: Group(id: 42, name: 'Team', fullPath: 'team'),
    projects: Paginated(
      items: [Project(id: 1, name: 'First', pathWithNamespace: 'team/first')],
      nextPage: 2,
    ),
    subgroups: Paginated(
      items: [Group(id: 9, name: 'Infra', fullPath: 'team/infra')],
      nextPage: 2,
    ),
  );

  @override
  Future<Paginated<Project>> projectsPage(int groupId, {int page = 1}) async {
    projectPages.add(page);
    return const Paginated(
      items: [Project(id: 2, name: 'Second', pathWithNamespace: 'team/second')],
    );
  }

  @override
  Future<Paginated<Group>> subgroupsPage(int groupId, {int page = 1}) async {
    subgroupPages.add(page);
    return const Paginated(
      items: [Group(id: 10, name: 'Docs', fullPath: 'team/docs')],
    );
  }
}

void main() {
  test(
    'loads the next project page once and retains earlier results',
    () async {
      final repository = _FakeRepository();
      final container = ProviderContainer(
        overrides: [
          groupDetailRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);
      final provider = groupDetailControllerProvider(42);

      await container.read(provider.future);
      await container.read(provider.notifier).loadMoreProjects();
      await container.read(provider.notifier).loadMoreProjects();

      expect(repository.projectPages, [2]);
      expect(
        container.read(provider).requireValue.projects.items.map((p) => p.name),
        ['First', 'Second'],
      );
    },
  );

  test(
    'loads the next subgroup page once and retains earlier results',
    () async {
      final repository = _FakeRepository();
      final container = ProviderContainer(
        overrides: [
          groupDetailRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);
      final provider = groupDetailControllerProvider(42);

      await container.read(provider.future);
      await container.read(provider.notifier).loadMoreSubgroups();
      await container.read(provider.notifier).loadMoreSubgroups();

      expect(repository.subgroupPages, [2]);
      expect(
        container
            .read(provider)
            .requireValue
            .subgroups
            .items
            .map((g) => g.name),
        ['Infra', 'Docs'],
      );
    },
  );
}
