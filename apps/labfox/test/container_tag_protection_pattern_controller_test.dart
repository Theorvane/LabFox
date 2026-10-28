import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_tag_protection_pattern_controller.dart';

const reviewedRule = ContainerTagProtectionRule(
  id: 2,
  projectId: 7,
  tagNamePattern: 'v*-release',
  minimumAccessLevelForPush: 'maintainer',
  minimumAccessLevelForDelete: 'owner',
);

class ProtectionPatternRepository extends ContainerRegistryRepository {
  ProtectionPatternRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  List<ContainerTagProtectionRule> rules = [reviewedRule];
  Object? failure;
  Object? readFailure;
  Completer<void>? pending;
  int reads = 0;
  ContainerTagProtectionRule? response;
  final writes = <(int, int, String)>[];
  @override
  Future<List<ContainerTagProtectionRule>> tagProtectionRules(
    int projectId,
  ) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return rules;
  }

  @override
  Future<ContainerTagProtectionRule> updateTagProtectionPattern(
    int projectId,
    int ruleId,
    String pattern,
  ) async {
    writes.add((projectId, ruleId, pattern));
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    final updated =
        response ??
        rules
            .singleWhere((rule) => rule.id == ruleId)
            .copyWith(tagNamePattern: pattern);
    rules = rules.map((rule) => rule.id == ruleId ? updated : rule).toList();
    return updated;
  }
}

void main() {
  for (final pattern in ['', '   ', reviewedRule.tagNamePattern]) {
    test(
      'rejects blank or unchanged pattern before network $pattern',
      () async {
        final repository = ProtectionPatternRepository();
        final container = ProviderContainer(
          overrides: [
            containerRegistryRepositoryProvider.overrideWith(
              (ref) async => repository,
            ),
          ],
        );
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(containerTagProtectionPatternControllerProvider(7).notifier)
              .savePattern(expected: reviewedRule, pattern: pattern),
          throwsArgumentError,
        );
        expect(repository.reads, 0);
        expect(repository.writes, isEmpty);
      },
    );
  }
  for (final response in [
    reviewedRule.copyWith(id: 3, tagNamePattern: 'v*-stable'),
    reviewedRule.copyWith(projectId: 8, tagNamePattern: 'v*-stable'),
    reviewedRule,
    reviewedRule.copyWith(
      tagNamePattern: 'v*-stable',
      minimumAccessLevelForPush: null,
    ),
    reviewedRule.copyWith(
      tagNamePattern: 'v*-stable',
      minimumAccessLevelForDelete: 'admin',
    ),
  ]) {
    test('mismatched response is not confirmed $response', () async {
      final repository = ProtectionPatternRepository()..response = response;
      final container = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(containerTagProtectionPatternControllerProvider(7).notifier)
            .savePattern(expected: reviewedRule, pattern: 'v*-stable'),
        throwsA(isA<GitLabServerException>()),
      );
    });
  }
  late ProtectionPatternRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectionPatternRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> save([ContainerTagProtectionRule expected = reviewedRule]) =>
      container
          .read(containerTagProtectionPatternControllerProvider(7).notifier)
          .savePattern(expected: expected, pattern: 'v*-stable');

  test(
    'updates only exact pattern and refreshes list only after success',
    () async {
      final other = reviewedRule.copyWith(id: 3, tagNamePattern: 'other-*');
      repository.rules = [reviewedRule, other];
      final sub = container.listen(
        containerTagProtectionControllerProvider(7),
        (_, _) {},
      );
      await container.read(containerTagProtectionControllerProvider(7).future);
      await save();
      expect(repository.writes, [(7, 2, 'v*-stable')]);
      expect(
        await container.read(
          containerTagProtectionControllerProvider(7).future,
        ),
        [reviewedRule.copyWith(tagNamePattern: 'v*-stable'), other],
      );
      sub.close();
    },
  );
  for (final current in <List<ContainerTagProtectionRule>>[
    [],
    [reviewedRule.copyWith(tagNamePattern: 'changed-*')],
    [reviewedRule.copyWith(minimumAccessLevelForPush: 'admin')],
    [reviewedRule.copyWith(minimumAccessLevelForDelete: null)],
    [reviewedRule.copyWith(projectId: 8)],
    [reviewedRule, reviewedRule],
  ]) {
    test('missing, changed or ambiguous rule rejects $current', () async {
      repository.rules = current;
      await expectLater(save(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
    });
  }
  for (final expected in [
    reviewedRule.copyWith(projectId: 8),
    reviewedRule.copyWith(id: 0),
    reviewedRule.copyWith(tagNamePattern: ''),
  ]) {
    test('invalid target rejects before reading $expected', () async {
      await expectLater(save(expected), throwsArgumentError);
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    });
  }
  test(
    'unknown and nullable roles are retained rather than inferred permission',
    () async {
      final rule = reviewedRule.copyWith(
        minimumAccessLevelForPush: 'future_role',
        minimumAccessLevelForDelete: null,
      );
      repository.rules = [rule];
      await save(rule);
      expect(repository.writes, [(7, 2, 'v*-stable')]);
    },
  );
  test('failed update retains cache and retries the real operation', () async {
    final sub = container.listen(
      containerTagProtectionControllerProvider(7),
      (_, _) {},
    );
    await container.read(containerTagProtectionControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(save(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container.read(containerTagProtectionControllerProvider(7)).requireValue,
      [reviewedRule],
    );
    repository.failure = null;
    await save();
    expect(repository.writes, [(7, 2, 'v*-stable'), (7, 2, 'v*-stable')]);
    sub.close();
  });
  test('failed re-read never writes', () async {
    repository.readFailure = const GitLabForbiddenException('private');
    await expectLater(save(), throwsA(isA<GitLabForbiddenException>()));
    expect(repository.writes, isEmpty);
  });
  test('pending update rejects duplicates', () async {
    repository.pending = Completer<void>();
    final pending = save();
    await Future<void>.delayed(Duration.zero);
    await expectLater(save(), throwsStateError);
    expect(repository.writes, hasLength(1));
    repository.pending!.complete();
    await pending;
  });
}
