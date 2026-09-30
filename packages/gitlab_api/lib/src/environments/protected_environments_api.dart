import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only project protected environments (Premium/Ultimate).
class ProtectedEnvironmentsApi {
  const ProtectedEnvironmentsApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/protected_environments';

  /// Creates a project rule with one role-based deploy grant and no approvals.
  Future<ProtectedEnvironment> createRoleOnly(
    Object projectId,
    String name, {
    required int accessLevel,
  }) async {
    if (name.trim().isEmpty ||
        name != name.trim() ||
        name.contains('*') ||
        !{30, 40}.contains(accessLevel)) {
      throw ArgumentError(
        'Exact environment name and supported deploy role required',
      );
    }
    try {
      final response = await _dio.post<dynamic>(
        _path(projectId),
        data: {
          'name': name,
          'deploy_access_levels': [
            {'access_level': accessLevel},
          ],
        },
        options: Options(
          followRedirects: false,
          extra: {'labfox_no_auth_retry': true},
        ),
      );
      if (response.statusCode != 201) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'protecting an environment',
        );
      }
      final raw = response.data;
      if (raw is! Map<String, dynamic> ||
          raw['name'] != name ||
          raw['deploy_access_levels'] is! List ||
          raw['approval_rules'] is! List ||
          raw['required_approval_count'] != 0) {
        throw const GitLabServerException(
          'Unconfirmed protected environment creation',
        );
      }
      try {
        final created = ProtectedEnvironment.fromJson(raw);
        if (created.deployAccessLevels.length != 1 ||
            created.deployAccessLevels.single.id == null ||
            created.deployAccessLevels.single.id! <= 0 ||
            created.deployAccessLevels.single.accessLevel != accessLevel ||
            created.deployAccessLevels.single.userId != null ||
            created.deployAccessLevels.single.groupId != null ||
            created.approvalRules.isNotEmpty) {
          throw const GitLabServerException(
            'Unconfirmed protected environment creation',
          );
        }
        return created;
      } on TypeError {
        throw const GitLabServerException(
          'Malformed protected environment creation',
        );
      } on FormatException {
        throw const GitLabServerException(
          'Malformed protected environment creation',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'protecting an environment');
    }
  }

  Future<Paginated<ProtectedEnvironment>> list(
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
          context: 'listing protected environments',
        );
      }
      final raw = response.data;
      if (raw is! List ||
          raw.any(
            (entry) =>
                entry is! Map<String, dynamic> ||
                entry['name'] is! String ||
                (entry['name'] as String).isEmpty,
          )) {
        throw const GitLabServerException(
          'Incomplete protected environment list',
        );
      }
      try {
        return Paginated.fromHeaders(
          raw
              .cast<Map<String, dynamic>>()
              .map(ProtectedEnvironment.fromJson)
              .toList(growable: false),
          response.headers.map,
        );
      } on TypeError {
        throw const GitLabServerException(
          'Malformed protected environment list',
        );
      } on FormatException {
        throw const GitLabServerException(
          'Malformed protected environment list',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'listing protected environments');
    }
  }

  Future<ProtectedEnvironment> get(Object projectId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a protected environment',
        );
      }
      return ProtectedEnvironment.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a protected environment');
    }
  }
}
