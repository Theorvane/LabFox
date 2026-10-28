import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/environments/data/environments_repository.dart';
import 'package:labfox/features/environments/presentation/controllers/environments_controller.dart';

class _FakeRepository extends EnvironmentsRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final requestedPages = <int>[];

  @override
  Future<Paginated<GitLabEnvironment>> list(
    int projectId, {
    String? state,
    String? search,
    int page = 1,
  }) async {
    requestedPages.add(page);
    expect(state, 'available');
    expect(search, 'prod');
    return page == 1
        ? const Paginated(
            items: [
              GitLabEnvironment(id: 1, name: 'production', state: 'available'),
            ],
            nextPage: 2,
          )
        : const Paginated(
            items: [
              GitLabEnvironment(
                id: 2,
                name: 'production-eu',
                state: 'available',
              ),
            ],
          );
  }
}

void main() {
  test('appends filtered environment pages once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        environmentsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = environmentListControllerProvider(
      const EnvironmentListRef(
        projectId: 7,
        state: 'available',
        search: 'prod',
      ),
    );
    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();
    expect(repository.requestedPages, [1, 2]);
    expect(container.read(provider).requireValue.items.map((item) => item.id), [
      1,
      2,
    ]);
  });
}
