import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/issues/data/issue_links_repository.dart';
import 'package:labfox/features/issues/presentation/controllers/issues_controllers.dart';
import 'package:labfox/features/issues/presentation/controllers/linked_issues_controller.dart';

class _Repository extends IssueLinksRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];

  @override
  Future<Paginated<IssueLink>> list(
    int projectId, {
    required int issueIid,
    int page = 1,
  }) async {
    expect(projectId, 7);
    expect(issueIid, 42);
    pages.add(page);
    return page == 1
        ? const Paginated(
            items: [
              IssueLink(
                id: 10,
                iid: 1,
                projectId: 7,
                title: 'First',
                state: 'opened',
                linkType: 'relates_to',
              ),
            ],
            nextPage: 2,
          )
        : const Paginated(
            items: [
              IssueLink(
                id: 11,
                iid: 2,
                projectId: 8,
                title: 'Second',
                state: 'closed',
                linkType: 'is_blocked_by',
              ),
            ],
          );
  }
}

void main() {
  test('appends linked issues once and keeps source iid', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        issueLinksRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = linkedIssuesControllerProvider(
      const IssueRef(projectId: 7, iid: 42),
    );

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.pages, [1, 2]);
    expect(container.read(provider).requireValue.items.map((link) => link.id), [
      10,
      11,
    ]);
  });
}
