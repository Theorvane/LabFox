import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_delete_pattern_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_cleanup_policy_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';

const reviewedPolicy = ContainerCleanupPolicy(
  enabled: true,
  cadence: '7d',
  keepN: 10,
  olderThan: '14d',
  nameRegexDelete: 'release.+',
  nameRegexKeep: 'stable',
);

class DeletePatternRepository extends ContainerRegistryRepository {
  DeletePatternRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ContainerCleanupPolicy? policy = reviewedPolicy;
  Object? failure;
  Object? readFailure;
  Completer<void>? pending;
  int reads = 0;
  final writes = <String>[];
  @override
  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return policy;
  }

  @override
  Future<void> setCleanupPolicyDeletePattern(
    int projectId, {
    required String nameRegexDelete,
  }) async {
    writes.add(nameRegexDelete);
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    policy = policy!.copyWith(nameRegexDelete: nameRegexDelete);
  }
}

void main() {
  test(
    'unreported keep pattern blocks deletion expansion before reading',
    () async {
      final repository = DeletePatternRepository();
      final container = ProviderContainer(
        overrides: [
          containerRegistryRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      final expected = reviewedPolicy.copyWith(
        enabled: false,
        nameRegexKeep: null,
      );
      repository.policy = expected;
      await expectLater(
        container
            .read(cleanupPolicyDeletePatternControllerProvider(7).notifier)
            .setDeletePattern(expected: expected, nameRegexDelete: '.*'),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test('explicit empty keep pattern is reported', () {
    expect(
      canEditCleanupDeletePattern(reviewedPolicy.copyWith(nameRegexKeep: '')),
      isTrue,
    );
  });

  late DeletePatternRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = DeletePatternRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  for (final nameRegexDelete in ['v.+', '.*', ' release .+ ']) {
    test(
      'updates only delete pattern $nameRegexDelete and refreshes after acceptance',
      () async {
        final sub = container.listen(
          containerCleanupPolicyControllerProvider(7),
          (_, _) {},
        );
        await container.read(
          containerCleanupPolicyControllerProvider(7).future,
        );
        await container
            .read(cleanupPolicyDeletePatternControllerProvider(7).notifier)
            .setDeletePattern(
              expected: reviewedPolicy,
              nameRegexDelete: nameRegexDelete,
            );
        expect(
          (await container.read(
            containerCleanupPolicyControllerProvider(7).future,
          ))!.nameRegexDelete,
          nameRegexDelete,
        );
        expect(repository.writes, [nameRegexDelete]);
        expect(repository.policy!.enabled, isTrue);
        expect(repository.policy!.cadence, '7d');
        sub.close();
      },
    );
  }
  test('failed update keeps cache and supports a real retry', () async {
    final sub = container.listen(
      containerCleanupPolicyControllerProvider(7),
      (_, _) {},
    );
    await container.read(containerCleanupPolicyControllerProvider(7).future);
    final command = container.read(
      cleanupPolicyDeletePatternControllerProvider(7).notifier,
    );
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(
      command.setDeletePattern(
        expected: reviewedPolicy,
        nameRegexDelete: 'v.+',
      ),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container.read(containerCleanupPolicyControllerProvider(7)).requireValue,
      reviewedPolicy,
    );
    expect(repository.reads, 2);
    repository.failure = null;
    await command.setDeletePattern(
      expected: reviewedPolicy,
      nameRegexDelete: 'v.+',
    );
    expect(repository.writes, ['v.+', 'v.+']);
    sub.close();
  });
  for (final current in [
    null,
    reviewedPolicy.copyWith(keepN: 25),
    reviewedPolicy.copyWith(enabled: false),
    reviewedPolicy.copyWith(nameRegexDelete: '.*'),
  ]) {
    test('stale or missing settings block writing $current', () async {
      repository.policy = current;
      await expectLater(
        container
            .read(cleanupPolicyDeletePatternControllerProvider(7).notifier)
            .setDeletePattern(expected: reviewedPolicy, nameRegexDelete: 'v.+'),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, isEmpty);
    });
  }
  test('next-run scheduler change alone is allowed', () async {
    repository.policy = reviewedPolicy.copyWith(nextRunAt: DateTime.utc(2030));
    await container
        .read(cleanupPolicyDeletePatternControllerProvider(7).notifier)
        .setDeletePattern(expected: reviewedPolicy, nameRegexDelete: 'v.+');
    expect(repository.writes, ['v.+']);
  });
  test(
    'invalid, unchanged or unreported policy rejects before reading',
    () async {
      final command = container.read(
        cleanupPolicyDeletePatternControllerProvider(7).notifier,
      );
      for (final nameRegexDelete in ['', '  ', 'release.+']) {
        await expectLater(
          command.setDeletePattern(
            expected: reviewedPolicy,
            nameRegexDelete: nameRegexDelete,
          ),
          throwsArgumentError,
        );
      }
      await expectLater(
        command.setDeletePattern(
          expected: const ContainerCleanupPolicy(),
          nameRegexDelete: 'v.+',
        ),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test(
    'unknown current delete pattern requires explicit supported replacement',
    () async {
      final unknown = reviewedPolicy.copyWith(
        nameRegexDelete: '(future-pattern)',
      );
      repository.policy = unknown;
      await container
          .read(cleanupPolicyDeletePatternControllerProvider(7).notifier)
          .setDeletePattern(expected: unknown, nameRegexDelete: 'v.+');
      expect(repository.writes, ['v.+']);
    },
  );
  test('unreported deletion criteria cannot change scheduling', () async {
    final incomplete = reviewedPolicy.copyWith(nameRegexDelete: null);
    repository.policy = incomplete;
    await expectLater(
      container
          .read(cleanupPolicyDeletePatternControllerProvider(7).notifier)
          .setDeletePattern(expected: incomplete, nameRegexDelete: 'v.+'),
      throwsArgumentError,
    );
    expect(repository.writes, isEmpty);
  });
  test('pending command blocks duplicates', () async {
    repository.pending = Completer<void>();
    final command = container.read(
      cleanupPolicyDeletePatternControllerProvider(7).notifier,
    );
    final first = command.setDeletePattern(
      expected: reviewedPolicy,
      nameRegexDelete: 'v.+',
    );
    await expectLater(
      command.setDeletePattern(expected: reviewedPolicy, nameRegexDelete: '.*'),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, ['v.+']);
    repository.pending!.complete();
    await first;
  });
  test(
    'legacy effective pattern is confirmed and replaced only in modern field',
    () async {
      final legacy = reviewedPolicy.copyWith(
        nameRegexDelete: null,
        nameRegex: 'legacy.+',
      );
      repository.policy = legacy;
      final command = container.read(
        cleanupPolicyDeletePatternControllerProvider(7).notifier,
      );
      await expectLater(
        command.setDeletePattern(expected: legacy, nameRegexDelete: 'legacy.+'),
        throwsArgumentError,
      );
      await command.setDeletePattern(expected: legacy, nameRegexDelete: 'v.+');
      expect(repository.writes, ['v.+']);
      expect(repository.policy!.nameRegex, 'legacy.+');
      expect(repository.policy!.nameRegexKeep, 'stable');
    },
  );
}
