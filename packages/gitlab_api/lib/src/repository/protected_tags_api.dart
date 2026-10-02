import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Protected tag rules for one project.
class ProtectedTagsApi {
  const ProtectedTagsApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/protected_tags';

  Future<Paginated<ProtectedTag>> list(
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
          context: 'listing protected tags',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(ProtectedTag.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing protected tags');
    }
  }

  /// Removes the named protection rule; repository tags remain intact.
  Future<void> unprotect(Object projectId, String name) async {
    if (name.trim().isEmpty) throw ArgumentError('Rule name must not be blank');
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'removing tag protection',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'removing tag protection');
    }
  }

  Future<ProtectedTag> get(Object projectId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a protected tag',
        );
      }
      final raw = response.data;
      if (raw is! Map<String, dynamic> ||
          raw['name'] != name ||
          raw['create_access_levels'] is! List) {
        throw const GitLabServerException('Incomplete tag protection response');
      }
      final entries = raw['create_access_levels'] as List;
      if (entries.any(
        (entry) =>
            entry is! Map<String, dynamic> ||
            ![
              'access_level',
              'user_id',
              'group_id',
              'deploy_key_id',
            ].any((field) => entry[field] is int),
      )) {
        throw const GitLabServerException(
          'Incomplete tag protection permissions',
        );
      }
      try {
        return ProtectedTag.fromJson(raw);
      } on TypeError {
        throw const GitLabServerException('Malformed tag protection response');
      } on FormatException {
        throw const GitLabServerException('Malformed tag protection response');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a protected tag');
    }
  }
}
