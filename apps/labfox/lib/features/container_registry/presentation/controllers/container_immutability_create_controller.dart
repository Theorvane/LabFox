import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'container_immutability_controller.dart';
import 'container_registry_controllers.dart';

class ContainerImmutabilityCreateController
    extends FamilyAsyncNotifier<void, int> {
  int _generation = 0;
  bool needsInspection = false;
  @override
  void build(int arg) {
    ref.watch(containerRegistryRepositoryProvider.future);
    ref.onDispose(() => _generation++);
    if (_generation > 0) needsInspection = true;
    _generation++;
  }

  Future<void> create(String pattern) async {
    if (state.isLoading || needsInspection) {
      throw StateError('Inspect rules before submitting again');
    }
    if (arg <= 0 || pattern.trim().isEmpty || pattern.runes.length > 100) {
      throw ArgumentError(
        'Positive project ID and a valid pattern length are required',
      );
    }
    final generation = _generation;
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (generation != _generation) {
        throw StateError('Authenticated account changed');
      }
      if (repository == null) throw StateError('No authenticated account');
      final rule = await repository.createImmutableTagRule(
        arg,
        pattern,
        isCurrent: () => generation == _generation,
      );
      if (generation != _generation) {
        throw StateError('Authenticated account changed');
      }
      if (rule.id.trim().isEmpty ||
          !rule.immutable ||
          rule.tagNamePattern != pattern) {
        throw const GitLabServerException(
          'Rule creation could not be confirmed',
        );
      }
      state = const AsyncData(null);
      ref.invalidate(containerImmutabilityControllerProvider(arg));
    } catch (error, stack) {
      if (generation == _generation) {
        needsInspection = true;
        state = AsyncError(error, stack);
      }
      rethrow;
    }
  }

  /// A fresh full scan is required before any manually requested retry.
  Future<void> inspect(String pattern) async {
    if (state.isLoading) throw StateError('An operation is pending');
    final generation = _generation;
    needsInspection = true;
    state = const AsyncLoading();
    try {
      final repository = await ref.read(
        containerRegistryRepositoryProvider.future,
      );
      if (generation != _generation) {
        throw StateError('Authenticated account changed');
      }
      if (repository == null) throw StateError('No authenticated account');
      final rules = await repository.immutableTagRules(arg);
      if (generation != _generation) {
        throw StateError('Authenticated account changed');
      }
      ref.invalidate(containerImmutabilityControllerProvider(arg));
      if (rules.any((r) => r.tagNamePattern == pattern)) {
        throw const GitLabConflictException(
          'An immutable rule already has this pattern',
        );
      }
      needsInspection = false;
      state = const AsyncData(null);
    } catch (error, stack) {
      if (generation == _generation) state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final containerImmutabilityCreateControllerProvider =
    AsyncNotifierProvider.family<
      ContainerImmutabilityCreateController,
      void,
      int
    >(ContainerImmutabilityCreateController.new);
