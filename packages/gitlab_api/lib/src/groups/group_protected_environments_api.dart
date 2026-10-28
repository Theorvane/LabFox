import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only group protected environments (Premium/Ultimate).
class GroupProtectedEnvironmentsApi {
  const GroupProtectedEnvironmentsApi(this._dio);

  final Dio _dio;

  String _path(Object groupId) =>
      '/groups/${Uri.encodeComponent(groupId.toString())}/protected_environments';

  Future<Paginated<ProtectedEnvironment>> list(
    Object groupId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(groupId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing group protected environments',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(ProtectedEnvironment.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing group protected environments');
    }
  }

  Future<ProtectedEnvironment> get(Object groupId, String name) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(groupId)}/${Uri.encodeComponent(name)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a group protected environment',
        );
      }
      return ProtectedEnvironment.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a group protected environment');
    }
  }
}
