import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_cadence_controller.dart';
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

class CadenceRepository extends ContainerRegistryRepository {
  CadenceRepository()
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
  Future<void> setCleanupPolicyCadence(
    int projectId, {
    required String cadence,
  }) async {
    writes.add(cadence);
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    policy = policy!.copyWith(cadence: cadence);
  }
}

void main() {
  late CadenceRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = CadenceRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  for (final cadence in ['1d', '14d', '1month', '3month']) {
    test(
      'updates only cadence $cadence and refreshes after acceptance',
      () async {
        final sub = container.listen(
          containerCleanupPolicyControllerProvider(7),
          (_, _) {},
        );
        await container.read(
          containerCleanupPolicyControllerProvider(7).future,
        );
        await container
            .read(cleanupPolicyCadenceControllerProvider(7).notifier)
            .setCadence(expected: reviewedPolicy, cadence: cadence);
        expect(
          (await container.read(
            containerCleanupPolicyControllerProvider(7).future,
          ))!.cadence,
          cadence,
        );
        expect(repository.writes, [cadence]);
        expect(repository.policy!.enabled, isTrue);
        expect(repository.policy!.keepN, 10);
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
      cleanupPolicyCadenceControllerProvider(7).notifier,
    );
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(
      command.setCadence(expected: reviewedPolicy, cadence: '1d'),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container.read(containerCleanupPolicyControllerProvider(7)).requireValue,
      reviewedPolicy,
    );
    expect(repository.reads, 2);
    repository.failure = null;
    await command.setCadence(expected: reviewedPolicy, cadence: '1d');
    expect(repository.writes, ['1d', '1d']);
    sub.close();
  });
  for (final current in [
    null,
    reviewedPolicy.copyWith(keepN: 25),
    reviewedPolicy.copyWith(enabled: false),
    reviewedPolicy.copyWith(cadence: '14d'),
  ]) {
    test('stale or missing settings block writing $current', () async {
      repository.policy = current;
      await expectLater(
        container
            .read(cleanupPolicyCadenceControllerProvider(7).notifier)
            .setCadence(expected: reviewedPolicy, cadence: '1d'),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, isEmpty);
    });
  }
  test('next-run scheduler change alone is allowed', () async {
    repository.policy = reviewedPolicy.copyWith(nextRunAt: DateTime.utc(2030));
    await container
        .read(cleanupPolicyCadenceControllerProvider(7).notifier)
        .setCadence(expected: reviewedPolicy, cadence: '1d');
    expect(repository.writes, ['1d']);
  });
  test(
    'invalid, unchanged or unreported policy rejects before reading',
    () async {
      final command = container.read(
        cleanupPolicyCadenceControllerProvider(7).notifier,
      );
      for (final cadence in ['', '2d', '7d']) {
        await expectLater(
          command.setCadence(expected: reviewedPolicy, cadence: cadence),
          throwsArgumentError,
        );
      }
      await expectLater(
        command.setCadence(
          expected: const ContainerCleanupPolicy(),
          cadence: '1d',
        ),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test(
    'unknown current cadence requires explicit supported replacement',
    () async {
      final unknown = reviewedPolicy.copyWith(cadence: 'future');
      repository.policy = unknown;
      await container
          .read(cleanupPolicyCadenceControllerProvider(7).notifier)
          .setCadence(expected: unknown, cadence: '1d');
      expect(repository.writes, ['1d']);
    },
  );
  test('unreported deletion criteria cannot change scheduling', () async {
    final incomplete = reviewedPolicy.copyWith(keepN: null);
    repository.policy = incomplete;
    await expectLater(
      container
          .read(cleanupPolicyCadenceControllerProvider(7).notifier)
          .setCadence(expected: incomplete, cadence: '1d'),
      throwsArgumentError,
    );
    expect(repository.writes, isEmpty);
  });
  test('pending command blocks duplicates', () async {
    repository.pending = Completer<void>();
    final command = container.read(
      cleanupPolicyCadenceControllerProvider(7).notifier,
    );
    final first = command.setCadence(expected: reviewedPolicy, cadence: '1d');
    await expectLater(
      command.setCadence(expected: reviewedPolicy, cadence: '14d'),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, ['1d']);
    repository.pending!.complete();
    await first;
  });
}
