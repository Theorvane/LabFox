import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_keep_pattern_controller.dart';
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

class KeepPatternRepository extends ContainerRegistryRepository {
  KeepPatternRepository()
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
  Future<void> setCleanupPolicyKeepPattern(
    int projectId, {
    required String nameRegexKeep,
  }) async {
    writes.add(nameRegexKeep);
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    policy = policy!.copyWith(nameRegexKeep: nameRegexKeep);
  }
}

void main() {
  late KeepPatternRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = KeepPatternRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  for (final nameRegexKeep in ['v.+', '.*', ' release .+ ']) {
    test(
      'updates only keep pattern $nameRegexKeep and refreshes after acceptance',
      () async {
        final sub = container.listen(
          containerCleanupPolicyControllerProvider(7),
          (_, _) {},
        );
        await container.read(
          containerCleanupPolicyControllerProvider(7).future,
        );
        await container
            .read(cleanupPolicyKeepPatternControllerProvider(7).notifier)
            .setKeepPattern(
              expected: reviewedPolicy,
              nameRegexKeep: nameRegexKeep,
            );
        expect(
          (await container.read(
            containerCleanupPolicyControllerProvider(7).future,
          ))!.nameRegexKeep,
          nameRegexKeep,
        );
        expect(repository.writes, [nameRegexKeep]);
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
      cleanupPolicyKeepPatternControllerProvider(7).notifier,
    );
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(
      command.setKeepPattern(expected: reviewedPolicy, nameRegexKeep: 'v.+'),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container.read(containerCleanupPolicyControllerProvider(7)).requireValue,
      reviewedPolicy,
    );
    expect(repository.reads, 2);
    repository.failure = null;
    await command.setKeepPattern(
      expected: reviewedPolicy,
      nameRegexKeep: 'v.+',
    );
    expect(repository.writes, ['v.+', 'v.+']);
    sub.close();
  });
  for (final current in [
    null,
    reviewedPolicy.copyWith(keepN: 25),
    reviewedPolicy.copyWith(enabled: false),
    reviewedPolicy.copyWith(nameRegexKeep: '.*'),
  ]) {
    test('stale or missing settings block writing $current', () async {
      repository.policy = current;
      await expectLater(
        container
            .read(cleanupPolicyKeepPatternControllerProvider(7).notifier)
            .setKeepPattern(expected: reviewedPolicy, nameRegexKeep: 'v.+'),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, isEmpty);
    });
  }
  test('next-run scheduler change alone is allowed', () async {
    repository.policy = reviewedPolicy.copyWith(nextRunAt: DateTime.utc(2030));
    await container
        .read(cleanupPolicyKeepPatternControllerProvider(7).notifier)
        .setKeepPattern(expected: reviewedPolicy, nameRegexKeep: 'v.+');
    expect(repository.writes, ['v.+']);
  });
  test(
    'invalid, unchanged or unreported policy rejects before reading',
    () async {
      final command = container.read(
        cleanupPolicyKeepPatternControllerProvider(7).notifier,
      );
      for (final nameRegexKeep in ['', '  ', 'stable']) {
        await expectLater(
          command.setKeepPattern(
            expected: reviewedPolicy,
            nameRegexKeep: nameRegexKeep,
          ),
          throwsArgumentError,
        );
      }
      await expectLater(
        command.setKeepPattern(
          expected: const ContainerCleanupPolicy(),
          nameRegexKeep: 'v.+',
        ),
        throwsArgumentError,
      );
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    },
  );
  test('unknown current keep pattern requires explicit replacement', () async {
    final unknown = reviewedPolicy.copyWith(nameRegexKeep: '(future-pattern)');
    repository.policy = unknown;
    await container
        .read(cleanupPolicyKeepPatternControllerProvider(7).notifier)
        .setKeepPattern(expected: unknown, nameRegexKeep: 'v.+');
    expect(repository.writes, ['v.+']);
  });
  test('unreported keep pattern cannot be replaced', () async {
    final incomplete = reviewedPolicy.copyWith(nameRegexKeep: null);
    repository.policy = incomplete;
    await expectLater(
      container
          .read(cleanupPolicyKeepPatternControllerProvider(7).notifier)
          .setKeepPattern(expected: incomplete, nameRegexKeep: 'v.+'),
      throwsArgumentError,
    );
    expect(repository.writes, isEmpty);
  });
  test('pending command blocks duplicates', () async {
    repository.pending = Completer<void>();
    final command = container.read(
      cleanupPolicyKeepPatternControllerProvider(7).notifier,
    );
    final first = command.setKeepPattern(
      expected: reviewedPolicy,
      nameRegexKeep: 'v.+',
    );
    await expectLater(
      command.setKeepPattern(expected: reviewedPolicy, nameRegexKeep: '.*'),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, ['v.+']);
    repository.pending!.complete();
    await first;
  });
  test(
    'legacy delete pattern stays unchanged while keep pattern is replaced',
    () async {
      final legacy = reviewedPolicy.copyWith(
        nameRegexDelete: null,
        nameRegex: 'legacy.+',
      );
      repository.policy = legacy;
      final command = container.read(
        cleanupPolicyKeepPatternControllerProvider(7).notifier,
      );
      await expectLater(
        command.setKeepPattern(expected: legacy, nameRegexKeep: 'stable'),
        throwsArgumentError,
      );
      await command.setKeepPattern(expected: legacy, nameRegexKeep: 'v.+');
      expect(repository.writes, ['v.+']);
      expect(repository.policy!.nameRegex, 'legacy.+');
      expect(repository.policy!.nameRegexDelete, isNull);
    },
  );
  test(
    'reported empty keep pattern can receive an explicit nonblank replacement',
    () async {
      final empty = reviewedPolicy.copyWith(nameRegexKeep: '');
      repository.policy = empty;
      await container
          .read(cleanupPolicyKeepPatternControllerProvider(7).notifier)
          .setKeepPattern(expected: empty, nameRegexKeep: 'stable');
      expect(repository.writes, ['stable']);
      expect(repository.policy!.nameRegexDelete, 'release.+');
    },
  );
}
