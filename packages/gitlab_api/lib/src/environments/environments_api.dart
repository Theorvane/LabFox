import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only project environment endpoints.
class EnvironmentsApi {
  const EnvironmentsApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/environments';

  Future<Paginated<GitLabEnvironment>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
    String? state,
    String? search,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'states': ?state,
          'search': ?search,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing environments',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabEnvironment.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing environments');
    }
  }

  /// [environmentId] is the environment's global ID.
  Future<GitLabEnvironment> get(Object projectId, int environmentId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$environmentId',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading an environment',
        );
      }
      return GitLabEnvironment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading an environment');
    }
  }
}
