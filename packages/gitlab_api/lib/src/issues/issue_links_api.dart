import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Linked issues for a project issue.
class IssueLinksApi {
  const IssueLinksApi(this._dio);

  final Dio _dio;

  Future<Paginated<IssueLink>> list(
    Object projectId, {
    required int issueIid,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/issues/$issueIid/links',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing linked issues',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(IssueLink.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing linked issues');
    }
  }
}
