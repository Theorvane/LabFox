import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'container_immutability_controller.dart';
import 'container_registry_controllers.dart';

class ContainerImmutabilityDeleteController
    extends FamilyAsyncNotifier<void, int> {
  bool needsReload = false;
  int _generation = 0;
  @override
  void build(int arg) {
    ref.watch(containerRegistryRepositoryProvider.future);
    ref.onDispose(() => _generation++);
    if (_generation > 0) needsReload = true;
    _generation++;
  }

  void _checkSession(int generation) {
    if (generation != _generation) {
      throw StateError('Authenticated account changed');
    }
  }

  Future<void> delete(ContainerTagImmutabilityRule expected) async {
    if (state.isLoading || needsReload) {
      throw StateError('Reload before submitting again');
    }
    if (arg <= 0 ||
        !expected.immutable ||
        expected.id.trim().isEmpty ||
        expected.tagNamePattern.trim().isEmpty) {
      throw ArgumentError(
        'A positive project ID and complete immutable rule are required',
      );
    }
    final generation = _generation;
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      _checkSession(generation);
      if (repository == null) throw StateError('No authenticated account');
      await repository.deleteImmutableTagRule(
        arg,
        expected,
        isCurrent: () => generation == _generation,
      );
      _checkSession(generation);
      state = const AsyncData(null);
      ref.invalidate(containerImmutabilityControllerProvider(arg));
    } catch (error, stack) {
      if (generation == _generation) {
        needsReload = true;
        state = AsyncError(error, stack);
      }
      rethrow;
    }
  }

  Future<ContainerTagImmutabilityRule> reload(String id) async {
    if (state.isLoading) throw StateError('An operation is pending');
    if (arg <= 0 || id.trim().isEmpty) {
      throw ArgumentError('Project and rule ID are required');
    }
    final generation = _generation;
    needsReload = true;
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      _checkSession(generation);
      if (repository == null) throw StateError('No authenticated account');
      final rules = await repository.immutableTagRules(arg);
      _checkSession(generation);
      ref.invalidate(containerImmutabilityControllerProvider(arg));
      final matching = rules.where((r) => r.id == id).toList();
      if (matching.isEmpty) {
        throw const GitLabNotFoundException('Immutable rule is unavailable');
      }
      if (matching.length != 1 || !matching.single.immutable) {
        throw const GitLabServerException('Ambiguous immutable rule');
      }
      needsReload = false;
      state = const AsyncData(null);
      return matching.single;
    } catch (error, stack) {
      if (generation == _generation) state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final containerImmutabilityDeleteControllerProvider =
    AsyncNotifierProvider.family<
      ContainerImmutabilityDeleteController,
      void,
      int
    >(ContainerImmutabilityDeleteController.new);
