import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project Releases endpoints.
class ReleasesApi {
  const ReleasesApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/releases';

  Future<Paginated<GitLabRelease>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing releases',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabRelease.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing releases');
    }
  }

  Future<GitLabRelease> get(Object projectId, String tagName) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a release',
        );
      }
      return GitLabRelease.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a release');
    }
  }

  Future<GitLabRelease> update(
    Object projectId,
    String tagName, {
    required String name,
    required String description,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(tagName)}',
        data: {'name': name, 'description': description},
      );
      if (response.statusCode != 200 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating a release',
        );
      }
      return GitLabRelease.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating a release');
    }
  }
}
