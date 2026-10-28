import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_create_controller.dart';

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
  ContainerTagProtectionRule? response;
  final writes = <(int, String, String?, String?)>[];
  List<ContainerTagProtectionRule> rules = [];
  @override
  Future<List<ContainerTagProtectionRule>> tagProtectionRules(
    int projectId,
  ) async => rules;
  @override
  Future<ContainerTagProtectionRule> createTagProtectionRule(
    int projectId, {
    required String tagNamePattern,
    required String minimumAccessLevelForPush,
    required String minimumAccessLevelForDelete,
  }) async {
    writes.add((
      projectId,
      tagNamePattern,
      minimumAccessLevelForPush,
      minimumAccessLevelForDelete,
    ));
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    final created =
        response ??
        ContainerTagProtectionRule(
          id: 2,
          projectId: projectId,
          tagNamePattern: tagNamePattern,
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
    String pattern = 'v*-release',
    String? push = 'maintainer',
    String? delete = 'owner',
  }) => container
      .read(containerTagProtectionCreateControllerProvider(7).notifier)
      .create(
        tagNamePattern: pattern,
        minimumAccessLevelForPush: push,
        minimumAccessLevelForDelete: delete,
      );
  test('creates exact criteria and refreshes only after success', () async {
    final sub = container.listen(
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(containerTagProtectionControllerProvider(7).future);
    await create(pattern: ' x/* ', push: 'owner', delete: 'admin');
    expect(repository.writes, [(7, ' x/* ', 'owner', 'admin')]);
    expect(
      (await container.read(
        containerTagProtectionControllerProvider(7).future,
      )).single.id,
      2,
    );
  });
  for (final (pattern, push, delete) in <(String, String?, String?)>[
    ('', 'owner', 'owner'),
    ('   ', 'owner', 'owner'),
    ('x', null, null),
    ('x', 'future', 'owner'),
    ('x', null, ''),
    ('x', 'owner', 'future'),
    ('x', 'owner', null),
    ('x', null, 'owner'),
    ('x', '', 'owner'),
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
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(containerTagProtectionControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(create(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container.read(containerTagProtectionControllerProvider(7)).requireValue,
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
  for (final push in ['maintainer', 'owner', 'admin']) {
    for (final delete in ['maintainer', 'owner', 'admin']) {
      test('creates both supported roles $push/$delete', () async {
        await create(push: push, delete: delete);
        expect(repository.writes, [(7, 'v*-release', push, delete)]);
      });
    }
  }
  for (final projectId in [0, -1]) {
    test('invalid project $projectId never writes', () async {
      await expectLater(
        container
            .read(
              containerTagProtectionCreateControllerProvider(
                projectId,
              ).notifier,
            )
            .create(
              tagNamePattern: 'v*-release',
              minimumAccessLevelForPush: 'maintainer',
              minimumAccessLevelForDelete: 'owner',
            ),
        throwsArgumentError,
      );
      expect(repository.writes, isEmpty);
    });
  }
  for (final response in [
    const ContainerTagProtectionRule(
      id: 0,
      projectId: 7,
      tagNamePattern: 'v*-release',
      minimumAccessLevelForPush: 'maintainer',
      minimumAccessLevelForDelete: 'owner',
    ),
    const ContainerTagProtectionRule(
      id: 2,
      projectId: 8,
      tagNamePattern: 'v*-release',
      minimumAccessLevelForPush: 'maintainer',
      minimumAccessLevelForDelete: 'owner',
    ),
    const ContainerTagProtectionRule(
      id: 2,
      projectId: 7,
      tagNamePattern: 'other',
      minimumAccessLevelForPush: 'maintainer',
      minimumAccessLevelForDelete: 'owner',
    ),
    const ContainerTagProtectionRule(
      id: 2,
      projectId: 7,
      tagNamePattern: 'v*-release',
      minimumAccessLevelForPush: 'owner',
      minimumAccessLevelForDelete: 'owner',
    ),
    const ContainerTagProtectionRule(
      id: 2,
      projectId: 7,
      tagNamePattern: 'v*-release',
      minimumAccessLevelForPush: 'maintainer',
      minimumAccessLevelForDelete: 'admin',
    ),
    const ContainerTagProtectionRule(
      id: 2,
      projectId: 7,
      tagNamePattern: 'v*-release',
      minimumAccessLevelForPush: 'maintainer',
      minimumAccessLevelForDelete: null,
    ),
  ]) {
    test('does not claim success for mismatched response $response', () async {
      repository.response = response;
      final sub = container.listen(
        containerTagProtectionControllerProvider(7),
        (_, _) {},
      );
      addTearDown(sub.close);
      await container.read(containerTagProtectionControllerProvider(7).future);
      await expectLater(create(), throwsA(isA<GitLabServerException>()));
      expect(
        container
            .read(containerTagProtectionControllerProvider(7))
            .requireValue,
        isEmpty,
      );
    });
  }
}
