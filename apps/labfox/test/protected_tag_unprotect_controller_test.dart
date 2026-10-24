import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_tags/presentation/controllers/protected_tags_controller.dart';
import 'protected_tag_unprotect_test.dart'
    show UnprotectRepository, unprotectRule;

void main() {
  late UnprotectRepository repository;
  late ProviderContainer container;
  const key = ProtectedTagRef(projectId: 7, name: 'release/*');
  setUp(() {
    repository = UnprotectRepository();
    container = ProviderContainer(
      overrides: [
        protectedTagsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> remove({ProtectedTag expected = unprotectRule}) => container
      .read(protectedTagUnprotectControllerProvider(key).notifier)
      .unprotect(expected: expected);
  test(
    're-reads frozen rule, removes once and refreshes cached list',
    () async {
      final sub = container.listen(
        protectedTagsControllerProvider(7),
        (_, _) {},
      );
      await container.read(protectedTagsControllerProvider(7).future);
      await remove();
      expect(repository.reads, 1);
      expect(repository.deletes, 1);
      expect(
        (await container.read(protectedTagsControllerProvider(7).future)).items,
        isEmpty,
      );
      sub.close();
    },
  );
  for (final rule in [
    unprotectRule.copyWith(name: 'other'),
    unprotectRule.copyWith(createAccessLevels: []),
    unprotectRule.copyWith(
      createAccessLevels: [const ProtectedBranchAccess(id: 1, accessLevel: 30)],
    ),
  ]) {
    test('changed frozen name or permissions blocks removal $rule', () async {
      repository.rule = rule;
      await expectLater(remove(), throwsA(isA<GitLabConflictException>()));
      expect(repository.deletes, 0);
    });
  }
  test('missing rule cannot authorize any removal', () async {
    repository.removed = true;
    await expectLater(remove(), throwsA(isA<GitLabNotFoundException>()));
    expect(repository.deletes, 0);
  });
  test('wrong expected identity rejects without reading', () async {
    await expectLater(
      remove(expected: unprotectRule.copyWith(name: 'wrong')),
      throwsArgumentError,
    );
    expect(repository.reads, 0);
    expect(repository.deletes, 0);
  });
  test('failure retains list and a retry re-reads the rule', () async {
    final sub = container.listen(protectedTagsControllerProvider(7), (_, _) {});
    await container.read(protectedTagsControllerProvider(7).future);
    repository.failure = const GitLabForbiddenException('private');
    await expectLater(remove(), throwsA(isA<GitLabForbiddenException>()));
    expect(
      container.read(protectedTagsControllerProvider(7)).requireValue.items,
      [unprotectRule],
    );
    expect(repository.lists, 1);
    repository.failure = null;
    await remove();
    expect(repository.reads, 2);
    expect(repository.deletes, 2);
    sub.close();
  });
  test('duplicates blocked while preflight is pending', () async {
    repository.pendingRead = Completer<void>();
    final pending = remove();
    await Future<void>.delayed(Duration.zero);
    await expectLater(remove(), throwsStateError);
    repository.pendingRead!.complete();
    await pending;
    expect(repository.deletes, 1);
  });
  for (final duringWrite in [false, true]) {
    test(
      'session change isolates ${duringWrite ? "completion" : "preflight"}',
      () async {
        final gate = Completer<void>();
        if (duringWrite) {
          repository.pendingDelete = gate;
        } else {
          repository.pendingRead = gate;
        }
        final pending = remove();
        final expectation = expectLater(
          pending,
          throwsA(isA<GitLabConflictException>()),
        );
        await Future<void>.delayed(Duration.zero);
        container.invalidate(protectedTagsRepositoryProvider);
        await container.read(protectedTagsRepositoryProvider.future);
        gate.complete();
        await expectation;
        expect(repository.deletes, duringWrite ? 1 : 0);
        expect(
          container
              .read(protectedTagUnprotectControllerProvider(key))
              .isLoading,
          isFalse,
        );
      },
    );
  }
}
