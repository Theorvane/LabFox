import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/project_labels_repository.dart';

final projectLabelsRepositoryProvider =
    FutureProvider<ProjectLabelsRepository?>((ref) async {
      final client = await ref.watch(gitLabClientProvider.future);
      return client == null ? null : ProjectLabelsRepository(client);
    });

class ProjectLabelsController
    extends FamilyAsyncNotifier<List<ProjectLabel>, int> {
  @override
  Future<List<ProjectLabel>> build(int projectId) async {
    final repository = await ref.watch(projectLabelsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    return repository.list(projectId);
  }

  Future<void> create({
    required String name,
    required String color,
    String? description,
  }) async {
    final repository = await ref.read(projectLabelsRepositoryProvider.future);
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

final projectLabelsControllerProvider =
    AsyncNotifierProvider.family<
      ProjectLabelsController,
      List<ProjectLabel>,
      int
    >(ProjectLabelsController.new);

class ProjectLabelRef {
  const ProjectLabelRef(this.projectId, this.labelId);
  final int projectId;
  final int labelId;

  @override
  bool operator ==(Object other) =>
      other is ProjectLabelRef &&
      other.projectId == projectId &&
      other.labelId == labelId;
  @override
  int get hashCode => Object.hash(projectId, labelId);
}

final projectLabelProvider =
    FutureProvider.family<ProjectLabel, ProjectLabelRef>((ref, item) async {
      final repository = await ref.watch(
        projectLabelsRepositoryProvider.future,
      );
      if (repository == null) throw StateError('No authenticated account');
      return repository.get(item.projectId, item.labelId);
    });
