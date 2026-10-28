import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Effective members of a project, including inherited memberships.
class ProjectMembersApi {
  const ProjectMembersApi(this._dio);

  final Dio _dio;

  Future<Paginated<ProjectMember>> list(
    Object projectId, {
    String? query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/members/all',
        queryParameters: {'page': page, 'per_page': perPage, 'query': ?query},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing project members',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(ProjectMember.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing project members');
    }
  }
}
