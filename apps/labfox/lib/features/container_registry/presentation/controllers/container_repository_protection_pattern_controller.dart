import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';
import 'container_repository_protection_controller.dart';

class ContainerRepositoryProtectionPatternController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> savePattern({
    required ContainerRepositoryProtectionRule expected,
    required String pattern,
  }) async {
    if (state.isLoading) throw StateError('Pattern update already pending');
    if (arg <= 0 ||
        expected.projectId != arg ||
        expected.id <= 0 ||
        expected.repositoryPathPattern.isEmpty ||
        pattern.trim().isEmpty ||
        pattern == expected.repositoryPathPattern) {
      throw ArgumentError(
        'An exact valid rule and changed nonblank pattern are required',
      );
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final matches = (await repository.repositoryProtectionRules(
        arg,
      )).where((rule) => rule.id == expected.id).toList();
      if (matches.length != 1 || matches.single != expected) {
        throw const GitLabConflictException('Rule changed since confirmation');
      }
      final updated = await repository.updateRepositoryProtectionPattern(
        arg,
        expected.id,
        pattern,
      );
      if (updated != expected.copyWith(repositoryPathPattern: pattern)) {
        throw const GitLabServerException(
          'Response did not confirm the requested pattern and retained roles',
        );
      }
      state = const AsyncData(null);
      ref.invalidate(containerRepositoryProtectionControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final containerRepositoryProtectionPatternControllerProvider =
    AsyncNotifierProvider.family<
      ContainerRepositoryProtectionPatternController,
      void,
      int
    >(ContainerRepositoryProtectionPatternController.new);
