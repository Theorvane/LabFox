import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Project snippet endpoints.
class SnippetsApi {
  const SnippetsApi(this._dio);

  final Dio _dio;

  /// Moves one file in an existing project snippet without changing content.
  Future<Snippet> moveFile(
    Object projectId,
    int snippetId, {
    required String previousPath,
    required String filePath,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/snippets/$snippetId',
        data: {
          'files': [
            {
              'action': 'move',
              'previous_path': previousPath,
              'file_path': filePath,
            },
          ],
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'moving a project snippet file',
        );
      }
      return Snippet.fromJson(response.data!);
    } on DioException catch (error) {
      throw mapError(error, context: 'moving a project snippet file');
    }
  }

  /// Adds one file to an existing project snippet without replacing its files.
  Future<Snippet> addFile(
    Object projectId,
    int snippetId, {
    required String filePath,
    required String content,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/snippets/$snippetId',
        data: {
          'files': [
            {'action': 'create', 'file_path': filePath, 'content': content},
          ],
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'adding a project snippet file',
        );
      }
      return Snippet.fromJson(response.data!);
    } on DioException catch (error) {
      throw mapError(error, context: 'adding a project snippet file');
    }
  }

  /// Updates one existing project snippet file without changing metadata.
  Future<Snippet> updateFileContent(
    Object projectId,
    int snippetId, {
    required String filePath,
    required String content,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/snippets/$snippetId',
        data: {
          'files': [
            {'action': 'update', 'file_path': filePath, 'content': content},
          ],
        },
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'updating project snippet content',
        );
      }
      return Snippet.fromJson(response.data!);
    } on DioException catch (error) {
      throw mapError(error, context: 'updating project snippet content');
    }
  }

  /// Updates project snippet metadata without changing any files.
  Future<Snippet> updateMetadata(
    Object projectId,
    int snippetId, {
    required String title,
    required String description,
    String? visibility,
  }) async {
    try {
      final payload = <String, String>{
        'title': title,
        'description': description,
      };
      if (visibility != null) payload['visibility'] = visibility;
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/snippets/$snippetId',
        data: payload,
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

  /// Deletes one project snippet after the server confirms the request.
  Future<void> delete(Object projectId, int snippetId) async {
    try {
      final response = await _dio.delete<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/snippets/$snippetId',
      );
      if (response.statusCode != 204) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'deleting a project snippet',
        );
      }
    } on DioException catch (error) {
      throw mapError(error, context: 'deleting a project snippet');
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
