import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';

class _FakeRepository extends ContainerRegistryRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final repositoryPages = <int>[];
  final tagPages = <int>[];

  @override
  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) async {
    repositoryPages.add(page);
    return page == 1
        ? const Paginated(
            items: [
              RegistryRepository(id: 1, name: '', path: 'first', projectId: 7),
            ],
            nextPage: 2,
          )
        : const Paginated(
            items: [
              RegistryRepository(
                id: 2,
                name: 'second',
                path: 'second',
                projectId: 7,
              ),
            ],
          );
  }

  @override
  Future<Paginated<RegistryTag>> tags(
    int projectId,
    int repositoryId, {
    int page = 1,
  }) async {
    tagPages.add(page);
    return page == 1
        ? const Paginated(
            items: [RegistryTag(name: 'first', path: 'first')],
            nextPage: 2,
          )
        : const Paginated(
            items: [RegistryTag(name: 'second', path: 'second')],
          );
  }
}

void main() {
  test('appends each image repository page once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = containerRepositoriesControllerProvider(7);

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.repositoryPages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((item) => item.path),
      ['first', 'second'],
    );
  });

  test('appends each image tag page once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = containerTagsControllerProvider(
      const RegistryRef(projectId: 7, repositoryId: 1),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.tagPages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((item) => item.name),
      ['first', 'second'],
    );
  });
}
