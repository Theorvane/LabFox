import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Group endpoints.
class GroupsApi {
  const GroupsApi(this._dio);

  final Dio _dio;

  String _groupPath(Object groupId) =>
      '/groups/${Uri.encodeComponent(groupId.toString())}';

  /// Lists groups the current user can access.
  Future<Paginated<Group>> list({int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/groups',
        queryParameters: {
          'all_available': false,
          'order_by': 'name',
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading groups',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(Group.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading groups');
    }
  }

  /// Retrieves one group without the deprecated embedded project lists.
  Future<Group> get(Object groupId) async {
    try {
      final response = await _dio.get<dynamic>(
        _groupPath(groupId),
        queryParameters: {'with_projects': false},
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the group',
        );
      }
      return Group.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the group');
    }
  }

  /// Projects directly in a group, including projects shared to it.
  Future<Paginated<Project>> listProjects({
    required Object groupId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_groupPath(groupId)}/projects',
        queryParameters: {
          'include_subgroups': false,
          'order_by': 'last_activity_at',
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading group projects',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(Project.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading group projects');
    }
  }

  /// Direct child groups, not every descendant in the hierarchy.
  Future<Paginated<Group>> listSubgroups({
    required Object groupId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_groupPath(groupId)}/subgroups',
        queryParameters: {
          'order_by': 'name',
          'page': page,
          'per_page': perPage,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading subgroups',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(Group.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading subgroups');
    }
  }
}
