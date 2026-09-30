import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_tags/data/protected_tags_repository.dart';
import 'package:labfox/features/protected_tags/presentation/controllers/protected_tags_controller.dart';

class _Repository extends ProtectedTagsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];
  Completer<Paginated<ProtectedTag>>? pendingSecondPage;

  @override
  Future<Paginated<ProtectedTag>> list(int projectId, {int page = 1}) async {
    expect(projectId, 7);
    pages.add(page);
    if (page == 2 && pendingSecondPage != null) {
      return pendingSecondPage!.future;
    }
    return page == 1
        ? const Paginated(items: [ProtectedTag(name: 'v*')], nextPage: 2)
        : const Paginated(items: [ProtectedTag(name: 'release/*')]);
  }
}

void main() {
  test('appends each protected tag page once', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        protectedTagsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = protectedTagsControllerProvider(7);

    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    await container.read(provider.notifier).loadMore();

    expect(repository.pages, [1, 2]);
    expect(
      container.read(provider).requireValue.items.map((rule) => rule.name),
      ['v*', 'release/*'],
    );
  });

  test('an invalidated list ignores an older page result', () async {
    final repository = _Repository();
    repository.pendingSecondPage = Completer<Paginated<ProtectedTag>>();
    final container = ProviderContainer(
      overrides: [
        protectedTagsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = protectedTagsControllerProvider(7);
    await container.read(provider.future);
    final pending = container.read(provider.notifier).loadMore();
    await Future<void>.delayed(Duration.zero);
    container.invalidate(provider);
    await container.read(provider.future);
    repository.pendingSecondPage!.complete(
      const Paginated(items: [ProtectedTag(name: 'stale/*')]),
    );
    await pending;
    expect(
      container.read(provider).requireValue.items.map((rule) => rule.name),
      ['v*'],
    );
  });
}
