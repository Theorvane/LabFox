import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';
import 'container_tag_protection_controller.dart';

class ContainerTagProtectionPatternController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> savePattern({
    required ContainerTagProtectionRule expected,
    required String pattern,
  }) async {
    if (state.isLoading) throw StateError('Pattern update already pending');
    if (arg <= 0 ||
        expected.projectId != arg ||
        expected.id <= 0 ||
        expected.tagNamePattern.trim().isEmpty ||
        pattern.trim().isEmpty ||
        pattern == expected.tagNamePattern) {
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
      final matches = (await repository.tagProtectionRules(
        arg,
      )).where((rule) => rule.id == expected.id).toList();
      if (matches.length != 1 || matches.single != expected) {
        throw const GitLabConflictException('Rule changed since confirmation');
      }
      final updated = await repository.updateTagProtectionPattern(
        arg,
        expected.id,
        pattern,
      );
      if (updated != expected.copyWith(tagNamePattern: pattern)) {
        throw const GitLabServerException(
          'Response did not confirm the requested pattern and retained roles',
        );
      }
      state = const AsyncData(null);
      ref.invalidate(containerTagProtectionControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final containerTagProtectionPatternControllerProvider =
    AsyncNotifierProvider.family<
      ContainerTagProtectionPatternController,
      void,
      int
    >(ContainerTagProtectionPatternController.new);
