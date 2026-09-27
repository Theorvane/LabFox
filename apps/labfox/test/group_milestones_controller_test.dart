import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/milestones/data/group_milestones_repository.dart';
import 'package:labfox/features/milestones/presentation/controllers/milestones_controller.dart';

class _FakeRepository extends GroupMilestonesRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final requestedPages = <int>[];
  int createCalls = 0;

  @override
  Future<GitLabMilestone> create(
    int groupId, {
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
  }) async {
    createCalls++;
    return GitLabMilestone(
      id: 55,
      iid: 9,
      groupId: groupId,
      title: title,
      state: 'active',
    );
  }

  @override
  Future<Paginated<GitLabMilestone>> list(
    int groupId, {
    required String state,
    int page = 1,
  }) async {
    requestedPages.add(page);
    return page == 1
        ? const Paginated(
            items: [
              GitLabMilestone(
                id: 12,
                iid: 3,
                groupId: 7,
                title: 'First',
                state: 'active',
              ),
            ],
            nextPage: 2,
          )
        : const Paginated(
            items: [
              GitLabMilestone(
                id: 13,
                iid: 4,
                groupId: 7,
                title: 'Second',
                state: 'active',
              ),
            ],
          );
  }
}

void main() {
  test('appends each group milestone page once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        groupMilestonesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = groupMilestoneListControllerProvider(
      const GroupMilestoneListRef(groupId: 7, state: 'active'),
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

  test(
    'rejects blank titles and reversed dates before group creation',
    () async {
      final repository = _FakeRepository();
      final container = ProviderContainer(
        overrides: [
          groupMilestonesRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      final provider = groupMilestoneListControllerProvider(
        const GroupMilestoneListRef(groupId: 7, state: 'active'),
      );
      await container.read(provider.future);
      await expectLater(
        container.read(provider.notifier).create(title: '  '),
        throwsArgumentError,
      );
      await expectLater(
        container
            .read(provider.notifier)
            .create(
              title: 'Release 1',
              startDate: DateTime(2026, 11, 1),
              dueDate: DateTime(2026, 10, 1),
            ),
        throwsArgumentError,
      );
      expect(repository.createCalls, 0);
    },
  );
}
