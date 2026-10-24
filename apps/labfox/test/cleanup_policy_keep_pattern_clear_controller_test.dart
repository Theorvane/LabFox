import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_keep_pattern_clear_controller.dart';
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

class KeepPatternClearRepository extends ContainerRegistryRepository {
  KeepPatternClearRepository()
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
  int writes = 0;
  @override
  Future<ContainerCleanupPolicy?> cleanupPolicy(int projectId) async {
    reads++;
    if (readFailure != null) throw readFailure!;
    return policy;
  }

  @override
  Future<void> clearCleanupPolicyKeepPattern(int projectId) async {
    writes++;
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    policy = policy!.copyWith(nameRegexKeep: '');
  }
}

void main() {
  late KeepPatternClearRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = KeepPatternClearRepository();
    container = ProviderContainer(
      overrides: [
        containerRegistryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> clear(ContainerCleanupPolicy expected) => container
      .read(cleanupPolicyKeepPatternClearControllerProvider(7).notifier)
      .clearKeepPattern(expected: expected);

  test('clears only keep pattern and refreshes after acceptance', () async {
    final sub = container.listen(
      containerCleanupPolicyControllerProvider(7),
      (_, _) {},
    );
    await container.read(containerCleanupPolicyControllerProvider(7).future);
    await clear(reviewedPolicy);
    expect(repository.writes, 1);
    expect(repository.policy, reviewedPolicy.copyWith(nameRegexKeep: ''));
    expect(
      (await container.read(
        containerCleanupPolicyControllerProvider(7).future,
      ))!.nameRegexKeep,
      '',
    );
    sub.close();
  });
  test('failure keeps cache and supports a real retry', () async {
    final sub = container.listen(
      containerCleanupPolicyControllerProvider(7),
      (_, _) {},
    );
    await container.read(containerCleanupPolicyControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(
      clear(reviewedPolicy),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(
      container.read(containerCleanupPolicyControllerProvider(7)).requireValue,
      reviewedPolicy,
    );
    repository.failure = null;
    await clear(reviewedPolicy);
    expect(repository.writes, 2);
    sub.close();
  });
  for (final expected in [
    reviewedPolicy.copyWith(nameRegexKeep: null),
    reviewedPolicy.copyWith(nameRegexKeep: ''),
    reviewedPolicy.copyWith(enabled: null),
    reviewedPolicy.copyWith(cadence: null),
    reviewedPolicy.copyWith(keepN: null),
    reviewedPolicy.copyWith(olderThan: null),
    reviewedPolicy.copyWith(nameRegexDelete: null),
  ]) {
    test(
      'unreported criteria or already empty pattern cannot clear $expected',
      () async {
        repository.policy = expected;
        await expectLater(clear(expected), throwsArgumentError);
        expect(repository.reads, 0);
        expect(repository.writes, 0);
      },
    );
  }
  for (final current in [
    null,
    reviewedPolicy.copyWith(nameRegexKeep: 'main'),
    reviewedPolicy.copyWith(nameRegexKeep: ''),
    reviewedPolicy.copyWith(enabled: false),
    reviewedPolicy.copyWith(keepN: 25),
  ]) {
    test('stale policy blocks clearing $current', () async {
      repository.policy = current;
      await expectLater(
        clear(reviewedPolicy),
        throwsA(isA<GitLabConflictException>()),
      );
      expect(repository.writes, 0);
    });
  }
  test('scheduler-only changes do not block confirmation', () async {
    repository.policy = reviewedPolicy.copyWith(nextRunAt: DateTime.utc(2030));
    await clear(reviewedPolicy);
    expect(repository.writes, 1);
  });
  test('legacy deletion criteria stay unchanged', () async {
    final policy = reviewedPolicy.copyWith(
      nameRegexDelete: null,
      nameRegex: 'legacy.+',
    );
    repository.policy = policy;
    await clear(policy);
    expect(repository.policy, policy.copyWith(nameRegexKeep: ''));
  });
  test(
    'unknown exact nonblank keep pattern can be explicitly cleared',
    () async {
      final policy = reviewedPolicy.copyWith(
        nameRegexKeep: r' (future-pattern) ',
      );
      repository.policy = policy;
      await clear(policy);
      expect(repository.writes, 1);
      expect(repository.policy!.nameRegexDelete, 'release.+');
    },
  );
  test('failed re-read does not write', () async {
    repository.readFailure = const GitLabForbiddenException('private');
    await expectLater(
      clear(reviewedPolicy),
      throwsA(isA<GitLabForbiddenException>()),
    );
    expect(repository.writes, 0);
  });
  test('pending command rejects duplicate writes', () async {
    repository.pending = Completer<void>();
    final pending = clear(reviewedPolicy);
    await Future<void>.delayed(Duration.zero);
    await expectLater(clear(reviewedPolicy), throwsStateError);
    expect(repository.writes, 1);
    repository.pending!.complete();
    await pending;
  });
}
