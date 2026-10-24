import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/deployments/data/deployments_repository.dart';
import 'package:labfox/features/deployments/presentation/controllers/deployments_controller.dart';

class _FakeRepository extends DeploymentsRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final requestedPages = <int>[];

  @override
  Future<Paginated<GitLabDeployment>> list(
    int projectId, {
    String? environment,
    String? status,
    int page = 1,
  }) async {
    expect(environment, 'production');
    expect(status, 'success');
    requestedPages.add(page);
    return page == 1
        ? const Paginated(
            items: [GitLabDeployment(id: 42, status: 'success')],
            nextPage: 2,
          )
        : const Paginated(items: [GitLabDeployment(id: 43, status: 'success')]);
  }
}

void main() {
  test('appends filtered deployment pages once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        deploymentsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = deploymentListControllerProvider(
      const DeploymentListRef(
        projectId: 7,
        environment: 'production',
        status: 'success',
      ),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.requestedPages, [1, 2]);
    expect(container.read(provider).requireValue.items.map((d) => d.id), [
      42,
      43,
    ]);
  });
}
