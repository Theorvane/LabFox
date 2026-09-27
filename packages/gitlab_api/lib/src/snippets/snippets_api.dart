import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project snippet endpoints.
class SnippetsApi {
  const SnippetsApi(this._dio);

  final Dio _dio;

  /// Updates project snippet metadata without changing any files.
  Future<Snippet> updateMetadata(
    Object projectId,
    int snippetId, {
    required String title,
    required String description,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/snippets/$snippetId',
        data: {'title': title, 'description': description},
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating project snippet metadata',
        );
      }
      return Snippet.fromJson(response.data!);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating project snippet metadata');
    }
  }

  /// Creates a single-file project snippet using the supported files array.
  Future<Snippet> create(
    Object projectId, {
    required String title,
    String? description,
    required String visibility,
    required String filePath,
    required String content,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/snippets',
        data: {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          'visibility': visibility,
          'files': [
            {'file_path': filePath, 'content': content},
          ],
        },
      );
      final data = response.data;
      if ((response.statusCode != 201 && response.statusCode != 200) ||
          data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'creating a project snippet',
        );
      }
      return Snippet.fromJson(data);
    } on DioException catch (error) {
      throw mapError(error, context: 'creating a project snippet');
    }
  }

  Future<Paginated<Snippet>> list(
    int projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/$projectId/snippets',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading project snippets',
        );
      }
      final items = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Snippet.fromJson)
          .toList(growable: false);
      return Paginated.fromHeaders(items, response.headers.map);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading project snippets');
    }
  }

  Future<Snippet> get(int projectId, int snippetId) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/$projectId/snippets/$snippetId',
      );
      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a project snippet',
        );
      }
      return Snippet.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a project snippet');
    }
  }

  /// Raw content of a single-file snippet.
  Future<String> raw(int projectId, int snippetId) async {
    try {
      final response = await _dio.get<String>(
        '/projects/$projectId/snippets/$snippetId/raw',
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading snippet content',
        );
      }
      return response.data ?? '';
    } on DioException catch (error) {
      throw mapError(error, context: 'loading snippet content');
    }
  }

  /// Raw content of one file in a multi-file snippet.
  Future<String> file(
    int projectId,
    int snippetId, {
    required String ref,
    required String path,
  }) async {
    try {
      final response = await _dio.get<String>(
        '/projects/$projectId/snippets/$snippetId/files/${Uri.encodeComponent(ref)}/${Uri.encodeComponent(path)}/raw',
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a snippet file',
        );
      }
      return response.data ?? '';
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a snippet file');
    }
  }
}
