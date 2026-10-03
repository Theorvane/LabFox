import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_activation_controller.dart';
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

class ActivationRepository extends ContainerRegistryRepository {
  ActivationRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ContainerCleanupPolicy? policy = reviewedPolicy;
  Object? failure;
  Object? readFailure;
  Completer<ContainerCleanupPolicy?>? readPending;
  Completer<void>? pending;
  int reads = 0;
  final writes = <bool>[];
  @override
  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async {
    expectSync(projectId, 7);
    reads++;
    if (readFailure != null) throw readFailure!;
    return readPending == null ? policy : readPending!.future;
  }

  @override
  Future<void> setCleanupPolicyEnabled(
    int projectId, {
    required bool enabled,
  }) async {
    expectSync(projectId, 7);
    writes.add(enabled);
    if (failure != null) throw failure!;
    await pending?.future;
    policy = policy?.copyWith(enabled: enabled);
  }
}

void main() {
  test(
    'unreported keep pattern blocks deletion expansion before reading',
    () async {
      final repository = ActivationRepository();
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
            .read(cleanupPolicyActivationControllerProvider(7).notifier)
            .setEnabled(expected: expected, enabled: true),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test('explicit empty keep pattern is reported', () {
    expect(
      canEnableCleanupPolicy(reviewedPolicy.copyWith(nameRegexKeep: '')),
      isTrue,
    );
  });

  test('cannot enable a policy with unreported retention criteria', () async {
    final repository = ActivationRepository();
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
          .read(cleanupPolicyActivationControllerProvider(7).notifier)
          .setEnabled(
            expected: reviewedPolicy.copyWith(enabled: false, keepN: null),
            enabled: true,
          ),
      throwsArgumentError,
    );
    expect(repository.writes, isEmpty);
  });
  late ActivationRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ActivationRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  for (final enabled in [true, false]) {
    test(
      'sets only requested status $enabled and refreshes after acceptance',
      () async {
        repository.policy = reviewedPolicy.copyWith(enabled: !enabled);
        final provider = containerCleanupPolicyControllerProvider(7);
        final expected = (await container.read(provider.future))!;
        await container
            .read(cleanupPolicyActivationControllerProvider(7).notifier)
            .setEnabled(expected: expected, enabled: enabled);
        expect((await container.read(provider.future))!.enabled, enabled);
        expect(repository.writes, [enabled]);
        expect(repository.reads, 3);
        expect(repository.policy!.keepN, expected.keepN);
        expect(repository.policy!.nameRegexDelete, expected.nameRegexDelete);
      },
    );
  }
  test('failure keeps read cache and allows a real retry', () async {
    final provider = containerCleanupPolicyControllerProvider(7);
    final expected = (await container.read(provider.future))!;
    final command = container.read(
      cleanupPolicyActivationControllerProvider(7).notifier,
    );
    repository.failure = const GitLabForbiddenException(
      'private',
      statusCode: 403,
    );
    await expectLater(
      command.setEnabled(expected: expected, enabled: false),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(container.read(provider).requireValue, expected);
    expect(repository.reads, 2);
    repository.failure = null;
    await command.setEnabled(expected: expected, enabled: false);
    expect(repository.writes, [false, false]);
  });
  test('blocks duplicate commands before repository resolution', () async {
    repository.pending = Completer<void>();
    final command = container.read(
      cleanupPolicyActivationControllerProvider(7).notifier,
    );
    final first = command.setEnabled(expected: reviewedPolicy, enabled: false);
    await expectLater(
      command.setEnabled(expected: reviewedPolicy, enabled: false),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, [false]);
    repository.pending!.complete();
    await first;
  });
  for (final policy in [
    null,
    const ContainerCleanupPolicy(),
    reviewedPolicy.copyWith(keepN: 25),
    reviewedPolicy.copyWith(enabled: false),
  ]) {
    test('rejects stale or unreported policy $policy before writing', () async {
      repository.policy = policy;
      await expectLater(
        container
            .read(cleanupPolicyActivationControllerProvider(7).notifier)
            .setEnabled(expected: reviewedPolicy, enabled: false),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, isEmpty);
    });
  }
  test(
    'scheduler next-run changes alone are not a settings conflict',
    () async {
      repository.policy = reviewedPolicy.copyWith(
        nextRunAt: DateTime.utc(2026, 10, 1),
      );
      await container
          .read(cleanupPolicyActivationControllerProvider(7).notifier)
          .setEnabled(expected: reviewedPolicy, enabled: false);
      expect(repository.writes, [false]);
    },
  );
  test(
    'unknown reviewed status cannot be enabled and no-op cannot be sent',
    () async {
      final command = container.read(
        cleanupPolicyActivationControllerProvider(7).notifier,
      );
      await expectLater(
        command.setEnabled(
          expected: const ContainerCleanupPolicy(),
          enabled: true,
        ),
        throwsArgumentError,
      );
      await expectLater(
        command.setEnabled(expected: reviewedPolicy, enabled: true),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test('missing account fails before reading or writing policy', () async {
    final empty = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(empty.dispose);
    await expectLater(
      empty
          .read(cleanupPolicyActivationControllerProvider(7).notifier)
          .setEnabled(expected: reviewedPolicy, enabled: false),
      throwsStateError,
    );
    expect(repository.writes, isEmpty);
  });
}
