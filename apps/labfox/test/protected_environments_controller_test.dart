import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

class _Repository extends ProtectedEnvironmentsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];

  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async {
    expect(projectId, 7);
    pages.add(page);
    return page == 1
        ? const Paginated(
            items: [ProtectedEnvironment(name: 'production')],
            nextPage: 2,
          )
        : const Paginated(items: [ProtectedEnvironment(name: 'staging')]);
  }

  @override
  Future<Paginated<ProtectedEnvironment>> listGroup(
    int groupId, {
    int page = 1,
  }) async {
    expect(groupId, 9);
    pages.add(page);
    return page == 1
        ? const Paginated(
            items: [ProtectedEnvironment(name: 'production')],
            nextPage: 2,
          )
        : const Paginated(items: [ProtectedEnvironment(name: 'staging')]);
  }
}

void main() {
  test('appends each protected environment page once', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        protectedEnvironmentsRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = protectedEnvironmentsControllerProvider(7);

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.pages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((rule) => rule.name),
      ['production', 'staging'],
    );
  });

  test('appends each group protected environment page once', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        protectedEnvironmentsRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = groupProtectedEnvironmentsControllerProvider(9);

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.pages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((rule) => rule.name),
      ['production', 'staging'],
    );
  });
}
