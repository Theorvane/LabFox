import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// GitLab project pipeline schedule endpoints.
class PipelineSchedulesApi {
  const PipelineSchedulesApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/pipeline_schedules';

  Future<PipelineSchedule> create(
    Object projectId, {
    required String description,
    required String ref,
    required String cron,
    String? cronTimezone,
    bool? active,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _path(projectId),
        data: {
          'description': description,
          'ref': ref,
          'cron': cron,
          'cron_timezone': ?cronTimezone,
          'active': ?active,
        },
      );
      if (response.statusCode != 201 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a pipeline schedule',
        );
      }
      return PipelineSchedule.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a pipeline schedule');
    }
  }

  Future<Paginated<PipelineSchedule>> list(
    Object projectId, {
    bool? active,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (active != null) 'scope': active ? 'active' : 'inactive',
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing pipeline schedules',
        );
      }
      final items = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PipelineSchedule.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(items, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing pipeline schedules');
    }
  }

  Future<PipelineSchedule> get(Object projectId, int scheduleId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$scheduleId',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a pipeline schedule',
        );
      }
      return PipelineSchedule.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a pipeline schedule');
    }
  }

  /// Runs the schedule now without changing its next planned run.
  Future<void> play(Object projectId, int scheduleId) async {
    try {
      final response = await _dio.post<dynamic>(
        '${_path(projectId)}/$scheduleId/play',
      );
      if (response.statusCode != 201) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'running a pipeline schedule',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'running a pipeline schedule');
    }
  }
}
