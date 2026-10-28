import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only GitLab project activity.
class EventsApi {
  const EventsApi(this._dio);

  final Dio _dio;

  Future<Paginated<ProjectEvent>> listProject(
    Object projectId, {
    String? targetType,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/events',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'sort': 'desc',
          'target_type': ?targetType,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing project activity',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(ProjectEvent.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing project activity');
    }
  }
}
