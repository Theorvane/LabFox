import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/package_registry/data/package_overview.dart';
import 'package:labfox/features/package_registry/data/package_registry_repository.dart';
import 'package:labfox/features/package_registry/presentation/controllers/package_controllers.dart';

class _FakeRepository extends PackageRegistryRepository {
  _FakeRepository()
    : super(GitLabClient(baseUrl: 'https://example.com', token: 'glpat-x'));

  final requestedPages = <int>[];

  @override
  Future<Paginated<GitLabPackage>> list(int projectId, {int page = 1}) async {
    requestedPages.add(page);
    return page == 1
        ? const Paginated(
            items: [GitLabPackage(id: 1, name: 'first', packageType: 'npm')],
            nextPage: 2,
          )
        : const Paginated(
            items: [GitLabPackage(id: 2, name: 'second', packageType: 'maven')],
          );
  }

  @override
  Future<PackageOverview> load(int projectId, int packageId) async =>
      const PackageOverview(
        package: GitLabPackage(id: 1, name: 'first', packageType: 'npm'),
        files: Paginated(
          items: [PackageFile(id: 1, packageId: 1, fileName: 'first.tgz')],
          nextPage: 2,
        ),
      );

  @override
  Future<Paginated<PackageFile>> files(
    int projectId,
    int packageId, {
    int page = 1,
  }) async => const Paginated(
    items: [PackageFile(id: 2, packageId: 1, fileName: 'second.tgz')],
  );
}

void main() {
  test('loads each package page once and retains earlier results', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        packageRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = packageListControllerProvider(7);

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.requestedPages, [1, 2]);
    expect(container.read(provider).requireValue.items.map((p) => p.name), [
      'first',
      'second',
    ]);
  });

  test('appends package files for the detail page', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        packageRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = packageDetailControllerProvider(
      const PackageRef(projectId: 7, packageId: 1),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMoreFiles();

    expect(
      container.read(provider).requireValue.files.items.map((f) => f.fileName),
      ['first.tgz', 'second.tgz'],
    );
  });
}
