import 'package:dio/dio.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../common/paginated.dart';
import '../gitlab_client.dart';

/// Read-only project container registry endpoints.
class ContainerRegistryApi {
  const ContainerRegistryApi(this._dio);

  final Dio _dio;

  String _path(Object projectId) =>
      '/projects/${Uri.encodeComponent(projectId.toString())}/registry/repositories';

  /// Lists all repository protection rules. This endpoint is not paginated.
  Future<List<ContainerRepositoryProtectionRule>> listRepositoryProtectionRules(
    Object projectId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/projects/${Uri.encodeComponent(projectId.toString())}/registry/protection/repository/rules',
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing container repository protection rules',
        );
      }
      return (response.data as List<dynamic>)
          .map(
            (item) => ContainerRepositoryProtectionRule.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapError(
        error,
        context: 'listing container repository protection rules',
      );
    }
  }

  /// Lists image repositories in a project.
  Future<Paginated<RegistryRepository>> listRepositories(
    Object projectId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(projectId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing container repositories',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(RegistryRepository.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing container repositories');
    }
  }

  /// Lists a container repository's tags.
  Future<Paginated<RegistryTag>> listTags(
    Object projectId,
    int repositoryId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$repositoryId/tags',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      if (response.statusCode != 200) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'listing container tags',
        );
      }
      final data = (response.data as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      return Paginated.fromHeaders(
        data.map(RegistryTag.fromJson).toList(growable: false),
        response.headers.map,
      );
    } on DioException catch (error) {
      throw mapError(error, context: 'listing container tags');
    }
  }

  /// Retrieves digest and image metadata for one tag.
  Future<RegistryTag> getTag(
    Object projectId,
    int repositoryId,
    String tagName,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '${_path(projectId)}/$repositoryId/tags/${Uri.encodeComponent(tagName)}',
      );
      if (response.statusCode != 200 || response.data == null) {
        throw mapStatus(
          response.statusCode,
          response.headers.map,
          context: 'loading a container tag',
        );
      }
      return RegistryTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapError(error, context: 'loading a container tag');
    }
  }
}
