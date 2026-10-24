import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project labels, including inherited group labels when listing.
class ProjectLabelsApi {
  const ProjectLabelsApi(this._dio);

  final Dio _dio;

  Future<Paginated<ProjectLabel>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/labels',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'with_counts': true,
          'include_ancestor_groups': true,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing project labels',
        );
      }
      final labels = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ProjectLabel.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(labels, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing project labels');
    }
  }

  Future<ProjectLabel> get(Object projectId, int labelId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/labels/$labelId',
      );
      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a project label',
        );
      }
      return ProjectLabel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a project label');
    }
  }

  Future<ProjectLabel> create(
    Object projectId, {
    required String name,
    required String color,
    String? description,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/projects/${_enc(projectId)}/labels',
        data: {
          'name': name,
          'color': color,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      if (response.statusCode != 201 ||
          response.data is! Map<String, dynamic>) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a project label',
        );
      }
      return ProjectLabel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a project label');
    }
  }

  static String _enc(Object projectId) => Uri.encodeComponent('$projectId');
}
