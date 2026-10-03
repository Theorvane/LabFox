import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';

class CleanupRepository extends ContainerRegistryRepository {
  CleanupRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  int calls = 0;
  int tagReads = 0;
  int repositoryReads = 0;
  Completer<void>? pending;
  Object? failure;
  Completer<Paginated<RegistryTag>>? tagPage;
  Completer<Paginated<RegistryRepository>>? repositoryPage;
  Map<String, Object?>? criteria;

  @override
  Future<void> cleanupTags(
    int projectId,
    int repositoryId, {
    required String nameRegexDelete,
    String? nameRegexKeep,
    int? keepN,
    String? olderThan,
  }) async {
    expectSync(projectId, 7);
    expectSync(repositoryId, 3);
    calls++;
    criteria = {
      'delete': nameRegexDelete,
      'keep': nameRegexKeep,
      'count': keepN,
      'age': olderThan,
    };
    if (failure != null) throw failure!;
    await pending?.future;
  }

  @override
  Future<Paginated<RegistryTag>> tags(
    int projectId,
    int repositoryId, {
    int page = 1,
  }) async {
    tagReads++;
    if (page == 2 && tagPage != null) return tagPage!.future;
    return Paginated(
      items: [RegistryTag(name: 'read-$tagReads', path: 'image')],
      nextPage: 2,
    );
  }

  @override
  Future<Paginated<RegistryRepository>> repositories(
    int projectId, {
    int page = 1,
  }) async {
    repositoryReads++;
    if (page == 2 && repositoryPage != null) return repositoryPage!.future;
    return Paginated(
      items: [
        RegistryRepository(
          id: repositoryReads,
          name: 'image',
          path: 'image',
          projectId: 7,
        ),
      ],
      nextPage: 2,
    );
  }
}

const cleanupKey = RegistryRef(projectId: 7, repositoryId: 3);

void main() {
  late CleanupRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = CleanupRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());

  test(
    'acceptance refreshes parents without pretending tags were removed',
    () async {
      final tags = containerTagsControllerProvider(cleanupKey);
      final images = containerRepositoriesControllerProvider(7);
      await container.read(tags.future);
      await container.read(images.future);
      await container
          .read(containerTagCleanupControllerProvider(cleanupKey).notifier)
          .schedule(
            nameRegexDelete: 'release.+',
            nameRegexKeep: 'stable',
            keepN: 10,
            olderThan: '7d',
          );
      await container.read(tags.future);
      await container.read(images.future);
      expect(repository.criteria, {
        'delete': 'release.+',
        'keep': 'stable',
        'count': 10,
        'age': '7d',
      });
      expect(repository.tagReads, 2);
      expect(repository.repositoryReads, 2);
      expect(container.read(tags).requireValue.items.single.name, 'read-2');
    },
  );

  test('failure preserves parents and can be retried', () async {
    final tags = containerTagsControllerProvider(cleanupKey);
    await container.read(tags.future);
    repository.failure = const GitLabForbiddenException(
      'secret server text',
      statusCode: 403,
    );
    final command = container.read(
      containerTagCleanupControllerProvider(cleanupKey).notifier,
    );
    await expectLater(
      command.schedule(nameRegexDelete: 'release'),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(repository.tagReads, 1);
    expect(container.read(tags).requireValue.items.single.name, 'read-1');
    repository.failure = null;
    await command.schedule(nameRegexDelete: 'release', keepN: 0);
    expect(repository.calls, 2);
  });

  test('rejects duplicate submissions while request is pending', () async {
    repository.pending = Completer<void>();
    final command = container.read(
      containerTagCleanupControllerProvider(cleanupKey).notifier,
    );
    final first = command.schedule(nameRegexDelete: 'release');
    await expectLater(
      command.schedule(nameRegexDelete: 'release'),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.calls, 1);
    repository.pending!.complete();
    await first;
  });

  test('missing account is a failed command', () async {
    final empty = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(empty.dispose);
    await expectLater(
      empty
          .read(containerTagCleanupControllerProvider(cleanupKey).notifier)
          .schedule(nameRegexDelete: 'release'),
      throwsStateError,
    );
    expect(
      empty.read(containerTagCleanupControllerProvider(cleanupKey)).hasError,
      isTrue,
    );
  });

  for (final failure in [false, true]) {
    test(
      'refresh ignores stale tag page ${failure ? 'failure' : 'success'}',
      () async {
        final provider = containerTagsControllerProvider(cleanupKey);
        await container.read(provider.future);
        repository.tagPage = Completer<Paginated<RegistryTag>>();
        final page = container.read(provider.notifier).loadMore();
        await Future<void>.delayed(Duration.zero);
        container.invalidate(provider);
        await container.read(provider.future);
        if (failure) {
          repository.tagPage!.completeError(
            const GitLabServerException('stale', statusCode: 500),
          );
        } else {
          repository.tagPage!.complete(
            const Paginated(
              items: [RegistryTag(name: 'stale', path: 'image')],
            ),
          );
        }
        await page;
        expect(container.read(provider).hasError, isFalse);
        expect(
          container.read(provider).requireValue.items.single.name,
          'read-3',
        );
      },
    );
    test(
      'refresh ignores stale repository page ${failure ? 'failure' : 'success'}',
      () async {
        final provider = containerRepositoriesControllerProvider(7);
        await container.read(provider.future);
        repository.repositoryPage = Completer<Paginated<RegistryRepository>>();
        final page = container.read(provider.notifier).loadMore();
        await Future<void>.delayed(Duration.zero);
        container.invalidate(provider);
        await container.read(provider.future);
        if (failure) {
          repository.repositoryPage!.completeError(
            const GitLabServerException('stale', statusCode: 500),
          );
        } else {
          repository.repositoryPage!.complete(const Paginated(items: []));
        }
        await page;
        expect(container.read(provider).hasError, isFalse);
        expect(container.read(provider).requireValue.items.single.id, 3);
      },
    );
  }
}
