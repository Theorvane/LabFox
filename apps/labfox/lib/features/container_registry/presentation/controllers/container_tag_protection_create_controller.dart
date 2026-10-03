import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import 'container_registry_controllers.dart';
import 'container_tag_protection_controller.dart';

class ContainerTagProtectionCreateController
    extends FamilyAsyncNotifier<void, int> {
  @override
  void build(int arg) {}

  Future<void> create({
    required String tagNamePattern,
    String? minimumAccessLevelForPush,
    String? minimumAccessLevelForDelete,
  }) async {
    if (state.isLoading) {
      throw StateError('Rule creation is already pending');
    }
    const roles = {'maintainer', 'owner', 'admin'};
    if (arg <= 0 ||
        tagNamePattern.trim().isEmpty ||
        !roles.contains(minimumAccessLevelForPush) ||
        !roles.contains(minimumAccessLevelForDelete)) {
      throw ArgumentError(
        'An exact tag pattern and two supported roles are required',
      );
    }
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      final created = await repository.createTagProtectionRule(
        arg,
        tagNamePattern: tagNamePattern,
        minimumAccessLevelForPush: minimumAccessLevelForPush!,
        minimumAccessLevelForDelete: minimumAccessLevelForDelete!,
      );
      if (created.id <= 0 ||
          created.projectId != arg ||
          created.tagNamePattern != tagNamePattern ||
          created.minimumAccessLevelForPush != minimumAccessLevelForPush ||
          created.minimumAccessLevelForDelete != minimumAccessLevelForDelete) {
        throw const GitLabServerException(
          'Creation response did not confirm requested criteria',
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

final containerTagProtectionCreateControllerProvider =
    AsyncNotifierProvider.family<
      ContainerTagProtectionCreateController,
      void,
      int
    >(ContainerTagProtectionCreateController.new);
