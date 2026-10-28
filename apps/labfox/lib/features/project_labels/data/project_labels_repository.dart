import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// Loads project and inherited labels, and creates project-owned labels.
class ProjectLabelsRepository {
  const ProjectLabelsRepository(this._client);

  final GitLabClient _client;

  Future<List<ProjectLabel>> list(int projectId) async {
    final labels = <ProjectLabel>[];
    var page = 1;
    while (true) {
      final result = await _client.projectLabels.list(projectId, page: page);
      labels.addAll(result.items);
      if (result.nextPage == null) return labels;
      page = result.nextPage!;
    }
  }

  Future<ProjectLabel> get(int projectId, int labelId) =>
      _client.projectLabels.get(projectId, labelId);

  Future<ProjectLabel> create(
    int projectId, {
    required String name,
    required String color,
    String? description,
  }) => _client.projectLabels.create(
    projectId,
    name: name,
    color: color,
    description: description,
  );
}
