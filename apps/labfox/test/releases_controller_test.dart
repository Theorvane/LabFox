import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/releases/data/releases_repository.dart';
import 'package:labfox/features/releases/presentation/controllers/releases_controller.dart';

class _FakeRepository extends ReleasesRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];

  @override
  Future<Paginated<GitLabRelease>> list(int projectId, {int page = 1}) async {
    pages.add(page);
    return page == 1
        ? const Paginated(
            items: [GitLabRelease(name: 'First', tagName: 'v1')],
            nextPage: 2,
          )
        : const Paginated(
            items: [GitLabRelease(name: 'Second', tagName: 'v2')],
          );
  }
}

void main() {
  test('appends each Release page once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = releaseListControllerProvider(7);

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.pages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((item) => item.tagName),
      ['v1', 'v2'],
    );
  });
}
