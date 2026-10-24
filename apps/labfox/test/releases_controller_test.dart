import 'package:dio/dio.dart';
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

class _DeleteResponseRepository extends ReleasesRepository {
  _DeleteResponseRepository() : super(_clientWithDeleteResponse());

  final lists = <int, int>{};
  int details = 0;

  static GitLabClient _clientWithDeleteResponse() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          expect(request.method, 'DELETE');
          expect(request.path, '/projects/7/releases/release%2F2');
          handler.resolve(
            Response<dynamic>(
              requestOptions: request,
              statusCode: 200,
              data: {'tag_name': 'release/2', 'name': 'Version 2'},
            ),
          );
        },
      ),
    );
    return GitLabClient(
      baseUrl: 'https://gitlab.example.com',
      token: 'glpat-xxxxxxxxxxxx',
      dio: dio,
    );
  }

  @override
  Future<Paginated<GitLabRelease>> list(int projectId, {int page = 1}) async {
    lists.update(projectId, (count) => count + 1, ifAbsent: () => 1);
    return const Paginated(
      items: [GitLabRelease(name: 'Version 2', tagName: 'release/2')],
    );
  }

  @override
  Future<GitLabRelease> get(int projectId, String tagName) async {
    details++;
    return const GitLabRelease(name: 'Version 2', tagName: 'release/2');
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

  test('200 OK deletion refreshes the affected release caches', () async {
    final repository = _DeleteResponseRepository();
    final container = ProviderContainer(
      overrides: [
        releasesRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    const key = ReleaseRef(projectId: 7, tagName: 'release/2');
    final affectedList = releaseListControllerProvider(7);
    final otherList = releaseListControllerProvider(8);
    final detail = releaseDetailProvider(key);
    container.listen(affectedList, (_, _) {});
    container.listen(otherList, (_, _) {});
    container.listen(detail, (_, _) {});
    await container.read(affectedList.future);
    await container.read(otherList.future);
    await container.read(detail.future);

    await container.read(releaseDeleteControllerProvider(key).future);
    await container
        .read(releaseDeleteControllerProvider(key).notifier)
        .delete();
    await container.read(affectedList.future);
    await container.read(detail.future);

    expect(repository.lists, {7: 2, 8: 1});
    expect(repository.details, 2);
  });
}
