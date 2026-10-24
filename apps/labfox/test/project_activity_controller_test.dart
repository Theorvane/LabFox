import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/activity/data/project_activity_repository.dart';
import 'package:labfox/features/activity/presentation/controllers/project_activity_controller.dart';

class _FakeRepository extends ProjectActivityRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final requestedPages = <int>[];

  @override
  Future<Paginated<ProjectEvent>> list(
    int projectId, {
    String? targetType,
    int page = 1,
  }) async {
    expect(targetType, 'issue');
    requestedPages.add(page);
    return page == 1
        ? const Paginated(
            items: [ProjectEvent(id: 1, projectId: 7, actionName: 'opened')],
            nextPage: 2,
          )
        : const Paginated(
            items: [ProjectEvent(id: 2, projectId: 7, actionName: 'closed')],
          );
  }
}

void main() {
  test('appends filtered project activity pages once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        projectActivityRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = projectActivityControllerProvider(
      const ProjectActivityRef(projectId: 7, targetType: 'issue'),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.requestedPages, [1, 2]);
    expect(container.read(provider).requireValue.items.map((e) => e.id), [
      1,
      2,
    ]);
  });
}
