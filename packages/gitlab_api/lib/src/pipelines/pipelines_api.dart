import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/exceptions.dart';
import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Stable project-pipeline statuses supported by the list filter.
/// Other response statuses remain visible when no filter is applied.
enum PipelineStatusFilter {
  created,
  pending,
  running,
  success,
  failed,
  canceled,
  skipped,
  manual,
}

/// Common project-pipeline sources accepted by the server-side list filter.
/// Unselected sources retain GitLab's default top-level pipeline listing.
enum PipelineSourceFilter {
  push('push'),
  web('web'),
  api('api'),
  schedule('schedule'),
  trigger('trigger'),
  pipeline('pipeline'),
  mergeRequestEvent('merge_request_event'),
  parentPipeline('parent_pipeline');

  const PipelineSourceFilter(this.apiValue);
  final String apiValue;
}

/// Common stable job statuses accepted by the pipeline jobs scope parameter.
/// Leaving the filter unset preserves every server-returned status.
enum PipelineJobStatusFilter {
  created,
  pending,
  running,
  success,
  failed,
  canceled,
  skipped,
  manual,
}

/// Pipeline and job endpoints.
class PipelinesApi {
  const PipelinesApi(this._dio);

  final Dio _dio;

  /// Lists a project's pipelines, most recent first.
  Future<Paginated<Pipeline>> list(
    Object projectId, {
    int page = 1,
    int perPage = 20,
    PipelineStatusFilter? status,
    String? ref,
    PipelineSourceFilter? source,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/pipelines',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'order_by': 'id',
          'sort': 'desc',
          if (status != null) 'status': status.name,
          'ref': ?ref,
          'source': ?source?.apiValue,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing pipelines',
        );
      }
      final pipelines = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Pipeline.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(pipelines, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing pipelines');
    }
  }

  /// Lists trigger jobs, using the pre-19.2 route only after a modern-route 404.
  Future<Paginated<PipelineTriggerJob>> triggerJobs(
    Object projectId, {
    required int pipelineId,
    int page = 1,
    int perPage = 20,
  }) async {
    final path = '/projects/${_enc(projectId)}/pipelines/$pipelineId';
    final query = {'page': page, 'per_page': perPage};
    try {
      Response<dynamic> response;
      try {
        response = await _dio.get<dynamic>(
          '$path/trigger_jobs',
          queryParameters: query,
        );
      } on DioException catch (error) {
        if (error.response?.statusCode != 404) rethrow;
        response = await _dio.get<dynamic>(
          '$path/bridges',
          queryParameters: query,
        );
        return _triggerJobsPage(response);
      }
      if (response.statusCode == 404) {
        response = await _dio.get<dynamic>(
          '$path/bridges',
          queryParameters: query,
        );
      }
      return _triggerJobsPage(response);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing pipeline trigger jobs');
    }
  }

  Paginated<PipelineTriggerJob> _triggerJobsPage(Response<dynamic> response) {
    if (response.statusCode != 200) {
      throw mapStatus(
        response.statusCode,
        response.headers.map,
        context: 'listing pipeline trigger jobs',
      );
    }
    final jobs = (response.data as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PipelineTriggerJob.fromJson)
        .toList(growable: false);
    return Paginated.fromHeaders(jobs, response.headers.map);
  }

  /// A single pipeline by id.
  Future<Pipeline> get(Object projectId, {required int pipelineId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/pipelines/$pipelineId',
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading the pipeline',
        );
      }
      return Pipeline.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading the pipeline');
    }
  }

  /// One jobs page; the caller decides when to request the server cursor.
  Future<Paginated<Job>> jobsPage(
    Object projectId, {
    required int pipelineId,
    int page = 1,
    int perPage = 20,
    PipelineJobStatusFilter? status,
    bool includeRetried = false,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${_enc(projectId)}/pipelines/$pipelineId/jobs',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (status != null) 'scope': status.name,
          if (includeRetried) 'include_retried': true,
        },
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading jobs',
        );
      }
      final payload = response.data;
      if (payload is! List) {
        throw const GitLabServerException('Invalid jobs response.');
      }
      final jobs = <Job>[];
      try {
        for (final item in payload) {
          if (item is! Map<String, dynamic>) throw const FormatException();
          jobs.add(Job.fromJson(item));
        }
      } on FormatException {
        throw const GitLabServerException('Invalid jobs response.');
      } on TypeError {
        throw const GitLabServerException('Invalid jobs response.');
      }
      final cursor = response.headers.value('x-next-page');
      if (cursor != null && cursor.isNotEmpty) {
        final next = int.tryParse(cursor);
        if (next == null || next <= page) {
          throw const GitLabServerException('Invalid jobs pagination.');
        }
      }
      return Paginated.fromHeaders(
        List<Job>.unmodifiable(jobs),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'loading jobs');
    }
  }

  /// All jobs of a pipeline, in GitLab's order.
  ///
  /// Convenience helper for callers that need the complete set. Interactive
  /// browsing uses [jobsPage] to display results without waiting for every page.
  Future<List<Job>> jobs(
    Object projectId, {
    required int pipelineId,
    int perPage = 100,
    PipelineJobStatusFilter? status,
    bool includeRetried = false,
  }) async {
    final jobs = <Job>[];
    int? page = 1;
    while (page != null) {
      final next = await jobsPage(
        projectId,
        pipelineId: pipelineId,
        page: page,
        perPage: perPage,
        status: status,
        includeRetried: includeRetried,
      );
      jobs.addAll(next.items);
      page = next.nextPage;
    }
    return List<Job>.unmodifiable(jobs);
  }

  /// Retries a pipeline, returning the updated resource.
  Future<Pipeline> retry(Object projectId, {required int pipelineId}) =>
      _action(projectId, pipelineId: pipelineId, action: 'retry');

  /// Cancels a pipeline.
  Future<Pipeline> cancel(Object projectId, {required int pipelineId}) =>
      _action(projectId, pipelineId: pipelineId, action: 'cancel');

  Future<Pipeline> _action(
    Object projectId, {
    required int pipelineId,
    required String action,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${_enc(projectId)}/pipelines/$pipelineId/$action',
      );
      final status = response.statusCode ?? 0;
      if (status == 409 || status == 422) {
        throw GitLabConflictException(
          'This pipeline cannot be $action-ed in its current state.',
          statusCode: status,
        );
      }
      final data = response.data;
      if (status < 200 || status >= 300 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating the pipeline',
        );
      }
      return Pipeline.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating the pipeline');
    }
  }

  static String _enc(Object projectId) =>
      projectId is int ? '$projectId' : Uri.encodeComponent('$projectId');
}
