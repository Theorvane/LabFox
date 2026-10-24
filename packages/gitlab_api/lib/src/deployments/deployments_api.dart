import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only GitLab project deployment endpoints.
class DeploymentsApi {
  const DeploymentsApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/deployments';

  Future<Paginated<GitLabDeployment>> list(
    Object projectId, {
    String? environment,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'order_by': 'created_at',
          'sort': 'desc',
          'environment': ?environment,
          'status': ?status,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing deployments',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(GitLabDeployment.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing deployments');
    }
  }

  /// [deploymentId] is the deployment's global ID, not its iid.
  Future<GitLabDeployment> get(Object projectId, int deploymentId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$deploymentId',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a deployment',
        );
      }
      return GitLabDeployment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a deployment');
    }
  }
}
