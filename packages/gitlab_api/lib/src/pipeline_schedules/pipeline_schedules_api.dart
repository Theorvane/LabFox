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

  /// Pipelines belonging to this schedule, newest first.
  Future<Paginated<Pipeline>> listPipelines(
    Object projectId,
    int scheduleId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$scheduleId/pipelines',
        queryParameters: {'page': page, 'per_page': perPage, 'sort': 'desc'},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing schedule pipelines',
        );
      }
      final items = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Pipeline.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(items, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing schedule pipelines');
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

  /// Updates timing metadata without rewriting ref, active, variables or inputs.
  Future<PipelineSchedule> update(
    Object projectId,
    int scheduleId, {
    String? description,
    String? cron,
    String? cronTimezone,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        '${_path(projectId)}/$scheduleId',
        data: {
          'description': ?description,
          'cron': ?cron,
          'cron_timezone': ?cronTimezone,
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating a pipeline schedule',
        );
      }
      return PipelineSchedule.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating a pipeline schedule');
    }
  }

  Future<PipelineSchedule> takeOwnership(
    Object projectId,
    int scheduleId,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        '${_path(projectId)}/$scheduleId/take_ownership',
      );
      if ((response.statusCode != 200 && response.statusCode != 201) ||
          response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'taking pipeline schedule ownership',
        );
      }
      return PipelineSchedule.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'taking pipeline schedule ownership');
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
