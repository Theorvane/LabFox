import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'container_registry_controllers.dart';
import 'container_tag_protection_controller.dart';

class ContainerTagProtectionDeleteController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> remove({required ContainerTagProtectionRule expected}) async {
    if (state.isLoading) throw StateError('Rule deletion is already pending');
    if (arg <= 0 ||
        expected.projectId != arg ||
        expected.id <= 0 ||
        expected.tagNamePattern.trim().isEmpty) {
      throw ArgumentError(
        'An explicit valid rule from this project is required',
      );
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final current = (await repository.tagProtectionRules(
        arg,
      )).where((rule) => rule.id == expected.id).toList();
      if (current.length != 1 || current.single != expected) {
        throw const GitLabConflictException(
          'Protection rule changed since confirmation',
        );
      }
      await repository.deleteTagProtectionRule(arg, expected.id);
      state = const AsyncData(null);
      ref.invalidate(containerTagProtectionControllerProvider(arg));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final containerTagProtectionDeleteControllerProvider =
    AsyncNotifierProvider.family<
      ContainerTagProtectionDeleteController,
      void,
      int
    >(ContainerTagProtectionDeleteController.new);
