import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_branches/data/protected_branches_repository.dart';
import 'package:labfox/features/protected_branches/presentation/controllers/protected_branches_controller.dart';

class _Repository extends ProtectedBranchesRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];
  Completer<Paginated<ProtectedBranch>>? pendingPage;

  @override
  Future<Paginated<ProtectedBranch>> list(int projectId, {int page = 1}) async {
    expect(projectId, 7);
    pages.add(page);
    if (page == 2 && pendingPage != null) return pendingPage!.future;
    return page == 1
        ? const Paginated(items: [ProtectedBranch(name: 'main')], nextPage: 2)
        : const Paginated(items: [ProtectedBranch(name: 'release/*')]);
  }
}

void main() {
  test('appends each protected branch page once', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        protectedBranchesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = protectedBranchesControllerProvider(7);

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.pages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((rule) => rule.name),
      ['main', 'release/*'],
    );
  });

  test('discards a page fetched before the list is refreshed', () async {
    final repository = _Repository()
      ..pendingPage = Completer<Paginated<ProtectedBranch>>();
    final container = ProviderContainer(
      overrides: [
        protectedBranchesRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = protectedBranchesControllerProvider(7);
    await container.read(provider.future);
    final stale = container.read(provider.notifier).loadMore();
    await Future<void>.delayed(Duration.zero);
    container.invalidate(provider);
    await container.read(provider.future);
    repository.pendingPage!.complete(
      const Paginated(items: [ProtectedBranch(name: 'stale')]),
    );
    await stale;
    expect(
      container.read(provider).requireValue.items.map((rule) => rule.name),
      ['main'],
    );
  });
}
