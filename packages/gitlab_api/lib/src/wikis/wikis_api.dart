import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../gitlab_client.dart';

/// Project wiki endpoints.
class WikisApi {
  const WikisApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/wikis';

  /// Deletes one page by its URL-encoded slug.
  Future<void> delete(Object projectId, String slug) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(slug)}',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting a wiki page',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting a wiki page');
    }
  }

  /// Lists page titles and slugs without downloading all page bodies.
  Future<List<WikiPage>> list(Object projectId) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {'with_content': false},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing wiki pages',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return data.map(WikiPage.fromJson).toList(growable: false);
    } on DioException catch (error) {
      throw mapError(error, context: 'listing wiki pages');
    }
  }

  /// Reads one page, preserving a nested slug as a single URL segment.
  Future<WikiPage> get(Object projectId, String slug) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/${Uri.encodeComponent(slug)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'reading a wiki page',
        );
      }
      return WikiPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'reading a wiki page');
    }
  }

  /// Creates a Markdown page and returns its server-generated slug.
  Future<WikiPage> create(
    Object projectId, {
    required String title,
    required String content,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _path(projectId),
        data: {'title': title, 'content': content, 'format': 'markdown'},
      );
      final data = response.data;
      if ((response.statusCode != 201 && response.statusCode != 200) ||
          data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a wiki page',
        );
      }
      return WikiPage.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a wiki page');
    }
  }

  /// Updates an existing page by its original, URL-encoded slug.
  Future<WikiPage> update(
    Object projectId, {
    required String slug,
    required String title,
    required String content,
    String? format,
  }) async {
    final payload = {'title': title, 'content': content};
    if (format != null) payload['format'] = format;
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '${_path(projectId)}/${Uri.encodeComponent(slug)}',
        data: payload,
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating a wiki page',
        );
      }
      return WikiPage.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating a wiki page');
    }
  }
}
