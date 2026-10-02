import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project endpoints.
class ProjectsApi {
  const ProjectsApi(this._dio);

  final Dio _dio;

  /// Clears only the keep pattern with an explicit empty string.
  Future<Project> clearCleanupPolicyKeepPattern(Object projectId) async {
    try {
      final response = await _dio.put<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}',
        data: {
          'container_expiration_policy_attributes': {'name_regex_keep': ''},
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'clearing cleanup policy keep pattern',
        );
      }
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'clearing cleanup policy keep pattern');
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
