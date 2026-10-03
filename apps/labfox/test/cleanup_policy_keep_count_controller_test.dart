import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_keep_count_controller.dart';
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

class KeepCountRepository extends ContainerRegistryRepository {
  KeepCountRepository()
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
  final writes = <int>[];
  @override
  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return policy;
  }

  @override
  Future<void> setCleanupPolicyKeepCount(
    int projectId, {
    required int keepN,
  }) async {
    writes.add(keepN);
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    policy = policy!.copyWith(keepN: keepN);
  }
}

void main() {
  test('unreported keep pattern blocks retention changes before reading', () async {
    final repository = KeepCountRepository()
      ..policy = reviewedPolicy.copyWith(nameRegexKeep: null);
    final container = ProviderContainer(overrides: [
      containerRegistryRepositoryProvider.overrideWith((ref) async => repository),
    ]);
    addTearDown(container.dispose);
    expect(canEditCleanupKeepCount(repository.policy), isFalse);
    await expectLater(
      container.read(cleanupPolicyKeepCountControllerProvider(7).notifier)
        .setKeepCount(expected: repository.policy!, keepN: 1),
      throwsArgumentError,
    );
    expect(repository.reads, 0);
    expect(repository.writes, isEmpty);
  });

  test('explicitly empty keep pattern permits confirmed retention changes', () async {
    final repository = KeepCountRepository()
      ..policy = reviewedPolicy.copyWith(nameRegexKeep: '');
    final container = ProviderContainer(overrides: [
      containerRegistryRepositoryProvider.overrideWith((ref) async => repository),
    ]);
    addTearDown(container.dispose);
    expect(canEditCleanupKeepCount(repository.policy), isTrue);
    await container.read(cleanupPolicyKeepCountControllerProvider(7).notifier)
      .setKeepCount(expected: repository.policy!, keepN: 1);
    expect(repository.writes, [1]);
  });

  late KeepCountRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = KeepCountRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  for (final keepN in [1, 5, 25, 50, 100]) {
    test(
      'updates only retention count $keepN and refreshes after acceptance',
      () async {
        final sub = container.listen(
          containerCleanupPolicyControllerProvider(7),
          (_, _) {},
        );
        await container.read(
          containerCleanupPolicyControllerProvider(7).future,
        );
        await container
            .read(cleanupPolicyKeepCountControllerProvider(7).notifier)
            .setKeepCount(expected: reviewedPolicy, keepN: keepN);
        expect(
          (await container.read(
            containerCleanupPolicyControllerProvider(7).future,
          ))!.keepN,
          keepN,
        );
        expect(repository.writes, [keepN]);
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
      cleanupPolicyKeepCountControllerProvider(7).notifier,
    );
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(
      command.setKeepCount(expected: reviewedPolicy, keepN: 1),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container.read(containerCleanupPolicyControllerProvider(7)).requireValue,
      reviewedPolicy,
    );
    expect(repository.reads, 2);
    repository.failure = null;
    await command.setKeepCount(expected: reviewedPolicy, keepN: 1);
    expect(repository.writes, [1, 1]);
    sub.close();
  });
  for (final current in [
    null,
    reviewedPolicy.copyWith(olderThan: '30d'),
    reviewedPolicy.copyWith(enabled: false),
    reviewedPolicy.copyWith(keepN: 25),
  ]) {
    test('stale or missing settings block writing $current', () async {
      repository.policy = current;
      await expectLater(
        container
            .read(cleanupPolicyKeepCountControllerProvider(7).notifier)
            .setKeepCount(expected: reviewedPolicy, keepN: 1),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, isEmpty);
    });
  }
  test('next-run scheduler change alone is allowed', () async {
    repository.policy = reviewedPolicy.copyWith(nextRunAt: DateTime.utc(2030));
    await container
        .read(cleanupPolicyKeepCountControllerProvider(7).notifier)
        .setKeepCount(expected: reviewedPolicy, keepN: 1);
    expect(repository.writes, [1]);
  });
  test(
    'invalid, unchanged or unreported policy rejects before reading',
    () async {
      final command = container.read(
        cleanupPolicyKeepCountControllerProvider(7).notifier,
      );
      for (final keepN in [0, -1, 2, 10]) {
        await expectLater(
          command.setKeepCount(expected: reviewedPolicy, keepN: keepN),
          throwsArgumentError,
        );
      }
      await expectLater(
        command.setKeepCount(
          expected: const ContainerCleanupPolicy(),
          keepN: 1,
        ),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test(
    'unknown current retention count requires explicit supported replacement',
    () async {
      final unknown = reviewedPolicy.copyWith(keepN: 999);
      repository.policy = unknown;
      await container
          .read(cleanupPolicyKeepCountControllerProvider(7).notifier)
          .setKeepCount(expected: unknown, keepN: 1);
      expect(repository.writes, [1]);
    },
  );
  test('unreported deletion criteria cannot change scheduling', () async {
    final incomplete = reviewedPolicy.copyWith(keepN: null);
    repository.policy = incomplete;
    await expectLater(
      container
          .read(cleanupPolicyKeepCountControllerProvider(7).notifier)
          .setKeepCount(expected: incomplete, keepN: 1),
      throwsArgumentError,
    );
    expect(repository.writes, isEmpty);
  });
  test('pending command blocks duplicates', () async {
    repository.pending = Completer<void>();
    final command = container.read(
      cleanupPolicyKeepCountControllerProvider(7).notifier,
    );
    final first = command.setKeepCount(expected: reviewedPolicy, keepN: 1);
    await expectLater(
      command.setKeepCount(expected: reviewedPolicy, keepN: 25),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, [1]);
    repository.pending!.complete();
    await first;
  });
}
