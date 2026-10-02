import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_tags/presentation/controllers/protected_tag_protect_controller.dart';
import 'package:labfox/features/protected_tags/presentation/controllers/protected_tags_controller.dart';

import 'protected_tag_protect_test.dart' show ProtectRepository;

void main() {
  late ProtectRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ProtectRepository();
    container = ProviderContainer(
      overrides: [
        protectedTagsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> create({String name = 'release/*', int role = 40}) => container
      .read(protectedTagProtectControllerProvider(7).notifier)
      .protect(name: name, createAccessLevel: role);
  for (final role in [0, 30, 40]) {
    test(
      'scans all pages, creates exact role $role, then refreshes list',
      () async {
        repository.pages[1] = const Paginated(
          items: [ProtectedTag(name: 'v*')],
          nextPage: 2,
        );
        repository.pages[2] = const Paginated(items: []);
        final sub = container.listen(
          protectedTagsControllerProvider(7),
          (_, _) {},
        );
        await container.read(protectedTagsControllerProvider(7).future);
        repository.reads.clear();
        await create(role: role);
        expect(repository.reads.take(2), [1, 2]);
        expect(repository.writes.single, (name: 'release/*', role: role));
        expect(
          (await container.read(
            protectedTagsControllerProvider(7).future,
          )).items.single.name,
          'release/*',
        );
        sub.close();
      },
    );
  }
  for (final page in [1, 2]) {
    test('duplicate on page $page blocks POST', () async {
      repository.pages[1] = Paginated(
        items: page == 1 ? [const ProtectedTag(name: 'release/*')] : [],
        nextPage: 2,
      );
      repository.pages[2] = Paginated(
        items: page == 2 ? [const ProtectedTag(name: 'release/*')] : [],
      );
      await expectLater(create(), throwsA(isA<GitLabConflictException>()));
      expect(repository.writes, isEmpty);
      expect(repository.reads, [1, 2]);
    });
  }
  test('repeated cursor blocks POST', () async {
    repository.pages[1] = const Paginated(items: [], nextPage: 2);
    repository.pages[2] = const Paginated(items: [], nextPage: 2);
    await expectLater(create(), throwsA(isA<GitLabServerException>()));
    expect(repository.writes, isEmpty);
  });
  test('duplicate names on separate pages block POST', () async {
    repository.pages[1] = const Paginated(
      items: [ProtectedTag(name: 'v*')],
      nextPage: 2,
    );
    repository.pages[2] = const Paginated(items: [ProtectedTag(name: 'v*')]);
    await expectLater(create(), throwsA(isA<GitLabServerException>()));
    expect(repository.writes, isEmpty);
  });
  for (final role in [-1, 10, 50]) {
    test('invalid role $role fails before read', () async {
      await expectLater(create(role: role), throwsArgumentError);
      expect(repository.reads, isEmpty);
      expect(repository.writes, isEmpty);
    });
  }
  test('blank name fails before read', () async {
    await expectLater(create(name: '  '), throwsArgumentError);
    expect(repository.reads, isEmpty);
  });
  test('read failure cannot dispatch', () async {
    repository.readFailure = const GitLabForbiddenException('private');
    await expectLater(create(), throwsA(isA<GitLabForbiddenException>()));
    expect(repository.writes, isEmpty);
  });
  test(
    'failed POST retains list and requires a fresh scan for retry',
    () async {
      final sub = container.listen(
        protectedTagsControllerProvider(7),
        (_, _) {},
      );
      await container.read(protectedTagsControllerProvider(7).future);
      repository.writeFailure = const GitLabConnectionException('private');
      await expectLater(create(), throwsA(isA<GitLabConnectionException>()));
      expect(
        container.read(protectedTagsControllerProvider(7)).requireValue.items,
        isEmpty,
      );
      repository.writeFailure = null;
      repository.reads.clear();
      await create();
      expect(repository.reads, contains(1));
      expect(repository.writes, hasLength(2));
      sub.close();
    },
  );
  test('malformed returned role cannot refresh or report acceptance', () async {
    repository.returned = const ProtectedTag(
      name: 'release/*',
      createAccessLevels: [ProtectedBranchAccess(accessLevel: 30)],
    );
    await expectLater(create(), throwsA(isA<GitLabServerException>()));
    expect(repository.writes, hasLength(1));
  });
  test('duplicate submission blocked while preflight pending', () async {
    repository.pendingRead = Completer<void>();
    final pending = create();
    await Future<void>.delayed(Duration.zero);
    await expectLater(create(), throwsStateError);
    repository.pendingRead!.complete();
    await pending;
    expect(repository.writes, hasLength(1));
  });
  for (final duringWrite in [false, true]) {
    test(
      'session change isolates ${duringWrite ? "completion" : "preflight"}',
      () async {
        final gate = Completer<void>();
        if (duringWrite) {
          repository.pendingWrite = gate;
        } else {
          repository.pendingRead = gate;
        }
        final pending = create();
        final expectation = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        container.invalidate(protectedTagsRepositoryProvider);
        await container.read(protectedTagsRepositoryProvider.future);
        gate.complete();
        await expectation;
        expect(repository.writes.length, duringWrite ? 1 : 0);
        expect(
          container.read(protectedTagProtectControllerProvider(7)).isLoading,
          isFalse,
        );
      },
    );
  }
}
