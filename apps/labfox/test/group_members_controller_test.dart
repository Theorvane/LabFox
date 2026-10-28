import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/members/data/group_members_repository.dart';
import 'package:labfox/features/members/presentation/controllers/members_controller.dart';

class _FakeRepository extends GroupMembersRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];

  @override
  Future<Paginated<ProjectMember>> list(
    int groupId, {
    String? query,
    int page = 1,
  }) async {
    expect(groupId, 7);
    expect(query, 'alex');
    pages.add(page);
    return Paginated(
      items: [
        ProjectMember(
          id: page,
          name: 'Alex',
          username: 'alex',
          accessLevel: 30,
        ),
      ],
      nextPage: page == 1 ? 2 : null,
    );
  }
}

void main() {
  test('searches effective group members and appends pages once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        groupMembersRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = projectMembersControllerProvider(
      const MemberListRef(groupId: 7, query: 'alex'),
    );
    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();
    expect(repository.pages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((member) => member.id),
      [1, 2],
    );
  });
}
