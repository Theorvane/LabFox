import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/tags_repository.dart';

final tagsRepositoryProvider = FutureProvider<TagsRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : TagsRepository(client);
});

/// Loads all tag pages and refreshes after a successful creation.
class TagsController extends FamilyAsyncNotifier<List<RepositoryTag>, int> {
  @override
  Future<List<RepositoryTag>> build(int projectId) async {
    final repository = await ref.watch(tagsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(projectId);
  }

  Future<void> create({
    required String name,
    required String fromRef,
    String? message,
  }) async {
    final repository = await ref.read(tagsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    await repository.create(arg, name: name, ref: fromRef, message: message);
    state = await AsyncValue.guard(() => repository.list(arg));
  }
}

final tagsControllerProvider =
    AsyncNotifierProvider.family<TagsController, List<RepositoryTag>, int>(
      TagsController.new,
    );

class TagRef {
  const TagRef(this.projectId, this.name);
  final int projectId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is TagRef && other.projectId == projectId && other.name == name;
  @override
  int get hashCode => Object.hash(projectId, name);
}

final tagProvider = FutureProvider.family<RepositoryTag, TagRef>((
  ref,
  tag,
) async {
  final repository = await ref.watch(tagsRepositoryProvider.future);
  if (repository == null) throw StateError('No authenticated account');
  return repository.get(tag.projectId, tag.name);
});
