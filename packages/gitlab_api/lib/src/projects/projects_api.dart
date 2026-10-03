import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project endpoints.
class ProjectsApi {
  const ProjectsApi(this._dio);

  final Dio _dio;

  /// Changes only the cleanup age threshold, preserving other policy settings.
  Future<Project> setCleanupPolicyAge(
    Object projectId, {
    required String olderThan,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {'older_than': olderThan},
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating cleanup policy age limit',
        );
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating cleanup policy age limit');
    }
  }

  /// Replaces only the keep pattern of an existing cleanup policy.
  Future<Project> setCleanupPolicyKeepPattern(
    Object projectId, {
    required String nameRegexKeep,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {
            'name_regex_keep': nameRegexKeep,
          },
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating cleanup policy keep pattern',
        );
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating cleanup policy keep pattern');
    }
  }

  /// Changes only matching-tag retention count, preserving other policy settings.
  Future<Project> setCleanupPolicyKeepCount(
    Object projectId, {
    required int keepN,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {'keep_n': keepN},
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating cleanup policy retention count',
        );
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating cleanup policy retention count');
    }
  }

  /// Changes only cleanup policy activation, preserving all retention settings.
  Future<Project> setCleanupPolicyEnabled(
    Object projectId, {
    required bool enabled,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {'enabled': enabled},
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating cleanup policy activation',
        );
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating cleanup policy activation');
    }
  }

  /// Changes only cleanup cadence, preserving activation and retention criteria.
  Future<Project> setCleanupPolicyCadence(
    Object projectId, {
    required String cadence,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {'cadence': cadence},
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating cleanup policy cadence',
        );
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating cleanup policy cadence');
    }
  }

  /// The projects the current user is a member of.
  ///
  /// Defaults to membership, most recently active first — the order that puts
  /// what someone is working on at the top. Pagination is by page number; the
  /// next cursor comes from the response headers, never an assumed count.
  Future<Paginated<Project>> list({int page = 1, int perPage = 20}) async {
    try {
      // Untyped, so an error body (which GitLab returns as an object, not a
      // list) does not fail a List cast before the status can be inspected.
      final response = await _dio.get<dynamic>(
        '/projects',
        queryParameters: {
          'membership': true,
          'order_by': 'last_activity_at',
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading projects',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final projects = data.map(Project.fromJson).toList(growable: false);
      return Paginated.fromHeaders(projects, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading projects');
    }
  }

  /// Reads policy presence separately from a reduced or omitted project field.
  Future<ContainerCleanupPolicySnapshot> cleanupPolicySnapshot(
    Object projectId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading cleanup policy presence',
        );
      }
      final data = response.data as Map<String, dynamic>;
      return ContainerCleanupPolicySnapshot.fromJson({
        'reported': data.containsKey('container_expiration_policy'),
        'policy': data['container_expiration_policy'],
      });
    } on DioException catch (error) {
      throw mapError(error, context: 'loading cleanup policy presence');
    }
  }

  /// Saves complete criteria with explicit activation, disabled by default.
  Future<Project> createCleanupPolicy(
    Object projectId, {
    bool enabled = false,
    required String cadence,
    required int keepN,
    required String olderThan,
    required String nameRegexDelete,
    required String nameRegexKeep,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {
            'enabled': enabled,
            'cadence': cadence,
            'keep_n': keepN,
            'older_than': olderThan,
            'name_regex_delete': nameRegexDelete,
            'name_regex_keep': nameRegexKeep,
          },
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating cleanup policy',
        );
      }
      try {
        return Project.fromJson(response.data as Map<String, dynamic>);
      } on TypeError {
        throw const GitLabServerException('Malformed cleanup policy response');
      } on FormatException {
        throw const GitLabServerException('Malformed cleanup policy response');
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'creating cleanup policy');
    }
  }

  /// Reads policy presence separately from a reduced or omitted project field.

  /// Saves a complete policy draft disabled; activation is a separate action.
  Future<Project> createDisabledCleanupPolicy(
    Object projectId, {
    required String cadence,
    required int keepN,
    required String olderThan,
    required String nameRegexDelete,
    required String nameRegexKeep,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {
            'enabled': false,
            'cadence': cadence,
            'keep_n': keepN,
            'older_than': olderThan,
            'name_regex_delete': nameRegexDelete,
            'name_regex_keep': nameRegexKeep,
          },
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating disabled cleanup policy',
        );
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating disabled cleanup policy');
    }
  }

  /// A single project by its numeric id.
  Future<Project> get(int projectId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId',
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the project',
        );
      }
      return Project.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the project');
    }
  }

  /// The raw README of a project on a given ref, or null when it has none.
  ///
  /// A project without a README is normal, so a 404 returns null rather than
  /// throwing — the overview renders without it. Other failures still surface.
  Future<String?> readme(int projectId, {required String ref}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/$projectId/repository/files/README.md/raw',
        queryParameters: {'ref': ref},
      );
      if (response.statusCode == 404) {
        return null;
      }
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the README',
        );
      }
      return response.data?.toString();
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the README');
    }
  }
}
