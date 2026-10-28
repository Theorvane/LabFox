import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Group labels, including ancestor-group labels when listing.
class GroupLabelsApi {
  const GroupLabelsApi(this._dio);

  final Dio _dio;

  String _path(Object groupId) =>
      '/groups/${Uri.encodeComponent(groupId.toString())}/labels';

  Future<Paginated<ProjectLabel>> list(
    Object groupId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(groupId),
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
          context: 'listing group labels',
        );
      }
      final labels = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ProjectLabel.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(labels, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing group labels');
    }
  }

  Future<ProjectLabel> get(Object groupId, int labelId) async {
    try {
      final response = await _dio.get<dynamic>('${_path(groupId)}/$labelId');
      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a group label',
        );
      }
      return ProjectLabel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a group label');
    }
  }

  Future<ProjectLabel> create(
    Object groupId, {
    required String name,
    required String color,
    String? description,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _path(groupId),
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
          context: 'creating a group label',
        );
      }
      return ProjectLabel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a group label');
    }
  }
}
