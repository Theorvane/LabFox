import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_age_controller.dart';
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

class AgeRepository extends ContainerRegistryRepository {
  AgeRepository()
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
  Future<void> setCleanupPolicyAge(
    int projectId, {
    required String olderThan,
  }) async {
    writes.add(olderThan);
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    policy = policy!.copyWith(olderThan: olderThan);
  }
}

void main() {
  late AgeRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = AgeRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  for (final olderThan in [
    '1d',
    '3d',
    '7d',
    '30d',
    '60d',
    '90d',
    '180d',
    '365d',
    '730d',
    '1095d',
  ]) {
    test(
      'updates only age limit $olderThan and refreshes after acceptance',
      () async {
        final sub = container.listen(
          containerCleanupPolicyControllerProvider(7),
          (_, _) {},
        );
        await container.read(
          containerCleanupPolicyControllerProvider(7).future,
        );
        await container
            .read(cleanupPolicyAgeControllerProvider(7).notifier)
            .setAge(expected: reviewedPolicy, olderThan: olderThan);
        expect(
          (await container.read(
            containerCleanupPolicyControllerProvider(7).future,
          ))!.olderThan,
          olderThan,
        );
        expect(repository.writes, [olderThan]);
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
      cleanupPolicyAgeControllerProvider(7).notifier,
    );
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(
      command.setAge(expected: reviewedPolicy, olderThan: '1d'),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container.read(containerCleanupPolicyControllerProvider(7)).requireValue,
      reviewedPolicy,
    );
    expect(repository.reads, 2);
    repository.failure = null;
    await command.setAge(expected: reviewedPolicy, olderThan: '1d');
    expect(repository.writes, ['1d', '1d']);
    sub.close();
  });
  for (final current in [
    null,
    reviewedPolicy.copyWith(keepN: 25),
    reviewedPolicy.copyWith(enabled: false),
    reviewedPolicy.copyWith(olderThan: '30d'),
  ]) {
    test('stale or missing settings block writing $current', () async {
      repository.policy = current;
      await expectLater(
        container
            .read(cleanupPolicyAgeControllerProvider(7).notifier)
            .setAge(expected: reviewedPolicy, olderThan: '1d'),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, isEmpty);
    });
  }
  test('next-run scheduler change alone is allowed', () async {
    repository.policy = reviewedPolicy.copyWith(nextRunAt: DateTime.utc(2030));
    await container
        .read(cleanupPolicyAgeControllerProvider(7).notifier)
        .setAge(expected: reviewedPolicy, olderThan: '1d');
    expect(repository.writes, ['1d']);
  });
  test(
    'invalid, unchanged or unreported policy rejects before reading',
    () async {
      final command = container.read(
        cleanupPolicyAgeControllerProvider(7).notifier,
      );
      for (final olderThan in ['', '0d', '2d', '14d']) {
        await expectLater(
          command.setAge(expected: reviewedPolicy, olderThan: olderThan),
          throwsArgumentError,
        );
      }
      await expectLater(
        command.setAge(
          expected: const ContainerCleanupPolicy(),
          olderThan: '1d',
        ),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test(
    'unknown current age limit requires explicit supported replacement',
    () async {
      final unknown = reviewedPolicy.copyWith(olderThan: 'future');
      repository.policy = unknown;
      await container
          .read(cleanupPolicyAgeControllerProvider(7).notifier)
          .setAge(expected: unknown, olderThan: '1d');
      expect(repository.writes, ['1d']);
    },
  );
  test('unreported deletion criteria cannot change scheduling', () async {
    final incomplete = reviewedPolicy.copyWith(olderThan: null);
    repository.policy = incomplete;
    await expectLater(
      container
          .read(cleanupPolicyAgeControllerProvider(7).notifier)
          .setAge(expected: incomplete, olderThan: '1d'),
      throwsArgumentError,
    );
    expect(repository.writes, isEmpty);
  });
  test('pending command blocks duplicates', () async {
    repository.pending = Completer<void>();
    final command = container.read(
      cleanupPolicyAgeControllerProvider(7).notifier,
    );
    final first = command.setAge(expected: reviewedPolicy, olderThan: '1d');
    await expectLater(
      command.setAge(expected: reviewedPolicy, olderThan: '30d'),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, ['1d']);
    repository.pending!.complete();
    await first;
  });
}
