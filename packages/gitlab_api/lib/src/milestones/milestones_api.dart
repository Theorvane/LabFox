import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project milestone endpoints.
class MilestonesApi {
  const MilestonesApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/milestones';

  Future<Paginated<GitLabMilestone>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
    String? state,
    bool includeAncestors = false,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'state': ?state,
          if (includeAncestors) 'include_ancestors': true,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing milestones',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabMilestone.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing milestones');
    }
  }

  /// [milestoneId] is the global ID, not the displayed project-local iid.
  Future<GitLabMilestone> get(Object projectId, int milestoneId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$milestoneId',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a milestone',
        );
      }
      return GitLabMilestone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a milestone');
    }
  }

  /// Deletes a project milestone by its global ID, not its project-local iid.
  Future<void> delete(Object projectId, int milestoneId) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/$milestoneId',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting a milestone',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting a milestone');
    }
  }

  Future<GitLabMilestone> create(
    Object projectId, {
    required String title,
    String? description,
    String? startDate,
    String? dueDate,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _path(projectId),
        data: {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          'start_date': ?startDate,
          'due_date': ?dueDate,
        },
      );
      if (response.statusCode != 201 ||
          response.data is! Map<String, dynamic>) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a milestone',
        );
      }
      return GitLabMilestone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a milestone');
    }
  }

  /// Changes a project milestone using its global ID, not its local iid.
  Future<GitLabMilestone> setStateEvent(
    Object projectId,
    int milestoneId, {
    required String stateEvent,
  }) async {
    if (stateEvent != 'close' && stateEvent != 'activate') {
      throw ArgumentError.value(stateEvent, 'stateEvent');
    }
    try {
      final response = await _dio.put<dynamic>(
        '${_path(projectId)}/$milestoneId',
        data: {'state_event': stateEvent},
      );
      if (response.statusCode != 200 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'changing milestone state',
        );
      }
      return GitLabMilestone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'changing milestone state');
    }
  }
}
