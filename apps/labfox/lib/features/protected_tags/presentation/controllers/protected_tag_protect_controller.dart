import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';

import '../../../tags/presentation/controllers/tags_controller.dart';
import 'protected_tags_controller.dart';

const protectedTagCreateRoles = [0, 30, 40];

/// Creates one project rule after a complete best-effort duplicate scan.
class ProtectedTagProtectController extends FamilyAsyncNotifier<void, int> {
  bool _disposed = false;
  @override
  void build(int arg) {
    ref.watch(protectedTagsRepositoryProvider.future);
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  bool _isCurrent(Object session) =>
      !_disposed &&
      identical(session, ref.read(protectedTagsRepositoryProvider.future));

  void _requireCurrent(Object session) {
    if (!_isCurrent(session)) {
      throw const GitLabConflictException('Protected tag session changed');
    }
  }

  /// Refreshes the complete rule inventory before a manual retry.
  Future<bool> inspect(String name) async {
    if (state.isLoading) throw StateError('Creation is already pending');
    if (name.trim().isEmpty) throw ArgumentError('Exact rule name required');
    final session = ref.read(protectedTagsRepositoryProvider.future);
    final repository = await ref.read(protectedTagsRepositoryProvider.future);
    _requireCurrent(session);
    if (repository == null) throw StateError('No authenticated account');
    final exists = await repository.containsName(arg, name);
    _requireCurrent(session);
    return exists;
  }

  Future<void> protect({
    required String name,
    required int createAccessLevel,
  }) async {
    if (state.isLoading) throw StateError('Creation is already pending');
    if (name.trim().isEmpty ||
        !protectedTagCreateRoles.contains(createAccessLevel)) {
      throw ArgumentError('Exact name and supported role required');
    }
    final session = ref.read(protectedTagsRepositoryProvider.future);
    state = const AsyncLoading();
    try {
      final repository = await session;
      _requireCurrent(session);
      if (repository == null) throw StateError('No authenticated account');
      final exists = await repository.containsName(arg, name);
      _requireCurrent(session);
      if (exists) {
        throw const GitLabConflictException(
          'Protected tag rule already exists',
        );
      }
      final created = await repository.protect(
        arg,
        name: name,
        createAccessLevel: createAccessLevel,
      );
      _requireCurrent(session);
      if (created.name != name ||
          created.createAccessLevels.length != 1 ||
          created.createAccessLevels.single.accessLevel != createAccessLevel) {
        throw const GitLabServerException('Unconfirmed protected tag creation');
      }
      state = const AsyncData(null);
      ref.invalidate(protectedTagsControllerProvider(arg));
      ref.invalidate(
        protectedTagDetailProvider(ProtectedTagRef(projectId: arg, name: name)),
      );
      ref.invalidate(tagsControllerProvider(arg));
      ref.invalidate(tagProvider);
    } catch (error, stackTrace) {
      if (_isCurrent(session)) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final protectedTagProtectControllerProvider =
    AsyncNotifierProvider.family<ProtectedTagProtectController, void, int>(
      ProtectedTagProtectController.new,
    );
