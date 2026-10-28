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
      final raw = response.data;
      if (raw is! List ||
          raw.any(
            (entry) =>
                entry is! Map<String, dynamic> ||
                entry['name'] is! String ||
                (entry['name'] as String).isEmpty ||
                entry['create_access_levels'] is! List,
          )) {
        throw const GitLabServerException('Incomplete protected tag list');
      }
      try {
        final items = raw
            .cast<Map<String, dynamic>>()
            .map(ProtectedTag.fromJson)
            .toList(growable: false);
        return Paginated.fromHeaders(items, response.headers.map);
      } on TypeError {
        throw const GitLabServerException('Malformed protected tag list');
      } on FormatException {
        throw const GitLabServerException('Malformed protected tag list');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'listing protected tags');
    }
  }

  /// Creates one project-wide rule with a documented role choice.
  Future<ProtectedTag> protect(
    Object projectId, {
    required String name,
    required int createAccessLevel,
  }) async {
    if (name.trim().isEmpty || !const [0, 30, 40].contains(createAccessLevel)) {
      throw ArgumentError('Exact name and supported create role required');
    }
    try {
      final response = await _dio.post<dynamic>(
        _path(projectId),
        data: {'name': name, 'create_access_level': createAccessLevel},
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 201 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating protected tag rule',
        );
      }
      final raw = response.data;
      if (raw is! Map<String, dynamic> ||
          raw['name'] != name ||
          raw['create_access_levels'] is! List) {
        throw const GitLabServerException('Incomplete protected tag creation');
      }
      try {
        final created = ProtectedTag.fromJson(raw);
        if (created.createAccessLevels.length != 1 ||
            created.createAccessLevels.single.accessLevel !=
                createAccessLevel) {
          throw const GitLabServerException('Unconfirmed protected tag role');
        }
        return created;
      } on TypeError {
        throw const GitLabServerException('Malformed protected tag creation');
      } on FormatException {
        throw const GitLabServerException('Malformed protected tag creation');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'creating protected tag rule');
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
