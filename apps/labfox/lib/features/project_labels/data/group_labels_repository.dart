import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Group and inherited labels through one authenticated GitLab client.
class GroupLabelsRepository {
  const GroupLabelsRepository(this.client);

  final GitLabClient client;

  Future<List<ProjectLabel>> list(int groupId) async {
    final labels = <ProjectLabel>[];
    var page = 1;
    while (true) {
      final result = await client.groupLabels.list(groupId, page: page);
      labels.addAll(result.items);
      if (result.nextPage == null) return labels;
      page = result.nextPage!;
    }
  }

  Future<ProjectLabel> get(int groupId, int labelId) =>
      client.groupLabels.get(groupId, labelId);

  Future<ProjectLabel> create(
    int groupId, {
    required String name,
    required String color,
    String? description,
  }) => client.groupLabels.create(
    groupId,
    name: name,
    color: color,
    description: description,
  );
}
