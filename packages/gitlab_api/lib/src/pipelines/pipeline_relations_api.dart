import 'package:gitlab_models/gitlab_models.dart';
import '../common/exceptions.dart';
import '../graphql/graphql_api.dart';

/// Reads the immediate relationship not exposed in the REST pipeline response.
class PipelineRelationsApi {
  const PipelineRelationsApi(this._graphql);
  final GraphQLApi _graphql;
  static const _document = r'''
query PipelineUpstream($fullPath: ID!, $pipelineId: CiPipelineID!) {
  project(fullPath: $fullPath) {
    id
    pipeline(id: $pipelineId) {
      id
      upstream { id status ref project { id } }
    }
  }
}
''';

  /// Null means no visible upstream, not proof of no inaccessible relationship.
  Future<PipelineUpstream?> upstream(
    String fullPath, {
    required int projectId,
    required int pipelineId,
  }) async {
    if (fullPath.trim().isEmpty || projectId <= 0 || pipelineId <= 0) {
      throw ArgumentError(
        'A project path and positive source IDs are required',
      );
    }
    final sourceId = 'gid://gitlab/Ci::Pipeline/$pipelineId';
    final data = await _graphql.query(
      document: _document,
      operationName: 'PipelineUpstream',
      variables: {'fullPath': fullPath, 'pipelineId': sourceId},
    );
    if (data.containsKey('project') && data['project'] == null) {
      throw const GitLabNotFoundException('Source project is unavailable');
    }
    try {
      final project = data['project'] as Map<String, dynamic>;
      if (project['id'] != 'gid://gitlab/Project/$projectId') {
        throw const FormatException('Source project mismatch');
      }
      if (project.containsKey('pipeline') && project['pipeline'] == null) {
        throw const GitLabNotFoundException('Source pipeline is unavailable');
      }
      final pipeline = project['pipeline'] as Map<String, dynamic>;
      if (pipeline['id'] != sourceId || !pipeline.containsKey('upstream')) {
        throw const FormatException('Missing or mismatched source pipeline');
      }
      if (pipeline['upstream'] == null) return null;
      final upstream = pipeline['upstream'] as Map<String, dynamic>;
      if (!upstream.containsKey('project') || !upstream.containsKey('ref')) {
        throw const FormatException('Incomplete target fields');
      }
      final target = PipelineUpstream.fromJson(upstream);
      if (target.pipelineId == null ||
          target.status.trim().isEmpty ||
          (target.project != null && target.projectId == null)) {
        throw const FormatException('Invalid target identity or status');
      }
      return target;
    } on GitLabNotFoundException {
      rethrow;
    } catch (_) {
      throw const GitLabServerException('Invalid upstream pipeline response');
    }
  }
}
