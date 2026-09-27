import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/milestones/data/milestones_repository.dart';
import 'package:labfox/features/milestones/presentation/controllers/milestones_controller.dart';

class _FakeRepository extends MilestonesRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final requestedPages = <int>[];
  final requestedAncestors = <bool>[];

  @override
  Future<Paginated<GitLabMilestone>> list(
    int projectId, {
    required String state,
    int page = 1,
    bool includeAncestors = false,
  }) async {
    requestedPages.add(page);
    requestedAncestors.add(includeAncestors);
    return page == 1
        ? const Paginated(
            items: [
              GitLabMilestone(id: 12, iid: 3, title: 'First', state: 'active'),
            ],
            nextPage: 2,
          )
        : const Paginated(
            items: [
              GitLabMilestone(id: 13, iid: 4, title: 'Second', state: 'active'),
            ],
          );
  }
}

void main() {
  test('appends each milestone page once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        milestonesRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = milestoneListControllerProvider(
      const MilestoneListRef(projectId: 7, state: 'active'),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.requestedPages, [1, 2]);
    expect(container.read(provider).requireValue.items.map((item) => item.id), [
      12,
      13,
    ]);
  });

  test('keeps ancestor milestones enabled across pages', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        milestonesRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = milestoneListControllerProvider(
      const MilestoneListRef(
        projectId: 7,
        state: 'active',
        includeAncestors: true,
      ),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();

    expect(repository.requestedAncestors, [true, true]);
  });
}
