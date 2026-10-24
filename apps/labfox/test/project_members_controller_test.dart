import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/members/data/project_members_repository.dart';
import 'package:labfox/features/members/presentation/controllers/members_controller.dart';

class _FakeRepository extends ProjectMembersRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];
  final queries = <String?>[];

  @override
  Future<Paginated<ProjectMember>> list(
    int projectId, {
    String? query,
    int page = 1,
  }) async {
    pages.add(page);
    queries.add(query);
    return page == 1
        ? const Paginated(
            items: [
              ProjectMember(
                id: 1,
                name: 'First',
                username: 'first',
                accessLevel: 30,
              ),
            ],
            nextPage: 2,
          )
        : const Paginated(
            items: [
              ProjectMember(
                id: 2,
                name: 'Second',
                username: 'second',
                accessLevel: 20,
              ),
            ],
          );
  }
}

void main() {
  test('preserves search across pages and appends once', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        projectMembersRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = projectMembersControllerProvider(
      const MemberListRef(projectId: 7, query: 'al'),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.pages, [1, 2]);
    expect(repository.queries, ['al', 'al']);
    expect(container.read(provider).requireValue.items.map((item) => item.id), [
      1,
      2,
    ]);
  });
}
