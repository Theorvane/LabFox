import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/container_registry/data/container_registry_repository.dart';
import 'package:labfox/features/container_registry/presentation/controllers/cleanup_policy_create_controller.dart';
import 'package:labfox/features/container_registry/presentation/controllers/container_registry_controllers.dart';

const absentPolicy = ContainerCleanupPolicySnapshot(reported: true);

class PolicyCreateRepository extends ContainerRegistryRepository {
  PolicyCreateRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  ContainerCleanupPolicySnapshot snapshot = absentPolicy;
  Object? failure;
  Object? readFailure;
  Completer<void>? pending;
  Completer<void>? pendingRead;
  int reads = 0;
  final writes = <ContainerCleanupPolicy>[];
  @override
  Future<ContainerCleanupPolicySnapshot> cleanupPolicySnapshot(
    int projectId,
  ) async {
    reads++;
    if (pendingRead != null) await pendingRead!.future;
    if (readFailure != null) throw readFailure!;
    return snapshot;
  }

  @override
  Future<void> createCleanupPolicy(
    int projectId, {
    bool enabled = false,
    required String cadence,
    required int keepN,
    required String olderThan,
    required String nameRegexDelete,
    required String nameRegexKeep,
  }) async {
    final policy = ContainerCleanupPolicy(
      enabled: enabled,
      cadence: cadence,
      keepN: keepN,
      olderThan: olderThan,
      nameRegexDelete: nameRegexDelete,
      nameRegexKeep: nameRegexKeep,
    );
    writes.add(policy);
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
    snapshot = ContainerCleanupPolicySnapshot(reported: true, policy: policy);
  }
}

void main() {
  late PolicyCreateRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = PolicyCreateRepository();
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
    ContainerCleanupPolicySnapshot expected = absentPolicy,
    bool enabled = false,
    String cadence = '1month',
    int keepN = 100,
    String olderThan = '365d',
    String delete = 'release.+',
    String keep = '.*',
  }) => container
      .read(cleanupPolicyCreateControllerProvider(7).notifier)
      .create(
        expected: expected,
        enabled: enabled,
        cadence: cadence,
        keepN: keepN,
        olderThan: olderThan,
        nameRegexDelete: delete,
        nameRegexKeep: keep,
      );

  test(
    'creates disabled criteria and refreshes only after acceptance',
    () async {
      final sub = container.listen(
        cleanupPolicySnapshotControllerProvider(7),
        (_, _) {},
      );
      await container.read(cleanupPolicySnapshotControllerProvider(7).future);
      await create(delete: r' release\..+ ', keep: '');
      expect(repository.writes.single.enabled, isFalse);
      expect(repository.writes.single.nameRegexDelete, r' release\..+ ');
      expect(repository.writes.single.nameRegexKeep, '');
      expect(
        (await container.read(
          cleanupPolicySnapshotControllerProvider(7).future,
        )).policy,
        repository.writes.single,
      );
      sub.close();
    },
  );
  test(
    'explicit activation sends enabled criteria after absence preflight',
    () async {
      await create(enabled: true, delete: r' release\..+ ', keep: '');
      expect(repository.reads, 1);
      expect(repository.writes.single.enabled, isTrue);
      expect(repository.writes.single.nameRegexDelete, r' release\..+ ');
      expect(repository.writes.single.nameRegexKeep, '');
    },
  );
  for (final expected in [
    const ContainerCleanupPolicySnapshot(reported: false),
    const ContainerCleanupPolicySnapshot(
      reported: true,
      policy: ContainerCleanupPolicy(),
    ),
    const ContainerCleanupPolicySnapshot(
      reported: true,
      policy: ContainerCleanupPolicy(enabled: false),
    ),
  ]) {
    test(
      'existing or unreported expected policy blocks creation $expected',
      () async {
        repository.snapshot = expected;
        await expectLater(create(expected: expected), throwsArgumentError);
        expect(repository.reads, 0);
        expect(repository.writes, isEmpty);
      },
    );
    test('changed current policy blocks stale absence $expected', () async {
      repository.snapshot = expected;
      await expectLater(create(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
    });
  }
  for (final delete in ['', '   ']) {
    test('blank delete pattern cannot create $delete', () async {
      await expectLater(create(delete: delete), throwsArgumentError);
      expect(repository.reads, 0);
      expect(repository.writes, isEmpty);
    });
  }
  test('unsupported cadence rejects before any read', () async {
    await expectLater(create(cadence: 'future'), throwsArgumentError);
    expect(repository.reads, 0);
  });
  test('unsupported count rejects before any read', () async {
    await expectLater(create(keepN: 0), throwsArgumentError);
    expect(repository.reads, 0);
  });
  test('unsupported age rejects before any read', () async {
    await expectLater(create(olderThan: 'future'), throwsArgumentError);
    expect(repository.reads, 0);
  });
  test('write failure retains reader and permits real retry', () async {
    final sub = container.listen(
      cleanupPolicySnapshotControllerProvider(7),
      (_, _) {},
    );
    await container.read(cleanupPolicySnapshotControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(create(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container.read(cleanupPolicySnapshotControllerProvider(7)).requireValue,
      absentPolicy,
    );
    repository.failure = null;
    await create();
    expect(repository.writes, hasLength(2));
    sub.close();
  });
  test('re-read failure never writes', () async {
    repository.readFailure = const GitLabForbiddenException('private');
    await expectLater(create(), throwsA(isA<GitLabForbiddenException>()));
    expect(repository.writes, isEmpty);
  });
  test('session change during preflight prevents enabled dispatch', () async {
    repository.pendingRead = Completer<void>();
    final pending = create(enabled: true);
    final expectation = expectLater(
      pending,
      throwsA(isA<GitLabConflictException>()),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(containerRegistryRepositoryProvider);
    await container.read(containerRegistryRepositoryProvider.future);
    repository.pendingRead!.complete();
    await expectation;
    expect(repository.writes, isEmpty);
  });
  test(
    'session change during write cannot report acceptance or refresh',
    () async {
      repository.pending = Completer<void>();
      final pending = create(enabled: true);
      final expectation = expectLater(
        pending,
        throwsA(isA<GitLabConflictException>()),
      );
      await Future<void>.delayed(Duration.zero);
      container.invalidate(containerRegistryRepositoryProvider);
      await container.read(containerRegistryRepositoryProvider.future);
      repository.pending!.complete();
      await expectation;
      expect(repository.writes, hasLength(1));
      expect(
        container.read(cleanupPolicyCreateControllerProvider(7)).isLoading,
        isFalse,
      );
    },
  );
  test('pending command blocks duplicate creation', () async {
    repository.pending = Completer<void>();
    final pending = create();
    await Future<void>.delayed(Duration.zero);
    await expectLater(create(), throwsStateError);
    expect(repository.writes, hasLength(1));
    repository.pending!.complete();
    await pending;
  });
}
