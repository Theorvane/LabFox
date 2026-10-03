import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_repository_protection_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_repository_protection_create_controller.dart';

class ProtectionCreateRepository extends ContainerRegistryRepository {
  ProtectionCreateRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  Object? failure;
  Completer<void>? pending;
  ContainerRepositoryProtectionRule? response;
  final writes = <(int, String, String?, String?)>[];
  List<ContainerRepositoryProtectionRule> rules = [];
  @override
  Future<List<ContainerRepositoryProtectionRule>> repositoryProtectionRules(
    int projectId,
  ) async => rules;
  @override
  Future<ContainerRepositoryProtectionRule> createRepositoryProtectionRule(
    int projectId, {
    required String repositoryPathPattern,
    String? minimumAccessLevelForPush,
    String? minimumAccessLevelForDelete,
  }) async {
    writes.add((
      projectId,
      repositoryPathPattern,
      minimumAccessLevelForPush,
      minimumAccessLevelForDelete,
    ));
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    final created =
        response ??
        ContainerRepositoryProtectionRule(
          id: 2,
          projectId: projectId,
          repositoryPathPattern: repositoryPathPattern,
          minimumAccessLevelForPush: minimumAccessLevelForPush,
          minimumAccessLevelForDelete: minimumAccessLevelForDelete,
        );
    rules = [...rules, created];
    return created;
  }
}

void main() {
  late ProtectionCreateRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectionCreateRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> create({
    String pattern = 'team/app-*',
    String? push = 'maintainer',
    String? delete,
  }) => container
      .read(containerRepositoryProtectionCreateControllerProvider(7).notifier)
      .create(
        repositoryPathPattern: pattern,
        minimumAccessLevelForPush: push,
        minimumAccessLevelForDelete: delete,
      );
  test('creates exact criteria and refreshes only after success', () async {
    final sub = container.listen(
      containerRepositoryProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(
      containerRepositoryProtectionControllerProvider(7).future,
    );
    await create(pattern: ' x/* ', push: 'owner', delete: 'admin');
    expect(repository.writes, [(7, ' x/* ', 'owner', 'admin')]);
    expect(
      (await container.read(
        containerRepositoryProtectionControllerProvider(7).future,
      )).single.id,
      2,
    );
  });
  for (final (pattern, push, delete) in <(String, String?, String?)>[
    ('', 'owner', null),
    ('   ', 'owner', null),
    ('x', null, null),
    ('x', 'future', null),
    ('x', null, ''),
    ('x', 'owner', 'future'),
  ]) {
    test(
      'invalid input is rejected before network: $pattern $push $delete',
      () async {
        await expectLater(
          create(pattern: pattern, push: push, delete: delete),
          throwsArgumentError,
        );
        expect(repository.writes, isEmpty);
      },
    );
  }
  test('permission failure retains cache and supports real retry', () async {
    final sub = container.listen(
      containerRepositoryProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(
      containerRepositoryProtectionControllerProvider(7).future,
    );
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(create(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container
          .read(containerRepositoryProtectionControllerProvider(7))
          .requireValue,
      isEmpty,
    );
    repository.failure = null;
    await create();
    expect(repository.writes.length, 2);
  });
  test('blocks duplicate command during pending creation', () async {
    repository.pending = Completer<void>();
    final first = create();
    await Future<void>.delayed(Duration.zero);
    await expectLater(create(), throwsStateError);
    expect(repository.writes.length, 1);
    repository.pending!.complete();
    await first;
  });
  for (final response in [
    const ContainerRepositoryProtectionRule(
      id: 0,
      projectId: 7,
      repositoryPathPattern: 'team/app-*',
      minimumAccessLevelForPush: 'maintainer',
    ),
    const ContainerRepositoryProtectionRule(
      id: 2,
      projectId: 8,
      repositoryPathPattern: 'team/app-*',
      minimumAccessLevelForPush: 'maintainer',
    ),
    const ContainerRepositoryProtectionRule(
      id: 2,
      projectId: 7,
      repositoryPathPattern: 'other',
      minimumAccessLevelForPush: 'maintainer',
    ),
    const ContainerRepositoryProtectionRule(
      id: 2,
      projectId: 7,
      repositoryPathPattern: 'team/app-*',
      minimumAccessLevelForPush: 'owner',
    ),
  ]) {
    test('does not claim success for mismatched response $response', () async {
      repository.response = response;
      await expectLater(create(), throwsA(isA<GitLabServerException>()));
    });
  }
}
