import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Group milestone endpoints.
class GroupMilestonesApi {
  const GroupMilestonesApi(this._dio);

  final Dio _dio;

  String _path(Object groupId) =>
      '/groups/${Uri.encodeComponent(groupId.toString())}/milestones';

  Future<Paginated<GitLabMilestone>> list(
    Object groupId, {
    int page = 1,
    int perPage = 20,
    String? state,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(groupId),
        queryParameters: {'page': page, 'per_page': perPage, 'state': ?state},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing group milestones',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabMilestone.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing group milestones');
    }
  }

  /// [milestoneId] is global, not the group-local iid.
  Future<GitLabMilestone> get(Object groupId, int milestoneId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(groupId)}/$milestoneId',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a group milestone',
        );
      }
      return GitLabMilestone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a group milestone');
    }
  }

  Future<GitLabMilestone> create(
    Object groupId, {
    required String title,
    String? description,
    String? startDate,
    String? dueDate,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _path(groupId),
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
          context: 'creating a group milestone',
        );
      }
      return GitLabMilestone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a group milestone');
    }
  }

  /// Updates a group milestone by global ID, not its group-local iid.
  Future<GitLabMilestone> update(
    Object groupId,
    int milestoneId, {
    required String title,
    String? description,
    String? startDate,
    String? dueDate,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) async {
    if (clearStartDate && startDate != null) {
      throw ArgumentError('Cannot set and clear the start date together');
    }
    if (clearDueDate && dueDate != null) {
      throw ArgumentError('Cannot set and clear the due date together');
    }
    try {
      final response = await _dio.put<dynamic>(
        '${_path(groupId)}/$milestoneId',
        data: {
          'title': title,
          'description': ?description,
          if (clearStartDate || startDate != null)
            'start_date': clearStartDate ? '' : startDate,
          if (clearDueDate || dueDate != null)
            'due_date': clearDueDate ? '' : dueDate,
        },
      );
      if (response.statusCode != 200 || response.data is! Map) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating a group milestone',
        );
      }
      return GitLabMilestone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating a group milestone');
    }
  }
}
