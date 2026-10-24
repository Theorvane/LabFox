import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/group_labels_repository.dart';

final groupLabelsRepositoryProvider = FutureProvider<GroupLabelsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : GroupLabelsRepository(client);
});

class GroupLabelsController
    extends FamilyAsyncNotifier<List<ProjectLabel>, int> {
  @override
  Future<List<ProjectLabel>> build(int groupId) async {
    final repository = await ref.watch(groupLabelsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(groupId);
  }

  Future<void> create({
    required String name,
    required String color,
    String? description,
  }) async {
    final repository = await ref.read(groupLabelsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    await repository.create(
      arg,
      name: name,
      color: color,
      description: description,
    );
    state = await AsyncValue.guard(() => repository.list(arg));
  }
}

final groupLabelsControllerProvider =
    AsyncNotifierProvider.family<
      GroupLabelsController,
      List<ProjectLabel>,
      int
    >(GroupLabelsController.new);

class GroupLabelRef {
  const GroupLabelRef(this.groupId, this.labelId);
  final int groupId;
  final int labelId;

  @override
  bool operator ==(Object other) =>
      other is GroupLabelRef &&
      other.groupId == groupId &&
      other.labelId == labelId;

  @override
  int get hashCode => Object.hash(groupId, labelId);
}

final groupLabelProvider = FutureProvider.family<ProjectLabel, GroupLabelRef>((
  ref,
  item,
) async {
  final repository = await ref.watch(groupLabelsRepositoryProvider.future);
  if (repository == null) throw StateError('No authenticated account');
  return repository.get(item.groupId, item.labelId);
});
